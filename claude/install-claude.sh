#!/usr/bin/env bash
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v claude >/dev/null 2>&1; then
    echo "[INFO] Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

PLUGIN="atlassian@claude-plugins-official"
if claude plugin list 2>/dev/null | grep -qF "${PLUGIN}"; then
    echo "[INFO] Claude plugin ${PLUGIN} already installed."
else
    claude plugin install "${PLUGIN}"
fi

if ! command -v npx >/dev/null 2>&1; then
    echo "[WARN] npx not found, skipping Claude skills." >&2
    exit 0
fi

SKILLS_LOCK="${HOME}/.agents/.skill-lock.json"
install_skill() {
    local name="$1" source="$2"
    if [[ -f "${SKILLS_LOCK}" ]] && grep -q "\"${name}\"" "${SKILLS_LOCK}"; then
        echo "[INFO] Claude skill ${name} already installed."
        return 0
    fi
    npx --yes skills add "${source}" --skill "${name}" -g -a claude-code -y
}

install_skill herdr herdrdev/herdr
install_skill find-skills vercel-labs/skills
install_skill terraform-skill https://github.com/antonbabenko/terraform-skill
