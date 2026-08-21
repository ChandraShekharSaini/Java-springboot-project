

pipeline {

    agent any

    environment {

        AWS_REGION = 'us-east-1'

        PROJECT_REPO = 'https://github.com/ChandraShekharSaini/Java-springboot-project.git'

        TERRAFORM_DIR = 'terraform'

        IMAGE_NAME = 'springboot-app'
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        // ============================================================
        // 1. Checkout entire project ONCE
        // ============================================================
        stage('Checkout Project') {
            steps {
                git branch: 'main',
                    url: "${PROJECT_REPO}"
            }
        }

        // ============================================================
        // 2. Terraform Init
        // ============================================================
        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform init
                    '''
                }
            }
        }

        // ============================================================
        // 3. Terraform Plan
        // ============================================================
        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform plan -out=tfplan
                    '''
                }
            }
        }

        // ============================================================
        // 4. Terraform Apply
        // ============================================================
        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        // ============================================================
        // 5. Get Terraform Outputs
        // ============================================================
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

                        echo "======================================"
                        echo "Private EC2: ${env.EC2_INSTANCE_ID}"
                        echo "ECR: ${env.ECR_REPOSITORY}"
                        echo "======================================"
                    }
                }
            }
        }

        // ============================================================
        // 6. Maven Build
        // ============================================================
        stage('Maven Build') {
            steps {
                dir('backend') {
                    sh '''
                        chmod +x mvnw || true
                        ./mvnw clean package -DskipTests
                    '''
                }
            }
        }

        // ============================================================
        // 7. Docker Build
        // ============================================================
        stage('Docker Build') {
            steps {
                dir('backend') {
                    sh '''
                        docker build \
                            -t ${IMAGE_NAME}:${IMAGE_TAG} \
                            -t ${IMAGE_NAME}:latest .
                    '''
                }
            }
        }

        // ============================================================
        // 8. Login to ECR
        // ============================================================
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

        // ============================================================
        // 9. Push Docker Image
        // ============================================================
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

        // ============================================================
        // 10. Deploy to PRIVATE EC2 using SSM
        // ============================================================
        stage('Deploy to Private EC2') {
            steps {
                script {

                    echo "Deploying to EC2: ${EC2_INSTANCE_ID}"

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
                                    "docker run -d --restart unless-stopped --name ${IMAGE_NAME} -p 8080:8080 ${ECR_REPOSITORY}:${IMAGE_TAG}"
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