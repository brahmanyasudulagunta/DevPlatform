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
        
          if grep -R "kubectl delete" . \
            --exclude=Jenkinsfile; then
            echo "ERROR: kubectl delete is not allowed in this repo"
            exit 1
          fi

          if grep -R "helm uninstall" . \
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
    
    stage('Terraform Apply (Dev)') {

      steps {
        sh '''
          cd terraform/dev
          terraform init
           
          terraform import module.dev_namespace.kubernetes_namespace.this dev || true
          
          terraform apply -auto-approve
       '''
      }
    }

  }
}
	
