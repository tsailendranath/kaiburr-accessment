pipeline {
    
	agent any

    environment {
        registry = "tsailendranath/hackathon"
        registryCredential = "dockerhublogin"
        
    }

    stages {
        
        stage('BUILD'){
            steps {
                sh 'npm install'
            
            }
            
        }

	    stage('TEST'){
            steps {
                sh 'npm test'
            }
        }

        stage('CODE ANALYSIS with SONARQUBE') {
          
		     environment {
             scannerHome = tool 'sonarscanner'
             }
        

            steps {
                withSonarQubeEnv('sonarqube1') {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=hackathon \
                    -Dsonar.projectName=hackathon-repo \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=. \
                    '''
                }
            

                timeout(time: 10, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('BUILD DOCKER IMGE') { 
            steps {
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }
        stage('SCAN DOCKER IMAGE') {
            steps {
                echo "-----------SCANNING------------"
                sh "trivy image --timeout 30m --exit-code 100 ${registry}:${BUILD_NUMBER}"
                //sh "trivy image --format json --severity HIGH,CRITICAL ${registry}:${BUILD_NUMBER} > report.json"
                // script {

                //     if (sh(returnStdout: true, script: 'echo $?')) {
                //         error('Trivy scan found critical or high vulnerabilities.')
                //     }
                // }
            }
        }
        stage('PUBLISH TO REGISTRY') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Remove Unused docker image') {
            steps{
                sh "docker rmi $registry:$BUILD_NUMBER"
            }
        }
        }
        stage('deploy to k8s ') {
            steps{
                //deploy the khelm chart
                sh 'helm upgrade --install helm/kaiburr --namespace mynamespace'
            }
        }
    post {
        always {
	  
            cleanWs()
         
        }
    }  
        

    }
}