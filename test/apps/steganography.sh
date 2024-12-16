#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/utils.sh

function steganography_app_build(){
    steganography_app_clean

    ./SecureExecutor --app --path Dockerfiles/apps/steganography.Dockerfile --build

    if image_exist "steganography-image" ; then
        return 0
    else
        return 1
    fi
}

function steganography_app_run(){
    ./SecureExecutor --app --path Dockerfiles/apps/steganography.Dockerfile --run
    # TODO: take response and verify if the operation was failed or not
}

function steganography_app_clean(){
    # If image already exists, then remove it
    if image_exist "steganography-image" ; then
        echo_y "  Image already exists, remove it..."
        remove_image "steganography-image"
    fi
}