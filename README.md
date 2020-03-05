# Lightweight Load Balancer

## Overview

Why should I pay for a managed load balancer when I don't (at this point), need the elastic scalability or throughput provided by those managed services? All I really need from a cloud provider's managed load balancer is the static IP address as ingress to my cluster, which can easily be provided by a droplet (or ec2, etc.) instance. Then I can use my droplet for load balancing and other compute tasks, all for cheaper than the elastic load balancer provided by DO.

This small load balancer replaces Digital Ocean's managed load balancer and exposes traffic into a kubernetes clusters.
Lightweight load balancer will forward traffic from to an ingress-controller running inside the kuberenetes cluster.
The lightweight load balancer will load balance all traffic to all the worker nodes in my kuberenetes cluster. It's understood that the ingress controller will be exposed from the cluster (via NodePort) at a configured port.

Currently this is only configured to work with Digital Ocean, though it should be easy to add other cloud providers.

## Required Params

Currently these are all required. Work should be done to make many of these optional, and not break when they aren't supplied. Without supplying all of these credentials, the load balancer can't be expected to work properly.

```bash
### Domains ###
# Domains to route to K8s ingress
# Note, all subdomains (ie. *.example.com) are routed by default
SUPPORTED_DOMAINS=<space separated list>

### Cluster info ###
# NodePort that ingress controller is running in cluster
INGRESS_CONTROLLER_NODE_PORT
# Used for "kubectl get nodes | grep externalIP's"
DIGITALOCEAN_CLUSTER_NAME=<cluster-name>
DIGITALOCEAN_ACCESS_TOKEN=<access_token>
# How often to poll for worker node IP's
CLUSTER_POLL_DELAY=<number-of-seconds>

### SSL certs ###
# Used for registering SSL certs
LETS_ENCRYPT_EMAIL=<email>
# Used for dnschallenge to get SSL certs
GODADDY_API_KEY=<key>
GODADDY_API_SECRET=<secret>
```

## Sample Usage

Strongly suggested that `-v /local-path/to/certs:/acme-certs/` is used to persist SSL certificates so you don't have to perform a dns challenge everytime you start the load balancer.

I run the following command on my droplet that I want to act as ingress to my kuberenetes cluster.

I helm install the `stable/nginx-ingress` chart into the cluster `endergy-cluster-1`, ensureing that I expose my service as a NodePort and not LoadBalancer so that DO doens't auto create an ingress.

```bash
docker run -d -it -p 443:443 -p 80:80 -p 1935:1935 \
    -v ${HOME}/.endergy-data/acme-certs/:/acme-certs/ \
    -e INGRESS_CONTROLLER_NODE_PORT=30269 \
    -e RTMP_NODE_PORT=30268 \
    -e DIGITALOCEAN_CLUSTER_NAME=endergy-cluster-1 \
    -e CLUSTER_POLL_DELAY=300 \
    -e SUPPORTED_DOMAINS="endergy.info endergy.co" \
    -e DIGITALOCEAN_ACCESS_TOKEN=$DO_ACCESS_TOKEN \
    -e GODADDY_API_KEY=$GODADDY_API_KEY \
    -e GODADDY_API_SECRET=$GODADDY_API_SECRET \
    -e LETS_ENCRYPT_EMAIL=jred0011@gmail.com \
    jaredhanson11/lightweight-load-balancer:latest
```

# ToDo's

- Option for SSL pass through. Currently, the lightweight-load-balancer terminates SSL and forwards requests to the ingress controller in plain http. There should be an option where the ingress controller handles decrypting the SSL request, and this load balancer passes the encrypted request to that ingress-controller.
- Take as input a dashboard user and password. Currently the user/pass is hardcoded and so without forking the repo, other's can't add their own user/pass to access their traefik dashboard.
