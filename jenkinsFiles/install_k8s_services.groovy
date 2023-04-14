// install filebaet, node-exporter, 
node('slave1 || slave2') {

    stage('clone git repo'){
        git branch: 'main', changelog: false, credentialsId: 'ac634407-8c13-4169-8ac3-029e1967a35c', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
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