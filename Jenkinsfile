pipeline {
    agent any

    stages {
      
        stage('Setup Terraform') {
            steps {
                script {
                    sh """
                    terraform init
                    terraform validate
                    """
                }
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
                    script {
                        def result = sh(
                            script: """
                            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                            az group show --name devops --query name --output tsv 2>/dev/null || echo 'not-exist'
                            """,
                            returnStdout: true
                        ).trim()
                        
                        if (result == "not-exist") {
                            echo "Resource group 'devops' does not exist. Failing the pipeline."
                            error("Resource group 'devops' is required but does not exist.")
                        } else {
                            echo "Resource group 'devops' exists. Proceeding with the pipeline."
                        }
                    }
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
                    script {
                        sh """
                        terraform plan \
                            -var 'client_id=$AZURE_CLIENT_ID' \
                            -var 'client_secret=$AZURE_CLIENT_SECRET' \
                            -var 'subscription_id=$AZURE_SUBSCRIPTION_ID' \
                            -var 'tenant_id=$AZURE_TENANT_ID'
                        """
                    }
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
                    script {
                        sh """
                        terraform apply -auto-approve \
                            -var 'client_id=$AZURE_CLIENT_ID' \
                            -var 'client_secret=$AZURE_CLIENT_SECRET' \
                            -var 'subscription_id=$AZURE_SUBSCRIPTION_ID' \
                            -var 'tenant_id=$AZURE_TENANT_ID'
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment succeeded!"
        }
        failure {
            echo "Deployment failed."
        }
    }
}
