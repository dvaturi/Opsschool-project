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

# Extract the Corefile section from the current ConfigMap YAML
corefile=$(echo "$current_config" | awk '/Corefile:/{flag=1;next}/^kind:/{flag=0}flag')

# Append the Consul plugin configuration to the Corefile section
updated_corefile="$corefile
    consul {
        errors
        cache 30
        forward . $consul_dns_ip
    }"

# Create a temporary file with the updated ConfigMap YAML
updated_configmap_file=$(mktemp)
echo "$current_config" | awk -v updated_corefile="$updated_corefile" '/Corefile:/{flag=1;print;next}/^kind:/{flag=0}flag{print updated_corefile}' > "$updated_configmap_file"

# Apply the updated ConfigMap
kubectl apply -f "$updated_configmap_file" -n kube-system

# Clean up the temporary file
rm "$updated_configmap_file"
