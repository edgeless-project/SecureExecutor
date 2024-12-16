#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

# ==================================================================================
# Fix conf files IP addresses
ETH_IP=$(ip addr show eth0 | awk '/inet /{print $2}' | cut -d/ -f1)

# Orchestrator.toml
awk -v eth_ip="$ETH_IP" '
{
    sub(/orchestrator_url = "http:\/\/127.0.0.1:7011"/, "orchestrator_url = \"http://" eth_ip ":7011\"");
    print
}
'   /home/user/edgeless/target/debug/orchestrator.toml > /home/user/edgeless/target/debug/orchestrator.toml.bak && \
    mv /home/user/edgeless/target/debug/orchestrator.toml.bak /home/user/edgeless/target/debug/orchestrator.toml

# Controller.toml
awk -v eth_ip="$ETH_IP" '
{
    sub(/controller_url = "http:\/\/127.0.0.1:7001"/, "controller_url = \"http://" eth_ip ":7001\"");
    sub(/orchestrator_url="http:\/\/127.0.0.1:7011"/, "orchestrator_url=\"http://" eth_ip ":7011\"");
    print
}
'   /home/user/edgeless/target/debug/controller.toml > /home/user/edgeless/target/debug/controller.toml.bak && \
    mv /home/user/edgeless/target/debug/controller.toml.bak /home/user/edgeless/target/debug/controller.toml

# cli.toml
awk -v eth_ip="$ETH_IP" '
{
    sub(/controller_url = "http:\/\/127.0.0.1:7001"/, "controller_url = \"http://" eth_ip ":7001\"");
    print
}
'   /home/user/edgeless/target/debug/cli.toml > /home/user/edgeless/target/debug/cli.toml.bak && \
    mv /home/user/edgeless/target/debug/cli.toml.bak /home/user/edgeless/target/debug/cli.toml


# ==================================================================================

# Install tmux to run these services
apk add tmux

# Basic tmux configuration
echo "
set -g prefix C-y
bind C-y send-prefix
unbind C-b
set -g mouse on
" > ~/.tmux.conf

# ---------------
# Start services
# ---------------

# Create panes
tmux -2 new-session -d -s "EDGELESS"
tmux split-window -v
tmux split-window -v

# Pane 0 -> e-Con
tmux select-pane -t 0
tmux send-keys "PS1='> e-CON: '" C-m
tmux send-keys "clear" C-m
tmux send-keys 'RUST_LOG=info ./edgeless_con_d'
tmux select-pane -t 0 -T 'e-CON'

# Pane 1 -> e-Orc
tmux select-pane -t 1
tmux send-keys "PS1='> e-ORC: '" C-m
tmux send-keys "clear" C-m
tmux send-keys 'RUST_LOG=info ./edgeless_orc_d'
tmux select-pane -t 1 -T 'e-ORC'

# Pane 2 -> CLI
tmux select-pane -t 2
tmux send-keys "PS1='> CLI: '" C-m
tmux send-keys "clear" C-m
tmux send-keys "echo ${ETH_IP}" C-m
tmux send-keys "UUID=$(./edgeless_cli workflow start ../../examples/noop/workflow.json)"
tmux select-pane -t 2 -T 'CLI'

tmux select-window -t "EDGELESS"
tmux -2 attach-session -t "EDGELESS"
