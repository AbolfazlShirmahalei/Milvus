# Milvus
## Overview
In this project, we are going to learn how to use the Milvus database and utilize it.

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
