#!/bin/bash

# Sets up a new deployment pipeline
# Make sure to set the correct environment variable (sandbox, cicd, staging or prod)

set -euo pipefail

: $WORKSPACE
: $ENVIRONMENT
: $STAGE
: ${AWS_REGION:="eu-west-2"}
: ${HTTP_PROXY:="localhost:8118"}
: $BRANCH
: ${TARGET:=gcp}
: ${FLY:=fly -t ${TARGET}}
: ${EXTRA_OPTIONS:=""}

if [[ ${WORKSPACE} =~ - ]]; then
    echo "Terraform workspace '${WORKSPACE}' cannot contain '-' (breaks some resource names)"
    exit 1
fi

export HTTP_PROXY=${HTTP_PROXY}

pipeline="${ENVIRONMENT}-${WORKSPACE}-deploy-${CONFIGURATION}-lambda"

${FLY} set-pipeline \
    -p ${pipeline} \
    -c ci/pipeline.yml \
    -v "workspace=${WORKSPACE}" \
    -v "aws_region=${AWS_REGION}" \
    -v "environment=${ENVIRONMENT}" \
    -v "branch=${BRANCH}" \
    -v "stage=${STAGE}" \
    ${EXTRA_OPTIONS}

${FLY} unpause-pipeline \
    -p ${pipeline}