pipeline {
    agent any
    tools {
        go "1.24.1"
    }
    environment {
        IMAGE_NAME = "ttl.sh/myapp:1h"
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
        stage('Docker Build Image') {
            steps {
                sh "docker build . --tag $IMAGE_NAME"
            }
        }
        stage('Docker Push Image') {
            steps {
                sh "docker push $IMAGE_NAME"
                echo "IMAGE_NAME is: $IMAGE_NAME"
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubernetes-token', serverUrl: 'https://k8s:6443']) {
                    sh "kubectl apply -f pod.yaml"
                    sh "kubectl apply -f service.yaml"
                }
            }
        }
    }
}
