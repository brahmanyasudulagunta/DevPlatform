#!/bin/bash
set -e

REQUEST_DIR="clusters/develop/requests"

echo "Processing namespace requests in $REQUEST_DIR"

NAMESPACES=()

for file in $REQUEST_DIR/*.yaml; do
  echo "Request detected:"
  NAME=$(grep "name:" "$file" | awk '{print $2}')
  ENV=$(grep "environment:" "$file" | awk '{print $2}')

  echo "  Namespace: $NAME"
  echo "  Environment: $ENV"

  # 🚫 BLOCK if namespace already exists
  if kubectl get namespace "$NAME" >/dev/null 2>&1; then
    echo "❌ ERROR: Namespace '$NAME' already exists."
    echo "Terraform must be the sole creator of namespaces."
    exit 1
  fi

  NAMESPACES+=("$NAME")
done

echo "All requests are valid. Proceeding with Terraform."

cd terraform/develop
terraform init
terraform apply -auto-approve
