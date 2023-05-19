// install filebaet, node-exporter, 
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

        stage('Install Cosnul on Kubernetes'){
            steps {
                dir('Opsschool-project/kubeFiles/'){
                    sh """ 
                        echo 'Install consul'
                        helm repo add hashicorp https://helm.releases.hashicorp.com
                        helm install --values values.yaml consul hashicorp/consul --create-namespace --namespace consul --version "1.0.0"
                    """
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