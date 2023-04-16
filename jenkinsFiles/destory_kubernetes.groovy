node('slave1 || slave2') {
    stage('clone git repo'){
        git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
    }

    stage("uninstall kondula app"){
        sh '''
            echo "deleting service & app pods"
            kubectl delete -f .kubeFiles/kandula_service.yaml
            kubectl delete -f .kubeFiles/kandula_deploy.yaml
        '''   
    }

    stage("removing github repo") {
        sh '''
            echo "deleting github repo"
            rm -rf ../Opsschool-project
        '''   
    }
}