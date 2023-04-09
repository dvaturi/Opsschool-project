// install filebaet, node-exporter, 
node('slave1'){

    stage('clone git repo'){
        git branch: 'master', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:mosheeven/final_project.git'
    }

    stage("Install Cosnul on Kubernetes") {
        
            withCredentials([kubeconfigFile(credentialsId: 'KubeAccess', variable: 'KUBECONFIG')]) {
                dir('terraform_final_project/kubeFiles/') {
                    sh '''
                    ls
                    export KUBECONFIG=\${KUBECONFIG}
                    kubectl get pods
                    echo "Install consul"
                    kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg=="
                    helm repo add hashicorp https://helm.releases.hashicorp.com
                    helm install consul hashicorp/consul -f values_consul.yaml
                    '''
                }   
        }
    }
}