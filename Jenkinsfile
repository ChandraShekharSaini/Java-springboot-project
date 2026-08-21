
pipeline {

    agent any

    environment {

        AWS_REGION = 'us-east-1'

        TERRAFORM_REPO = 'https://github.com/ChandraShekharSaini/Java-springboot-project.git'
        APP_REPO       = 'https://github.com/ChandraShekharSaini/Java-springboot-project.git'

        TERRAFORM_DIR = 'terraform'

        IMAGE_NAME = 'springboot-app'
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Terraform') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    git branch: 'main',
                        url: "${TERRAFORM_REPO}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Get AWS Resource IDs') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {

                        env.EC2_INSTANCE_ID = sh(
                            script: 'terraform output -raw private_ec2_1a_instance_id',
                            returnStdout: true
                        ).trim()

                        env.ECR_REPOSITORY = sh(
                            script: 'terraform output -raw ecr_repository_url',
                            returnStdout: true
                        ).trim()

                        echo "EC2 Instance ID: ${env.EC2_INSTANCE_ID}"
                        echo "ECR Repository: ${env.ECR_REPOSITORY}"
                    }
                }
            }
        }

        stage('Checkout Spring Boot Application') {
            steps {
                dir('application') {
                    git branch: 'main',
                        url: "${APP_REPO}"
                }
            }
        }

     

        stage('Docker Build') {
            steps {
                dir('application/backend') {
                    sh '''
                        docker build \
                            -t ${IMAGE_NAME}:${IMAGE_TAG} \
                            -t ${IMAGE_NAME}:latest .
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password \
                        --region ${AWS_REGION} | \
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REPOSITORY}
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    docker tag \
                        ${IMAGE_NAME}:${IMAGE_TAG} \
                        ${ECR_REPOSITORY}:${IMAGE_TAG}

                    docker tag \
                        ${IMAGE_NAME}:latest \
                        ${ECR_REPOSITORY}:latest

                    docker push \
                        ${ECR_REPOSITORY}:${IMAGE_TAG}

                    docker push \
                        ${ECR_REPOSITORY}:latest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {

                    def commandId = sh(
                        script: """
                            aws ssm send-command \
                                --region ${AWS_REGION} \
                                --instance-ids ${EC2_INSTANCE_ID} \
                                --document-name "AWS-RunShellScript" \
                                --parameters 'commands=[
                                    "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}",
                                    "docker pull ${ECR_REPOSITORY}:${IMAGE_TAG}",
                                    "docker stop ${IMAGE_NAME} || true",
                                    "docker rm ${IMAGE_NAME} || true",
                                    "docker run -d --restart unless-stopped --name ${IMAGE_NAME} -p 8080:8084 ${ECR_REPOSITORY}:${IMAGE_TAG}"
                                ]' \
                                --query "Command.CommandId" \
                                --output text
                        """,
                        returnStdout: true
                    ).trim()

                    echo "SSM Command ID: ${commandId}"

                    sh """
                        aws ssm wait command-executed \
                            --region ${AWS_REGION} \
                            --command-id ${commandId} \
                            --instance-id ${EC2_INSTANCE_ID}
                    """

                    sh """
                        aws ssm get-command-invocation \
                            --region ${AWS_REGION} \
                            --command-id ${commandId} \
                            --instance-id ${EC2_INSTANCE_ID}
                    """
                }
            }
        }
    }

    post {

        success {
            echo """
            ======================================
            Deployment Successful!
            ======================================
            EC2: ${env.EC2_INSTANCE_ID}
            ECR: ${env.ECR_REPOSITORY}
            Image: ${env.IMAGE_TAG}
            Region: ${env.AWS_REGION}
            ======================================
            """
        }

        failure {
            echo "CI/CD Pipeline Failed!"
        }
    }
}

