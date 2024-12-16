#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh

# Indicate if we should rebuild all images even though they exist
# For debugging reasons for instance
FORCE_BUILD_IMAGES=false

function image_exist(){
    local image_name=$1
    image_name=$(echo "${image_name}" | cut -d':' -f1)  # Remove tag from name

    if [ "$(docker image ls | grep -c "${image_name}")" -gt 0 ]; then
        return 0
    else 
        return 1
    fi
}

function text_contains(){
    local text=$1
    local substring=$2

    if [ "$(echo "${text}" | grep -c "${substring}")" -gt 0 ]; then
        return 0
    else 
        return 1
    fi
}

function remove_image(){
    local image_name=$1
    # Remove tag from name
    image_name=$(echo "${image_name}" | cut -d':' -f1)  

    # If container running stop it before removing
    local container_id
    container_id=$(docker container ls | grep "${image_name}" | tr -s ' ' | cut -d' ' -f 1)
    if [ -n "${container_id}" ] ; then
        exec_cmd docker container stop "${container_id}" > /dev/null
    fi

    # Delete image
    local image_id
    image_id=$(docker image ls | grep "${image_name}" | tr -s ' ' | cut -d' ' -f 3)
    if [ -n "${image_id}" ]; then
        exec_cmd docker image rm -f "${image_id}" > /dev/null
    fi
}

function build_image(){
    local image_name="$1"
    local dockerfile="$2"
    local build_args="$3"   # This can be empty, so echo it during build

    # Check if force build option is enabled or image does not exist
    if ${FORCE_BUILD_IMAGES} || ! image_exist "${image_name}"; then 
        # Log message
        echo_y "- [BUILD IMAGE]: '${image_name}'..."

        # Build image
        exec_cmd docker build --platform linux/amd64 --no-cache \
            -t "${image_name}" \
            --build-arg USER_ID="$(id -u "$USER")" \
            --build-arg GROUP_ID="$(id -g "$USER")" \
            ${build_args:+${build_args}} \
            -f "${dockerfile}" .

        # Check that the image has been created
        if ! image_exist "${image_name}"; then
            echo_r " [ERROR] Failed to build image: [${image_name}]"
            exit 1
        fi
    else 
        echo_g "\tImage: '${image_name}' already exists, nothing to do."
    fi
}