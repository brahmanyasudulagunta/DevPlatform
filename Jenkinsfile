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
    
    stage('Terraform Apply (Develop)') {

      steps {
        sh '''
          cd terraform/develop
          terraform init
           
          terraform import module.develop_namespace.kubernetes_namespace.this develop || true
          
          terraform apply -auto-approve
       '''
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
        
     stage('Fetch Secrets from Vault') {
       steps {
          sh '''
            export DB_USER=$(vault kv get -field=db_user platform/jenkins)
            export DB_PASSWORD=$(vault kv get -field=db_password platform/jenkins)

            echo "Secrets fetched successfully (values hidden)"
             
            '''
      }
    }
    
   
  }
}
	
