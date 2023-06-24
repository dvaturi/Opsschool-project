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
updated_config=$(echo "$current_config" | awk -v consul_dns_ip="$consul_dns_ip" '/Corefile:/{flag=1;print;next}/^kind:/{flag=0}flag{print}END{print "    consul {\n        errors\n        cache 30\n        forward . " consul_dns_ip "\n    }"}')

# Apply the updated ConfigMap
echo "$updated_config" | kubectl apply -f - -n kube-system

# Create a temporary file with the updated ConfigMap YAML
updated_configmap_file=$(mktemp)
echo "$current_config" | awk -v updated_corefile="$updated_corefile" '/Corefile:/{flag=1;print;next}/^kind:/{flag=0}flag{print updated_corefile}' > "$updated_configmap_file"

# Apply the updated ConfigMap
kubectl apply -f "$updated_configmap_file" -n kube-system

# Clean up the temporary file
rm "$updated_configmap_file"
