#!/bin/bash

set -euo pipefail

: ${WORKSPACE:=`jq -r '.[] | select(.name == "head_name").value' ./bpm-store-attachment/.git/resource/metadata.json | sed 's/[^a-zA-Z0-9]/_/g'`}
: ${AWS_REGION}
: ${TF_VAR_stage}
: ${S3_NAME}
: ${S3_KEY}

export TF_VAR_dns=`echo $WORKSPACE | sed 's/_/-/g'`

. ./bpm-store-attachment/ci/tasks/util/assume_role.sh
. ./bpm-store-attachment/ci/tasks/util/setup_terraform.sh

terraform destroy --auto-approve

echo "done"