FROM traefik:v2.0.0
RUN apk add curl --virtual .build-deps \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    && curl -sL https://github.com/digitalocean/doctl/releases/download/v1.37.0/doctl-1.37.0-linux-amd64.tar.gz | tar -xzv \
    && mv ./kubectl /usr/local/bin/ \
    && mv ./doctl /usr/local/bin/ \
    && apk del .build-deps \
    && apk add bash \
    && chmod -R +x /usr/local/bin/kubectl \
    && mkdir -p /dynamic-config /logs
WORKDIR /loadbalancer
COPY ./*.sh ./
ENV CLUSTER_POLL_DELAY=60

# See: https://doc.traefik.io/traefik/v2.0/https/acme/#dnschallenge for these additional config options
# These params helped fix DNS caching issues causing LetsEncrypt to fail
# See: https://community.traefik.io/t/dnschallenge-sporadically-failing-txt-record-invalid/5543/2 for explanation
ENV GODADDY_POLLING_INTERVAL=30
ENV GODADDY_PROPAGATION_TIMEOUT=1200
ENV NAMECHEAP_POLLING_INTERVAL=30
ENV NAMECHEAP_PROPAGATION_TIMEOUT=1200

ENTRYPOINT ["./entrypoint.sh"]
EXPOSE 80 443
CMD [ ]
