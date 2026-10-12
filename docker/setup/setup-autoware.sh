#!/bin/bash

CURRENT_DIR=`pwd`

cd `dirname $0`
SCRIPTS_DIR=`pwd`
DIR=`dirname ${SCRIPTS_DIR}`

cd ${SCRIPTS_DIR}
git clone -b 1.8.0 https://github.com/autowarefoundation/autoware.git

cd autoware
./setup-dev-env.sh -y --no-nvidia --no-cuda-drivers --data-dir ${CURRENT_DIR}/autoware_data/ml_models

cd autoware
mkdir -p src
vcs import src < ./repositories/autoware.repos
rosdep update
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
