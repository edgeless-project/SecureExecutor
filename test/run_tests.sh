#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

source ./src/log.sh

SUCCEED_TESTS=0
FAILED_TESTS=0
TOTAL_TESTS=1
function test(){
    echo_y "* ${CLR_YELLOW}[${TOTAL_TESTS}. NEW TEST]:${CLR_RST} $@"
    "$@" 
    if [[ $? -eq 0 ]] ; then 
        echo_g "====> [SUCCEED] ${@}"
        SUCCEED_TESTS=$((SUCCEED_TESTS + 1))
    else 
        echo_r "====? [FAILED] ${@}" 
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo
    echo "--------------------------------------------------------------------"
    echo
}

function run_all_tests(){
    echo_y "============ LOCATE ALL TESTS ============"
    # If you want, you can only pass a single file to run tests
    if [[ $# -gt 0 ]] ; then
        test_files="$@"
    # Else run all tests
    else 
        test_files=$(find ./test -name "*.sh" | grep -v run_tests.sh)
    fi

    echo "> Test files found:"
    echo "${test_files}" | tr ' ' '\n'
    for test_file in ${test_files} ; do
        source ${test_file}
    done

    echo 
    echo 
    echo_y "============ LOCATE TEST FUNCTIONS ============"
    test_functions=$(cat $test_files | grep -v "#" | grep function | cut -d' ' -f2 | cut -d'(' -f1 )
    echo "> Test functions found:"
    echo "${test_functions}" | tr ' ' '\n'

    echo 
    echo 
    echo_y "============ RUN ALL TESTS ============"
    for func in ${test_functions} ; do
        test $func 
    done

    echo 
    echo 
    echo_y "============ STATISTICS ============"
    echo_g "- NUMBER OF SUCCEED TESTS: ${SUCCEED_TESTS}"
    echo_r "- NUMBER OF FAILED TESTS:  ${FAILED_TESTS}"
    echo   "- TOTAL NUMBER OF TESTS:   $(( ${TOTAL_TESTS} - 1 ))"
}

run_all_tests $@