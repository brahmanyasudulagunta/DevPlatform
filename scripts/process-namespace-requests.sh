#!/bin/bash
set -euo pipefail

REQUEST_DIR="clusters/develop/requests"

if [ ! -d "$REQUEST_DIR" ]; then
  echo "No request directory found at $REQUEST_DIR. Skipping."
  exit 0
fi

echo "Processing namespace requests in $REQUEST_DIR"

# 🔹 ADD: array to accumulate namespaces
REQUESTED_NS=()

for file in "$REQUEST_DIR"/*.yaml; do
  [ -e "$file" ] || { echo "No request files found."; exit 0; }

  NAME=$(yq -r '.metadata.name' "$file")
  ENV=$(yq -r '.spec.environment' "$file")

  echo "Request detected:"
  echo "  Namespace: $NAME"
  echo "  Environment: $ENV"

  # Only process develop environment
  if [ "$ENV" != "develop" ]; then
    echo "Skipping $NAME (env=$ENV)"
    continue
  fi

  # 🔹 ADD: collect namespace instead of applying immediately
  REQUESTED_NS+=("\"$NAME\"")
done

# 🔹 ADD: run Terraform ONCE with ALL namespaces
if [ "${#REQUESTED_NS[@]}" -gt 0 ]; then
  NS_LIST=$(printf ",%s" "${REQUESTED_NS[@]}")
  NS_LIST="[${NS_LIST:1}]"

  echo "Applying Terraform with namespaces: $NS_LIST"

  cd "terraform/develop"
  terraform init -input=false
  terraform apply -auto-approve -var="requested_namespaces=$NS_LIST"
  cd -
else
  echo "No namespaces to process."
fi
