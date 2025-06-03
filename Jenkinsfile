pipeline {
    agent any
    tools {
        go "1.24.1"
    }
    environment {
        IMAGE_NAME = "ttl.sh/my-app:2h"
        EC2_HOST = "47.129.240.179"
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
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'target-ssh-key',
                        keyFileVariable: 'ssh_key',
                        usernameVariable: 'ssh_user'
                    )
                ]) {
                    sh """
                        echo "[1] Tag & Push to Registry"
                        docker tag my-app ${IMAGE_NAME}
                        docker push ${IMAGE_NAME}

                        echo "[2] SSH to EC2 and Run Docker"
                        ssh -o StrictHostKeyChecking=no -i "$ssh_key" $ssh_user@$EC2_HOST "
                            docker stop my-app || true &&
                            docker rm my-app || true &&
                            docker pull ${IMAGE_NAME} &&
                            docker run -d --name my-app -p 4444:4444 ${IMAGE_NAME}
                        "
                    """
                }
            }
        }
    }
}
