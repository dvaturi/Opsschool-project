// install node_exporter, filebeat, config coredns
pipeline {
    agent {
        label 'slaves'
    }
    stages {
        stage('clone git repo'){
            steps {
                git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
            }
        }

        stage("update kubeconfig"){
            steps {
                sh """
                    echo 'updating kubeconfig'
                    aws eks --region=us-east-1 update-kubeconfig --name ${params.CLUSTER_NAME}
                """   
            }
        }
        
        stage('Install node_exporter and filebeat on Kubernetes'){
            steps {
                dir('Opsschool-project/kubeFiles/'){
                    sh '''
                    echo "apply changes for coredns"
                    chmod +x update-coredns-configmap.sh
                    ./update-configmap.sh

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
    
    post {
        success {
            slackSend channel: '#webhooks', color: 'good', message: "${env.JOB_NAME} finished with ${currentBuild.currentResult}: build number#${env.BUILD_NUMBER}"
        }
        failure {
            slackSend channel: '#webhooks', color: 'danger', message: "${env.JOB_NAME} finished with ${currentBuild.currentResult}: build number#${env.BUILD_NUMBER}"
        }
    }
}