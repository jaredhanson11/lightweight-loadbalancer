#! /usr/bin/env bash
_sleep() { sleep $CLUSTER_POLL_DELAY; }

if [[ -z "$INGRESS_CONTROLLER_NODE_PORT" || -z "$DIGITALOCEAN_ACCESS_TOKEN" || -z "$DIGITALOCEAN_CLUSTER_NAME" ]]; then
    echo "DIGITALOCEAN_ACCESS_TOKEN is required."
    echo "DIGITALOCEAN_CLUSTER_NAME is required."
    echo "INGRESS_CONTROLLER_NODE_PORT is required."
    exit 1
fi

doctl auth init
doctl kubernetes cluster kubeconfig save $DIGITALOCEAN_CLUSTER_NAME

while true; do
    echo "$(date): Checking for new nodes."
    ips=($(kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address}))
    if [[ "${ips[@]}" == "${last_run[@]}" || ${#ips[@]} -eq 0 ]]; then
        echo "$(date): No new nodes."
        _sleep
        continue
    fi
    last_run=(${ips[@]})

    load_balancer=$(cat <<-EOM
[http.services]
  [http.services.ingress-controller.loadBalancer]
    passHostHeader = true
    [http.services.ingress-controller.loadBalancer.healthCheck]
      path = "/healthz"
EOM
)
    for ip in ${ips[@]}; do
        load_balancer+=$(cat <<-EOM

    [[http.services.ingress-controller.loadBalancer.servers]]
      url = "http://$ip:$INGRESS_CONTROLLER_NODE_PORT/"
EOM
)
    done

echo "$(date): New config generated."
echo "$load_balancer"
echo "$load_balancer" > /dynamic-config/loadbalancer.toml
_sleep
done