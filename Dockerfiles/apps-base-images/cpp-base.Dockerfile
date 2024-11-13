# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/crosscompilers:ubuntu20.04-scone5.9.0
# ==================================================================
# These are SCONE related. USE THEM as is for C/C++ programs
RUN printf 'Q 1\ne 0 0 0\ns 1 0 0\n' > /etc/sgx-musl.conf

# Create aliases Environment setup
RUN echo 'alias gcc="scone-gcc"' >> ~/.bashrc
RUN echo 'alias g++="scone-g++"' >> ~/.bashrc
RUN echo 'alias ld="scone-ld"' >> ~/.bashrc
RUN echo 'alias gdb="scone-gdb"' >> ~/.bashrc

# Environment Setup
ENV CC="scone-gcc"
ENV CXX="scone-g++"
# ==================================================================

# Update system
RUN apt update && apt install -y git \
        vim botan curl autoconf libtool \
        make cmake build-essential git \
        wget checkinstall zlib1g-dev