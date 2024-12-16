# SPDX-FileCopyrightText: © 2024 Technical University of Crete
# SPDX-License-Identifier: MIT

FROM registry.scontain.com/sconecuratedimages/apps:python3.10.5-alpine3.15-scone5.8-pre-release

RUN apk update && apk add --no-cache git vim

RUN printf 'Q 4\ne -1 0 0\ns -1 0 0\ne -1 1 0\ns -1 1 0\ne -1 2 0\ns -1 2 0\ne -1 3 0\ns -1 3 0' > /etc/sgx-musl.conf