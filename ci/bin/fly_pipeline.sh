#!/bin/bash

# Sets up a new deployment pipeline
# Make sure to set the correct environment variable (sandbox, cicd, staging or prod)

set -euo pipefail

: $ENVIRONMENT
: $STAGE
: ${AWS_REGION:="eu-west-2"}
: ${HTTP_PROXY:="localhost:8118"}
: ${TARGET:=gcp}
: ${FLY:=../fly -t ${TARGET}}
: ${EXTRA_OPTIONS:=""}

export HTTP_PROXY=${HTTP_PROXY}

pipeline="prices-store-attachments-${ENVIRONMENT}"

${FLY} set-pipeline \
    -p ${pipeline} \
    -c ci/pipeline.yml \
    -v "aws_region=${AWS_REGION}" \
    -v "environment=${ENVIRONMENT}" \
    -v "stage=${STAGE}" \
    ${EXTRA_OPTIONS}

${FLY} unpause-pipeline \
    -p ${pipeline}