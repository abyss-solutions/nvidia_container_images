ARG IMAGE_NAME
FROM ${IMAGE_NAME}:13.1.0-base-ubuntu24.04 AS base

ENV NV_CUDA_LIB_VERSION=13.1.0-1

FROM base AS base-amd64

ENV NV_NVTX_VERSION=13.1.68-1
ENV NV_LIBNPP_VERSION=13.0.2.21-1
ENV NV_LIBNPP_PACKAGE=libnpp-13-1=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION=12.7.2.19-1

ENV NV_LIBCUBLAS_PACKAGE_NAME=libcublas-13-1
ENV NV_LIBCUBLAS_VERSION=13.2.0.9-1
ENV NV_LIBCUBLAS_PACKAGE=${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

FROM base AS base-arm64

ENV NV_NVTX_VERSION=13.1.68-1
ENV NV_LIBNPP_VERSION=13.0.2.21-1
ENV NV_LIBNPP_PACKAGE=libnpp-13-1=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION=12.7.2.19-1

ENV NV_LIBCUBLAS_PACKAGE_NAME=libcublas-13-1
ENV NV_LIBCUBLAS_VERSION=13.2.0.9-1
ENV NV_LIBCUBLAS_PACKAGE=${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-13-1=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-13-1=${NV_NVTX_VERSION} \
    libcusparse-13-1=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME}

# Add entrypoint items
COPY entrypoint.d/ /opt/nvidia/entrypoint.d/
COPY nvidia_entrypoint.sh /opt/nvidia/
ENV NVIDIA_PRODUCT_NAME="CUDA"
ENTRYPOINT ["/opt/nvidia/nvidia_entrypoint.sh"]