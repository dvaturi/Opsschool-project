node('slave1 || slave2') {
    stage('clone git'){
        git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
    }
    
    stage('deploy app'){
        steps {
            sh '''     
                kubectl apply -f  ./Opsschool-project/kubeFiles/kandula_deploy.yaml
                kubectl apply -f  ./Opsschool-project/kubeFiles/kandula_service.yaml
            '''
        }
    }
}