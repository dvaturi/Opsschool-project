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
            if kubectl get svc kandula-service; then
                kubectl delete -f ./kubeFiles/kandula_service.yaml
            else
                echo "kandula service is not available"
            fi
        '''   
    }

    stage("uninstall kandula deployment") {
        sh '''
            echo "deleting kandula deployment"
            if kubectl get deploy kandula-deployment; then
                kubectl delete -f ./kubeFiles/kandula_deploy.yaml
            else
                echo "kandula deployment is not available"
            fi
        '''   
    }

    stage("removing github repo") {
        sh '''
            echo "deleting github repo"
            rm -rf ../Opsschool-project
        '''   
    }
}
