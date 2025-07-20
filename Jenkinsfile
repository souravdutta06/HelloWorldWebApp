pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        PATH = "/usr/bin/dotnet:${env.PATH}"
        JD_IMAGE = "souravdutta06/helloworldwebapp:latest"
        DOCKER_BUILDKIT = "1"  // Keep enabled if installing buildx
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Buildx') {
            steps {
                sh '''
                    mkdir -p ~/.docker/cli-plugins
                    curl -L https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64 \
                         -o ~/.docker/cli-plugins/docker-buildx
                    chmod a+x ~/.docker/cli-plugins/docker-buildx
                '''
            }
        }
        
        stage('Build') {
            steps {
                sh 'dotnet build'                
            }
        }
        
        stage('Unit Test') {
            steps {
                sh 'dotnet test HelloWorldWebApp.Tests/HelloWorldWebApp.Tests.csproj'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh "docker build -t ${env.JD_IMAGE} ."
            }
        }
        
        stage('Docker Push') {
            steps {
                sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
                sh "docker push ${env.JD_IMAGE}"
            }
        }
        
        stage('Deploy to AppServer') {
            steps {
                sshagent(credentials: ['appserver-ssh']) {
                    sh "ssh -o StrictHostKeyChecking=no sysadmin@20.120.177.214 'docker pull ${env.JD_IMAGE}'"
                    sh "ssh sysadmin@20.120.177.214 'docker run -d -p 80:80 --name helloworldapp ${env.JD_IMAGE}'"
                }
            }
        }
    }
}
