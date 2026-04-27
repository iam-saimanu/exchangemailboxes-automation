pipeline {
    agent any

    stages {
        stage('Run Script') {
            steps {
                withCredentials([
                    string(credentialsId: 'tenant-id', variable: 'TENANT_ID'),
                    string(credentialsId: 'client-id', variable: 'CLIENT_ID'),
                    string(credentialsId: 'entra-secret', variable: 'CLIENT_SECRET')
                ]) {
                    bat """
                    powershell -ExecutionPolicy Bypass -File create-users.ps1 ^
                    -tenantId %TENANT_ID% ^
                    -clientId %CLIENT_ID% ^
                    -clientSecret %CLIENT_SECRET%
                    """
                }
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
