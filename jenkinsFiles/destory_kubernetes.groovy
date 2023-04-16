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

    stage("uninstall kandula service"){
        sh '''
            echo "deleting kandula service"
            if kubectl get svc kandula-service -n your-namespace; then
                kubectl delete svc kandula-service -n your-namespace
            else
                echo "kandula service is not available"
            fi
        '''   
    }

    stage("uninstall kandula deployment") {
        sh '''
            echo "deleting kandula deployment"
            if kubectl get deploy kandula-deployment -n kandula; then
                kubectl delete deploy kandula-deployment -n kandula
            else
                echo "kandula deployment is not available"
            fi
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
            slackSend color: slackColor, message: "Destroy_app finished with ${end}: build number#${env.BUILD_NUMBER}"
        }
    }
}
