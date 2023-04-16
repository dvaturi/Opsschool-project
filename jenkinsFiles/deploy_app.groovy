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

    stage("slack notification") {
        slackColor = "good"
        end = "success"
        try {
        } catch (Exception e) {
        slackColor = "danger"
        end = "failure"
        currentBuild.result = "FAILURE"
        } finally {
            slackSend color: slackColor, message: "deploy_app finished with ${end}: build number#${env.BUILD_NUMBER}"
        }
    }
}
