# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

# Use this argument to change from prod to dev build (see below)
# Clone edgeless project (prod mode) or copy them (dev mode) from the current directory 
# This way sources can be modified in order to debug or test various aspects of the project
ARG EDGELESS_BUILD_MODE=prod

# ====================================================================
# 0) In either case (prod or dev mode), do some initialization
# ====================================================================
FROM rust_build_env:latest AS rust_base

# Use wasmi as runtime (this fixes default runtime errors, which is a JIT)
ARG NODE_RUNTIME="--no-default-features --features wasmi"

# This can be used to checkout to a specific stable commit
# Useful for trubleshooting/debugging (last checked commint is the one below)
ARG STABLE_COMMIT="81d41455fbddcbdf477037c9dd24889d2c80c0b5"

# ====================================================================
# 1) Developement (Copy edgeless sources from SecureExecutor dir, need to download it first)
# ====================================================================
FROM rust_base AS edgeless-node-dev
COPY ./edgeless/ /home/user/edgeless/

# ====================================================================
# 2) Production (Download edgeless sources from EDGELESS repo) 
# ====================================================================
FROM rust_base AS edgeless-node-prod
WORKDIR /home/user/
RUN git clone https://github.com/edgeless-project/edgeless.git

# ====================================================================
# 3) In either case (prod or dev mode) build the project 
# ====================================================================
FROM edgeless-node-${EDGELESS_BUILD_MODE} AS edgeless_node

# Move to edgeless dir and build edgeless node
WORKDIR /home/user/edgeless/edgeless_node

# This can be used during debugging
# RUN git checkout ${STABLE_COMMIT}

# Minor fix, related to sysinfo crate in edgeless_node when run from inside an enclave
# ====================================================================
RUN sed -i 's/sysinfo = .*/sysinfo = { path = ".\/sysinfo" }/' ./Cargo.toml
COPY ./sysinfo/ /home/user/edgeless/edgeless_node/sysinfo/
# ====================================================================
# RUN sed -i "s/sys.used_memory()/sys.total_memory() - sys.free_memory()/g" ./src/agent/mod.rs

# Build Code
RUN cargo build ${NODE_RUNTIME}
ENV CARGO_TARGET_DIR=/home/user/edgeless/target/

# Change dir ownership to something else than root and create binaries dir
WORKDIR /home/user/
ARG USER_ID=-9001
ARG GROUP_ID=-9001
RUN chown -R $USER_ID:$GROUP_ID /home/user/
RUN mkdir -p /home/user/edgeless_node

ARG CACHEBUST=1
# Create configuration 
RUN bash -c "/home/user/edgeless/target/debug/edgeless_node_d -t /home/user/edgeless/target/debug/node.toml"

EXPOSE 7001
EXPOSE 7011