#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh

# Test statistics
SUCCEED_TESTS=()
FAILED_TESTS=()
TOTAL_TESTS_CNT=1

function test(){
    echo_y "* ${CLR_YELLOW}[${TOTAL_TESTS_CNT}. NEW TEST]:${CLR_RST} $*"
     
    if "$@" ; then 
        echo_g "====> [SUCCEED] ${*}"
        SUCCEED_TESTS+=("${*}")
    else 
        echo_r "====? [FAILED] ${*}" 
        FAILED_TESTS+=("${*}")
    fi
    TOTAL_TESTS_CNT=$((TOTAL_TESTS_CNT + 1))
    echo
    echo "--------------------------------------------------------------------"
    echo
}

function run_all_tests(){
    echo_y "============ LOCATE ALL TEST FILES ============"
    # If you want, you can only pass specific files to run tests
    if [[ $# -gt 0 ]] ; then
        test_files=("$*")
    # Else run all tests
    else 
        test_files=($(find ./test -name "*.sh" | grep -v run_tests.sh))
    fi

    echo "> Test files found:"
    i=1
    for test_file in ${test_files[@]} ; do
        # shellcheck disable=SC1090
        source "${test_file}"
        echo "   $i) ${test_file}"
        ((i++))
    done
    echo 
    echo 
    
    echo_y "============ LOCATE TEST FUNCTIONS ============"
    test_functions=($(cat ${test_files[*]} | grep -v "#" | grep function | cut -d' ' -f2 | cut -d'(' -f1 ))
    echo "> Test functions found:"
    i=1
    for func in "${test_functions[@]}" ; do
        echo "   $i) ${func}"
        ((i++))
    done
    echo 
    echo 

    echo_y "============ RUN ALL TESTS ============"
    for func in "${test_functions[@]}" ; do
        test "$func" 
    done

    echo 
    echo 
    echo_y "============ STATISTICS ============"
    echo_g "- NUMBER OF SUCCEED TESTS: ${#SUCCEED_TESTS[@]}"
    for i in "${SUCCEED_TESTS[@]}" ; do
        echo_g "   * ${i}()"
    done
    echo_r "- NUMBER OF FAILED TESTS:  ${#FAILED_TESTS[@]}"
    for i in "${FAILED_TESTS[@]}" ; do
        echo_r "   * ${i}()"
    done
    echo   "- TOTAL NUMBER OF TESTS:   $(( TOTAL_TESTS_CNT - 1 ))"

    exit ${#FAILED_TESTS[@]}
}

run_all_tests "$@"