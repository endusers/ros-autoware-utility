#!/bin/bash

sudo sed -i -e 's/no-cgroups =.*$/no-cgroups = false/g' /etc/nvidia-container-runtime/config.toml
