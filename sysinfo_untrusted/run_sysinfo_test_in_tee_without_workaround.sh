#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

# Copy sysinfo_test to lambdas directory
mkdir -p ../lambdas/rust/
cp -r sysinfo_test/ ../lambdas/rust/sysinfo-test 

# Edit sysinfo_test/Cargo.toml and add default sysinfo version
sed -i 's/sysinfo = .*/sysinfo = "0.32.0"/' ../lambdas/rust/sysinfo-test/Cargo.toml

# Minor fix
sed -i "s/sys.used_memory()/sys.total_memory() - sys.free_memory()/g" ../lambdas/rust/sysinfo-test/src/main.rs

# Utilize SecureExecutor to build, run and delete trusted image
cd ..
./SecureExecutor --rust --lambda-name sysinfo-test --build --run --clean
cd -

# Clean 
rm -rf ../lambdas/rust/sysinfo-test 