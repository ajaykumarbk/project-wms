pipeline {
    agent any

    environment {
        DOCKER_USER = "ajaykumara"
        FRONTEND_IMAGE = "${DOCKER_USER}/frontend-app"
        BACKEND_IMAGE = "${DOCKER_USER}/backend-app"
    }

    stages {
        stage('Checkout Code') {
    steps {
        git url: 'https://github.com/ajaykumarbk/WMS', branch: 'master'
    }
}

        stage('Build Docker Images') {
            parallel {
                stage('Build Frontend Image') {
                    steps {
                        script {
                            sh "docker build -t ${FRONTEND_IMAGE}:${BUILD_NUMBER} ./frontend"
                        }
                    }
                }

                stage('Build Backend Image') {
                    steps {
                        script {
                            sh "docker build -t ${BACKEND_IMAGE}:${BUILD_NUMBER} ./backend"
                        }
                    }
                }
            }
        }

        stage('DockerHub Login') {
            steps {
                script {
                    
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-cred',
                        usernameVariable: 'USERNAME',
                        passwordVariable: 'PASSWORD'
                    )]) {
                        sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Images to DockerHub') {
            steps {
                script {
                
                    sh "docker push ${FRONTEND_IMAGE}:${BUILD_NUMBER}"
                    sh "docker tag ${FRONTEND_IMAGE}:${BUILD_NUMBER} ${FRONTEND_IMAGE}:latest"
                    sh "docker push ${FRONTEND_IMAGE}:latest"
                    sh "docker push ${BACKEND_IMAGE}:${BUILD_NUMBER}"
                    sh "docker tag ${BACKEND_IMAGE}:${BUILD_NUMBER} ${BACKEND_IMAGE}:latest"
                    sh "docker push ${BACKEND_IMAGE}:latest"
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker image rm ${FRONTEND_IMAGE}:${BUILD_NUMBER} || true"
                sh "docker image rm ${FRONTEND_IMAGE}:latest || true"
                sh "docker image rm ${BACKEND_IMAGE}:${BUILD_NUMBER} || true"
                sh "docker image rm ${BACKEND_IMAGE}:latest || true"
            }
        }
    }
}
