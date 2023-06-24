#!/bin/bash

# Get the IP address of the consul-dns service
consul_dns_ip=$(kubectl get svc consul-consul-dns -n consul -o jsonpath='{.spec.clusterIP}')

#!/bin/bash

# Get the IP address of the consul-dns service
consul_dns_ip=$(kubectl get svc consul-consul-dns -n consul -o jsonpath='{.spec.clusterIP}')

# Exit if the consul-dns IP address is not found
if [ -z "$consul_dns_ip" ]; then
  echo "Error: Unable to retrieve consul-dns IP address."
  exit 1
fi

# Get the current CoreDNS ConfigMap YAML
current_config=$(kubectl get configmap coredns -n kube-system -o yaml)

# Update the Corefile section in the current ConfigMap YAML
updated_config=$(echo "$current_config" | awk 'NR==18{print "    consul {\n        errors\n        cache 30\n        forward . '"$consul_dns_ip"'\n    }"}1')

# Apply the updated ConfigMap
echo "$updated_config" | kubectl apply -f - -n kube-system
