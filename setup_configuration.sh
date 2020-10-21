#! /usr/bin/env bash
configuration=$(cat <<-EOM
[http.middlewares]
  [http.middlewares.https-redirect.redirectscheme]
    scheme = "https"
  [http.middlewares.removewww-redirect.redirectregex]
    regex = "^(https?\\\\://)(?:www\\\\.)+(.+)"
    replacement = "\${1}\${2}"
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

function adddomain()
{
  local domain=$1
  local domain_dash="${domain/\./\-}"
  local cert_resolver=$2
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
      certResolver = "${cert_resolver}"
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
      certResolver = "${cert_resolver}"
      [[http.routers.Route-${domain_dash}-dashboard.tls.domains]]
        main = "dashboard.${domain}"
EOM
)

}

godaddy_domains=(${GODADDY_SUPPORTED_DOMAINS[@]})
for godaddy_domain in ${godaddy_domains[@]}; do
  adddomain $godaddy_domain "godaddy-cert-manager"
done

namecheap_domains=(${NAMECHEAP_SUPPORTED_DOMAINS[@]})
for namecheap_domain in ${namecheap_domains[@]}; do
  adddomain $namecheap_domain "namecheap-cert-manager"
done

echo "$configuration"
echo "$configuration" > /dynamic-config/routers.toml
