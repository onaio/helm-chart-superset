#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if [[ -z "$(helm repo list | grep architectminds)" ]]; then
    set -x
    helm repo add architectminds https://architectminds.github.io/helm-charts/
    helm repo update
    set +x
fi

ECR_URI=$1
TARGET_NAMESPACE=$2
ECR_ACCOUNT_NUMBER="$(printf $ECR_URI | sed 's/\(^[0-9]\+\).*/\1/')"
ECR_REGION="$(printf $ECR_URI | sed 's/.*\.\([^\.]\+\)\.amazonaws\.com.*/\1/')"
RELEASE_NAME="aws-ecr-credential-$ECR_ACCOUNT_NUMBER-$ECR_REGION"
# NOTE This is hardcoded, need to fork and host a helm repo to fix
SECRET_NAME="aws-registry"

if [[ -z "$ECR_URI" ]]; then
    echo "Specify an ECR name like <userid>.dkr.ecr.<region>.amazonaws.com"
    exit 0
fi

if [[ -z "$TARGET_NAMESPACE" ]]; then
    echo "Specify target namespace for the $SECRET_NAME secret"
    exit 0
fi

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
    echo "Specify AWS_ACCESS_KEY_ID"
    exit 0
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "Specify AWS_SECRET_ACCESS_KEY"
    exit 0
fi

if [[ ! -z "$(kubectl get secret --namespace $TARGET_NAMESPACE $SECRET_NAME)" ]]; then
    echo "Secret $SECRET_NAME is already present!"
fi

set -x
helm install --debug $RELEASE_NAME architectminds/aws-ecr-credential \
    --set-string aws.account=$ECR_ACCOUNT_NUMBER \
    --set-string aws.region=$ECR_REGION \
    --set-string aws.accessKeyId=$(printf $AWS_ACCESS_KEY_ID | base64 -) \
    --set-string aws.secretAccessKey=$(printf $AWS_SECRET_ACCESS_KEY | base64 -) \
    --set-string nameOverride=$SECRET_NAME \
    --set-string targetNamespace=$TARGET_NAMESPACE
set +x

while [[ -z "$(kubectl --namespace $RELEASE_NAME-ns logs job.batch/$RELEASE_NAME-job | grep patched)" ]]; do
    echo "Waiting for $RELEASE_NAME-job to finish..."
    sleep 1
done

set -x
kubectl describe --namespace $TARGET_NAMESPACE secret $SECRET_NAME
set +x
