#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh

SUPPORTED_LAMBDA_LANGUAGES=("cpp python rust")

# This is the location in the final image where crate contents will be stored
CONTAINER_PROJECT_DIR="/home/app"

function val_exists_in_array(){
    # Take input parameters
    local value=$1
    local array=$2

    # Check if value exists in array
    local exists=0
    for i in "${array[@]}" ; do
        if [ "$i" == "$value" ] ; then
            exists=1
        fi
    done
    return ${exists}
}

# -------------------------------------------------
# CREATE LAMBDA
# -------------------------------------------------

function create_template_project(){
    local lang=$1

    # if [[ `val_exists_in_array $lang $SUPPORTED_LAMBDA_LANGUAGES` == 1 ]] ; then
    #     echo ""
    # fi

    rm -rf ./lambdas/${lang}/${LAMBDA_NAME}/                                                                 # Remove old lambda if already exists
    mkdir -p ./lambdas/${lang}/
    cp -r ./templates/${lang}/ ./lambdas/${lang}/${LAMBDA_NAME}                                              # Copy template files to new lambda location
    echo_g "New project created: ./lambdas/${lang}/${LAMBDA_NAME}"                                           # Display debug message
}

# -------------------------------------------------
# BUILD IMAGE
# -------------------------------------------------

function build_cpp_image(){
    # Read parameters
    lambda_name=$1
    image_name=$2
    static_dynamic=$3

    lambda_dir="lambdas/$TARGET/$LAMBDA_NAME"

    if [ $static_dynamic == "static" ] ; then
        exec docker build -t "${image_name}" --build-arg PROJECT_DIR=./${lambda_dir} --build-arg CONTAINER_PROJECT_DIR=${CONTAINER_PROJECT_DIR} -f Dockerfiles/cpp-static.Dockerfile .   # Create image to create executable
    else 
        exec docker build -t "${image_name}" --build-arg PROJECT_DIR=./${lambda_dir} --build-arg CONTAINER_PROJECT_DIR=${CONTAINER_PROJECT_DIR} -f Dockerfiles/cpp-build.Dockerfile .    # Create image to create executable
        exec docker run --rm -it -v ./${lambda_dir}/build:${CONTAINER_PROJECT_DIR}/bin -w ${CONTAINER_PROJECT_DIR}  ${image_name} sh -c "cp ./build/executable ./bin"                           # Copy executable to local dir
        exec docker image rm -f ./${image_name}                                                                                                                                                 # Remove image
        exec docker build -t ${image_name} --build-arg PROJECT_DIR=./${lambda_dir} --build-arg CONTAINER_PROJECT_DIR=${CONTAINER_PROJECT_DIR} -f Dockerfiles/cpp-dynamic.Dockerfile .                                                               # Create image that will only contain the executable

        # Clean 
        # sudo rm -rf ./${lambda_dir}/build # FIXME: executable in host does not has proper permissions to delete
    fi
    echo_g " > Image [${image_name}] created"
}

function build_python_image(){
    # Read parameters
    lambda_name=$1
    image_name=$2

    lambda_dir="lambdas/$TARGET/$LAMBDA_NAME"

    exec docker build -t "${image_name}" --build-arg PROJECT_DIR=./${lambda_dir} --build-arg CONTAINER_PROJECT_DIR=${CONTAINER_PROJECT_DIR} -f Dockerfiles/python3.Dockerfile .
}

function build_rust_image(){
    # Read parameters
    lambda_name=$1
    image_name=$2

    lambda_dir="lambdas/$TARGET/$LAMBDA_NAME"
    
    exec docker build -t "${image_name}" --build-arg PROJECT_DIR=./${lambda_dir} --build-arg CONTAINER_PROJECT_DIR=${CONTAINER_PROJECT_DIR} -f Dockerfiles/rust.Dockerfile .
}


# -------------------------------------------------
# RUN CONTAINER
# -------------------------------------------------

function run_container(){
    # Read parameters
    lambda_name=$1
    image_name=$2
    env_variables=${ENV_VARS}
    vol_path=${VOL_PATH}

    if [ -z "`docker image ls  | grep $(echo ${image_name} | cut -d':' -f1)`" ]; then echo_r "Please build first the image"; exit 0 ; fi

    # Set volume in case vol_path is not empty
    vol_option=""
    if [ ! -z $vol_path ]; then vol_option="-v ${vol_path}:${CONTAINER_PROJECT_DIR}/$(basename "$vol_path")" ; fi

    # Determine SGX device
    determine_sgx_device

    # Run docker container
    timems exec docker run -it --rm $MOUNT_SGXDEVICE \
                ${env_variables} \
                ${vol_option} \
                -e SCONE_VERSION=1 \
                -e SCONE_MODE=hw  \
                ${image_name}
}

# -------------------------------------------------
# CLEAN UP
# -------------------------------------------------

function cleanup(){
    image_name=$1
    
    # Finally delete generated image
    image_id="`docker image ls | grep $(echo ${image_name} | cut -d':' -f1) | tr -s ' ' | cut -d' ' -f3`"
    if [ ! -z ${image_id} ] ; then exec docker image rm -f ${image_id} ; fi
}

