# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/crosscompilers:ubuntu20.04-scone5.9.0

# Install prerequisetes
RUN apt-get -y upgrade && apt-get -y update && \
    apt install -y curl autoconf libtool make cmake build-essential git pkg-config libssl-dev

# INPUT ARGUMENTS
# During docker build pass those values 
ARG PROJECT_DIR
ARG CONTAINER_PROJECT_DIR

# Copy project files
RUN mkdir -p ${CONTAINER_PROJECT_DIR}/
COPY ${PROJECT_DIR} ${CONTAINER_PROJECT_DIR}/.

# Build executable
WORKDIR ${CONTAINER_PROJECT_DIR}
RUN scone cargo build --target=x86_64-scone-linux-musl

CMD scone cargo run