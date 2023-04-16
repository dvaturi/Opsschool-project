node('slave1 || slave2') {
    def customImage
    def container
    
    stage('clone git repo'){
        git branch: 'dean-kandula', changelog: false, credentialsId: 'github', poll: false, url: 'git@github.com:dvaturi/kandula-app-9.git'
    }
    
    stage('build docker image'){
        customImage = docker.build("dvaturi/kandula:latest")
    }

    stage('scan image with trivy'){
        sh "trivy image --timeout 5m --exit-code=0 --severity CRITICAL,HIGH,UNKNOWN,LOW,MEDIUM $customImage.id"
    }
    
    stage('run docker'){
       container = customImage.run('-p 5000:5000 -e FLASK_APP="bla" -e SECRET_KEY="bla"')
    }
    
    stage('Test application'){
        sh 'sleep 10'
        response = sh (script: 'curl -Is localhost:5000 | head -1 | awk \'{print $2}\'', returnStdout: true).trim()

        if ("$response" == "200"){
            echo "the resonse is ${response}"
            
            withDockerRegistry(credentialsId: 'dockerhub') {
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
    

    stage("slack notification") {
        slackColor = "good"
        end = "success"
        try {
        } catch (Exception e) {
        slackColor = "danger"
        end = "failure"
        currentBuild.result = "FAILURE"
        } finally {
            slackSend color: slackColor, message: "build finished with ${end}: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        }
    }
    
}