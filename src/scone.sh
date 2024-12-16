#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh

export RUST_TRUSTED_BIN_RT_IMG="registry.scontain.com/sconecuratedimages/crosscompilers:ubuntu20.04-scone5.9.0"

# export GDB_DBG_FLAGS="--cap-add SYS_PTRACE"
export GDB_DBG_FLAGS=""

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
                echo_y "Warning: No SGX device found! Will run in SIM mode." > /dev/stderr
                export MOUNT_SGXDEVICE=""
                export SGXDEVICE=""
            fi
        fi
    fi
}

function sconify_execuble(){
    exec_path=$1

    # These are internal variables, all extracted from exec_path
    exec_dir_host="${exec_path%/*}"
    exec_name="${exec_path##*/}"
    exec_dir_cont="/home/user/$(basename "$exec_dir_host")"

    # Determine SGX device
    determine_sgx_device

    # Sconify executable 
    echo_y "- [SCONIFY Executable]"
    echo_y "-  exec_dir_host: ${exec_dir_host}"
    echo_y "-  exec_name: ${exec_name}"
    echo_y "-  exec_dir_cont: ${exec_dir_cont}"

    exec_cmd docker  run --rm -it \
                --platform linux/amd64 \
                ${MOUNT_SGXDEVICE:+"$MOUNT_SGXDEVICE"} \
                -v "${exec_dir_host}":"${exec_dir_cont}" \
                -w="${exec_dir_cont}" \
                --network=host \
                -u "$(id -u "$USER")":"$(id -g "$USER")" \
                ${GDB_DBG_FLAGS:+"$GDB_DBG_FLAGS"} \
                --add-host=host.docker.internal:host-gateway \
                "${RUST_TRUSTED_BIN_RT_IMG}" \
                sh -c "scone-signer sign --sconify --syslibs 1 ./${exec_name}"
    echo_g "Process Completed! ('${exec_path}' is now a secure executable)"
}