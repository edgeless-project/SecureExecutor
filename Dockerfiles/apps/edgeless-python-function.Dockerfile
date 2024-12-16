# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/apps:python3.10.5-alpine3.15-scone5.8-pre-release

# Input arguments
ARG EDGELESS_FUNCTION_PATH

# ------------------------------------------------------------------------------

# Update system and install needed packages
RUN apk update && apk upgrade && \
    pip install --upgrade pip && \
    apk add gcc gfortran coreutils && \
    apk add python3-dev py3-setuptools && \
    pip install setuptools wheel

# Python packages (see https://sconedocs.github.io/Python/) 
RUN apk add --no-cache bats libbsd openssl musl-dev build-base && \
    apk add --no-cache cairo-dev cairo 

# ------------------------------------------------------------------------------

# EDGELESS specific 
WORKDIR /usr/src/app
COPY ${EDGELESS_FUNCTION_PATH} .
RUN pip3 install --no-cache-dir -r requirements.txt

# ------------------------------------------------------------------------------

# SCONE related 
RUN printf 'Q 4\ne -1 0 0\ns -1 0 0\ne -1 1 0\ns -1 1 0\ne -1 2 0\ns -1 2 0\ne -1 3 0\ns -1 3 0' > /etc/sgx-musl.conf
ENV SCONE_MODE=hw 
ENV SCONE_VERSION=1
ENV SCONE_HEAP=256M
ENV SCONE_ALLOW_DLOPEN=2

# ------------------------------------------------------------------------------

EXPOSE 7101
CMD ["python3", "./src/function.py", "--log-level", "INFO", "--port", "7101", "--max-workers", "10"]