// install filebaet, node-exporter, 
node('slave1'){

    stage('clone git repo'){
        git branch: 'master', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:mosheeven/final_project.git'
    }

    stage("Install Cosnul on Kubernetes") {
        
            withCredentials([kubeconfigFile(credentialsId: 'KubeAccess', variable: 'KUBECONFIG')]) {
                dir('terraform_final_project/kubeFiles/') {
                    sh '''
                    export KUBECONFIG=\${KUBECONFIG}
                    echo "apply changes for coredns"
                    kubectl apply -f coredns.yaml

                    echo "node exporter"
                    helm repo add bitnami https://charts.bitnami.com/bitnami
                    helm install k8s bitnami/node-exporter -f values_node-exporter.yaml  

                    echo "filebeat"
                    kubectl apply -f filebeat.yaml
                    '''
                }   
        }
    }
}