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
          find . -name "*.yaml" -exec yamllint {} +
        '''
      }
    }

    stage('Validate Kubernetes Access') {
      steps {
        sh 'kubectl get nodes'
      }
    }

    stage('Policy Guardrails') {
      steps {
        sh '''
          if grep -R "kubectl delete" . --exclude=Jenkinsfile; then exit 1; fi
          if grep -R "helm uninstall" . --exclude=Jenkinsfile; then exit 1; fi
        '''
      }
    }

    stage('Manual Approval') {
      steps {
        input message: "Approve platform changes?"
      }
    }

    stage('Ansible Configuration') {
      steps {
        sh '''
          cd scripts/ansible
          ansible-playbook -i inventory.ini site.yml 
        '''
      }
    }

    stage('Process Self-Service Requests') {
      steps {
        sh 'scripts/process-namespace-requests.sh'
      }
    }
  }
}
