# After running Jobs run the following manual steps.
1. get the consul svc ip. 
```bash
kubectl get svc
```
2. update the value in. kubeFiles/coredns.yaml and apply the file.
3. update the configmap coredns.
```
    kubectl edit configmap coredns -n kube-system
    consul {
        errors
        cache 30
        forward . <svc-ip>
    }
```