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
    echo "Namespace '$NAME' already exists — skipping"
    continue
  fi

  NEW_NAMESPACES+=("\"$NAME\"")
done

if [ "${#NEW_NAMESPACES[@]}" -eq 0 ]; then
  echo "No new namespaces to create. Exiting cleanly."
  exit 0
fi

NAMESPACE_JSON="[$(IFS=,; echo "${NEW_NAMESPACES[*]}")]"

echo "New namespaces to be created: $NAMESPACE_JSON"

cd "terraform/$ENV"

terraform init -input=false

terraform apply -auto-approve \
  -var="requested_namespaces=${NAMESPACE_JSON}"
