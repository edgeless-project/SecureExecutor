#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

function determine_sgx_device {                                                             
    export SGXDEVICE="/dev/sgx_enclave"                                                     
    export MOUNT_SGXDEVICE="--device=/dev/sgx_enclave"                                      
    if [[ ! -e "$SGXDEVICE" ]] ; then                                                       
        export SGXDEVICE="/dev/sgx"                                                         
        export MOUNT_SGXDEVICE="--device=/dev/sgx"                                          
        if [[ ! -e "$SGXDEVICE" ]] ; then                                                   
            export SGXDEVICE="/dev/isgx"                                                    
            export MOUNT_SGXDEVICE="--device=/dev/isgx"                                     
            if [[ ! -c "$SGXDEVICE" ]] ; then                                               
                echo "Warning: No SGX device found! Will run in SIM mode." > /dev/stderr  
                export MOUNT_SGXDEVICE=""                                                   
                export SGXDEVICE=""                                                         
            fi                                                                              
        fi                                                                                  
    fi                                                                                      
}                                                                                           
# Debug 
CLR_RED='\033[0;31m'
CLR_GREEN='\033[0;32m'
CLR_YELLOW='\033[0;33m'
CLR_RST='\033[0m'

# DEBUG prints
function echo_r(){ echo -e "${CLR_RED}$*${CLR_RST}"; }
function echo_g(){ echo -e "${CLR_GREEN}$*${CLR_RST}"; }
function echo_y(){ echo -e "${CLR_YELLOW}$*${CLR_RST}"; }

echo_y "========================================================================"
echo_y "* Determine SGX device..."
determine_sgx_device
echo "  > export SGXDEVICE=$SGXDEVICE"
echo "  > export MOUNT_SGXDEVICE=$MOUNT_SGXDEVICE"

echo_y "========================================================================"
echo_y "* Start LAS..."
docker compose up -d las

echo_y "========================================================================"
echo_y "* LAS IP and PORT:"
LAS_IP=$(docker ps | grep registry.scontain.com/sconecuratedimages/las | awk '{print $1}' | xargs docker inspect | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep "IPAddress" | tr -d '"' | tr -d ',' | tr -d ' ' | cut -d':' -f2)
LAS_PORT=18766

echo "   From [registry.scontain.com/sconecuratedimages/crosscompilers:runtime] connect to [registry.scontain.com/sconecuratedimages/las] via running this command:"
echo "   $ scone las probe --las ${LAS_IP}:${LAS_PORT}"

echo_y "========================================================================"
echo_y "* Verify that LAS is running..."
docker container ls | grep las

echo_y "========================================================================"
echo_y "* Run Attestation from a different container that has scone utility"
docker run --device=/dev/isgx -it --rm --net=host registry.scontain.com/sconecuratedimages/crosscompilers:runtime-scone5.9.0 bash -c "scone las probe --las ${LAS_IP}:${LAS_PORT}"

echo_y "========================================================================"
echo_y "* Stop LAS container"
docker compose down
