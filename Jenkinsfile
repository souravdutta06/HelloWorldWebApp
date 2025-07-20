pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        PATH = "/usr/bin/dotnet:${env.PATH}"
        JD_IMAGE = "souravdutta06/helloworldwebapp:latest"
        DOCKER_BUILDKIT = "1"  // Keep enabled if installing buildx
        APP_IP = "20.120.177.214"
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
            sh """
                ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no sysadmin@${env.APP_IP} '
                    # Clean up
                    docker stop helloworldapp || true
                    docker rm helloworldapp || true
                    
                    # Get new image
                    docker pull ${env.JD_IMAGE}
                    
                    # Start container
                    docker run -d \\
                        --name helloworldapp \\
                        -p 8080:80 \\
                        ${env.JD_IMAGE}
                    
                    # Wait for startup
                    sleep 10
                    
                    # Run diagnostics
                    echo "\\n=== Container Status ==="
                    docker ps -a
                    
                    echo "\\n=== Application Logs ==="
                    docker logs helloworldapp
                    
                    echo "\\n=== Port Mapping ==="
                    docker port helloworldapp
                    
                    echo "\\n=== Network Inspection ==="
                    docker exec helloworldapp netstat -tuln
                    
                    echo "\\n=== Internal Access Test ==="
                    docker exec helloworldapp curl -I http://localhost
                    
                    echo "\\n=== External Access Test ==="
                    curl -I http://localhost || true
                    
                    echo "\\n=== Firewall Check ==="
                    sudo ufw status
                '
            """
        }
    }
}
    }
}
