#!/bin/bash

# Runs a `terraform apply` on ${TERRAFORM_SOURCE}

set -euo pipefail

: ${WORKSPACE}
: ${TERRAFORM_SOURCE}
: ${TF_VAR_stage}
: ${AWS_REGION}
: ${S3_NAME}
: ${S3_KEY}

# Ensure the workspace doesn't have any invalid character
if [[ ${WORKSPACE} =~ - ]]; then
    echo "Terraform workspace cannot contain '-' (breaks some resource names)"
    exit 1
fi

. ./bpm-store-attachment/ci/tasks/util/assume_role.sh
. ./bpm-store-attachment/ci/tasks/util/setup_terraform.sh

terraform apply \
    --auto-approve
echo "done"