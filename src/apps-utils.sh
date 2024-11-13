#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh
source ./src/scone.sh

function build_base_images(){
    docker build -t secureexecutor-app-base:ubuntu -f ./Dockerfiles/apps-base-images/cpp-base.Dockerfile . 
    docker build -t secureexecutor-app-base:python3 -f ./Dockerfiles/apps-base-images/python-base.Dockerfile .  
}

function project_build_from_dockerimage(){
    local dockerfile=$1
    local imagename="$(basename ${dockerfile} | cut -d'.' -f1)-image:latest"

    # Handle errors
    if [[ ! -e ${dockerfile} ]] ; then echo "Dockerfile [$dockerfile] does not exist. Please provide a valid file path." ; exit 0 ; fi

    build_base_images

    # Build image
    docker build -t ${imagename} -f ${dockerfile} . 

    exit 0
}

function project_run_from_dockerimage(){
    local dockerfile=$1
    local imagename="$(basename ${dockerfile} | cut -d'.' -f1)-image:latest"

    # Handle errors
    if [ -z "`docker image ls  | grep $(echo ${imagename} | cut -d':' -f1)`" ]; then echo_r "Please build first the image"; exit 0 ; fi

    # Run image
    determine_sgx_device  
    docker run $MOUNT_SGXDEVICE \
        -it --rm \
        -e SCONE_HEAP=256M -e SCONE_MODE=hw -e SCONE_ALLOW_DLOPEN=2 -e SCONE_ALPINE=1 -e SCONE_VERSION=1 \
        ${ENV_VARS} \
        ${imagename}
    exit 0
}