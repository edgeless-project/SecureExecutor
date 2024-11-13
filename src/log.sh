#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

# Debug 
CLR_RED='\033[0;31m'
CLR_GREEN='\033[0;32m'
CLR_YELLOW='\033[0;33m'
CLR_BOLD_WHITE='\033[1;37m'
CLR_RST='\033[0m'

# DEBUG prints
function echo_r(){ echo -e "${CLR_RED}$@${CLR_RST}"; }
function echo_g(){ echo -e "${CLR_GREEN}$@${CLR_RST}"; }
function echo_y(){ echo -e "${CLR_YELLOW}$@${CLR_RST}"; }
function exec(){
    export PS4='> '
    set -x
    "$@"
    { set +x; } 2>/dev/null  
    # echo
}

function timems(){
    start=$(date +%s%3N)  # Capture start time in milliseconds
    "$@"
    end=$(date +%s%3N)    # Capture end time in milliseconds
    elapsed=$((end - start))  # Calculate elapsed time
    echo 
    echo_g " > Operation completed time elapsed: ${elapsed}ms"
}