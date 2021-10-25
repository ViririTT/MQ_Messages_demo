pipeline {
  environment {
    imagename = "viriritt/docker-jenkins"
    registryCredential = 'viriritt'
    dockerImage = ''
  }
  agent any
  stages {
    stage('Cloning Git') {
      steps {
        git([url: 'https://github.com/ViririTT/CustomerIS.git', branch: 'main', credentialsId: 'viririt'])
        echo "cloning git repo..."
 
      }
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build imagename
        }
      }
    }
    stage('Deploy Image') {
      steps{
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
        sh "docker rmi $imagename:$BUILD_NUMBER"
         sh "docker rmi $imagename:latest"
 
      }
    }
  }
}
