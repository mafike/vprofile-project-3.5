pipeline {
    agent any

    stages {
        stage('Build Artifact') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archiveArtifacts 'target/*.war' // Archive the WAR file for later download
            }
        }   

        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test"
            }
        }

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }

        stage('Vulnerability Scan - Docker') {
            steps {
                parallel(
                    "Dependency Scan": {
                        sh "mvn dependency-check:check"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-docker-image-scan.sh"
                    }
                )
            }
        }

    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'   // Archive JUnit test results
            jacoco execPattern: '**/target/jacoco.exec' // Archive JaCoCo coverage results
            
            // Temporary step to list contents of target/pit-reports directory
            script {
                sh 'echo "Listing target/pit-reports contents..."'
                sh 'ls -l target/pit-reports || echo "No pit-reports directory found"'
            }
            
            // Archive PIT reports directory temporarily to ensure it exists
            archiveArtifacts artifacts: 'target/pit-reports/**/*', allowEmptyArchive: true

            // Dynamically publish the PIT mutation testing HTML report from the timestamped directory
            script {
                def reportDir = sh(script: 'ls -d target/pit-reports/*/', returnStdout: true).trim()
                echo "Publishing report from: ${reportDir}"
                
                publishHTML(target: [
                    reportName: 'PIT Mutation Testing Report',
                    reportDir: reportDir,
                    reportFiles: 'index.html',
                    keepAll: true,
                    alwaysLinkToLastBuild: true
                ])
            }
        }
    }
}
