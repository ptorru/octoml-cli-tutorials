#!/bin/bash
set -eux

# Install pip requirements
pip install -r requirements.txt

# Check for docker installation
if ! command -v docker &> /dev/null
then
    echo "ERROR: docker not found. Please install docker: https://docs.docker.com/engine/install/"
    exit 1
fi

# Download pretrained model into tutorials
./download_model.sh
