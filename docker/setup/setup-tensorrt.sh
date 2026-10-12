#!/bin/bash

CURRENT_DIR=`pwd`

cd `dirname $0`
SCRIPTS_DIR=`pwd`
DIR=`dirname ${SCRIPTS_DIR}`

cd ${SCRIPTS_DIR}
mkdir -p ${SCRIPTS_DIR}/tensorrt
cd ${SCRIPTS_DIR}/tensorrt

export tensorrt_version=10.8.0.43-1+cuda12.8

sudo apt-get update && sudo apt-get install -y \
    libnvinfer10=${tensorrt_version} \
    libnvinfer-plugin10=${tensorrt_version} \
    libnvonnxparsers10=${tensorrt_version} \
    libnvinfer-dev=${tensorrt_version} \
    libnvinfer-plugin-dev=${tensorrt_version} \
    libnvinfer-headers-dev=${tensorrt_version} \
    libnvinfer-headers-plugin-dev=${tensorrt_version} \
    libnvonnxparsers-dev=${tensorrt_version} \
    && rm -rf /var/lib/apt/lists/*

sudo apt-mark hold \
    libnvinfer10 \
    libnvinfer-plugin10 \
    libnvonnxparsers10 \
    libnvinfer-dev \
    libnvinfer-plugin-dev \
    libnvonnxparsers-dev \
    libnvinfer-headers-dev \
    libnvinfer-headers-plugin-dev
