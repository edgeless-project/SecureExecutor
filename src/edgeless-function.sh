#!/bin/bash

source ./src/log.sh

function download_rust_function(){
    git clone https://github.com/edgeless-project/edgeless.git --depth 1
    cp -r ./edgeless/edgeless_container_function/* .
    rm -rf ./edgeless
}

function download_python_function(){
    git clone https://github.com/edgeless-project/runtime-python.git --depth 1
    mv ./runtime-python/* .
    rm -rf ./runtime-python
    rm ./Dockerfile
    mv ./requirements.txt ./requirements.txt.bak
    echo "# Due to dependency issues, do not put version numbers in the requirements.txt file" >> ./requirements.txt
    cut -d'=' -f 1 < ./requirements.txt.bak >> ./requirements.txt
    rm -rf requirements.txt.bak
    ./scripts/compile-proto.sh
}

function edgeless_function_new(){
    # Input arguments
    local function_lang=$1
    local function_name=$2

    local function_dir="./edgeless_function/${function_lang}/${function_name}"
    
    # If another function already exists, delete it 
    rm -rf "${function_dir}"

    # Create new function placeholder
    mkdir -p "${function_dir}"

    # Download from the edgeless organization the appropriate function code
    echo_y "- Created new ${function_lang} function: [${function_name}] ..."
    pushd "${function_dir}" > /dev/null || exit
    if [ "${function_lang}" == "rust" ]; then
        download_rust_function
    elif [ "${function_lang}" == "python" ]; then
        download_python_function
    fi
    popd > /dev/null || exit

    # Log message
    echo_g "- Operation completed! You can now find function sources at: ${function_dir}"
    exit 0
}

function edgeless_function_build(){
    # Input arguments
    local function_lang=$1
    local function_name=$2

    # Set needed parameters
    local image_name="edgeless-sgx-function-${function_lang}-${function_name}:latest"
    local function_dir="./edgeless_function/${function_lang}/${function_name}"
    local dockerfile="Dockerfiles/apps/edgeless-${function_lang}-function.Dockerfile"

    # Ensure that function directory exists
    echo_y "- Build trusted image of function: [${function_name}] ..."
    if [ ! -d "${function_dir}" ]; then
        echo_r "[ERROR] Function directory does not exist: ${function_dir}"
        echo "Please create first a new function titled: [${function_name}]"
        return 1
    fi
    
    # Delete image if already exists
    docker image rm -f "${image_name}" > /dev/null

    # Build image 
    if docker build -t "${image_name}" --no-cache --build-arg EDGELESS_FUNCTION_PATH="${function_dir}" -f "${dockerfile}" . ; then
        echo_g "- Operation completed! Image created: [${image_name}]"
    else
        echo_r "- [ERROR] Operation failed!"
    fi

    exit 0
}