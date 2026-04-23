pipeline {
    agent any

    environment {
        TENANT_ID = 'your-tenant-id'
        CLIENT_ID = 'your-client-id'
        CLIENT_SECRET = credentials('entra-secret')
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Run PowerShell Script') {
            steps {
                powershell '''
                ./create-users.ps1 `
                -tenantId $env:TENANT_ID `
                -clientId $env:CLIENT_ID `
                -clientSecret $env:CLIENT_SECRET
                '''
            }
        }
    }

    post {
        success {
            echo 'Users created successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
