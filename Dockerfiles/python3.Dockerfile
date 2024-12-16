# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/apps:python-3.7.3-alpine3.10-scone4

RUN apk update && apk upgrade && \
    pip install --upgrade pip && \
    apk add gcc gfortran coreutils && \
    apk add python3-dev py3-setuptools && \
    pip install setuptools wheel

# Python packages (see https://sconedocs.github.io/Python/) 
RUN apk add --no-cache bats libbsd openssl musl-dev build-base && \
    apk add --no-cache cairo-dev cairo 

RUN printf 'Q 1\ne 0 0 0\ns 1 0 0\n' > /etc/sgx-musl.conf
ENV SCONE_HEAP=256M

# INPUT ARGUMENTS
# During docker build pass those values 
ARG PROJECT_DIR
ARG CONTAINER_PROJECT_DIR

# Copy project files
RUN mkdir -p ${CONTAINER_PROJECT_DIR}/
COPY ${PROJECT_DIR} ${CONTAINER_PROJECT_DIR}

WORKDIR ${CONTAINER_PROJECT_DIR}

# Install requirements if any
RUN pip install --no-cache-dir -r requirements.txt

# SCONE
ENV SCONE_MODE=hw 
ENV SCONE_VERSION=1
ENV SCONE_HEAP=256M
ENV SCONE_ALLOW_DLOPEN=2

# RUN executable
CMD ["python3", "main.py"]
