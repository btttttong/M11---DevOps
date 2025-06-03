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
                    sh '''
                    echo "[1] Build Docker Image"
                    docker build -t my-app .

                    echo "[2] Tag & Push to ttl.sh"
                    docker tag my-app $IMAGE_NAME
                    docker push $IMAGE_NAME

                    echo "[3] SSH to Docker VM and Deploy"
                    ssh -o StrictHostKeyChecking=no -i "$ssh_key" $ssh_user@docker "
                        docker pull $IMAGE_NAME &&
                        docker stop my-app || true &&
                        docker rm my-app || true &&
                        docker run -d --name my-app -p 4444:4444 $IMAGE_NAME
                    "
                    '''
                }
            }
        }
        /*
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
                    chmod +x main

                    mkdir -p ~/.ssh
                    ssh-keyscan target >> ~/.ssh/known_hosts

                    ssh -i ${ssh_key} laborant@target 'sudo systemctl stop main.service || true'

                    scp -i ${ssh_key} main ${ssh_user}@target:
                    scp -i ${ssh_key} main.service ${ssh_user}@target:

                    ssh -i ${ssh_key} laborant@target '
                        sudo mv /home/laborant/main /opt/main &&
                        sudo mv /home/laborant/main.service /etc/systemd/system/main.service &&
                        sudo systemctl daemon-reload &&
                        sudo systemctl enable --now main.service
                    '
                    """
                }
            }
        }
        */
    }
}
