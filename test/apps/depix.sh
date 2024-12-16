#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/utils.sh

function depix_app_build(){
    depix_app_clean

    ./SecureExecutor --app --path Dockerfiles/apps/depix.Dockerfile --build

    if image_exist "depix-image" ; then
        return 0
    else
        return 1
    fi
}

function depix_app_run(){
    ./SecureExecutor --app --path Dockerfiles/apps/depix.Dockerfile --run
    # TODO: take response and verify if the operation was failed or not
}

function depix_app_clean(){
    # If image already exists, then remove it
    if image_exist "depix-image" ; then
        echo_y "  Image already exists, remove it..."
        remove_image "depix-image"
    fi
}