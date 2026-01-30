#!/bin/bash
set -euo pipefail

REQUEST_DIR="clusters/develop/requests"

if [ ! -d "$REQUEST_DIR" ]; then
  echo "No request directory found at $REQUEST_DIR. Skipping."
  exit 0
fi

echo "Processing namespace requests in $REQUEST_DIR"

for file in "$REQUEST_DIR"/*.yaml; do
  [ -e "$file" ] || { echo "No request files found."; exit 0; }

  NAME=$(yq -r '.metadata.name' "$file")
  ENV=$(yq -r '.spec.environment' "$file")

  echo "Request detected:"
  echo "  Namespace: $NAME"
  echo "  Environment: $ENV"

  cd "terraform/$ENV"
  terraform init -input=false
  terraform apply -auto-approve -var="name=$NAME"
  cd -
done
