import os
import sys
from pathlib import Path
from typing import Optional, Dict, List, Type

import docker
from docker.errors import NotFound
from pymilvus import MilvusClient

sys.path.append(os.path.expanduser("~/Milvus/."))
from applications.config import (
    DATA_BASE_CONTAINER_NAME,
    DATA_BASE_PORT,
    DATA_BASE_DEFAULT_PATH,
    DATA_BASE_RUNNER_PATH,
)


class MilvusDataBase:
    def __init__(
        self,
        data_base_path: Optional[str] = None,
        data_base_runner_path: Optional[str] = None,
        data_base_container_name: str = DATA_BASE_CONTAINER_NAME,
        password: Optional[str] = None,
        data_base_port: int = DATA_BASE_PORT,
    ):
        if data_base_path is None:
            data_base_path = DATA_BASE_DEFAULT_PATH
        Path(data_base_path).mkdir(parents=True, exist_ok=True)
        os.chdir(data_base_path)

        if data_base_runner_path is None:
            data_base_runner_path = DATA_BASE_RUNNER_PATH
        self._data_base_runner_path = data_base_runner_path

        self._data_base_container_name = data_base_container_name

        if password is None:
            password = input("sudo password:")
        self._password = password

        self.start()

        self._milvus_client = MilvusClient(url=f"http://localhost:{data_base_port}")

    @property
    def _is_container_running(self) -> bool:
        client = docker.from_env()
        try:
            container = client.containers.get(self._data_base_container_name)
            return container.status == "running"
        except NotFound:
            return False

    def start(self, password: Optional[str] = None):
        if not self._is_container_running:
            os.system(f"echo {self._password} | sudo -S bash {self._data_base_runner_path} start")

    def stop(self):
        if self._is_container_running:
            os.system(f"echo {self._password} | sudo -S bash {self._data_base_runner_path} stop")

    def delete(self):
        self.stop()
        os.system(f"echo {self._password} | sudo -S bash {self._data_base_runner_path} delete")

    def create_collection(
        self,
        collection_name: str,
        dimension: int,
    ):
        self._milvus_client.create_collection(
            collection_name=collection_name,
            dimension=dimension,
            consistency_level="Strong",
        )

    def insert(
        self,
        collection_name: str,
        data: List[Dict[str, Type]],
    ):
        self._milvus_client.insert(
            collection_name=collection_name,
            data=data,
        )

    def search(
        self,
        collection_name: str,
        query_vec: List[List[float]],
        limit: int,
        output_fields: list[str],
    ) -> List[List[Dict[str, Type]]]:
        return self._milvus_client.search(
            collection_name=collection_name,
            data=query_vec,
            limit=limit,
            output_fields=output_fields,
        )
