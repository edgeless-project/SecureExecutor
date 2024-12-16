#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/utils.sh
source ./src/scone.sh

PYTHON_FUNCTION_TEST_NAME="edgeless_func_test_python"

function edgeless_function_python_new(){
    # Check if the edgeless_function dir already exist
    if [[ -e ./edgeless_function/python/${PYTHON_FUNCTION_TEST_NAME} ]] ; then
        rm_edgeless_function_python
    fi

    # Create new edgeless_function dir
    ./SecureExecutor --edgeless-function --python --function-name ${PYTHON_FUNCTION_TEST_NAME} --new 

    # Check that the new directory created
    if [ -d ./edgeless_function/python/${PYTHON_FUNCTION_TEST_NAME} ] ; then
        return 0
    else
        return 1
    fi
}

function edgeless_function_python_build(){
    # If image already exists, then remove it
    if image_exist "${PYTHON_FUNCTION_TEST_NAME}"; then 
        echo_y "  Image already exists, remove it..."
        remove_image "${PYTHON_FUNCTION_TEST_NAME}"
    fi

    # Build image
    response=$(./SecureExecutor --edgeless-function --python --function-name ${PYTHON_FUNCTION_TEST_NAME} --build)
    echo "${response}"

    if text_contains "${response}" "[ERROR]" ; then
        return 0
    else
        return 1
    fi
}

function edgeless_function_python_run(){
    local image_name
    image_name="$(docker image ls | grep "${PYTHON_FUNCTION_TEST_NAME}" | tr -s ' ' | cut -d' ' -f1):latest"
    
    determine_sgx_device
    
    local response
    response=$(timeout 5 docker run --rm ${MOUNT_SGXDEVICE:+"$MOUNT_SGXDEVICE"} "${image_name}" 2>&1)
    echo "${response}"

    if text_contains "${response}" "INFO:__main__:starting server at" ; then
        return 0
    else
        return 1
    fi
}

function edgeless_function_python_cleanup(){
    remove_image "${PYTHON_FUNCTION_TEST_NAME}"

    if image_exist "${PYTHON_FUNCTION_TEST_NAME}" ; then 
        return 1
    else 
        return 0
    fi
}


function rm_edgeless_function_python(){
    rm -rf ./edgeless_function/python/${PYTHON_FUNCTION_TEST_NAME}

    # Check that the directory removed
    if [[ ! -d ./edgeless_function/python/${PYTHON_FUNCTION_TEST_NAME} ]] ; then
        return 0
    else
        return 1
    fi
}