#!/bin/bash

# Runs a `terraform apply` on ${TERRAFORM_SOURCE}

set -euo pipefail

: ${WORKSPACE:=`jq -r '.[] | select(.name == "head_name").value' ./bpm-store-attachment/.git/resource/metadata.json | sed 's/[^a-zA-Z0-9]/_/g'`}
: ${TERRAFORM_SOURCE}
: ${TF_VAR_stage}
: ${AWS_REGION}
: ${S3_NAME}
: ${S3_KEY}

export TF_VAR_dns:=`echo $WORKSPACE | sed 's/_/-/g'`

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