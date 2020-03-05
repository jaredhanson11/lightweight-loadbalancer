#! /usr/bin/env bash
./setup_configuration.sh
./watch_cluster.sh &
default_args=\
"--api=true \
--api.insecure=true \
--providers.file=true \
--providers.file.directory=/dynamic-config \
--entrypoints.http.address=:80 \
--entrypoints.https.address=:443 \
--entrypoints.rtmp.address=:1935 \
--certificatesresolvers.cert-manager.acme.dnschallenge=true \
--certificatesresolvers.cert-manager.acme.dnschallenge.provider=godaddy \
--certificatesresolvers.cert-manager.acme.email=${LETS_ENCRYPT_EMAIL} \
--certificatesresolvers.cert-manager.acme.storage=/acme-certs/acme.json \
--accesslog.filepath=/logs/access.log"
traefik $default_args $@
