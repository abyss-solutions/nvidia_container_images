#!/bin/bash

set -euo pipefail

# Installs CUDA packages directly on this Ubuntu host using the same package
# versions as the Docker images in this repository. OS and architecture are
# auto-detected; all other options mirror build.sh.

CUDA_VERSION=""
BASE_IMAGE_NAME="base"

args=("$@")
script_name=$(basename "$0")
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
run_cmd_return=0
debug_flag=0
dry_run=0
use_kitpick=0
install_devel=0
setup_docker=0

# Populated by detect_host()
NVARCH=""
DOCKER_ARCH=""
OS_PATH_NAME=""

err() {
    local mesg=$1; shift
    printf "ERROR: $(basename "${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]}")#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}\n\n" "$mesg" 1>&2
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}" 1>&2
        printf '\n\n'
    fi
    exit 1
}

msg() {
    local mesg=$1; shift
    printf ">>> $(basename "${BASH_SOURCE[1]}")#${BASH_LINENO[0]} %s\n\n" "$mesg"
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}"
        printf '\n\n'
    fi
}

debug() {
    if [[ ${debug_flag} -eq 1 ]]; then
        local mesg=$1; shift
        printf "%s\n\n" "### DEBUG: $(basename "${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]}")#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}" 1>&2
        if [[ $# -gt 0 ]]; then
            printf '%s ' "${@}" 1>&2
            printf '\n\n'
        fi
    fi
}

warning() {
    local mesg=$1; shift
    printf "WARNING: $(basename "${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]}")#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}\n\n" "$mesg" 1>&2
    if [[ $# -gt 0 ]]; then
        printf '%s ' "${@}" 1>&2
        printf '\n\n'
    fi
}

norun() {
    local mesg=$1; shift
    printf "XXXX NORUN: $(basename "${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]}")#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} ${mesg}\n\n" "$mesg"
    if [[ $# -gt 0 ]]; then
        printf '%s ' "$@"
        printf '\n\n'
    fi
}

run_cmd() {
    run_cmd_return=0
    if [[ ${dry_run} -eq 1 ]]; then
        SOURCE_LINE_OVERRIDE=2 BASH_LINE_OVERRIDE=1 norun "CMD:" "$@"
    else
        printf "%s\n\n" "$(basename "${BASH_SOURCE[${SOURCE_LINE_OVERRIDE:-1}]}")#${BASH_LINENO[${BASH_LINE_OVERRIDE:-0}]} Running command:"
        printf "%s " "${@}"
        printf "\n\n"
        printf "Output: \n\n"
        echo -e "$@" | source /dev/stdin
        run_cmd_return=$?
        echo
        printf "Command returned: %s\n\n" "${run_cmd_return}"
        return $run_cmd_return
    fi
}

if [[ ${#args[@]} -eq 0 ]]; then
    echo
    err "No arguments specified!"
fi

usage() {
    echo "${script_name} - CUDA Host Install Helper"
    echo
    echo "Installs CUDA packages directly on this Ubuntu machine, using the"
    echo "exact package versions defined in the Dockerfiles in this repo."
    echo "The OS version and architecture are auto-detected from the host."
    echo
    echo "Usage: ${script_name} [options]"
    echo
    echo "OPTIONS"
    echo
    echo "    -h, --help            - Show this message."
    echo "    -n, --dry-run         - Show commands but don't do anything."
    echo "    -d, --debug           - Show debug output."
    echo "    --cuda-version <str>  - The CUDA version to install."
    echo "    --kitpick             - Install from the kitpick directory."
    echo "    --devel               - Also install devel packages (default: base + runtime only)."
    echo "    --docker              - Install the NVIDIA Container Toolkit and configure Docker"
    echo "                           for GPU passthrough (can be used with or without --cuda-version)."
    echo
    exit 155
}

# Remove the legacy cuda.list if it conflicts with the modern cuda-keyring
# sources file. This can happen regardless of whether CUDA is being installed,
# and causes any apt-get update to fail with exit code 100.
fix_apt_conflicts() {
    local keyring_list="/etc/apt/sources.list.d/cuda-${OS_PATH_NAME}-${NVARCH}.list"
    local legacy_list="/etc/apt/sources.list.d/cuda.list"
    if [[ -f "${keyring_list}" && -f "${legacy_list}" ]]; then
        warning "Removing conflicting ${legacy_list} (superseded by ${keyring_list})"
        run_cmd "rm -f ${legacy_list}"
    fi
}

detect_host() {
    command -v lsb_release &>/dev/null || err "lsb_release not found — is this Ubuntu?"
    local os_name os_ver
    os_name=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    [[ "${os_name}" == "ubuntu" ]] || err "Only Ubuntu is supported. Detected OS: ${os_name}"
    os_ver=$(lsb_release -sr | tr -d '.')
    OS_PATH_NAME="${os_name}${os_ver}"
    msg "Detected host OS: ${os_name} $(lsb_release -sr)"

    local machine_arch
    machine_arch=$(uname -m)
    case "${machine_arch}" in
        x86_64)  NVARCH="x86_64"; DOCKER_ARCH="amd64" ;;
        aarch64) NVARCH="sbsa";   DOCKER_ARCH="arm64" ;;
        *)       err "Unsupported architecture: ${machine_arch}" ;;
    esac
    msg "Detected host arch: ${machine_arch} (NVARCH=${NVARCH})"
}

# Parse ENV vars from a Dockerfile into the global associative array _envs.
# Handles both legacy (ENV KEY value) and modern (ENV KEY=value) syntax.
# Respects arch-specific sections (FROM base AS base-amd64 / base-arm64) and
# collects global and common-section ENVs unconditionally.
parse_envs() {
    local dockerfile="$1"
    declare -gA _envs=()
    local section="global"

    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%"${line##*[![:space:]]}"}"  # rtrim

        # Detect arch-specific sections (case-insensitive AS)
        local lower_line="${line,,}"
        if [[ "${lower_line}" =~ ^from[[:space:]].*[[:space:]]as[[:space:]]base-([a-z0-9]+)$ ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi
        if [[ "${lower_line}" =~ ^from[[:space:]]base-\$\{targetarch\} ]]; then
            section="common"
            continue
        fi

        # Only collect ENVs from sections relevant to our target arch
        [[ "${section}" == "global" || "${section}" == "${DOCKER_ARCH}" || "${section}" == "common" ]] || continue

        # Match: ENV KEY value  or  ENV KEY=value  (with optional quotes on value)
        if [[ "${line}" =~ ^ENV[[:space:]]+([A-Z_][A-Z_0-9]*)([[:space:]]|=)(.+)$ ]]; then
            local k="${BASH_REMATCH[1]}"
            local v="${BASH_REMATCH[3]}"
            v="${v%\"}"
            v="${v#\"}"
            # Expand any ${VAR} references already known, matching Docker's own ENV expansion
            for existing_k in "${!_envs[@]}"; do
                v="${v//\$\{${existing_k}\}/${_envs[${existing_k}]}}"
            done
            _envs["${k}"]="${v}"
            debug "ENV [${section}] ${k}=${v}"
        fi
    done < "${dockerfile}"
}

# Expand ${VAR} references in a string using _envs.
expand() {
    local text="$1"
    for k in "${!_envs[@]}"; do
        text="${text//\$\{${k}\}/${_envs[${k}]}}"
    done
    echo "${text}"
}

# Collect a multi-line RUN block into a single string.
# Sets global _run_buf and _run_has_content.
# Reads from the open file descriptor passed via coproc/subshell — not used
# directly; instead, callers drive a while-read loop and call _collect_run.

# Extract all apt-get install package names from a Dockerfile.
# Skips any RUN block whose content contains skip_pattern (e.g. "cuda-keyring"
# to avoid re-processing the keyring setup block).
# Outputs one expanded package per line.
extract_packages() {
    local dockerfile="$1"
    local skip_pattern="${2:-__NO_SKIP__}"
    local packages=()
    local buf=""
    local in_run=0

    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%"${line##*[![:space:]]}"}"

        if [[ ${in_run} -eq 1 ]]; then
            buf+=" ${line%\\}"
            [[ "${line}" == *\\ ]] && continue
            in_run=0
        elif [[ "${line,,}" =~ ^run[[:space:]].*apt-get[[:space:]]+install ]]; then
            buf="${line%\\}"
            if [[ "${line}" == *\\ ]]; then
                in_run=1
                continue
            fi
        else
            continue
        fi

        # Skip this block if it matches the skip pattern
        if [[ "${buf}" =~ ${skip_pattern} ]]; then
            buf=""
            continue
        fi

        # Extract package tokens: everything after "apt-get install", before first "&&"
        local pkg_section
        pkg_section=$(echo "${buf}" | sed -E 's/.*apt-get[[:space:]]+install[[:space:]]*//')
        pkg_section=$(echo "${pkg_section}" | sed 's/&&.*//')

        read -ra raw_pkgs <<< "$(echo "${pkg_section}" | tr -s '[:space:]' ' ')"
        for pkg in "${raw_pkgs[@]}"; do
            [[ -z "${pkg}" ]] && continue
            # Skip apt flags (-y, --no-install-recommends, etc.)
            [[ "${pkg}" == -* ]] && continue
            local expanded
            expanded="$(expand "${pkg}")"
            [[ -n "${expanded}" ]] && packages+=("${expanded}")
        done
        buf=""
    done < "${dockerfile}"

    for pkg in "${packages[@]}"; do printf '%s\n' "${pkg}"; done
}

# Extract package names from RUN apt-mark hold lines in a Dockerfile.
extract_hold_packages() {
    local dockerfile="$1"
    local hold_pkgs=()
    local buf=""
    local in_run=0

    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%"${line##*[![:space:]]}"}"

        if [[ ${in_run} -eq 1 ]]; then
            buf+=" ${line%\\}"
            [[ "${line}" == *\\ ]] && continue
            in_run=0
        elif [[ "${line,,}" =~ ^run[[:space:]].*apt-mark[[:space:]]+hold ]]; then
            buf="${line%\\}"
            if [[ "${line}" == *\\ ]]; then
                in_run=1
                continue
            fi
        else
            continue
        fi

        local hold_section
        hold_section=$(echo "${buf}" | sed -E 's/.*apt-mark[[:space:]]+hold[[:space:]]*//')
        hold_section=$(echo "${hold_section}" | sed 's/&&.*//')

        read -ra pkgs <<< "$(echo "${hold_section}" | tr -s '[:space:]' ' ')"
        for pkg in "${pkgs[@]}"; do
            [[ -z "${pkg}" ]] && continue
            [[ "${pkg}" == -* ]] && continue
            hold_pkgs+=("$(expand "${pkg}")")
        done
        buf=""
    done < "${dockerfile}"

    for pkg in "${hold_pkgs[@]}"; do printf '%s\n' "${pkg}"; done
}

# Set up the CUDA apt repository. Detects whether the base Dockerfile uses the
# modern cuda-keyring .deb method or the legacy apt-key method.
# If the modern keyring sources list already exists, removes any conflicting
# legacy cuda.list and skips the full setup — the repo is already ready.
setup_cuda_repo() {
    local base_dockerfile="$1"
    parse_envs "${base_dockerfile}"

    msg "Setting up CUDA apt repository for ${OS_PATH_NAME}/${NVARCH}"

    # The cuda-keyring package creates a file named cuda-${OS_PATH_NAME}-${NVARCH}.list.
    # If that file exists the repo is already properly configured.
    local keyring_list="/etc/apt/sources.list.d/cuda-${OS_PATH_NAME}-${NVARCH}.list"
    if [[ -f "${keyring_list}" ]]; then
        msg "CUDA apt repository already configured via ${keyring_list}, skipping keyring setup"
        run_cmd "apt-get update"
        return 0
    fi

    # Remove any stale legacy cuda.list before a fresh setup
    run_cmd "rm -f /etc/apt/sources.list.d/cuda.list"

    run_cmd "apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates"

    if grep -q "cuda-keyring" "${base_dockerfile}"; then
        debug "Using modern cuda-keyring .deb method"
        run_cmd "curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/${OS_PATH_NAME}/${NVARCH}/cuda-keyring_1.1-1_all.deb"
        run_cmd "dpkg -i cuda-keyring_1.1-1_all.deb"
        run_cmd "rm -f cuda-keyring_1.1-1_all.deb"
    elif grep -q "apt-key add" "${base_dockerfile}"; then
        debug "Using legacy apt-key method"
        local pub_url
        pub_url=$(grep -oP 'https://\S+\.pub' "${base_dockerfile}" | head -1)
        [[ -n "${pub_url}" ]] || err "Could not extract GPG key URL from ${base_dockerfile}"
        pub_url="$(expand "${pub_url}")"
        run_cmd "curl -fsSL '${pub_url}' | apt-key add -"
        run_cmd "echo 'deb https://developer.download.nvidia.com/compute/cuda/repos/${OS_PATH_NAME}/${NVARCH} /' > /etc/apt/sources.list.d/cuda.list"
    else
        err "Could not determine CUDA apt repository setup method from ${base_dockerfile}"
    fi

    run_cmd "apt-get purge --autoremove -y curl"
    run_cmd "apt-get update"
}

# Install one Dockerfile layer (base / runtime / devel) on the host.
install_layer() {
    local layer="$1"
    local os_dir="$2"
    local dockerfile="${os_dir}/${layer}/Dockerfile"

    [[ -f "${dockerfile}" ]] || err "Dockerfile not found: ${dockerfile}"

    msg "Installing CUDA ${layer} packages"
    parse_envs "${dockerfile}"

    local pkgs=()
    # For the base layer, skip the keyring-setup RUN block (we handle it separately)
    local skip_pat="__NO_SKIP__"
    [[ "${layer}" == "base" ]] && skip_pat="(cuda-keyring|apt-key add|3bf863cc\.pub)"

    mapfile -t pkgs < <(extract_packages "${dockerfile}" "${skip_pat}")

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        warning "No apt packages found in ${dockerfile}"
    else
        run_cmd "apt-get install -y --no-install-recommends ${pkgs[*]}"
    fi

    # Apply apt-mark hold for packages that shouldn't be auto-upgraded
    local hold_pkgs=()
    mapfile -t hold_pkgs < <(extract_hold_packages "${dockerfile}")
    if [[ ${#hold_pkgs[@]} -gt 0 ]]; then
        run_cmd "apt-mark hold ${hold_pkgs[*]}"
    fi
}

check_vars() {
    if [[ -z "${CUDA_VERSION}" && ${setup_docker} -eq 0 ]]; then
        err "Nothing to do — specify --cuda-version and/or --docker"
    fi
}

# Install the NVIDIA Container Toolkit and configure Docker for GPU passthrough.
setup_docker_runtime() {
    msg "Setting up NVIDIA Container Toolkit for Docker GPU passthrough"

    command -v docker &>/dev/null || err "Docker is not installed. Install Docker before running --docker."

    local keyring="/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
    local sources_list="/etc/apt/sources.list.d/nvidia-container-toolkit.list"

    if [[ -f "${sources_list}" ]]; then
        msg "NVIDIA Container Toolkit repository already configured (${sources_list})"
    else
        msg "Adding NVIDIA Container Toolkit apt repository"
        run_cmd "apt-get update && apt-get install -y --no-install-recommends curl gnupg2"
        run_cmd "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o ${keyring}"
        # Download the official list file (which uses apt's $(ARCH) variable) and
        # inject the signed-by option so apt can authenticate the packages.
        run_cmd "curl -sL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=${keyring}] https://#g' | tee ${sources_list}"
        run_cmd "apt-get update"
    fi

    run_cmd "apt-get install -y nvidia-container-toolkit"

    msg "Configuring Docker runtime"
    run_cmd "nvidia-ctk runtime configure --runtime=docker"
    run_cmd "systemctl restart docker"

    msg "Docker GPU passthrough ready. Test with: docker run --rm --gpus all nvidia/cuda:base nvidia-smi"
}

main() {
    printf "\n"
    msg "${script_name} START"

    for (( a = 0; a < ${#args[@]}; a++ )); do
        case "${args[$a]}" in
            -h|--help)
                usage ;;
            -n|--dry-run)
                dry_run=1 ;;
            -d|--debug)
                debug_flag=1 ;;
            --kitpick)
                use_kitpick=1 ;;
            --devel)
                install_devel=1
                BASE_IMAGE_NAME=devel ;;
            --docker)
                setup_docker=1 ;;
            --cuda-version)
                CUDA_VERSION="${args[(($a+1))]}"
                debug "CUDA_VERSION=${CUDA_VERSION}"
                ((a=a+1)) ;;
            *)
                err "Unknown argument '${args[$a]}'!"
                usage ;;
        esac
    done

    check_vars
    detect_host
    fix_apt_conflicts

    local base_path
    if [[ ${use_kitpick} -eq 1 ]]; then
        base_path="${script_dir}/kitpick"
    else
        base_path="${script_dir}/dist/${CUDA_VERSION}"
    fi

    if [[ -n "${CUDA_VERSION}" ]]; then
        local os_dir="${base_path}/${OS_PATH_NAME}"
        [[ -d "${os_dir}" ]] || err "No Dockerfiles found for ${OS_PATH_NAME} with CUDA ${CUDA_VERSION}. Not found: ${os_dir}"

        # Set up the CUDA apt repository
        setup_cuda_repo "${os_dir}/base/Dockerfile"

        # Install layers
        install_layer "base"    "${os_dir}"
        install_layer "runtime" "${os_dir}"

        if [[ ${install_devel} -eq 1 ]]; then
            install_layer "devel" "${os_dir}"
        fi

        run_cmd "rm -rf /var/lib/apt/lists/*"
        run_cmd "ldconfig"

        msg "CUDA ${CUDA_VERSION} installed successfully."
        msg "Add /usr/local/cuda/bin to your PATH to use nvcc and other CUDA tools."
    fi

    if [[ ${setup_docker} -eq 1 ]]; then
        setup_docker_runtime
    fi

    msg "${script_name} END"
}

main
