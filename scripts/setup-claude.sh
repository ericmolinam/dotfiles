#!/usr/bin/env bash
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v claude >/dev/null 2>&1; then
    echo "[INFO] Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

if ! command -v npx >/dev/null 2>&1; then
    echo "[WARN] npx not found, skipping Claude skills." >&2
    exit 0
fi

SKILLS_LOCK="${HOME}/.agents/.skill-lock.json"
install_skill() {
    local name="$1" source="$2"
    if [[ -f "${SKILLS_LOCK}" ]] && grep -q "\"${name}\"" "${SKILLS_LOCK}"; then
        echo "[INFO] Skill ${name} already installed."
        return 0
    fi
    npx --yes skills add "${source}" --skill "${name}" -g -a claude-code -y
}

install_skill herdr herdrdev/herdr
