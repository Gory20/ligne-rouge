pipeline {
    environment {
        webDockerImageName = "gorysow/ligne-rouge-web"
        dbDockerImageName = "gorysow/ligne-rouge-db"
        webDockerImage = ""
        dbDockerImage = ""
        registryCredential = 'docker-hub'
        KUBECONFIG = "/home/gory/.kube/config"
        TERRA_DIR  = "/home/gory/ligne-rouge/terraform"
        ANSIBLE_DIR = "/home/gory/ligne-rouge/ansible"
    }
    agent any
    stages {
        stage('Checkout Source') {
            steps {
                git 'https://github.com/Gory20/ligne-rouge.git'
            }
        }
        stage('Build Docker images') {
            steps {
                script {
                    sh 'docker-compose down -v'
                    //sh 'docker-compose up --build -d'
                }
            }
        }
        stage('Build Web Docker image') {
            steps {
                script {
                    webDockerImage = docker.build webDockerImageName, "-f App.Dockerfile ."
                }
            }
        }
        stage('Build DB Docker image') {
            steps {
                script {
                    dbDockerImage = docker.build dbDockerImageName, "-f Db.Dockerfile ."
                }
            }
        }
        stage('Pushing Images to Docker Registry') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                        webDockerImage.push('latest')
                        dbDockerImage.push('latest')
                    }
                }
            }
        }
        stage("Provision Kubernetes Cluster with Terraform") {
            steps {
                script {
                    sh """
                    cd ${TERRA_DIR}
                    terraform init
                    terraform plan
                    terraform apply --auto-approve
                    """
                }
            }
        }
        stage('Install Python dependencies and Deploy with Ansible') {
            steps {
                script {
                    sh """
                    sudo apt-get install -y python3-venv
                    cd ${ANSIBLE_DIR}
                    sudo python3 -m venv venv
                    . venv/bin/activate
                    pip install kubernetes ansible
                    ansible-playbook ${ANSIBLE_DIR}/playbook.yml
                    """
                }
            }
        }
    }
    post {
        success {
            slackSend channel: 'groupe4', message: 'Success to deploy'
        }
        failure {
            slackSend channel: 'groupe4', message: 'Failed to deploy'
        }
    }
}
