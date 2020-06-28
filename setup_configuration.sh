#! /usr/bin/env bash
configuration=$(cat <<-EOM
[http.middlewares]
  [http.middlewares.https-redirect.redirectscheme]
    scheme = "https"
  [http.middlewares.removewww-redirect.redirectregex]
    regex = "^(https?\\\\://)(?:www\\\\.)+(.+)"
    replacement = "${1}${2}"
    permanent = true
  [http.middlewares.basic-auth.basicAuth]
    users = [
      "endergyAdmin:{SHA}QTuQPWM/ZZ11WLPWdAgW9jT9FM0="
    ]
[http.services]
  [http.services.local-redirect.LoadBalancer]
    [[http.services.local-redirect.LoadBalancer.servers]]
      url = ""
  [http.services.traefik-dashboard.LoadBalancer]
    [[http.services.traefik-dashboard.LoadBalancer.servers]]
      url = "http://localhost:8080"

[http.routers]
EOM
)

domains=(${SUPPORTED_DOMAINS[@]})
for domain in ${domains[@]}; do
domain_dash="${domain/\./\-}"
configuration+=$(cat <<-EOM

  [http.routers.Route-${domain_dash}-insecure]
    entryPoints = ["http"]
    rule = "HostRegexp(\`${domain}\`, \`{subdomain:.*}.${domain}\`)"
    middlewares = ["https-redirect"]
    service = "local-redirect"
  [http.routers.Route-${domain_dash}]
    entryPoints = ["https"]
    rule = "HostRegexp(\`${domain}\`, \`{subdomain:.*}.${domain}\`)"
    middlewares = ["removewww-redirect"]
    service = "ingress-controller"
    [http.routers.Route-${domain_dash}.tls]
      certResolver = "cert-manager"
      [[http.routers.Route-${domain_dash}.tls.domains]]
        main = "${domain}"
        sans = ["*.${domain}"]
  [http.routers.Route-${domain_dash}-dashboard]
    entryPoints = ["https"]
    rule = "Host(\`dashboard.${domain}\`)"
    service = "traefik-dashboard"
    middlewares = ["basic-auth"]
    priority = 1000
    [http.routers.Route-${domain_dash}-dashboard.tls]
      certResolver = "cert-manager"
      [[http.routers.Route-${domain_dash}-dashboard.tls.domains]]
        main = "dashboard.${domain}"
EOM
)
done
configuration+=$(cat <<-EOM

[tcp.routers]
  [tcp.routers.Route-${domain_dash}]
    entryPoints = ["rtmp"]
    rule = "HostSNI(\`*\`)"
    service = "rtmp-ingress"
EOM
)

echo "$configuration"
echo "$configuration" > /dynamic-config/routers.toml
