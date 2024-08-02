ARG IMAGE_NAME=nvidia/cuda:12.2.0-runtime-ubuntu22.04
FROM ${IMAGE_NAME} as base

FROM base as base-amd64

ENV NV_CUDNN_VERSION=9.2.1.18-1
ENV NV_CUDNN_PACKAGE_NAME=libcudnn9-cuda-12
ENV NV_CUDNN_PACKAGE=${NV_CUDNN_PACKAGE_NAME}=${NV_CUDNN_VERSION}

# Define the architecture explicitly
ARG TARGETARCH=amd64

LABEL maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>"
LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*

