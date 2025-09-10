ARG IMAGE_NAME
FROM ${IMAGE_NAME}:13.0.1-runtime-opensuse15 AS base

ENV PKG_CMD=zypper

FROM base AS base-amd64

ENV NV_CUDNN_VERSION=9.13.0.50-1
ENV NV_CUDNN_PACKAGE=libcudnn9-cuda-13-${NV_CUDNN_VERSION}


FROM base-${TARGETARCH}

ARG TARGETARCH

LABEL maintainer="NVIDIA CORPORATION <sw-cuda-installer@nvidia.com>"

LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"


RUN ${PKG_CMD} --non-interactive --gpg-auto-import-keys install \
    ${NV_CUDNN_PACKAGE} \
    && ${PKG_CMD} clean -a \
    && rm -rf /var/cache/zypp/*