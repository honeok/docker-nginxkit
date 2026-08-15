#!/usr/bin/env sh
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2011-2026 Nginx, Inc.
# Copyright (c) 2025-2026 honeok <i@honeok.com>
#
# Based on the NGINX Docker entrypoint script.

set -e

SCRIPT_NAME="$(basename "$0")"
DEFAULT_CONF="/etc/nginx/conf.d/default.conf"

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

# Check if IPv6 is available.
if [ ! -f /proc/net/if_inet6 ]; then
    entrypoint_log "$SCRIPT_NAME: info: IPv6 not available"
    exit 0
fi

# Check if default.conf exists.
if [ ! -f "$DEFAULT_CONF" ]; then
    entrypoint_log "$SCRIPT_NAME: info: $DEFAULT_CONF is not a file or does not exist"
    exit 0
fi

# Check if default.conf can be modified.
touch "$DEFAULT_CONF" 2> /dev/null || {
    entrypoint_log "$SCRIPT_NAME: info: can not modify $DEFAULT_CONF (read-only file system?)"
    exit 0
}

# Avoid modifying it again after restart.
grep -q "listen  \[::\]:80;" "$DEFAULT_CONF" && {
    entrypoint_log "$SCRIPT_NAME: info: IPv6 listen already enabled"
    exit 0
}

# Enable IPv6 on default.conf listen sockets.
sed -i -E 's#listen       80;#listen       80;\n    listen  [::]:80;#' "$DEFAULT_CONF"

entrypoint_log "$SCRIPT_NAME: info: Enabled listen on IPv6 in $DEFAULT_CONF"

exit 0
