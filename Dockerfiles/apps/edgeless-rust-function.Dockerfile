# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/crosscompilers:ubuntu20.04-scone5.9.0

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
RUN git clone https://github.com/edgeless-project/edgeless.git

# TODO: replace edgeless_container_function with our developed function
WORKDIR /home/edgeless/edgeless_container_function

# Build edgeless_container_function 
RUN scone-cargo build --release --target=x86_64-scone-linux-musl
# ------------------------------------------------------------------------------

# Enviroment variables
ENV RUST_LOG=info
# SCONE related env vars  
ENV SCONE_MODE=hw    
ENV SCONE_VERSION=1  

EXPOSE 7101

#CMD ["/home/edgeless/target/x86_64-scone-linux-musl/release/edgeless_container_function_d", "--endpoint", "http://0.0.0.0:7101/"] 
