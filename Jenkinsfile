pipeline {
    agent any

    environment {
        IMAGE_NAME = "ttl.sh/my-app:2h"
        TARGET_HOST = "target"
    }

    triggers {
        pollSCM('*/1 * * * *') // check Git every minute
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'node --test'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker tag my-app $IMAGE_NAME
                docker push $IMAGE_NAME
                '''
            }
        }

        stage('Deploy to Target VM') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'target-ssh-key',
                        keyFileVariable: 'ssh_key',
                        usernameVariable: 'ssh_user'
                    )
                ]) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no -i "$ssh_key" $ssh_user@$TARGET_HOST '
                        docker pull $IMAGE_NAME &&
                        docker stop my-app || true &&
                        docker rm my-app || true &&
                        docker run -d --name my-app -p 4444:4444 $IMAGE_NAME
                    '
                    '''
                }
            }
        }
    }
}