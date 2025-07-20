pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        PATH = "/usr/bin/dotnet:${env.PATH}"
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
                sh 'dotnet test tests/HelloWorldWebApp.Tests/HelloWorldWebApp.Tests.csproj'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("souravdutta06/HelloWorldWebApp:latest")
                }
            }
        }
        stage('Docker Push') {
            steps {
                sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
                sh "docker push souravdutta06/HelloWorldWebApp:latest"
            }
        }
        stage('Deploy to AppServer') {
            steps {
                sshagent(credentials: ['appserver-ssh']) {
                    sh "ssh -o StrictHostKeyChecking=no sysadmin@48.221.120.232 'docker pull souravdutta06/HelloWorldWebApp:latest'"
                    sh "ssh sysadmin@48.221.120.232 'docker run -d -p 80:80 souravdutta06/HelloWorldWebApp:latest'"
                }
            }
        }
    }
}
