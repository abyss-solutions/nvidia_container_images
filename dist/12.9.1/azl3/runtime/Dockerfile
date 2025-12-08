ARG IMAGE_NAME
FROM ${IMAGE_NAME}:12.9.1-base-azl3 AS base

ENV PKG_CMD=tdnf

ENV NV_CUDA_LIB_VERSION=12.9.1-1

FROM base AS base-amd64

ENV NV_NVTX_VERSION=12.9.79-1
ENV NV_LIBNPP_VERSION=12.4.1.87-1
ENV NV_LIBNPP_PACKAGE=libnpp-12-9-${NV_LIBNPP_VERSION}
ENV NV_LIBCUBLAS_VERSION=12.9.1.4-1
FROM base AS base-arm64

ENV NV_NVTX_VERSION=12.9.79-1
ENV NV_LIBNPP_VERSION=12.4.1.87-1
ENV NV_LIBNPP_PACKAGE=libnpp-12-9-${NV_LIBNPP_VERSION}
ENV NV_LIBCUBLAS_VERSION=12.9.1.4-1
FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer="NVIDIA CORPORATION <sw-cuda-installer@nvidia.com>"

RUN ${PKG_CMD} install -y \
    cuda-libraries-12-9-${NV_CUDA_LIB_VERSION} \
    cuda-nvtx-12-9-${NV_NVTX_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    libcublas-12-9-${NV_LIBCUBLAS_VERSION} \
    && ${PKG_CMD} clean all \
    && rm -rf /var/cache/yum/*

# Add entrypoint items
COPY entrypoint.d/ /opt/nvidia/entrypoint.d/
COPY nvidia_entrypoint.sh /opt/nvidia/
ENV NVIDIA_PRODUCT_NAME="CUDA"
ENTRYPOINT ["/opt/nvidia/nvidia_entrypoint.sh"]