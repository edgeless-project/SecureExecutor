#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh
source ./src/utils.sh

RUST_TEST_NAME="secure_executor_lambda_test_rust"

# Check that you cannot run a container that is not build yet
function rust_run_container_when_image_not_exist(){
    # If image already exists, then remove it
    if image_exist "${RUST_TEST_NAME}" ; then 
        echo_y "  Image already exists, remove it..."
        remove_image "${RUST_TEST_NAME}"
    fi

    # Try to run it before building image first
    response=$(./SecureExecutor --lambda --rust --function-name ${RUST_TEST_NAME} --run)
    echo "${response}"

    # Check response (The part after the pipe removes color related chars)
    if text_contains "${response}" "[ERROR]" ; then
        return 0
    else
        return 1
    fi
}


# Check that you cannot build an image for which you do not have yet its sources
function rust_build_image_before_create_lambda(){
    # If image already exists, then remove it
    if image_exist "${RUST_TEST_NAME}" ; then
        echo_y "  Image already exists, remove it"
        remove_image "${RUST_TEST_NAME}"
    fi

    # Try to build it before creating first the equivalent project directory
    response=$(./SecureExecutor --lambda --rust --function-name ${RUST_TEST_NAME} --build)
    echo "${response}"

    # Check response
    if text_contains "${response}" "[ERROR]" ; then
        return 0
    else
        return 1
    fi
}


# Create a new lambda in rust
function rust_create_new_lambda(){
    # Check if the lambda dir already exist
    if [[ -e ./lambda/rust/${RUST_TEST_NAME} ]] ; then
        rm_rust_lambda
    fi

    # Create new lambda dir
    ./SecureExecutor --lambda --rust --function-name ${RUST_TEST_NAME} --new 

    # Check that the new directory created
    if [ -d ./lambdas/rust/${RUST_TEST_NAME} ] ; then
        return 0
    else
        return 1
    fi
}


# Build secure image as long as you have its sources
function rust_build_lambda(){
    response=$(./SecureExecutor --lambda --rust --function-name ${RUST_TEST_NAME} --build)

    if image_exist "${RUST_TEST_NAME}" ; then
        return 0
    else
        return 1
    fi
}


# Since you have build the image, then you should be able to run it
function rust_run_lambda(){
    response=$(./SecureExecutor --lambda --rust --function-name ${RUST_TEST_NAME} --run)
    echo "${response}"

    # Check response
    if text_contains "${response}" "Hello Rust"; then
        return 0
    else
        return 1
    fi
}


# Clean docker image and make sure that there are not any further docker related stuff
function rust_cleanup_lambda(){
    ./SecureExecutor --lambda --rust --function-name ${RUST_TEST_NAME} --clean

    if image_exist "${RUST_TEST_NAME}" ; then
        return 1
    else
        return 0
    fi
}


# Cleanup also lambda sources
function rm_rust_lambda(){
    rm -rf ./lambdas/rust/${RUST_TEST_NAME}

    # Check that the new directory created
    if [[ ! -d ./lambda/rust/${RUST_TEST_NAME} ]] ; then
        return 0
    else
        return 1
    fi
}