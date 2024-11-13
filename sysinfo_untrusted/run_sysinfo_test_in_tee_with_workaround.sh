#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

# Copy sysinfo_test to lambdas directory
mkdir -p ../lambdas/rust/
cp -r sysinfo_test/ ../lambdas/rust/sysinfo-test 
cp -r ../sysinfo ../lambdas/rust/sysinfo-test/src/sysinfo 

# Edit sysinfo_test/Cargo.toml and add default sysinfo version
sed -i 's/sysinfo = .*/sysinfo = { path = ".\/src\/\/sysinfo" }/' ../lambdas/rust/sysinfo-test/Cargo.toml

# FIXME: this script is not working yet, need to fix openssl issue

# Utilize SecureExecutor to build, run and delete trusted image
cd ..
./SecureExecutor --rust --lambda-name sysinfo-test --build --run --clean
cd -

# # Clean 
rm -rf ../lambdas/rust/sysinfo-test 