pipeline {
    agent any

    environment {
        PATH = "/usr/bin:$PATH" // Update this path if Azure CLI is installed elsewhere
    }

    stages {
        stage('Setup Terraform') {
            steps {
                sh '''
                terraform init
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
                    set -e  # Exit immediately on failure
                    az login --service-principal \
                        --username "$AZURE_CLIENT_ID" \
                        --password "$AZURE_CLIENT_SECRET" \
                        --tenant "$AZURE_TENANT_ID"
                    
                    az group show --name devops --query name --output tsv 2>/dev/null || echo "Resource group does not exist"
                    '''
                }
            }
        }

        stage('Plan Infrastructure') {
            steps {
                withCredentials([
                    azureServicePrincipal(credentialsId: 'AZURE_CREDENTIALS',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'),
                    string(credentialsId: 'GITHUB_CREDENTIALS', variable: 'GITHUB_AUTH_TOKEN')
                ]) {
                    sh '''
                    export TF_VAR_client_id="$AZURE_CLIENT_ID"
                    export TF_VAR_client_secret="$AZURE_CLIENT_SECRET"
                    export TF_VAR_subscription_id="$AZURE_SUBSCRIPTION_ID"
                    export TF_VAR_tenant_id="$AZURE_TENANT_ID"
                    export TF_VAR_github_auth_token="$GITHUB_AUTH_TOKEN"

                    terraform plan
                    '''
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                withCredentials([
                    azureServicePrincipal(credentialsId: 'AZURE_CREDENTIALS',
                        subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                        clientIdVariable: 'AZURE_CLIENT_ID',
                        clientSecretVariable: 'AZURE_CLIENT_SECRET',
                        tenantIdVariable: 'AZURE_TENANT_ID'),
                    string(credentialsId: 'GITHUB_CREDENTIALS', variable: 'GITHUB_AUTH_TOKEN')
                ]) {
                    sh '''
                    export TF_VAR_client_id="$AZURE_CLIENT_ID"
                    export TF_VAR_client_secret="$AZURE_CLIENT_SECRET"
                    export TF_VAR_subscription_id="$AZURE_SUBSCRIPTION_ID"
                    export TF_VAR_tenant_id="$AZURE_TENANT_ID"
                    export TF_VAR_github_auth_token="$GITHUB_AUTH_TOKEN"

                    terraform apply -auto-approve
                    '''
                }
            }
        }
    }
}