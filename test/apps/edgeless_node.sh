#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

function edgeless_node_build(){
    ./SecureExecutor --edgeless-node --build
    if [ $(docker image ls | grep "edgeless_node" | wc -l) -gt 0 ] ; then return 0
    else return 1 ; fi
}

# function edgeless_node_run(){
#     ./SecureExecutor --edgeless-node --run
# }

# function edgeless_node_cleanup(){
    # docker image rm -f $(docker image ls | grep rust_build_env | tr -s ' ' | cut -d' ' -f 3) > /dev/null
#     # If image already exists, then remove it
#     if [ $(docker image ls | grep "rust_build_env" | wc -l) -gt 0 ] ; then 
#         echo_y "  [rust_build_env] Image already exists, remove it..."
#         
#     fi

#     # If image already exists, then remove it
#     if [ $(docker image ls | grep "edgeless_node" | wc -l) -gt 0 ] ; then 
#         echo_y "  Image already exists, remove it..."
#         docker image rm -f $(docker image ls | grep edgeless_node | tr -s ' ' | cut -d' ' -f 3) > /dev/null
#     fi
# }