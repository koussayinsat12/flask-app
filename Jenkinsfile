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

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    script {
                        docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
                            docker.image("${DOCKER_HUB_REPO}:latest").push()
                        }
                    }
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: ANSIBLE_SSH_CREDENTIALS, keyFileVariable: 'SSH_KEY')]) {
                    withKubeConfig(
                        clusterName: 'minikube', 
                        contextName: 'minikube', 
                        credentialsId: 'minikube-jenkins-secret', 
                        serverUrl: 'https://192.168.49.2:8443'
                    ) {
                       
                            sh '''
                            ansible-playbook -i /var/lib/jenkins/workspace/pipeline-tp/ansible/inventory.yaml /var/lib/jenkins/workspace/pipeline-tp/ansible/deploy.yaml
                            '''
                        
                    }
                }
            }
        }
    }
}
