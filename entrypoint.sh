#!/bin/sh
#
# Copyright (C) 2023 James Fuller, <jim@webcomposite.com>, et al.
#
# SPDX-License-Identifier: MIT
#
# Copied from official curl docker image:
# https://github.com/curl/curl-container/blob/main/etc/entrypoint.sh
# with the only modification being the shellcheck suppression

set -e

# shellcheck disable=SC2312
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- curl "$@"
fi

exec "$@"
