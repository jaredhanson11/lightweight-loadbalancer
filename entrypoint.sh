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
--certificatesresolvers.godaddy-cert-manager.acme.dnschallenge=true \
--certificatesresolvers.godaddy-cert-manager.acme.dnschallenge.provider=godaddy \
--certificatesresolvers.godaddy-cert-manager.acme.email=${LETS_ENCRYPT_EMAIL} \
--certificatesresolvers.godaddy-cert-manager.acme.storage=/acme-certs/acme.json \
--certificatesresolvers.namecheap-cert-manager.acme.dnschallenge=true \
--certificatesresolvers.namecheap-cert-manager.acme.dnschallenge.provider=namecheap \
--certificatesresolvers.namecheap-cert-manager.acme.email=${LETS_ENCRYPT_EMAIL} \
--certificatesresolvers.namecheap-cert-manager.acme.storage=/acme-certs/namecheap-acme.json \
--accesslog.filepath=/logs/access.log"
traefik $default_args $@
