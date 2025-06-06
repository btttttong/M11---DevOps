pipeline {
    agent any

    environment {
        IMAGE_NAME = "btttttong/my-app:latest"
        TARGET_HOST = "docker"
    }

    triggers {
        pollSCM('*/1 * * * *')
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'docker version'
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh 'node --test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push $IMAGE_NAME
                    '''
                }
            }
        }

        // stage('Deploy to Target') {
        //     steps {
        //         withCredentials([
        //             sshUserPrivateKey(
        //                 credentialsId: 'target-ssh-key',
        //                 keyFileVariable: 'ssh_key',
        //                 usernameVariable: 'ssh_user'
        //             )
        //         ]) {
        //             sh """
        //             ssh -o StrictHostKeyChecking=no -i "$ssh_key" $ssh_user@$TARGET_HOST "
        //                 docker pull $IMAGE_NAME &&
        //                 docker stop my-app || true &&
        //                 docker rm my-app || true &&
        //                 docker run -d --restart unless-stopped --name my-app -p 4444:4444 $IMAGE_NAME
        //             "
        //             """
        //         }
        //     }
        // }
                stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'target-ssh-key',
                        keyFileVariable: 'ssh_key',
                        usernameVariable: 'ssh_user'
                    )
                ]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no -i "\$ssh_key" \$ssh_user@k8s '
                        cat <<EOF | kubectl apply -f -
                        apiVersion: apps/v1
                        kind: Deployment
                        metadata:
                        name: my-app
                        spec:
                        replicas: 1
                        selector:
                            matchLabels:
                            app: my-app
                        template:
                            metadata:
                            labels:
                                app: my-app
                            spec:
                            containers:
                            - name: my-app
                                image: $IMAGE_NAME
                                ports:
                                - containerPort: 4444
                        ---
                        apiVersion: v1
                        kind: Service
                        metadata:
                        name: my-app-service
                        spec:
                        type: NodePort
                        selector:
                            app: my-app
                        ports:
                        - port: 80
                            targetPort: 4444
                            nodePort: 30080
                        EOF
                                            '
                                            """
                }
            }
        }
    }
}