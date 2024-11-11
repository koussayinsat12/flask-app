pipeline {
    environment {
        DOCKER_HUB_REPO = 'kousai12/python-app'
        DOCKER_HUB_CREDENTIALS = 'dockerHub'
        ANSIBLE_SSH_CREDENTIALS = 'ANSIBLE_SSH_KEY'
      
    }
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }

    

        

     
    }
}
