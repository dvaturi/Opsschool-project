# run the following after consul is running.
### consul DNS
# install helm pgk for consul
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg=="
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install consul hashicorp/consul -f values_consul.yaml

# run configmap for consul after chagne the svc ip.
kubectl apply -f coredns.yaml 
# validate 
kubectl get configmap kube-dns -n kube-system -o yaml
# update coredns configuration
kubectl edit configmap coredns -n kube-system
    consul {
        errors
        cache 30
        forward . 172.20.101.158
    }
# vertify with 
k apply -f verifyConsulDns.yaml
k logs <nampe pod>
# vertify with curl 
kubectl run curl --rm -i --tty --image tutum/curl -- bash


### node exporter
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install k8s bitnami/node-exporter -f values_node-exporter.yaml

### filebeat 
kubectl apply -f filebeat.yaml
# incase of change in the config map need to restart the pods.
kubectl rollout restart daemonset filebeat



# tests
dig -t a <service-cluster-default>.service.opsschool.consul

kubectl -n kube-system edit configmap coredns -o yaml

    consul {
        errors
        cache 30
        forward . 172.20.190.13
    }


172.20.190.13 = consul-consul-dns ClusterIP