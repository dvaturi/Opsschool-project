node('slave1 || slave2') {
    stage('clone git'){
        git branch: 'main', changelog: false, credentialsId: 'ac634407-8c13-4169-8ac3-029e1967a35c', poll: false, url: 'git@github.com:dvaturi/Opsschool-project.git'
    }
    
    stage('deploy app'){
        kubernetesDeploy configs: 'Opsschool-project/kubeFiles/kandula_service.yaml, Opsschool-project/kubeFiles/kandula_deploy.yaml', kubeConfig: [path: ''], kubeconfigId: 'KubeAccess', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']
    }
}