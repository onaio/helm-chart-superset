#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

KUBECTL_EXE="${SCRIPT_DIR}/kubectl"

if [[ ! -f "${KUBECTL_EXE}" ]]; then
    set -x
    curl -Lo "${KUBECTL_EXE}" "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kubectl"
    chmod +x "${KUBECTL_EXE}"
    set +x
fi

HELM_EXE="${SCRIPT_DIR}/helm"

if [[ ! -f "${HELM_EXE}" ]]; then
    HELM_TGZ="${HELM_EXE}.tar.gz"
    set -x
    curl -Lo "${HELM_TGZ}" "https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz"
    tar -xvf "${HELM_TGZ}" -C "${SCRIPT_DIR}" "linux-amd64/helm"
    mv "${SCRIPT_DIR}/linux-amd64/helm" "${HELM_EXE}"
    rm -rf "${HELM_TGZ}" "${SCRIPT_DIR}/linux-amd64"
    chmod +x "${HELM_EXE}"
    set +x
fi

KIND_EXE="${SCRIPT_DIR}/kind"

if [[ ! -f "${KIND_EXE}" ]]; then
    set -x
    curl -Lo "${KIND_EXE}" https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
    chmod +x "${KIND_EXE}"
    set +x
fi

YQ_EXE="${SCRIPT_DIR}/yq"

if [[ ! -f "${YQ_EXE}" ]]; then
    set -x
    curl -Lo "${YQ_EXE}" https://github.com/mikefarah/yq/releases/download/3.4.0/yq_linux_amd64
    chmod +x "${YQ_EXE}"
    set +x
fi

export PATH="${SCRIPT_DIR}:${PATH}"
export KUBECONFIG="${SCRIPT_DIR}/.kube/config"

CLUSTER_NAME="${CLUSTER_NAME:-kind}"

#CLEAN_CLUSTER=
if [[ ! -z "${CLEAN_CLUSTER}" ]]; then
    set -x
    kind delete cluster --name "${CLUSTER_NAME}"
    set +x
fi

EXISTING_CLUSTER="$("${KIND_EXE}" get clusters | grep -e "^${CLUSTER_NAME}\$")"

if [[ -z "${EXISTING_CLUSTER}" ]]; then
    set -x
    kind create cluster --name "${CLUSTER_NAME}"
    set +x
fi

echo ""
echo "KIND clusters:"
kind get clusters

echo ""
echo "Cluster info:"
kubectl cluster-info
