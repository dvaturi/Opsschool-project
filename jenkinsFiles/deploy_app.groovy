node('slave1'){
    stage('clone git'){
        git branch: 'master', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:mosheeven/final_project.git'
    }
    
    stage('deploy app'){
        kubernetesDeploy configs: 'terraform_final_project/kubeFiles/kandula_service.yaml, terraform_final_project/kubeFiles/kandula_deploy.yaml', kubeConfig: [path: ''], kubeconfigId: 'KubeAccess', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']
    }
}