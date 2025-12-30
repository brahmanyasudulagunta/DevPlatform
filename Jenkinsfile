pipeline {
  agent any

  environment {
    KUBECONFIG = "${HOME}/.kube/config"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate YAML') {
      steps {
        sh '''
          echo "Running YAML lint..."
          find . -name "*.yaml" -exec yamllint {} +
        '''
      }
    }

    stage('Validate Kubernetes Access') {
      steps {
        sh '''
          echo "Checking cluster connectivity..."
          kubectl get nodes
        '''
      }
    }

    stage('Policy Guardrails') {
      steps {
        sh '''
          echo "Checking for forbidden operations..."
        
          if grep -R "kubectl delete" .; then
            --exclude=Jenkinsfile; then
            echo "ERROR: kubectl delete is not allowed in this repo"
            exit 1
          fi

          if grep -R "helm uninstall" .; then
            --exclude=Jenkinsfile; then
            echo "ERROR: helm uninstall is not allowed in this repo"
            exit 1
          fi
        '''
      }
    }

    stage('Manual Approval') {
      steps {
        input message: "Approve platform changes to be merged?"
      }
    }
  }
}
	
