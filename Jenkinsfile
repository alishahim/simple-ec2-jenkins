pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id') // Jenkins credential ID for AWS Access Key
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key') // Jenkins credential ID for AWS Secret Key
        PRIVATE_KEY = credentials('ec2-private-key') // Jenkins credential ID for the private key
        HOST = credentials('ec2-host')             // Jenkins credential ID for EC2 host
        USER = credentials('ec2-user')             // Jenkins credential ID for EC2 user
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Set Up Python Environment') {
            steps {
                echo 'Setting up Python environment...'
                sh '''
                    python3 -m pip install --upgrade pip
                    pip cache purge
                    pip install -r requirements.txt
                    pip install pytest
                '''
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                sh '''
                    pytest
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "Deploying application to EC2 instance: ${env.HOST} as ${env.USER}"

                script {
                    // Write private key to a file
                    writeFile file: 'private_key.pem', text: env.PRIVATE_KEY
                    sh 'chmod 600 private_key.pem'

                    // Test SSH connectivity
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i private_key.pem ${USER}@${HOST} "echo 'Connected to EC2 instance!'"
                    '''

                    // Ensure required packages are installed
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i private_key.pem ${USER}@${HOST} "sudo apt-get update && sudo apt-get install -y procps"
                    '''

                    // Stop any running Gunicorn process
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i private_key.pem ${USER}@${HOST} "
                        if pgrep -f 'gunicorn -b 0.0.0.0:5000' > /dev/null; then
                            echo 'Stopping Gunicorn processes...';
                            pgrep -f 'gunicorn -b 0.0.0.0:5000' | grep -v $$ | xargs sudo kill -9;
                        else
                            echo 'No Gunicorn process running.';
                        fi"
                    '''

                    // Deploy application code
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i private_key.pem ${USER}@${HOST} "mkdir -p ~/app"
                        scp -o StrictHostKeyChecking=no -i private_key.pem -r ./* ${USER}@${HOST}:~/app/
                    '''

                    // Start the application
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i private_key.pem ${USER}@${HOST} "cd ~/app && chmod +x run.sh && nohup ./run.sh > app.log 2>&1 &"
                    '''

                    // Clean up private key
                    sh 'rm -f private_key.pem'
                }

                echo 'Deployment to EC2 complete!'
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
