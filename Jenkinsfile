pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/dotnet/sdk:8.0'
            args '--platform linux/amd64 -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        DOCKER_BUILDKIT = "1"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        JD_IMAGE = "souravdutta06/helloworldwebapp:${env.BUILD_ID}"
        APP_IP = "20.120.177.214"
    }
    stages {
        stage('Fix Permissions') {
    steps {
        sh '''
            # Fix potential permission issues
            docker run --rm -v $PWD:/src alpine \
                chown -R $(id -u):$(id -g) /src
        '''
    }
}
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: scm.branches,
                    extensions: scm.extensions + [[
                        $class: 'CloneOption',
                        shallow: true,
                        depth: 1,
                        timeout: 10
                    ]],
                    userRemoteConfigs: scm.userRemoteConfigs
                ])
            }
        }
        
        stage('Restore & Build') {
            steps {
                sh 'dotnet restore'
                sh 'dotnet build --configuration Release --no-restore'
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh 'dotnet test HelloWorldWebApp.Tests/HelloWorldWebApp.Tests.csproj --configuration Release --no-build --verbosity normal'
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        dockerImage = docker.build("${env.JD_IMAGE}", 
                            "--build-arg BUILDKIT_INLINE_CACHE=1 " +
                            "--cache-from souravdutta06/helloworldwebapp:latest ."
                        )
                    }
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to AppServer') {
            steps {
                sshagent(credentials: ['appserver-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 sysadmin@${env.APP_IP} '
                            docker pull ${env.JD_IMAGE} && \
                            docker stop helloworldapp || true && \
                            docker rm helloworldapp || true && \
                            docker run -d --restart=always --name helloworldapp -p 80:80 ${env.JD_IMAGE}
                        '
                    """
                }
            }
        }
    }
    post {
        always {
            script {
                // Clean up Docker images to save disk space
                sh "docker rmi ${env.JD_IMAGE} || true"
            }
        }
        success {
            slackSend(color: 'good', message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
        }
        failure {
            slackSend(color: 'danger', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
            archiveArtifacts artifacts: '**/TestResults/*', allowEmptyArchive: true
        }
    }
}
