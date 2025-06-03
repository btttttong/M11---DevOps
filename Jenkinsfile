pipeline {
    agent any
    tools {
        go "1.24.1"
    }
    environment {
        IMAGE_NAME = "ttl.sh/my-app:2h"
        EC2_HOST = ""
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
                        echo "[1] SSH to Docker VM and Build + Deploy"
                        ssh -o StrictHostKeyChecking=no -i "$ssh_key" $ssh_user@docker "
                            cd ~/M11---DevOps &&
                            ls -l &&
                            docker build -t my-app . &&
                            docker tag my-app ${IMAGE_NAME} &&
                            docker push ${IMAGE_NAME} &&
                            docker stop my-app || true &&
                            docker rm my-app || true &&
                            docker run -d --name my-app -p 4444:4444 ${IMAGE_NAME}
                        "
                        """
                }
            }
        }
    }
}
