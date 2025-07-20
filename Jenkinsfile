pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        PATH = "/usr/bin/dotnet:${env.PATH}"
        JD_IMAGE = "souravdutta06/helloworldwebapp:latest"  // Define image name as variable
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
                // Build from root directory with explicit Dockerfile path
                dir("${env.WORKSPACE}") {
                    sh "docker build -t ${env.JD_IMAGE} -f HelloWorldWebApp/Dockerfile ."
                }
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
                    // Use environment variable for IP consistency
                    sh "ssh -o StrictHostKeyChecking=no sysadmin@20.120.177.214 'docker pull ${env.JD_IMAGE}'"
                    sh "ssh sysadmin@20.120.177.214 'docker run -d -p 80:80 ${env.JD_IMAGE}'"
                }
            }
        }
    }
}
