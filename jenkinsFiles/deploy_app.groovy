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
        
        stage('deploy app'){
            steps {
                sh '''     
                    kubectl apply -f  ./kubeFiles/kandula_deploy.yaml
                    kubectl apply -f  ./kubeFiles/kandula_service.yaml
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


