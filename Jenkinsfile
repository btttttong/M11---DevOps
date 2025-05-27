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
            withCredentials([
                sshUserPrivateKey(
                    credentialsId: 'target-ssh-key',
                    keyFileVariable: 'ssh_key',
                    usernameVariable: 'ssh_user'
                )
            ]) {
                sh """
                mkdir -p ~/.ssh
                ssh-keyscan docker-vm >> ~/.ssh/known_hosts
                ansible-playbook -i hosts.ini playbook.yml --private-key "$ssh_key" -u "$ssh_user"
                """
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
