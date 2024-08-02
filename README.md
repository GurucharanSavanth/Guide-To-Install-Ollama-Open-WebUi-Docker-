# Guide-To-Install-Ollama-Open-WebUi-Docker-

Install Ollama with Open-WebUi with docker and expose and host the local AI model to internet ( free ) 

# Ollama and Docker Setup Guide

This repository provides a step-by-step guide for installing Ollama, setting up Docker with NVIDIA support, and configuring TensorFlow with GPU support. Additionally, it includes instructions for using Watchtower to automate container up>

## Table of Contents

- [Installation Requirements](#installation-requirements)
- [Install Ollama](#install-ollama)
- [Install Docker and NVIDIA Container Toolkit](#install-docker-and-nvidia-container-toolkit)
- [Install TensorFlow GPU Jupyter Version](#install-tensorflow-gpu-jupyter-version)
- [Build Docker Image with CUDA and cuDNN](#build-docker-image-with-cuda-and-cudnn)
- [Run Docker Container with NVIDIA GPUs](#run-docker-container-with-nvidia-gpus)
- [Automatic Container Updates with Watchtower](#automatic-container-updates-with-watchtower)
- [If you intend to make the Open-WebUi public](#Generating-a-public-link-to-access-ollama-via-internet)
## Installation-Requirements

- Arch Linux (or a compatible distribution)
- NVIDIA GPU with supported drivers
- Docker installed on your system
- `yay` package manager (for installing AUR packages)

## Install Ollama

To install Ollama on Linux, run:

```sh
curl -fsSL https://ollama.com/install.sh | sh
```

## Install Docker and NVIDIA Container Toolkit

1. **Install Required Packages**:

   ```sh
   yay -S nvidia-docker-compose docker nvidia-container-toolkit
   ```

2. **Start and Enable Docker**:

   ```sh
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Configure Docker for NVIDIA**:

   Create and edit the Docker daemon configuration:

   ```sh
   sudo mkdir -p /etc/docker
   sudo nano /etc/docker/daemon.json
   ```

   Add the following JSON configuration:

   ```json
   {
       "default-runtime": "nvidia",
       "runtimes": {
         "nvidia": {
           "path": "nvidia-container-runtime",
           "runtimeArgs": []
         }
       }
   }
   ```

4. **Add User to Docker Group**:

   ```sh
   sudo groupadd docker
   sudo usermod -aG docker <Your_System_Name>/
   newgrp docker
   ```

   Replace `<Your_System_Name>` with your actual username. to findout use `whoami` on terminal

## Install TensorFlow GPU Jupyter Version

To run TensorFlow with GPU support in a Jupyter notebook:

```sh
docker run -d --restart unless-stopped --runtime=nvidia   -v $(realpath ~/notebooks):/tf/notebooks -p 8888:8888   tensorflow/tensorflow:nightly-gpu-jupyter
```

## Build Docker Image with CUDA and cuDNN

Create a Dockerfile with the following content:

```dockerfile
FROM ${IMAGE_NAME} as base

FROM base as base-amd64

ENV NV_CUDNN_VERSION=9.2.1.18-1
ENV NV_CUDNN_PACKAGE_NAME=libcudnn9-cuda-12
ENV NV_CUDNN_PACKAGE=${NV_CUDNN_PACKAGE_NAME}=${NV_CUDNN_VERSION}

# Define the architecture explicitly
ARG TARGETARCH=amd64

LABEL maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>"
LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends     ${NV_CUDNN_PACKAGE}     && apt-mark hold ${NV_CUDNN_PACKAGE_NAME}     && rm -rf /var/lib/apt/lists/*
```

### Build the Docker Image

```sh
docker build -t my-cuda-image .
```

## Run Docker Container with NVIDIA GPUs

```sh
docker run --gpus all -it --rm   -e NVIDIA_VISIBLE_DEVICES=all   -e NVIDIA_DRIVER_CAPABILITIES=compute,utility   -e TF_FORCE_GPU_ALLOW_GROWTH=true   my-cuda-image
```

## Automatic Container Updates with Watchtower

To enable automatic updates for your Docker containers, use Watchtower:

```sh
docker run -d   --name open-webui   --gpus all   --cpus="all"   --restart always   --ulimit memlock=-1:-1   --ulimit stack=67108864:67108864   --shm-size=1g   --memory-swap=-1   -v ollama:/root/.ollama   -v open-webui:/app/backend/data   -p 3000:8080   --label=com.centurylinklabs.watchtower.enable=true   ghcr.io/open-webui/open-webui:ollama
```

### Setting Up Watchtower

Run Watchtower in a separate container to monitor and update your containers:

```sh
docker run -d   --name watchtower   --restart always   -v /var/run/docker.sock:/var/run/docker.sock   containrrr/watchtower   --cleanup   --label-enable
```

### Explanation

- **Watchtower Container Options**:
  - `-v /var/run/docker.sock:/var/run/docker.sock`: Grants Watchtower access to the Docker daemon.
  - `--cleanup`: Removes old images after updates, freeing up disk space.
  - `--label-enable`: Only monitors containers with the label `watchtower.enable=true`.

This setup ensures that your `open-webui` container is automatically updated when a new version of the image is released, with minimal downtime.

### Inorder to access the Jupyter notebook 
You can type  `127.0.0.1:8888/tree?` and if it ask for the tokens use ` docker log < container id > ` and copy and past the token 

### Inorder to access the ollama openweb-webui
You can type `127.0.0.1:3000` or `localhost:3000/`


### If you intend to make the Open-WebUi public

1. Install ngrok : `yay -S ngrok`
2. Now open the Ngrok websight : `https://dashboard.ngrok.com/get-started/setup/linux`
3. sign in and copy past ngrok config add-authtoken  command
4. open the yml file  `` nano /home/<Your_System_Name>/.config/ngrok/ngrok.yml``
5. past this below the auth token  
```yml
tunnels:
  webui:
    addr: 3000 # the address you assigned
    proto: http
    metadata: "Web UI Tunnel for Ollama"
```
6.Inorder to use the public web internet via url run this command
``sh
ngrok start --all 
`` 

##Done Enjoy 
