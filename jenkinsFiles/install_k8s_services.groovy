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
                sh '''
                echo "apply changes for coredns"
                chmod +x ./kubeFiles/update-coredns-configmap.sh
                ./kubeFiles/update-coredns-configmap.sh --validate=false

                echo "node exporter"
                helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                helm repo update
                helm install  node-exporter prometheus-community/prometheus-node-exporter -n monitoring --values ./kubeFiles/values_node_exporter.yaml

                echo "filebeat"
                kubectl apply -f ./kubeFiles/filebeat.yaml
                ''' 
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