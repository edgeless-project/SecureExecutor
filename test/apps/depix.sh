#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

function depix_app_build(){
    depix_app_clean

    ./SecureExecutor --build-from-dockerimage Dockerfiles/apps/depix.Dockerfile
    if [ $(docker image ls | grep "depix" | wc -l) -gt 0 ] ; then return 0
    else return 1 ; fi
}

function depix_app_run(){
    ./SecureExecutor --run-from-dockerimage Dockerfiles/apps/depix.Dockerfile
    # TODO: take response and verify if the operation was failed or not
}

function depix_app_clean(){
    # If image already exists, then remove it
    if [ $(docker image ls | grep "depix" | wc -l) -gt 0 ] ; then 
        echo_y "  Image already exists, remove it"
        docker image rm -f $(docker image ls | grep depix | tr -s ' ' | cut -d' ' -f 3)
    fi
}