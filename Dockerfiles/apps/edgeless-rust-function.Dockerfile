# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/crosscompilers:ubuntu20.04-scone5.9.0

# Input arguments
ARG EDGELESS_FUNCTION_PATH

# Update system
RUN apt-get update -y 
RUN apt-get install -y git curl unzip

# Install version 3.20.0 of protobuf  
WORKDIR /home
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/protoc-3.20.3-linux-x86_64.zip 
RUN unzip protoc-3.20.3-linux-x86_64.zip -d /home/.local
RUN cp /home/.local/bin/protoc /usr/bin/protoc
RUN cp -r /home/.local/include/google /usr/include/ 

# ------------------------------------------------------------------------------
# Download edgeless code
WORKDIR /home/
# Get from GitHub the MVP and remove the default edgeless_container_function implementation
RUN git clone https://github.com/edgeless-project/edgeless.git
RUN rm -rf /home/edgeless/edgeless_container_function

# Copy the developer edgeless_container_function implementation into the image
COPY ${EDGELESS_FUNCTION_PATH} /home/edgeless/edgeless_container_function

# Build edgeless_container_function 
WORKDIR /home/edgeless/edgeless_container_function
RUN scone-cargo build --release --target=x86_64-scone-linux-musl
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# SCONE related ENV variables
ENV SCONE_MODE=hw
ENV SCONE_VERSION=1  
# ------------------------------------------------------------------------------

# ENV PORT=7101
ENV RUST_LOG=info
EXPOSE 7101
CMD ["/home/edgeless/target/x86_64-scone-linux-musl/release/edgeless_container_function_d", "--endpoint", "http://0.0.0.0:7101/"] 
