# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM rust_build_env:latest

# This is a stable version of edgeless
ARG STABLE_COMMIT="ab613bd0f20f6574855278b4239a1b5ebdfa69a3"

# Clone edgeless project
WORKDIR /home/user
RUN git clone https://github.com/edgeless-project/edgeless.git 

# Build whole edgeless project
WORKDIR /home/user/edgeless/
RUN git checkout ${STABLE_COMMIT}
RUN cargo build

# ARG CACHEBUST=1

# Create configuration files
RUN bash -c "/home/user/edgeless/target/debug/edgeless_orc_d -t /home/user/edgeless/target/debug/orchestrator.toml"
RUN bash -c "/home/user/edgeless/target/debug/edgeless_con_d -t /home/user/edgeless/target/debug/controller.toml"
RUN bash -c "/home/user/edgeless/target/debug/edgeless_cli -t /home/user/edgeless/target/debug/cli.toml"

# Build example workflows
WORKDIR /home/user/edgeless/target/debug/
RUN bash -c "./edgeless_cli function build ../../examples/noop/noop_function/function.json"
RUN bash -c "./edgeless_cli function build ../../examples/ping_pong/ping/function.json"
RUN bash -c "./edgeless_cli function build ../../examples/ping_pong/pong/function.json"

# Copy configuration fix script USE THIS ONLY FOR DEBUG!!!
COPY ../../test/run_edgeless_system.sh /home/user/edgeless/target/debug/

EXPOSE 7001
EXPOSE 7011
