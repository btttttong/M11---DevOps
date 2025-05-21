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
                sh 'scp main laborant@target:~'
            }
        }
    }
}
