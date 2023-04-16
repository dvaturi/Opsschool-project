pipeline {
    agent none
    stages {
        stage('Choose agent') {
            steps {
                script {
                    try {
                        // Try running on slave1
                        agent { label 'slave1' }
                        currentBuild.agentLabel = 'slave1'
                    } catch (Exception e) {
                        // If slave1 is unavailable, run on slave2
                        agent { label 'slave2' }
                        currentBuild.agentLabel = 'slave2'
                    }
                }
            }
        }
        stage('clone git repo'){
            agent { label currentBuild.agentLabel }
            steps {
                git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
            }
        }
        stage("update kubeconfig"){
            agent { label currentBuild.agentLabel }
            steps {
                sh """
                    echo 'updating kubeconfig'
                    aws eks --region=us-east-1 update-kubeconfig --name ${params.CLUSTER_NAME}
                """
            }
        }
        stage("uninstall kandula service"){
            agent { label currentBuild.agentLabel }
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
            agent { label currentBuild.agentLabel }
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
            slackSend channel: '#webhooks', color: 'good', message: '${env.BUILD_NAME} finished with ${end}: build number#${env.BUILD_NUMBER}'
        }
        failure {
            slackSend channel: '#webhooks', color: 'danger', message: '${env.BUILD_NAME} finished with ${end}: build number#${env.BUILD_NUMBER}'
        }
    }
}
