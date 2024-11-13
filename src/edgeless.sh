#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/utils.sh
source ./src/scone.sh

BUILD_MODE="PRODUCTION"
# BUILD_MODE="DEVELOPMENT"

# ===============================================================================================================
# This is a workaround for sysinfo
# Some parts of the sysinfo crate that the edgeless node utilizes
# DO NOT work as expected, for this reason, in the edgeless_node code
# these functions that do not work properly, have been updated and retrieve data
# From the untrusted part, in the ./scripts/sysinfo directory, a new rust project
# exists which is actually a http server, which receives requests from the updated version
# of the sysinfo crate (see ./sysinfo) and response back. 
# This means, that most of the functions are the same, but these that do not behave as needed
# will retrieve from an external application the info
function sysinfo_workaround_server_start(){    sysinfo_workaround_server_stop
    cd ./sysinfo_untrusted/sysinfo_server
    echo "Build sysinfo untrusted server (sysinfo workaround)..."
    cargo build
    ./target/debug/sysinfo &
    export SYSINFO_PID=$!
    echo "Untrusted server started [PID: ${SYSINFO_PID}]"
    cd - &> /dev/null
}

function sysinfo_workaround_server_stop(){
    # Kill server
    echo "Kill sysinfo untrusted servers (if exist)"
    bash -c "kill -9 $(ps aux | grep sysinfo | grep -v grep | tr -s ' ' | cut -d' ' -f2) &> /dev/null"
}
# ===============================================================================================================

function remove_edgeless_node_image(){
    docker image rm $(docker image ls  | grep edgeless_node | tr -s ' ' | cut -d' ' -f3)
}

function build_edgeless_node_image_prod(){
    build_image "edgeless_node" "Dockerfiles/apps/edgeless-node.Dockerfile"
}

function build_edgeless_node_image_dev(){
    remove_edgeless_node_image
    build_image "edgeless_node" "Dockerfiles/apps/edgeless-node.Dockerfile --build-arg EDGELESS_BUILD_MODE=dev"
}

function build_edgeless_system_image(){
    build_image "edgeless_system" "Dockerfiles/apps/edgeless-system.Dockerfile"
}

function copy_edgeless_node_executable(){
    # Remove all old edgeless_node directory contents
    rm -rf edgeless_node && mkdir -p edgeless_node/

    # Copy files
    echo_y "- [CREATE EDGELESS_NODE DIR] Create edgeless_node directory and copy files there..."
    docker  run -it --rm -v `pwd`/edgeless_node/:/home/user/edgeless_node/ -w=/home/user/edgeless -u $(id -u $USER):$(id -g $USER) --net=host edgeless_node \
            sh -c "\
                cp /home/user/edgeless/target/debug/edgeless_node_d /home/user/edgeless_node/edgeless_node_d && \
                /home/user/edgeless_node/edgeless_node_d -t /home/user/edgeless_node/node.toml"
}

function build_edgeless_node(){
    sysinfo_workaround_server_start
    build_rust_env
    [[ ${BUILD_MODE} == "PRODUCTION" ]] && build_edgeless_node_image_prod || build_edgeless_node_image_dev 
    copy_edgeless_node_executable
    sconify_execuble "`pwd`/edgeless_node/edgeless_node_d"
    sysinfo_workaround_server_stop
}

function run_edgeless_node(){
    if [ ! -d edgeless_node ] ; then echo_r "Build first edgeless_node" ; exit 0; fi

    sysinfo_workaround_server_start

    # Determine SGX device
    determine_sgx_device

    # Run docker container
    docker  run --rm -it \
            --platform linux/amd64 \
            -v `pwd`/edgeless_node:/work \
            -w=/work \
            ${GDB_DBG_FLAGS} \
            -u $(id -u $USER):$(id -g $USER) \
            --network=host \
            $MOUNT_SGXDEVICE \
            ${RUST_TRUSTED_BIN_RT_IMG} \
            sh -c "SCONE_VERSION=1 SCONE_MODE=hw RUST_LOG=info SCONE_LOG=FATAL SCONE_HEAP=1G SCONE_RUST_BACKTRACE=FULL ./edgeless_node_d"
    
    sysinfo_workaround_server_stop
}
