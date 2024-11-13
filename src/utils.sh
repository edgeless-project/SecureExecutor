#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

function build_image(){
    image_name=$1
    dockerfile=$2
    build_args=$3

    # Check if force build option is enabled or image does not exist
    if ${FORCE_BUILD_IMAGES} || [ -z "`docker image ls  | grep $(echo ${image_name} | cut -d':' -f1)`" ]; then 
        echo_y "- [Build Image]: '${image_name}'..."
        docker build --platform linux/amd64 --no-cache \
            -t ${image_name} \
            --build-arg USER_ID=$(id -u $USER) --build-arg GROUP_ID=$(id -g $USER) ${build_args} \
            -f ${dockerfile} .
    else 
        echo_g "- Image: '${image_name}' already exists"
    fi
}