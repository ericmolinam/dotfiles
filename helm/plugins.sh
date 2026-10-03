#!/usr/bin/env bash
set -euo pipefail

if ! command -v helm >/dev/null 2>&1; then
    echo "[WARN] helm not found, skipping helm plugins." >&2
    exit 0
fi

install_plugin() {
    local name="$1" url="$2"
    shift 2
    if helm plugin list | awk 'NR>1 {print $1}' | grep -qx "${name}"; then
        echo "[INFO] helm plugin ${name} already installed."
        return 0
    fi
    helm plugin install "${url}" "$@"
}

install_plugin secrets https://github.com/jkroepke/helm-secrets --verify=false
install_plugin unittest https://github.com/helm-unittest/helm-unittest.git
