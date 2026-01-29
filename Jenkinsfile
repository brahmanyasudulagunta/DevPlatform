pipeline {
  agent any

  environment {
    KUBECONFIG = "${HOME}/.kube/config"
    VAULT_ADDR = "https://127.0.0.1:8200"
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

    stage('Fetch Secrets from Vault') {
      steps {
        script {
          env.DB_USER = sh(
            script: 'vault kv get -field=db_user platform/jenkins',
            returnStdout: true
          ).trim()

          env.DB_PASSWORD = sh(
            script: 'vault kv get -field=db_password platform/jenkins',
            returnStdout: true
          ).trim()
        }
      }
    }

    stage('Terraform Apply (Develop)') {
      steps {
        sh '''
          cd terraform/develop
          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Process Self-Service Requests') {
      steps {
        sh 'scripts/process-namespace-requests.sh'
      }
    }

    stage('Ansible Configuration') {
      steps {
        sh '''
          cd scripts/ansible
          ansible-playbook -i inventory.ini site.yml \
            --extra-vars "db_user=$DB_USER db_password=$DB_PASSWORD"
        '''
      }
    }
  }
}
