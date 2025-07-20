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
            sh """
                ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no sysadmin@${env.APP_IP} '
                    # Pull latest image
                    docker pull ${env.JD_IMAGE} || { echo "ERROR: Image pull failed"; exit 1; }
                    
                    # Remove existing container if exists
                    if docker container inspect helloworldapp >/dev/null 2>&1; then
                        docker stop helloworldapp
                        docker rm helloworldapp
                    fi
                    
                    # Start new container with cleanup hook
                    docker run -d \\
                        --name helloworldapp \\
                        --restart=unless-stopped \\
                        --health-cmd "curl -f http://localhost/healthz || exit 1" \\
                        --health-interval=30s \\
                        --health-start-period=10s \\
                        --health-retries=3 \\
                        -p 80:80 \\
                        ${env.JD_IMAGE}
                    
                    # Verify deployment
                    echo "Deployment complete. Container status:"
                    docker ps --filter "name=helloworldapp" --format "table {{.ID}}\\t{{.Names}}\\t{{.Status}}"
                '
            """
        }
    }
}
    }
}
