#!/bin/bash

CURRENT_DIR=`pwd`

cd `dirname $0`
SCRIPTS_DIR=`pwd`
DIR=`dirname ${SCRIPTS_DIR}`

cd ${SCRIPTS_DIR}
mkdir -p ${SCRIPTS_DIR}/spconv
cd ${SCRIPTS_DIR}/spconv

wget "https://github.com/autowarefoundation/spconv_cpp/releases/download/spconv_v2.3.8%2Bcumm_v0.5.3%2Bcu130-rev1/cumm_0.5.3_amd64.deb"
wget "https://github.com/autowarefoundation/spconv_cpp/releases/download/spconv_v2.3.8%2Bcumm_v0.5.3%2Bcu130-rev1/spconv_2.3.8_amd64.deb"

sudo apt-get update && sudo apt-get install -y \
    ./cumm_0.5.3_amd64.deb \
    ./spconv_2.3.8_amd64.deb \
    && rm -rf /var/lib/apt/lists/*
