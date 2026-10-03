#!/usr/bin/env bash
set -euo pipefail

if command -v brew >/dev/null 2>&1 && [[ -d "$(brew --prefix helm@3 2>/dev/null)/bin" ]]; then
    export PATH="$(brew --prefix helm@3)/bin:${PATH}"
fi

if ! command -v helm >/dev/null 2>&1; then
    echo "[WARN] helm not found, skipping helm plugins." >&2
    exit 0
fi

# Helm 4 verifies plugin signatures and these plugins ship none. Helm 3 has no --verify flag.
VERIFY_FLAGS=()
if helm plugin install --help 2>&1 | grep -q -- '--verify'; then
    VERIFY_FLAGS=(--verify=false)
fi

install_plugin() {
    local name="$1" url="$2"
    if helm plugin list | awk 'NR>1 {print $1}' | grep -qx "${name}"; then
        echo "[INFO] helm plugin ${name} already installed."
        return 0
    fi
    helm plugin install "${url}" ${VERIFY_FLAGS[@]+"${VERIFY_FLAGS[@]}"}
}

install_plugin secrets https://github.com/jkroepke/helm-secrets
install_plugin unittest https://github.com/helm-unittest/helm-unittest.git
