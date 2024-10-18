# Milvus
## Overview
In this project, we are going to learn how to use the `Milvus` database and utilize it.

## Build up

### Dependency Management with Poetry
We are using Python 3.9.13, and We used pyenv to install the required version of Python (You can use [this link](https://github.com/pyenv/pyenv) to install pyenv.).

To manage this project's dependencies and packaging, we use Poetry.
If you don't have Poetry installed, you can follow these steps to install Poetry version 1.8.2:
1. **Installing Poetry (1.8.2)**

   You can use `pip` to install Poetry with the specified version:
   
   ```bash
    pip install poetry==1.8.2
   ```

   This will install Poetry version 1.8.2 globally on your system.

2. **Verify the Installation**

   To confirm that Poetry 1.8.2 is installed correctly, run the following command:

   ```bash
   poetry --version
   ```

   You should see the version information, which should be `1.8.2`.

### Install Dependencies
1. **Activate Poetry Env**
    
    You can activate your poetry env with the following command:
    ```bash
    poetry shell
   ```
2. **Install Dependencies**

    ```bash
    poetry install
   ```

## Run test.ipynb
To run this file, you need to be a member of the docker and sudo groups. 
First, activate your environment, and then open this notebook using JupyterLab. 
By running the cells in this notebook, you will:
1. Create the database
2. Add data to it
3. Perform a few searches
4. Finally, delete the database

## Questions
1. ***Witch one is better? `Chroma` or `Milvus`?***

    choosing between `Milvus` and `Chroma` largely depends on the specific needs of the project. 
`Milvus` stands out for its scaling capabilities and performance for large datasets, while `Chroma` is simpler to use and well-suited for AI-specific applications.

   However, given that we need the database we choose to perform well at a large scale of data, `Milvus` is the better choice.


2. ***How to install `Milvous`?***

   The installation of `Milvus` is done using Docker. 
In this project, we set up the database following the steps mentioned on the `Milvus` website. 
To set up the database, we need to follow the steps below:
   1. **Download the Installation Script**
      
      `Milvus` provides an installation script to install it as a docker container.
   You can download the installation script by following command:
      ```bash
       curl -sfL https://raw.githubusercontent.com/milvus-io/milvus/master/scripts/standalone_embed.sh -o standalone_embed.sh
      ```
      This file has been downloaded previously and you can view it at the address `applications/milvus_runner.sh` in the repo.
   2. **Start, Stop and Delete the database**
      You can run the database container with the following command:
       ```bash
       bash milvus_runner.sh start
      ```
      And you can stop and delete the container with the following commands:
      ```bash
       bash milvus_runner.sh stop
       bash milvus_runner.sh delete
      ```
         
   To see how to activate and use this database, you can check the wrapper written in the file `applications/milvues_data_base_provider.py`.
