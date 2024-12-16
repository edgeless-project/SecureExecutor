# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM alpine:edge AS rust_build_env

# ==========================================================================
# Bare minimum environment to build RUST images
# ==========================================================================

RUN apk add --no-cache \
    rust \
    cargo \
    bash \
    rustup \
    openssl-dev \
    protoc \
    autoconf \
    automake \
    libtool \
    pkgconfig \
    nasm \
    yasm \
    make \
    clang-dev \
    g++ \
    git \
    shadow \
    su-exec \
    gcompat && \
    ln -s /usr/bin/gcc /usr/bin/musl-gcc && \
    ln -s /usr/bin/g++ /usr/bin/musl-g++ && \
    mkdir -p /work/cli/rust-cli/target && \
    /usr/bin/rustup-init --default-toolchain stable --profile default -y

ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-Ctarget-feature=-crt-static"

# ==========================================================================
# PROTOCOL BUFFER
# ==========================================================================

RUN export PROTOC_VERSION="3.20.3" && \
    wget -q https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip && \
    unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local && \
    export PATH=$PATH:/usr/local/bin

# ==========================================================================
# WEB ASSEMBLY (IMPORTANT! Only wasmi)
# ==========================================================================

RUN rustup target add wasm32-unknown-unknown && \
    cargo install wasm-opt

# ==========================================================================
# Create same user as host device
# In order to fix permission errors
# ==========================================================================

ARG USER_ID=-9001
ARG GROUP_ID=-9001

RUN useradd -u $USER_ID -o -m user && \
    groupmod -g $GROUP_ID user && \
    export HOME=/home/user && \
    su user