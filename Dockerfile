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
ENTRYPOINT ["./entrypoint.sh"]
EXPOSE 80 443
CMD [ ]
