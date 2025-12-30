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
          ! grep -R "kubectl delete" .
          ! grep -R "helm uninstall" .
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
