#!/usr/bin/env bash

run_node1() {
    cat << EOF > embedEtcd.yaml
listen-client-urls: http://0.0.0.0:2379
advertise-client-urls: http://0.0.0.0:2379
quota-backend-bytes: 4294967296
auto-compaction-mode: revision
auto-compaction-retention: '1000'
EOF

    cat << EOF > user.yaml
# Extra config to override default milvus.yaml
EOF

    sudo docker run -d \
        --name milvus-node1 \
        --security-opt seccomp:unconfined \
        -e ETCD_USE_EMBED=true \
        -e ETCD_DATA_DIR=/var/lib/milvus/etcd \
        -e ETCD_CONFIG_PATH=/milvus/configs/embedEtcd.yaml \
        -e COMMON_STORAGETYPE=local \
        -v $(pwd)/volumes/milvus:/var/lib/milvus \
        -v $(pwd)/embedEtcd.yaml:/milvus/configs/embedEtcd.yaml \
        -v $(pwd)/user.yaml:/milvus/configs/user.yaml \
        -p 19530:19530 \
        -p 9091:9091 \
        -p 2379:2379 \
        --health-cmd="curl -f http://localhost:9091/healthz" \
        --health-interval=30s \
        --health-start-period=90s \
        --health-timeout=20s \
        --health-retries=3 \
        milvusdb/milvus:v2.4.13-hotfix \
        milvus run standalone  1> /dev/null
}

run_node2() {
    cat << EOF > embedEtcd.yaml
listen-client-urls: http://0.0.0.0:2379
advertise-client-urls: http://0.0.0.0:2379
quota-backend-bytes: 4294967296
auto-compaction-mode: revision
auto-compaction-retention: '1000'
EOF

    cat << EOF > user.yaml
# Extra config to override default milvus.yaml
EOF

    sudo docker run -d \
        --name milvus-node2 \
        --security-opt seccomp:unconfined \
        -e ETCD_USE_EMBED=true \
        -e ETCD_DATA_DIR=/var/lib/milvus/etcd \
        -e ETCD_CONFIG_PATH=/milvus/configs/embedEtcd.yaml \
        -e COMMON_STORAGETYPE=local \
        -v $(pwd)/volumes/milvus:/var/lib/milvus \
        -v $(pwd)/embedEtcd.yaml:/milvus/configs/embedEtcd.yaml \
        -v $(pwd)/user.yaml:/milvus/configs/user.yaml \
        -p 19531:19530 \
        -p 9092:9091 \
        -p 2380:2379 \
        --health-cmd="curl -f http://localhost:9091/healthz" \
        --health-interval=30s \
        --health-start-period=90s \
        --health-timeout=20s \
        --health-retries=3 \
        milvusdb/milvus:v2.4.13-hotfix \
        milvus run standalone  1> /dev/null
}

wait_for_milvus_running() {
    echo "Wait for Milvus Cluster Starting..."
    while true
    do
        res1=`sudo docker ps|grep milvus-node2|grep healthy|wc -l`
        res2=`sudo docker ps|grep milvus-node2|grep healthy|wc -l`
        if [ $res1 -eq 1 ] && [ $res2 -eq 1 ]
        then
            echo "Start successfully."
            echo "To change the default Milvus configuration, add your settings to the user.yaml file and then restart the service."
            break
        fi
        sleep 1
    done
}

start() {
    res1=`sudo docker ps|grep milvus-node1|grep healthy|wc -l`
    res2=`sudo docker ps|grep milvus-node2|grep healthy|wc -l`
    if [ $res1 -eq 1 ] && [ $res2 -eq 1 ]
    then
        echo "Milvus Cluster is running."
        exit 0
    fi

    res3=`sudo docker ps -a|grep milvus-node1|wc -l`
    res4=`sudo docker ps -a|grep milvus-node2|wc -l`

    if [ $res1 -eq 0 ]
    then
        if [ $res3 -eq 1 ]
        then
            sudo docker start milvus-node1 1> /dev/null
        else
            run_node1
        fi
    fi

    if [ $res2 -eq 0 ]
    then
        if [ $res4 -eq 1 ]
        then
            sudo docker start milvus-node2 1> /dev/null
        else
            run_node2
        fi
    fi

    if [ $? -ne 0 ]
    then
        echo "Start failed."
        exit 1
    fi

    wait_for_milvus_running
}

stop() {
    sudo docker stop milvus-node1 1> /dev/null
    sudo docker stop milvus-node2 1> /dev/null

    if [ $? -ne 0 ]
    then
        echo "Stop failed."
        exit 1
    fi
    echo "Stop successfully."
}

delete_container() {
    res1=`sudo docker ps|grep milvus-node1|wc -l`
    res2=`sudo docker ps|grep milvus-node2|wc -l`

    if [ $res1 -eq 1 ] | [ $res2 -eq 1 ]
    then
        echo "Please stop Milvus service before delete."
        exit 1
    fi
    sudo docker rm milvus-node1 1> /dev/null
    sudo docker rm milvus-node2 1> /dev/null
    if [ $? -ne 0 ]
    then
        echo "Delete milvus container failed."
        exit 1
    fi
    echo "Delete milvus container successfully."
}

delete() {
    delete_container
    sudo rm -rf $(pwd)/volumes
    sudo rm -rf $(pwd)/embedEtcd.yaml
    sudo rm -rf $(pwd)/user.yaml
    echo "Delete successfully."
}

case $1 in
    restart)
        stop
        start
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    delete)
        delete
        ;;
    *)
        echo "please use bash standalone_embed.sh restart|start|stop|upgrade|delete"
        ;;
esac
