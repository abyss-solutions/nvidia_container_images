## NVIDIA CUDA

[CUDA](https://developer.nvidia.com/cuda-zone) is a parallel computing platform and programming model developed by NVIDIA for general computing on graphical processing units (GPUs). With CUDA, developers can dramatically speed up computing applications by harnessing the power of GPUs.

The CUDA Toolkit from NVIDIA provides everything you need to develop GPU-accelerated applications. The CUDA Toolkit includes GPU-accelerated libraries, a compiler, development tools and the CUDA runtime.

The CUDA container images provide an easy-to-use distribution for CUDA supported platforms and architectures.

## End User License Agreements

The images are governed by the following NVIDIA End User License Agreements. By pulling and using the CUDA images, you accept the terms and conditions of these licenses.
Since the images may include components licensed under open-source licenses such as GPL, the sources for these components are archived [here](https://developer.download.nvidia.com/compute/cuda/opensource/image).

### NVIDIA Deep learning Container License

To view the NVIDIA Deep Learning Container license, click [here](https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license)

## Documentation

For more information on CUDA, including the release notes, programming model, APIs and developer tools, visit the [CUDA documentation site](https://docs.nvidia.com/cuda).

## Announcement

### CUDA Container Support Policy

CUDA image container tags have a lifetime. The tags will be deleted Six Months after the last supported "Tesla Recommended Driver" has gone end-of-life OR a newer update release has been made for the same CUDA version.

Please see [CUDA Container Support Policy](https://gitlab.com/nvidia/container-images/cuda/-/blob/master/doc/support-policy.md) for more information.

Breaking changes are announced on [Gitlab Issue #209](https://gitlab.com/nvidia/container-images/cuda/-/issues/209).

### Cuda Repo Signing Key has Changed!

This may present itself as the following errors.

debian:

```
Reading package lists... Done
W: GPG error: http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64  InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY A4B469963BF863CC
W: The repository 'http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64  InRelease' is not signed.
N: Data from such a repository can't be authenticated and is therefore potentially dangerous to use.
N: See apt-secure(8) manpage for repository creation and user configuration details.
```

RPM:

```
warning: /var/cache/dnf/cuda-fedora32-x86_64-d60aafcddb176bf5/packages/libnvjpeg-11-1-11.3.0.105-1.x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID d42d0685: NOKEY
cuda-fedora32-x86_64                                                                                  23 kB/s | 1.6 kB     00:00
Importing GPG key 0x7FA2AF80:
 Userid     : "cudatools <cudatools@nvidia.com>"
 Fingerprint: AE09 FE4B BD22 3A84 B2CC FCE3 F60F 4B3D 7FA2 AF80
 From       : https://developer.download.nvidia.com/compute/cuda/repos/fedora32/x86_64/7fa2af80.pub
Is this ok [y/N]: y
Key imported successfully
Import of key(s) didn't help, wrong key(s)?
Public key for libnvjpeg-11-1-11.3.0.105-1.x86_64.rpm is not installed. Failing package is: libnvjpeg-11-1-11.3.0.105-1.x86_64
 GPG Keys are configured as: https://developer.download.nvidia.com/compute/cuda/repos/fedora32/x86_64/7fa2af80.pub
The downloaded packages were saved in cache until the next successful transaction.
You can remove cached packages by executing 'dnf clean packages'.
Error: GPG check FAILED
```

Updated images will be pushed out over the next few days containing the new repo key. Please follow progress using the links below:

* https://forums.developer.nvidia.com/t/notice-cuda-linux-repository-key-rotation/212771h
* https://gitlab.com/nvidia/container-images/cuda/-/issues/158

### Multi-arch image manifests are now LIVE for all supported CUDA container image versions

It is now possible to build CUDA container images for all supported architectures using Docker
Buildkit in one step. See the example script below.

The deprecated image names `nvidia/cuda-arm64` and `nvidia/cuda-ppc64le` will remain available, but no longer supported.

The following product pages still exist but will no longer be supported:

* https://hub.docker.com/r/nvidia/cuda-ppc64le
* https://hub.docker.com/r/nvidia/cuda-arm64

The following gitlab repositories will be archived:

* https://gitlab.com/nvidia/container-images/cuda-ppc64le

### Deprecated: "latest" tag

The "latest" tag for CUDA, CUDAGL, and OPENGL images has been deprecated on NGC and Docker Hub.

With the removal of the latest tag, the following use case will result in the "manifest unknown" error:

```
$ docker pull nvidia/cuda
Error response from daemon: manifest for nvidia/cuda:latest not found: manifest unknown: manifest
unknown
```

This is not a bug.

## Overview of Images

Three flavors of images are provided:
- `base`: Includes the CUDA runtime (cudart)
- `runtime`: Builds on the `base` and includes the [CUDA math libraries](https://developer.nvidia.com/gpu-accelerated-libraries), and [NCCL](https://developer.nvidia.com/nccl). A `runtime` image that also includes [cuDNN](https://developer.nvidia.com/cudnn) is available. Some images may also include [TensorRT](https://developer.nvidia.com/tensorrt).
- `devel`: Builds on the `runtime` and includes headers, development tools for building CUDA images. These images are particularly useful for multi-stage builds.

The Dockerfiles for the images are open-source and licensed under 3-clause BSD. For more information see the Supported Tags section below.

### NVIDIA Container Toolkit

The [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit) for Docker is required to run CUDA images.

For CUDA 10.0, `nvidia-docker2` (v2.1.0) or greater is recommended. It is also recommended to use Docker 19.03.

### How to report a problem

Read [NVIDIA Container Toolkit Frequently Asked Questions](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions) to see if the problem has been encountered before.

After it has been determined the problem is not with the NVIDIA runtime, report an issue at the [CUDA Container Image Issue Tracker](https://gitlab.com/nvidia/container-images/cuda/-/issues).

## Supported tags

Supported tags are updated to the latest CUDA, cuDNN, and TensorRT versions. These tags are also periodically updated to fix CVE vulnerabilities.

For a full list of supported tags, click [*here*](https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md).

## LATEST CUDA 13.0.2

Visit [OpenSource @ Nvidia](https://developer.download.nvidia.com/compute/cuda/opensource/image/) for the GPL sources of the packages contained in the CUDA base image layers.

Due to specific set of vulnerabilities present in rockylinux10/ubi10 images without official patch available at this time, cuda images are not released for these operating systems. We are currently working on mitigation options and images will be released soon.

### ubuntu24.04 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-ubuntu24.04` (*13.0.2/ubuntu2404/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2404/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-ubuntu24.04` (*13.0.2/ubuntu2404/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2404/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-ubuntu24.04` (*13.0.2/ubuntu2404/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2404/devel/cudnn/Dockerfile)
- [`13.0.2-devel-ubuntu24.04` (*13.0.2/ubuntu2404/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2404/devel/Dockerfile)
- [`13.0.2-base-ubuntu24.04` (*13.0.2/ubuntu2404/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2404/base/Dockerfile)

### ubuntu22.04 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-ubuntu22.04` (*13.0.2/ubuntu2204/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2204/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-ubuntu22.04` (*13.0.2/ubuntu2204/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2204/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-ubuntu22.04` (*13.0.2/ubuntu2204/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2204/devel/cudnn/Dockerfile)
- [`13.0.2-devel-ubuntu22.04` (*13.0.2/ubuntu2204/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2204/devel/Dockerfile)
- [`13.0.2-base-ubuntu22.04` (*13.0.2/ubuntu2204/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubuntu2204/base/Dockerfile)

### ubi9 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-ubi9` (*13.0.2/ubi9/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi9/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-ubi9` (*13.0.2/ubi9/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi9/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-ubi9` (*13.0.2/ubi9/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi9/devel/cudnn/Dockerfile)
- [`13.0.2-devel-ubi9` (*13.0.2/ubi9/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi9/devel/Dockerfile)
- [`13.0.2-base-ubi9` (*13.0.2/ubi9/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi9/base/Dockerfile)

### ubi8 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-ubi8` (*13.0.2/ubi8/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi8/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-ubi8` (*13.0.2/ubi8/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi8/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-ubi8` (*13.0.2/ubi8/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi8/devel/cudnn/Dockerfile)
- [`13.0.2-devel-ubi8` (*13.0.2/ubi8/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi8/devel/Dockerfile)
- [`13.0.2-base-ubi8` (*13.0.2/ubi8/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/ubi8/base/Dockerfile)

### rockylinux9 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-rockylinux9` (*13.0.2/rockylinux9/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux9/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-rockylinux9` (*13.0.2/rockylinux9/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux9/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-rockylinux9` (*13.0.2/rockylinux9/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux9/devel/cudnn/Dockerfile)
- [`13.0.2-devel-rockylinux9` (*13.0.2/rockylinux9/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux9/devel/Dockerfile)
- [`13.0.2-base-rockylinux9` (*13.0.2/rockylinux9/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux9/base/Dockerfile)

### rockylinux8 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-rockylinux8` (*13.0.2/rockylinux8/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux8/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-rockylinux8` (*13.0.2/rockylinux8/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux8/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-rockylinux8` (*13.0.2/rockylinux8/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux8/devel/cudnn/Dockerfile)
- [`13.0.2-devel-rockylinux8` (*13.0.2/rockylinux8/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux8/devel/Dockerfile)
- [`13.0.2-base-rockylinux8` (*13.0.2/rockylinux8/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/rockylinux8/base/Dockerfile)

### oraclelinux9 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-oraclelinux9` (*13.0.2/oraclelinux9/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux9/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-oraclelinux9` (*13.0.2/oraclelinux9/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux9/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-oraclelinux9` (*13.0.2/oraclelinux9/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux9/devel/cudnn/Dockerfile)
- [`13.0.2-devel-oraclelinux9` (*13.0.2/oraclelinux9/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux9/devel/Dockerfile)
- [`13.0.2-base-oraclelinux9` (*13.0.2/oraclelinux9/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux9/base/Dockerfile)

### oraclelinux8 [arm64, x86_64]

- [`13.0.2-cudnn-runtime-oraclelinux8` (*13.0.2/oraclelinux8/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux8/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-oraclelinux8` (*13.0.2/oraclelinux8/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux8/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-oraclelinux8` (*13.0.2/oraclelinux8/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux8/devel/cudnn/Dockerfile)
- [`13.0.2-devel-oraclelinux8` (*13.0.2/oraclelinux8/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux8/devel/Dockerfile)
- [`13.0.2-base-oraclelinux8` (*13.0.2/oraclelinux8/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/oraclelinux8/base/Dockerfile)

### opensuse15 [x86_64]

- [`13.0.2-cudnn-runtime-opensuse15` (*13.0.2/opensuse15/runtime/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/opensuse15/runtime/cudnn/Dockerfile)
- [`13.0.2-runtime-opensuse15` (*13.0.2/opensuse15/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/opensuse15/runtime/Dockerfile)
- [`13.0.2-cudnn-devel-opensuse15` (*13.0.2/opensuse15/devel/cudnn/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/opensuse15/devel/cudnn/Dockerfile)
- [`13.0.2-devel-opensuse15` (*13.0.2/opensuse15/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/opensuse15/devel/Dockerfile)
- [`13.0.2-base-opensuse15` (*13.0.2/opensuse15/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/opensuse15/base/Dockerfile)

### azl3 [arm64, x86_64]

- [`13.0.2-runtime-azl3` (*13.0.2/azl3/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/azl3/runtime/Dockerfile)
- [`13.0.2-devel-azl3` (*13.0.2/azl3/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/azl3/devel/Dockerfile)
- [`13.0.2-base-azl3` (*13.0.2/azl3/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/azl3/base/Dockerfile)

### amzn2023 [arm64, x86_64]

- [`13.0.2-runtime-amzn2023` (*13.0.2/amzn2023/runtime/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/amzn2023/runtime/Dockerfile)
- [`13.0.2-devel-amzn2023` (*13.0.2/amzn2023/devel/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/amzn2023/devel/Dockerfile)
- [`13.0.2-base-amzn2023` (*13.0.2/amzn2023/base/Dockerfile*)](https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/13.0.2/amzn2023/base/Dockerfile)

### Unsupported tags

A list of tags that are no longer supported can be found [*here*](https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/unsupported-tags.md)

### Source of this description

This [Readme](https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/README.md) is located in the `doc` directory of the CUDA Container Image source repository. ([history](https://gitlab.com/nvidia/container-images/cuda/commits/master/doc/README.md))