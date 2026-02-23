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

    stage('Ansible Configuration') {
      steps {
        sh '''
          cd scripts/ansible
          ansible-playbook -i inventory.ini site.yml
        '''
      }
    }

    stage('Terraform - Develop') {
      steps {
        sh '''
          cd terraform/develop
          terraform init -input=false
          terraform validate
          terraform plan -out=tfplan
          terraform apply -auto-approve tfplan
        '''
      }
    }

    stage('Approve Production Deployment') {
      steps {
        input message: "Develop is succeeded. Approve production deployment?"
      }
    }

    stage('Terraform - Production') {
      steps {
        sh '''
          cd terraform/production
          terraform init -input=false
          terraform validate
          terraform plan -out=tfplan
          terraform apply -auto-approve tfplan
        '''
      }
    }

    stage('Process Self-Service Requests') {
      steps {
        sh 'scripts/process-namespace-requests.sh'
      }
    }

    stage('Apply RBAC Policies') {
      steps {
        sh 'kubectl apply -f rbac/'
      }
    }

    stage('Apply Network Policies') {
      steps {
        sh 'kubectl apply -f network-policies/'
      }
    }
  }
}
