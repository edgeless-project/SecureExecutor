#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

CPP_TEST_NAME="test_cpp"

remove_color(){
    echo "$@" | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'
}

# Check that you cannot run a container that is not build yet
function cpp_run_container_when_image_not_exist(){
    # If image already exists, then remove it
    if [ $(docker image ls | grep "${CPP_TEST_NAME}" | wc -l) -gt 0 ] ; then 
        echo_y "  Image already exists, remove it..."
        docker image rm -f $(docker image ls | grep ${CPP_TEST_NAME} | tr -s ' ' | cut -d' ' -f 3) > /dev/null
    fi

    # Try to run it before building image first
    response="$(./SecureExecutor --cpp --lambda-name ${CPP_TEST_NAME} --run)" 
    echo ${response}
    response=$(remove_color ${response})

    # Check response (The part after the pipe removes color related chars)
    if [ "${response}" == "Please build first the image" ] ; then
        return 0
    else
        return 1
    fi
}


# Check that you cannot build an image for which you do not have yet its sources
function cpp_build_image_before_create_lambda(){
    # If image already exists, then remove it
    if [ $(docker image ls | grep "${CPP_TEST_NAME}" | wc -l) -gt 0 ] ; then 
        echo_y "  Image already exists, remove it"
        docker image rm -f $(docker image ls | grep ${CPP_TEST_NAME} | tr -s ' ' | cut -d' ' -f 3)
    fi

    # Try to build it before creating first the equivalent project directory
    response="$(./SecureExecutor --cpp --lambda-name ${CPP_TEST_NAME} --build)" # The part after the pipe removes color related chars
    echo ${response}
    response=$(remove_color ${response})

    # Check response
    if [ "${response}" == "Please create first the lambda function!" ] ; then
        return 0
    else
        return 1
    fi
}


# Create a new lambda in cpp
function cpp_create_new_lambda(){
    # Check if the lambda dir already exist
    if [[ -e ./lambda/cpp/${CPP_TEST_NAME} ]] ; then
        rm_cpp_lambda
    fi

    # Create new lambda dir
    ./SecureExecutor --cpp --lambda-name ${CPP_TEST_NAME} --new 

    # Check that the new directory created
    if [ -d ./lambdas/cpp/${CPP_TEST_NAME} ] ; then
        return 0
    else
        return 1
    fi
}


# # Build secure image as long as you have its sources
function cpp_build_lambda(){
    response="$(./SecureExecutor --cpp --lambda-name ${CPP_TEST_NAME} --build)"
    if [ $(docker image ls | grep "${CPP_TEST_NAME}" | wc -l) -gt 0 ] ; then return 0
    else return 1 ; fi
}


# Since you have build the image, then you should be able to run it
function cpp_run_lambda(){
    response="$(./SecureExecutor --cpp --lambda-name ${CPP_TEST_NAME} --run)"
    echo ${response}

    # Check response
    if [ "$(echo ${response} | grep 'Hello CPP' | wc -l)" -gt 0 ] ; then
        return 0
    else
        return 1
    fi
}


# # Clean docker image and make sure that there are not any further docker related stuff
function cpp_cleanup_lambda(){
    ./SecureExecutor --cpp --lambda-name ${CPP_TEST_NAME} --clean
    if [ $(docker image ls | grep "${CPP_TEST_NAME}" | wc -l) -eq 0 ] ; then return 0
    else return 1 ; fi
}


# Cleanup also lambda sources
function rm_cpp_lambda(){
    rm -rf ./lambdas/cpp/${CPP_TEST_NAME}

    # Check that the new directory created
    if [[ ! -d ./lambda/cpp/${CPP_TEST_NAME} ]] ; then
        return 0
    else
        return 1
    fi
}