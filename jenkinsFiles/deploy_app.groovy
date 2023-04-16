node('slave1 || slave2') {
    stage('clone git repo'){
        git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
    }

    stage("update kubeconfig"){
        sh """
            echo 'updating kubeconfig'
            aws eks --region=us-east-1 update-kubeconfig --name ${params.CLUSTER_NAME}
        """   
    }
    
    stage('deploy app'){
        sh '''     
            kubectl apply -f  ./kubeFiles/kandula_deploy.yaml
            kubectl apply -f  ./kubeFiles/kandula_service.yaml
        '''
    }

    post {
        success {
            slackSend channel: '#webhooks', color: 'good', message: "Deploy_app pipeline for the following cluster ${params.CLUSTER_NAME} completed successfully"
        }
        failure {
            slackSend channel: '#webhooks', color: 'danger', message: "Deploy_app pipeline for the following cluster ${params.CLUSTER_NAME} failed"
        }
    }
}
