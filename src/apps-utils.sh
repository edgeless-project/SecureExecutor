#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh
source ./src/scone.sh
source ./src/utils.sh

function build_base_images(){
    exec_cmd docker build -t secureexecutor-app-base:ubuntu -f ./Dockerfiles/apps-base-images/cpp-base.Dockerfile . 
    exec_cmd docker build -t secureexecutor-app-base:python3 -f ./Dockerfiles/apps-base-images/python-base.Dockerfile .  
}

function project_build_from_dockerimage(){
    local dockerfile=$1
    local imagename
    imagename="$(basename "${dockerfile}" | cut -d'.' -f1)-image:latest"

    # Handle errors
    if [[ ! -e ${dockerfile} ]] ; then 
        echo_r "[ERROR] Dockerfile [$dockerfile] does not exist. Please provide a valid file path." 
        exit 0
    fi

    build_base_images

    # Build image
    exec_cmd docker build -t "${imagename}" -f "${dockerfile}" . 

    echo_g " > Image [${imagename}] created"
    exit 0
}

function project_run_from_dockerimage(){
    local dockerfile=$1
    local env_variables=$2
    local imagename
    imagename="$(basename "${dockerfile}" | cut -d'.' -f1)-image:latest"

    # Handle errors
    if ! image_exist "${imagename}"; then
        echo_r "[ERROR] Please build the image first, [${imagename}] does not exist"
        exit 0
    fi

    # Run image
    determine_sgx_device  
    exec_cmd docker run --rm \
        ${MOUNT_SGXDEVICE:+${MOUNT_SGXDEVICE}} \
        ${env_variables:+${env_variables}} \
        -e SCONE_HEAP=256M -e SCONE_MODE=hw -e SCONE_ALLOW_DLOPEN=2 -e SCONE_ALPINE=1 -e SCONE_VERSION=1 \
        "${imagename}"
    exit 0
}