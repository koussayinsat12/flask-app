pipeline {
    agent any

    environment {
        TF_CLI_ARGS = "-var='client_id=$AZURE_CLIENT_ID' -var='client_secret=$AZURE_CLIENT_SECRET' -var='subscription_id=$AZURE_SUBSCRIPTION_ID' -var='tenant_id=$AZURE_TENANT_ID'"
    }

    stages {
        stage('Setup Terraform') {
            steps {
                sh """
                terraform init
                terraform validate
                """
            }
        }

        stage('Check Resource Group') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'AZURE_PRINCIPLE',
                    subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZURE_CLIENT_ID',
                    clientSecretVariable: 'AZURE_CLIENT_SECRET',
                    tenantIdVariable: 'AZURE_TENANT_ID'
                )]) {
                    sh """
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                    az group show --name devops --query name --output tsv 2>/dev/null || echo 'Resource group not found'
                    """
                }
            }
        }

        stage('Plan Infrastructure') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'AZURE_PRINCIPLE',
                    subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZURE_CLIENT_ID',
                    clientSecretVariable: 'AZURE_CLIENT_SECRET',
                    tenantIdVariable: 'AZURE_TENANT_ID'
                )]) {
                    sh "terraform plan $TF_CLI_ARGS"
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'AZURE_PRINCIPLE',
                    subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZURE_CLIENT_ID',
                    clientSecretVariable: 'AZURE_CLIENT_SECRET',
                    tenantIdVariable: 'AZURE_TENANT_ID'
                )]) {
                    sh "terraform apply -auto-approve $TF_CLI_ARGS"
                }
            }
        }
    }
}
