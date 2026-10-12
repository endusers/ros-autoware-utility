#!/bin/bash

CURRENT_DIR=`pwd`

cd `dirname $0`
SCRIPTS_DIR=`pwd`
DIR=`dirname ${SCRIPTS_DIR}`

cd ${SCRIPTS_DIR}
mkdir -p ${SCRIPTS_DIR}/cuda
cd ${SCRIPTS_DIR}/cuda

cuda_version="12.8"

os=ubuntu2204
arch_dir=$(
  case "$(dpkg --print-architecture)" in
    amd64) echo x86_64 ;;
    aarch64) echo arm64 ;;
    *) echo "$(dpkg --print-architecture)";;
  esac
)

wget "https://developer.download.nvidia.com/compute/cuda/repos/${os}/${arch_dir}/cuda-keyring_1.1-1_all.deb"
sudo dpkg -i cuda-keyring_1.1-1_all.deb
cuda_version_dashed=$(eval sed -e "s/[.]/-/g" <<< "${cuda_version}")
sudo apt-get update && sudo apt-get install -y \
    cuda-toolkit-${cuda_version_dashed} \
    && rm -rf /var/lib/apt/lists/*
