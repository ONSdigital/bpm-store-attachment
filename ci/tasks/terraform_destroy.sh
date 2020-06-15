#!/bin/bash

set -euo pipefail

: ${WORKSPACE}
: ${AWS_REGION}
: ${S3_NAME}
: ${S3_KEY}

. ./bpm-store-attachment/ci/tasks/util/assume_role.sh
. ./bpm-store-attachment/ci/tasks/util/setup_terraform.sh

terraform destroy --auto-approve

echo "done"