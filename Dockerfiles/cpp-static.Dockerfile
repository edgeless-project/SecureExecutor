# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/crosscompilers:ubuntu20.04-scone5.9.0

# Install prerequisetes
RUN apt-get -y upgrade && apt-get -y update && \
    apt install -y curl autoconf libtool make cmake build-essential git

# INPUT ARGUMENTS
# During docker build pass those values 
ARG PROJECT_DIR
ARG CONTAINER_PROJECT_DIR

# Copy project files
RUN mkdir -p ${CONTAINER_PROJECT_DIR}/
COPY ${PROJECT_DIR} ${CONTAINER_PROJECT_DIR}/.

RUN printf 'Q 1\ne 0 0 0\ns 1 0 0\n' > /etc/sgx-musl.conf

# Create aliases
RUN echo 'alias gcc="scone-gcc"' >> ~/.bashrc
RUN echo 'alias g++="scone-g++"' >> ~/.bashrc
RUN echo 'alias ld="scone-ld"' >> ~/.bashrc
RUN echo 'alias gdb="scone-gdb"' >> ~/.bashrc

ENV CC="scone-gcc"
ENV CXX="scone-g++"

# Build executable
RUN mkdir -p ${CONTAINER_PROJECT_DIR}/build/
WORKDIR ${CONTAINER_PROJECT_DIR}/build
RUN cmake ..
RUN make

# Run executable
CMD ["./executable"]
