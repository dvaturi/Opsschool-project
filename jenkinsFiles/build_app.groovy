pipeline {
    agent {
        node {
            label 'slave1 || slave2'
        }
    }
    environment {
        customImage = ''
        container = ''
    }
    stages {
        stage('clone git repo'){
            steps {
                git branch: 'dean-kandula', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/kandula-app-9.git'
            }
        }
        stage('build docker image'){
            steps {
                script {
                    customImage = docker.build("dvaturi/kandula:latest")
                }
            }
        }
        stage('scan image with trivy'){
            steps {
                sh "trivy image --timeout 5m --exit-code=0 --severity CRITICAL,HIGH,UNKNOWN,LOW,MEDIUM $customImage.id"
            }
        }
        stage('run docker'){
            steps {
                script {
                    container = customImage.run('-p 5000:5000 -e FLASK_APP="bla" -e SECRET_KEY="bla"')
                }
            }
        }
        stage('Test application'){
            steps {
                script {
                    sh 'sleep 10'
                    response = sh (script: 'curl -Is localhost:5000 | head -1 | awk \'{print $2}\'', returnStdout: true).trim()

                    if ("$response" == "200"){
                        echo "the response is ${response}"

                        withDockerRegistry(credentialsId: 'dockerhub') {
                            customImage.push()
                            customImage.push("${BUILD_NUMBER}")
                        }
                    }
                    else{
                        container.stop()
                        error("application didn't return 200,  $response")
                    }
                }
            }
        }
        stage('clean'){
            steps {
                script {
                    container.stop()
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
