#!/usr/bin/env bash
set -euo pipefail

# 尝试运行 cargo prove --version 命令
if ! command -v cargo &> /dev/null || ! cargo prove --version &> /dev/null; then
    # step1: install sp1 prover system
    curl -L https://sp1up.succinct.xyz | bash

    # Store the correct profile file (i.e. .profile for bash or .zshenv for ZSH).
    case $SHELL in
    */zsh)
        PROFILE=${ZDOTDIR-"$HOME"}/.zshenv
        PREF_SHELL=zsh
        ;;
    */bash)
        PROFILE=$HOME/.bashrc
        PREF_SHELL=bash
        ;;
    */fish)
        PROFILE=$HOME/.config/fish/config.fish
        PREF_SHELL=fish
        ;;
    */ash)
        PROFILE=$HOME/.profile
        PREF_SHELL=ash
        ;;
    *)
        echo "sp1up: could not detect shell, manually add ${SP1_BIN_DIR} to your PATH."
        exit 1
        ;;
    esac

    [ -f "${PROFILE}" ] && source "${PROFILE}"
    sp1up
else
  echo "sp1 prover system installed, skip the installation steps"
fi

# 尝试运行 nvidia-smi 命令
if ! command -v nvidia-smi &> /dev/null || ! nvidia-smi &> /dev/null; then
    # 获取 Ubuntu 系统版本代号
    . /etc/os-release
    UBUNTU_CODENAME=${UBUNTU_CODENAME:-$VERSION_CODENAME}
    # 根据系统版本选择安装 CUDA
    case $UBUNTU_CODENAME in
        focal)
            # Ubuntu 20.04
            wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
            sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
            wget https://developer.download.nvidia.com/compute/cuda/12.5.0/local_installers/cuda-repo-ubuntu2004-12-5-local_12.5.0-555.42.02-1_amd64.deb
            sudo dpkg -i cuda-repo-ubuntu2004-12-5-local_12.5.0-555.42.02-1_amd64.deb
            sudo cp /var/cuda-repo-ubuntu2004-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/
            sudo apt-get update
            sudo apt-get -y install cuda-toolkit-12-5
            ;;
        jammy)
            # Ubuntu 22.04
            wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
            sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
            wget https://developer.download.nvidia.com/compute/cuda/12.5.0/local_installers/cuda-repo-ubuntu2204-12-5-local_12.5.0-555.42.02-1_amd64.deb
            sudo dpkg -i cuda-repo-ubuntu2204-12-5-local_12.5.0-555.42.02-1_amd64.deb
            sudo cp /var/cuda-repo-ubuntu2204-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/
            sudo apt-get update
            sudo apt-get -y install cuda-toolkit-12-5
            ;;
        *)
            echo "不支持的 Ubuntu 版本: $UBUNTU_CODENAME"
            exit 1
            ;;
    esac
else
  echo "CUDA Already installed, skip the installation steps"
fi

# 检查 Docker 是否已经安装
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get -y install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    . /etc/os-release
    UBUNTU_CODENAME=${UBUNTU_CODENAME:-$VERSION_CODENAME}
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      ${UBUNTU_CODENAME} stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    # install the docker engine
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker installed, skip the installation steps"
fi

# 检查 nvidia-container-toolkit 是否可用
if ! command -v nvidia-container-cli &> /dev/null; then
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo systemctl restart docker
else
    echo "nvidia-container-toolkit installed, skip the installation steps"
fi

# pull the docker image which calculate the eth proof
# 检查镜像是否已经下载
if ! docker images | grep -qE "public\.ecr\.aws/succinct-labs/moongate\s+v4\.1\.0"; then
    docker pull public.ecr.aws/succinct-labs/moongate:v4.1.0
else
    echo "docker image public.ecr.aws/succinct-labs/moongate:v4.1.0 is downloaded, skip the download step"
fi
