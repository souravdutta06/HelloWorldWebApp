pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        PATH = "/usr/bin/dotnet:${env.PATH}"
        JD_IMAGE = "souravdutta06/helloworldwebapp:latest"
        DOCKER_BUILDKIT = "1"  // Enable BuildKit to resolve deprecation warning
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
                // Build from current directory (where Dockerfile is located)
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
