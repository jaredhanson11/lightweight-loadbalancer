#! /usr/bin/env bash
./watch_cluster.sh &
default_args=\
"--providers.file=true \
--providers.file.directory=/dynamic-config \
--entrypoints.http.address=:80 \
--entrypoints.https.address=:443"
traefik $default_args $@