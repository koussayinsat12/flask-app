pipeline {
    agent any

    environment {
        PATH = "/usr/bin:$PATH" // Update if Azure CLI is installed elsewhere
        DOCKER_HUB_REPO = 'kousai12/python-app'
        DOCKER_HUB_CREDENTIALS = 'dockerHub'
        RESOURCE_GROUP = 'devops' // Set the resource group name
        DOCKER_IMAGE = "kousai12/python-app:latest"
    }

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
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    script {
                        docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDENTIALS}") {
                            docker.image("${DOCKER_HUB_REPO}:latest").push()
                        }
                    }
                }
            }
        }

        stage('Setup Terraform') {
            steps {
                sh '''
                terraform init
                '''
            }
        }
        stage('Validate Terraform') {
            steps {
                sh '''
                terraform validate
                '''
            }
        }

        stage('Check Resource Group') {
            steps {
                withCredentials([
                    azureServicePrincipal(
                        credentialsId: 'AZURE_CREDENTIALS',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'
                    )
                ]) {
                    sh '''
                    az login --service-principal \
                        --username "$AZURE_CLIENT_ID" \
                        --password "$AZURE_CLIENT_SECRET" \
                        --tenant "$AZURE_TENANT_ID"
                    
                    az group show --name ${RESOURCE_GROUP} --query name --output tsv 2>/dev/null || echo "Resource group does not exist"
                    '''
                }
            }
        }

        stage('Plan Infrastructure') {
            steps {
                withCredentials([
                    azureServicePrincipal(
                        credentialsId: 'AZURE_CREDENTIALS',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'
                    )
                ]) {
                    sh '''
                    export TF_VAR_client_id="$AZURE_CLIENT_ID"
                    export TF_VAR_client_secret="$AZURE_CLIENT_SECRET"
                    export TF_VAR_subscription_id="$AZURE_SUBSCRIPTION_ID"
                    export TF_VAR_tenant_id="$AZURE_TENANT_ID"
                    export TF_VAR_docker_image="${DOCKER_HUB_REPO}:latest"
                    terraform plan
                    '''
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                withCredentials([
                    azureServicePrincipal(
                        credentialsId: 'AZURE_CREDENTIALS',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'
                    )
                ]) {
                    sh '''
                    export TF_VAR_client_id="$AZURE_CLIENT_ID"
                    export TF_VAR_client_secret="$AZURE_CLIENT_SECRET"
                    export TF_VAR_subscription_id="$AZURE_SUBSCRIPTION_ID"
                    export TF_VAR_tenant_id="$AZURE_TENANT_ID"
                    export TF_VAR_docker_image="${DOCKER_IMAGE}"
                    terraform apply -auto-approve
                    '''
                }
            }
        }
         
    }
}
