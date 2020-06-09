#!/bin/bash

# Destroys an environment and tears down the associated pipeline

set -euo pipefail

: ${WORKSPACE:="bpm"}
: ${CONFIGURATION:="attachment"}
: ${ENVIRONMENT:="sandbox"}
: ${HTTP_PROXY:="localhost:8118"}
: ${TARGET:=gcp}
: ${FLY:=fly -t ${TARGET}}

export HTTP_PROXY=${HTTP_PROXY}

pipeline="${ENVIRONMENT}-${WORKSPACE}-deploy-${CONFIGURATION}-lambda"

${FLY} trigger-job -j ${pipeline}/destroy -w  || {
    echo "Concourse destroy job failed - resources may already be deleted"
    exit 1
}
${FLY} destroy-pipeline -p ${pipeline} --non-interactive