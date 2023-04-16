pipeline {
    agent {
        label 'slave1 || slave2'
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

        stage("uninstall kandula service"){
            steps { 
                sh '''
                    echo "deleting kandula service"
                    if kubectl get svc backend-service -n kandula; then
                    kubectl delete -f ./kubeFiles/kandula_service.yaml -n kandula
                    else
                        echo "kandula service is not available"
                    fi
                '''
            }
        }

        stage("uninstall kandula deployment") {
            steps {
                sh '''
                    echo "deleting kandula deployment"
                    if kubectl get deploy kandula-prod -n kandula; then
                    kubectl delete -f ./kubeFiles/kandula_deploy.yaml  -n kandula
                    else
                        echo "kandula deployment is not available"
                    fi
                '''
            }
        }
    }

    post {
        success {
            slackSend channel: '#webhooks', color: 'good', message: "${env.JOB_NAME} finished with ${currentBuild.currentResult}: build number#${env.BUILD_NUMBER}"
        }
        failure {
            slackSend channel: '#webhooks', color: 'danger', message: "${env.BUILD_NAME} finished with ${currentBuild.currentResult}: build number#${env.BUILD_NUMBER}"
        }
    }
}
