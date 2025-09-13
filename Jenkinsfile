pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        AWS_ACCOUNT_ID = "130723357658"
        REPO_NAME = "devops-task"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/gajenderyadavv/devops-task.git'
            }
        }

        stage('Login to ECR') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                sh '''
                    docker build -t $REPO_NAME:$IMAGE_TAG .
                    docker tag $REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Import') {
            steps {
                dir('terraform') {
                    withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                        script {
                            def result = sh(script: "terraform state list | grep aws_security_group.ecs_sg || true", returnStdout: true).trim()
                            if (!result) {
                                echo "Importing existing security group into Terraform state..."
                                sh "terraform import aws_security_group.ecs_sg sg-0a31774897f00f1a9"
                            } else {
                                echo "Resource already in state, skipping import."
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
    steps {
        dir('terraform') {
            withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                // Remove old SG from state (if exists)
                sh 'terraform state rm aws_security_group.ecs_sg || true'
                sh 'terraform apply -auto-approve'
            }
        }
    }
}

        stage('Verify Infra') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                    sh 'aws ecs list-clusters --region $AWS_REGION'
                }
            }
        }
    }
}
