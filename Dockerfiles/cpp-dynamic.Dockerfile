# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/crosscompilers:runtime-scone5.9.0

# Install prerequisetes
RUN apk upgrade && apk update 

RUN printf 'Q 1\ne 0 0 0\ns 1 0 0\n' > /etc/sgx-musl.conf

# INPUT ARGUMENTS
# During docker build pass those values 
ARG CONTAINER_PROJECT_DIR
ARG PROJECT_DIR

# Copy project files
RUN mkdir -p ${CONTAINER_PROJECT_DIR}/
WORKDIR ${CONTAINER_PROJECT_DIR}/
COPY ${PROJECT_DIR}/build/* .

# Run executable
CMD ["./executable"]
