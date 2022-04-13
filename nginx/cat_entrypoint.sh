#!/bin/sh
set -e
envsubst '${API_PROXY_PASS}' < /tmp/cat_server_block.conf > /etc/nginx/conf.d/nginx.conf