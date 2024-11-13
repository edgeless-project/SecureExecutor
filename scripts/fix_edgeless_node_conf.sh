#!/bin/bash

# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

# Fix the IP addresses of EDGELESS node and E-ORC in a default node.toml file. 
# This script requires a single input parameter: E-ORC's IP address. 
# It will then update the IP addresses in the node.toml file accordingly.

# ----------------------------------------------------------------------------

# E-ORC IP address, take it as input argument
ORC_IP=$1

# Find NET_INT IP address and set this IP to EDGELESS node related values
NET_INT="eno1"  # TODO: change this interface for your system
ETH_IP=$(ip addr show ${NET_INT} | awk '/inet /{print $2}' | cut -d/ -f1)

# ----------------------------------------------------------------------------

# Replace 127.0.0.1 with the appropriate value using awk
awk -v eth_ip="$ETH_IP" -v orc_ip="$ORC_IP" '
{
    sub(/agent_url = "http:\/\/127.0.0.1:7021"/, "agent_url = \"http://" eth_ip ":7021\"");
    sub(/invocation_url = "http:\/\/127.0.0.1:7002"/, "invocation_url = \"http://" eth_ip ":7002\"");
    sub(/metrics_url = "http:\/\/127.0.0.1:7003"/, "metrics_url = \"http://" eth_ip ":7003\"");
    sub(/guest_api_host_url = "http:\/\/127.0.0.1:7100"/, "guest_api_host_url = \"http://" eth_ip ":7100\"");

    sub(/orchestrator_url = "http:\/\/127.0.0.1:7011"/, "orchestrator_url = \"http://" orc_ip ":7011\"");
    sub(/http_ingress_url = "http:\/\/127.0.0.1:7035"/, "http_ingress_url = \"http://" eth_ip ":7035\"");
    
    sub(/labels = \[\]/, "labels = [\"nuc-device\"]");
    
    sub(/is_tee_running = false/, "is_tee_running = true");
    print
}
' node.toml > node.toml.bak && mv node.toml.bak node.toml
