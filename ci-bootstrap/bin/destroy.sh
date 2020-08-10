#!/bin/bash

set -euo pipefail

: ${ENVIRONMENT}
: ${CONCOURSE_ACCOUNT}

pattern="^sandbox|dev|cicd|uat|preprod|prod$"
if [[ ! ${ENVIRONMENT} =~ $pattern ]]; then
    echo "Unknown environment target '${ENVIRONMENT}' - must match '${pattern}'"
    exit 1
fi

pushd terraform
rm -rf .terraform/ || true
rm *.tfstate* || true
rm role.tf || true
sed "s/{{environment}}/${ENVIRONMENT}/;s/{{concourse_account}}/${CONCOURSE_ACCOUNT}/" role.tf.tmpl > role.tf

tfenv install
terraform init
terraform destroy --auto-approve --var "environment=${ENVIRONMENT}" .

rm role.tf
popd
