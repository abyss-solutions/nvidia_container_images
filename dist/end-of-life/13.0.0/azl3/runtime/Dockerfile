ARG IMAGE_NAME
FROM ${IMAGE_NAME}:13.0.0-base-azl3 AS base

ENV PKG_CMD=tdnf

ENV NV_CUDA_LIB_VERSION=13.0.0-1

FROM base AS base-amd64

ENV NV_NVTX_VERSION=13.0.39-1
ENV NV_LIBNPP_VERSION=13.0.0.50-1
ENV NV_LIBNPP_PACKAGE=libnpp-13-0-${NV_LIBNPP_VERSION}
ENV NV_LIBCUBLAS_VERSION=13.0.0.19-1
FROM base AS base-arm64

ENV NV_NVTX_VERSION=13.0.39-1
ENV NV_LIBNPP_VERSION=13.0.0.50-1
ENV NV_LIBNPP_PACKAGE=libnpp-13-0-${NV_LIBNPP_VERSION}
ENV NV_LIBCUBLAS_VERSION=13.0.0.19-1
FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer="NVIDIA CORPORATION <sw-cuda-installer@nvidia.com>"

RUN ${PKG_CMD} install -y \
    cuda-libraries-13-0-${NV_CUDA_LIB_VERSION} \
    cuda-nvtx-13-0-${NV_NVTX_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    libcublas-13-0-${NV_LIBCUBLAS_VERSION} \
    && ${PKG_CMD} clean all \
    && rm -rf /var/cache/yum/*

# Add entrypoint items
COPY entrypoint.d/ /opt/nvidia/entrypoint.d/
COPY nvidia_entrypoint.sh /opt/nvidia/
ENV NVIDIA_PRODUCT_NAME="CUDA"
ENTRYPOINT ["/opt/nvidia/nvidia_entrypoint.sh"]