#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/utils.sh

function edgeless_node_build(){
    ./SecureExecutor --edgeless-node --build
    
    if image_exist "edgeless_node" ; then 
        return 0
    else 
        return 1
    fi
}

# function edgeless_node_run(){
#     ./SecureExecutor --edgeless-node --run
# }

function edgeless_node_cleanup(){
    remove_image "edgeless_node"
    remove_image "rust_build_env"

    return 0
}