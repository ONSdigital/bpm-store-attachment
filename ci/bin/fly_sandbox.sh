#!/bin/bash

# Sets up a new sandbox deployment pipeline

set -euo pipefail

: $WORKSPACE
: ${AWS_REGION:="eu-west-2"}
: ${HTTP_PROXY:="localhost:8118"}
: ${BRANCH:="master"}
: ${TARGET:=gcp}
: ${FLY:=fly -t ${TARGET}}
: ${EXTRA_OPTIONS:=""}

if [[ ${WORKSPACE} =~ - ]]; then
    echo "Terraform workspace '${WORKSPACE}' cannot contain '-' (breaks some resource names)"
    exit 1
fi

export HTTP_PROXY=${HTTP_PROXY}

pipeline="${WORKSPACE}-deploy-attachment-lambda"

${FLY} set-pipeline \
    -p ${pipeline} \
    -c ci/pipeline.yml \
    -v "workspace=${WORKSPACE}" \
    -v "aws_region=${AWS_REGION}" \
    -v "environment=sandbox" \
    -v "branch=${BRANCH}" \
    ${EXTRA_OPTIONS}

${FLY} unpause-pipeline \
    -p ${pipeline}