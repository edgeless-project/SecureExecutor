#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh
source ./src/utils.sh

# This is the location in the final image where crate contents will be stored
CONTAINER_PROJECT_DIR="/home/app"

# -------------------------------------------------
# CREATE LAMBDA PLACEHOLDER
# -------------------------------------------------

function create_template_project(){
    local lang=$1
    local lambda_name=$2

    rm -rf "./lambdas/${lang}/${lambda_name}/"                          # Remove old lambda if already exists
    mkdir -p "./lambdas/${lang}/"
    cp -r "./templates/${lang}/" "./lambdas/${lang}/${lambda_name}"     # Copy template files to new lambda location
    echo_g "New project created: ./lambdas/${lang}/${lambda_name}"      # Display debug message
}

# -------------------------------------------------
# BUILD IMAGE
# -------------------------------------------------

function build_cpp_image(){
    # Read parameters
    local lambda_name=$1
    local image_name=$2
    local static_dynamic=$3

    lambda_dir="lambdas/cpp/${lambda_name}"

    #  TODO: add static/dynamic tag
    if [ "${static_dynamic}" == "static" ] ; then
        exec_cmd docker build -t "${image_name}" --build-arg PROJECT_DIR="./${lambda_dir}" --build-arg CONTAINER_PROJECT_DIR="${CONTAINER_PROJECT_DIR}" -f Dockerfiles/cpp-static.Dockerfile .   # Create image to create executable
    else 
        exec_cmd docker build -t "${image_name}" --build-arg PROJECT_DIR="./${lambda_dir}" --build-arg CONTAINER_PROJECT_DIR="${CONTAINER_PROJECT_DIR}" -f Dockerfiles/cpp-build.Dockerfile .    # Create image to create executable
        exec_cmd docker run --rm -it -v "./${lambda_dir}/build":"${CONTAINER_PROJECT_DIR}/bin" -w "${CONTAINER_PROJECT_DIR}" "${image_name}" sh -c "cp ./build/executable ./bin"                 # Copy executable to local dir
        docker image rm -f "./${image_name}"                                                                                                                                            # Remove image
        exec_cmd docker build -t "${image_name}" --build-arg PROJECT_DIR="./${lambda_dir}" --build-arg CONTAINER_PROJECT_DIR="${CONTAINER_PROJECT_DIR}" -f Dockerfiles/cpp-dynamic.Dockerfile .  # Create image that will only contain the executable

        # Clean 
        # sudo rm -rf ./${lambda_dir}/build # FIXME: executable in host does not has proper permissions to delete
    fi
    echo_g " > Image [${image_name}] created"
}

function build_python_image(){
    # Read parameters
    local lambda_name=$1
    local image_name=$2

    lambda_dir="lambdas/python/${lambda_name}"

    exec_cmd docker build -t "${image_name}" --build-arg PROJECT_DIR="./${lambda_dir}" --build-arg CONTAINER_PROJECT_DIR="${CONTAINER_PROJECT_DIR}" -f Dockerfiles/python3.Dockerfile .
    echo_g " > Image [${image_name}] created"
}

function build_rust_image(){
    # Read parameters
    local lambda_name=$1
    local image_name=$2

    lambda_dir="lambdas/rust/${lambda_name}"
    
    exec_cmd docker build -t "${image_name}" --build-arg PROJECT_DIR="./${lambda_dir}" --build-arg CONTAINER_PROJECT_DIR="${CONTAINER_PROJECT_DIR}" -f Dockerfiles/rust.Dockerfile .
    echo_g " > Image [${image_name}] created"
}


# -------------------------------------------------
# RUN CONTAINER
# -------------------------------------------------

function run_container(){
    # Read parameters
    local lambda_name=$1
    local image_name=$2
    local env_variables=$3
    local vol_path=$4

    if ! image_exist "${image_name}"; then 
        echo_r "[ERROR] Please build the image first"
        exit 0
    fi

    # Set volume in case vol_path is not empty
    vol_option=""
    if [ -n "$vol_path" ]; then
        vol_option="-v ${vol_path}:${CONTAINER_PROJECT_DIR}/$(basename "$vol_path")"
    fi

    # Determine SGX device
    determine_sgx_device

    # Run docker container
    exec_cmd docker run --rm \
                ${MOUNT_SGXDEVICE:+${MOUNT_SGXDEVICE}} \
                ${env_variables:+${env_variables}} \
                ${vol_option:+${vol_option}} \
                -e SCONE_VERSION=1 \
                -e SCONE_MODE=hw  \
                "${image_name}"
}
