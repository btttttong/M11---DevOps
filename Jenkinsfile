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
                    echo 'Deploying...'
                    echo "Using SSH key: \$ssh_key"
                    echo "Using SSH user: \$ssh_user"

                    mkdir -p ~/.ssh
                    ssh-keyscan docker-vm >> ~/.ssh/known_hosts

                    # Inject public key to remote if not already present
                    PUBKEY=\$(cat ~/.ssh/jenkins.pub)
                    ssh -i "\$ssh_key" "\$ssh_user"@docker-vm "echo '✔ connected'" '
                        mkdir -p ~/.ssh &&
                        touch ~/.ssh/authorized_keys &&
                        grep -qxF "\$PUBKEY" ~/.ssh/authorized_keys || (echo "" >> ~/.ssh/authorized_keys && echo "\$PUBKEY" >> ~/.ssh/authorized_keys) &&
                        chmod 700 ~/.ssh &&
                        chmod 600 ~/.ssh/authorized_keys
                    '

                    # Run Ansible deploy
                    ansible-playbook -i hosts.ini playbook.yml --private-key "\$ssh_key" -u "\$ssh_user"
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
