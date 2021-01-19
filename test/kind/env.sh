#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export PATH="${SCRIPT_DIR}:${PATH}"
export KUBECONFIG="${SCRIPT_DIR}/.kube/config"

"$@"
