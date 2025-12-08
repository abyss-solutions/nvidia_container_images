ARG IMAGE_NAME
FROM ${IMAGE_NAME}:13.0.0-cudnn-devel-ubuntu24.04 AS base

FROM base AS base-arm64

ENV NV_TENSORRT_VERSION=10.13.2.6-1+cuda13.0
ENV NV_TENSORRT_PACKAGE_NAME=tensorrt-libs
ENV NV_TENSORRT_PACKAGE=tensorrt-libs=${NV_TENSORRT_VERSION}
ENV NV_TENSORRT_PACKAGE_DEV=tensorrt-dev=${NV_TENSORRT_VERSION}
FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>"
LABEL com.nvidia.tensorrt.version="${NV_TENSORRT_VERSION}"


RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_TENSORRT_PACKAGE} \
    ${NV_TENSORRT_PACKAGE_DEV} \
    && apt-mark hold ${NV_TENSORRT_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*
