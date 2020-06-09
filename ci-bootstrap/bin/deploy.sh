#!/bin/bash

set -euo pipefail

: ${ENVIRONMENT}

pattern="^sandbox|cicd|staging|prod$"
if [[ ! ${ENVIRONMENT} =~ $pattern ]]; then
    echo "Unknown environment target '${ENVIRONMENT}' - must match '${pattern}'"
    exit 1
fi

pushd terraform
rm -rf .terraform/ || true
rm *.tfstate* || true
rm role.tf || true
sed "s/{{environment}}/${ENVIRONMENT}/" role.tf.tmpl > role.tf

tfenv install
terraform init
terraform apply --auto-approve --var "environment=${ENVIRONMENT}" .

rm role.tf
popd