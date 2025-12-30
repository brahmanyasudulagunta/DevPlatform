pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate Kubernetes Manifests') {
      steps {
        sh '''
          echo "Validating YAML files..."
          find . -name "*.yaml" -exec yamllint {} +
        '''
      }
    }

    stage('Policy Check') {
      steps {
        sh '''
          echo "Checking forbidden actions..."
          ! grep -R "kubectl delete" .
        '''
      }
    }

    stage('Approval Gate') {
      steps {
        input message: "Approve platform changes?"
      }
    }
  }
}
