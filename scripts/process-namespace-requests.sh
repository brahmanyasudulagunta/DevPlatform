#!/bin/bash
set -euo pipefail

REQUEST_DIR="clusters/dev/requests"

[ -d "$REQUEST_DIR" ] || {
  echo "No request directory. Skipping."
  exit 0
}

shopt -s nullglob
FILES=("$REQUEST_DIR"/*.yaml)
shopt -u nullglob

[ ${#FILES[@]} -gt 0 ] || {
  echo "No namespace requests found."
  exit 0
}

for file in "${FILES[@]}"; do
  NAME=$(grep '^  name:' "$file" | awk '{print $2}')
  ENV=$(grep '^  environment:' "$file" | awk '{print $2}')

  [ -n "$NAME" ] && [ -n "$ENV" ] || {
    echo "Invalid request: $file"
    exit 1
  }

  echo "Provisioning namespace '$NAME' in '$ENV'"

  (cd "terraform/$ENV" && terraform init && terraform apply -auto-approve -var="name=$NAME")
done
