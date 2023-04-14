// install filebaet, node-exporter, 
node('slave1 || slave2') {

    stage('clone git repo'){
        git branch: 'main', changelog: false, credentialsId: 'ac634407-8c13-4169-8ac3-029e1967a35c', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
    }

    stage("Install Cosnul on Kubernetes") {
        
            withCredentials([kubeconfigFile(credentialsId: 'KubeAccess', variable: 'KUBECONFIG')]) {
                dir('Opsschool-project/kubeFiles/') {
                    sh '''
                    export KUBECONFIG=\${KUBECONFIG}
                    kubectl get pods
                    echo "Install consul"
                    helm delete consul
                    kubectl delete secret consul-gossip-encryption-key

                    echo "delete coredns"
                    kubectl delete -f coredns.yaml

                    echo "delete node exporter"
                    helm delete k8s 

                    echo "delete filebeat"
                    kubectl delete -f filebeat.yaml

                    echo "delete service & app pods"
                    kubectl delete -f kandula_service.yaml
                    kubectl delete -f kandula_deploy.yaml
                    '''
                }   
        }
    }
}