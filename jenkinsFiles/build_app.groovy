node('slave1'){
    def customImage
    def container
    
    stage('clone git repo'){
        git branch: 'main', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:mosheeven/kandula_assignment.git'
    }
    
    stage('build docker image'){
        customImage = docker.build("devmozes/kandula:latest")
    }

    stage('scan image with trivy'){
        sh "trivy image --timeout 5m --exit-code=0 --severity CRITICAL,HIGH,UNKNOWN,LOW,MEDIUM $customImage.id"
    }
    
    stage('run docker'){
       container = customImage.run('-p 5000:5000')
    }
    
    stage('Test application'){
        sh 'sleep 10'
        response = sh (script: 'curl -Is localhost:5000 | head -1 | awk \'{print $2}\'', returnStdout: true).trim()

        if ("$response" == "200"){
            echo "the resonse is ${response}"
            
            withDockerRegistry(credentialsId: '1cb6f268-6712-4a54-b041-7d7989fa1635') {
                customImage.push()
                customImage.push("${BUILD_NUMBER}")
            }
        }
        else{
            container.stop()
            error("application didnt reutrn 200,  $response")
        }
        
    }
    
    stage('clean'){
       container.stop()
    }
    
}