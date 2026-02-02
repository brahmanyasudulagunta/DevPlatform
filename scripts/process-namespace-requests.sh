#!/bin/bash
set -euo pipefail

REQUEST_DIR="clusters/develop/requests"
ENV="develop"

echo "Processing namespace requests in $REQUEST_DIR"

NEW_NAMESPACES=()

for file in "$REQUEST_DIR"/*.yaml; do
  [ -e "$file" ] || continue

  NAME=$(grep "^ *name:" "$file" | awk '{print $2}')
  ENV_REQ=$(grep "^ *environment:" "$file" | awk '{print $2}')

  echo "Request detected:"
  echo "  Namespace: $NAME"
  echo "  Environment: $ENV_REQ"

  if [ "$ENV_REQ" != "$ENV" ]; then
    echo "ERROR: Environment mismatch in $file"
    exit 1
  fi

  if kubectl get namespace "$NAME" >/dev/null 2>&1; then
    echo "Namespace '$NAME' already exists — skipping (legacy or already provisioned)"
    continue
  fi

  NEW_NAMESPACES+=("$NAME")
done

if [ "${#NEW_NAMESPACES[@]}" -eq 0 ]; then
  echo "No new namespaces to create. Exiting cleanly."
  exit 0
fi

echo "New namespaces to be created:"
printf ' - %s\n' "${NEW_NAMESPACES[@]}"

cd "terraform/$ENV"

terraform init -input=false

terraform apply -auto-approve \
  -var="requested_namespaces=${NEW_NAMESPACES[*]}"
