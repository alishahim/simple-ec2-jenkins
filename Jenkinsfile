pipeline {
    agent any

    environment {
        HOST = credentials('ec2-host')             // Jenkins credential ID for EC2 host
        USER = credentials('ec2-user')             // Jenkins credential ID for EC2 user
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id') // AWS Access Key
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key') // AWS Secret Key
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Setting up Python environment and running tests...'
                sh '''
                    pip install -r requirements.txt
                    pip install pytest
                    pytest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "Deploying application to EC2 instance: ${env.HOST} as ${env.USER}"

                withCredentials([
                    file(credentialsId: 'ec2-private-key', variable: 'PRIVATE_KEY_FILE')
                ]) {
                    sh '''
                        echo "Testing SSH connectivity to ${USER}@${HOST}..."

                        # Test SSH connectivity
                        ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY_FILE ${USER}@${HOST} "echo 'Connected to EC2 instance!'"

                        # Ensure required packages are installed
                        ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY_FILE ${USER}@${HOST} "sudo apt-get update && sudo apt-get install -y procps"

                        # Deploy the application
                        ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY_FILE ${USER}@${HOST} "mkdir -p ~/app"
                        scp -o StrictHostKeyChecking=no -i $PRIVATE_KEY_FILE -r ./* ${USER}@${HOST}:~/app/

                        echo "Starting the application using run.sh..."
                        ssh -o StrictHostKeyChecking=no -i $PRIVATE_KEY_FILE ${USER}@${HOST} "
                            cd ~/app &&
                            chmod +x run.sh &&
                            nohup ./run.sh > app.log 2>&1 &
                            sleep 5 && # Wait for the app to start
                            ps aux | grep gunicorn || echo 'Gunicorn process not found'
                        "
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
    }
}
