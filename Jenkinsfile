pipeline {
    agent any
    tools {
        go "1.24.1"
    }

    triggers {
        pollSCM('*/1 * * * *') // Poll Git repository every 1 minute
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh "go build main.go"
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                sh "go test ./..."
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sshagent(['77afc6fa-8107-4176-abb5-906bae6182d4']) {
                    sh 'ssh -o StrictHostKeyChecking=no laborant@target "echo connected"'
                }
            }
        }
    }
}
