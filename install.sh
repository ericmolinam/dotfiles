#!/usr/bin/env bash
set -euo pipefail

# --- Color formatting helpers ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Dotfiles root directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH="$(uname -m)"
ZSHRC="${HOME}/.zshrc"

STEPS=(prereqs brew links gpg zsh helm claude macos)

load_brew() {
    local brew_bin
    if command -v brew >/dev/null 2>&1; then
        brew_bin="$(command -v brew)"
    elif [[ -x /opt/homebrew/bin/brew ]]; then
        brew_bin=/opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
        brew_bin=/usr/local/bin/brew
    else
        log_error "Homebrew not found. Run the brew step first."
        return 1
    fi
    eval "$("${brew_bin}" shellenv)"
}

step_prereqs() {
    if [[ "${ARCH}" == "arm64" ]]; then
        if arch -x86_64 /usr/bin/true 2>/dev/null; then
            log_info "Rosetta 2 is already installed."
        else
            log_info "Installing Rosetta 2..."
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
            log_success "Rosetta 2 installed."
        fi
    fi

    if xcode-select -p >/dev/null 2>&1; then
        log_info "Xcode Command Line Tools already installed."
    else
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        until xcode-select -p >/dev/null 2>&1; do
            sleep 5
        done
        log_success "Xcode Command Line Tools installed."
    fi
}

step_brew() {
    local brew_prefix brew_bin
    if [[ "${ARCH}" == "arm64" ]]; then
        brew_prefix="/opt/homebrew"
    else
        brew_prefix="/usr/local"
    fi
    brew_bin="${brew_prefix}/bin/brew"

    if command -v brew >/dev/null 2>&1; then
        brew_bin="$(command -v brew)"
        log_info "Homebrew found at ${brew_bin}."
    elif [[ -x "${brew_bin}" ]]; then
        log_info "Homebrew found at ${brew_bin}."
    else
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_success "Homebrew installed."
    fi

    eval "$("${brew_bin}" shellenv)"

    local zprofile="${HOME}/.zprofile"
    local shellenv_cmd="eval \"\$(${brew_bin} shellenv)\""
    if [[ -f "${zprofile}" ]] && grep -qF "${brew_bin} shellenv" "${zprofile}"; then
        log_info "Homebrew shellenv already configured in ${zprofile}."
    else
        log_info "Adding Homebrew shellenv to ${zprofile}..."
        echo -e "\n# Homebrew environment\n${shellenv_cmd}" >> "${zprofile}"
        log_success "Homebrew added to ${zprofile}."
    fi

    local brewfile="${DOTFILES_DIR}/Brewfile"
    if [[ -f "${brewfile}" ]]; then
        log_info "Updating Homebrew formulae..."
        brew update --quiet
        log_info "Running brew bundle to install CLI tools, apps, and extensions..."
        brew bundle install --file="${brewfile}"
        log_success "Brewfile packages are up to date."
    else
        log_warn "No Brewfile found at ${brewfile}. Skipping package installation."
    fi
}

create_symlink() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "${dest}")"

    if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
        log_info "Symlink already correct: ${dest} -> ${src}"
        return 0
    fi

    if [[ -e "${dest}" || -L "${dest}" ]]; then
        log_warn "Backing up existing ${dest} to ${dest}.backup"
        mv -f "${dest}" "${dest}.backup"
    fi

    ln -s "${src}" "${dest}"
    log_success "Created symlink: ${dest} -> ${src}"
}

step_links() {
    log_info "Linking configuration files..."
    create_symlink "${DOTFILES_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
    create_symlink "${DOTFILES_DIR}/git/.gitignore_global" "${HOME}/.gitignore_global"

    local vscode_user_dir="${HOME}/Library/Application Support/Code/User"
    create_symlink "${DOTFILES_DIR}/vscode/settings.json" "${vscode_user_dir}/settings.json"
}

step_gpg() {
    load_brew
    local gpg_bin gpg2_bin
    gpg_bin="$(brew --prefix)/bin/gpg"
    gpg2_bin="$(brew --prefix)/bin/gpg2"
    if [[ -x "${gpg_bin}" && ! -e "${gpg2_bin}" ]]; then
        ln -s "${gpg_bin}" "${gpg2_bin}"
        log_success "Created symlink: ${gpg2_bin} -> ${gpg_bin}"
    else
        log_info "gpg2 symlink already present or gpg not installed."
    fi
}

step_zsh() {
    local custom_source
    custom_source="[[ -f \"${DOTFILES_DIR}/zsh/.zshrc_custom\" ]] && source \"${DOTFILES_DIR}/zsh/.zshrc_custom\""
    if [[ -f "${ZSHRC}" ]] && grep -qF ".zshrc_custom" "${ZSHRC}"; then
        log_info "Custom zsh config already sourced in ${ZSHRC}."
    else
        log_info "Adding custom zsh config source to ${ZSHRC}..."
        echo -e "\n# Sourced from dotfiles\n${custom_source}" >> "${ZSHRC}"
        log_success "Custom zsh aliases & config sourced in ${ZSHRC}."
    fi

    local omz_dir="${HOME}/.oh-my-zsh"
    if [[ -d "${omz_dir}" ]]; then
        log_info "oh-my-zsh already installed."
    else
        log_info "Installing oh-my-zsh..."
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        log_success "oh-my-zsh installed."
    fi

    local autosuggestions_dir="${ZSH_CUSTOM:-${omz_dir}/custom}/plugins/zsh-autosuggestions"
    if [[ -d "${autosuggestions_dir}" ]]; then
        log_info "zsh-autosuggestions already installed."
    else
        log_info "Installing zsh-autosuggestions..."
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${autosuggestions_dir}"
        log_success "zsh-autosuggestions installed."
    fi

    local omz_source
    omz_source="[[ -f \"${DOTFILES_DIR}/zsh/.zshrc_omz\" ]] && source \"${DOTFILES_DIR}/zsh/.zshrc_omz\""
    if [[ -f "${ZSHRC}" ]] && grep -qE "\.zshrc_omz|oh-my-zsh\.sh" "${ZSHRC}"; then
        log_info "oh-my-zsh already configured in ${ZSHRC}."
    else
        log_info "Adding oh-my-zsh config source to ${ZSHRC}..."
        echo -e "\n# oh-my-zsh from dotfiles\n${omz_source}" >> "${ZSHRC}"
        log_success "oh-my-zsh config sourced in ${ZSHRC}."
    fi
}

step_helm() {
    load_brew
    log_info "Installing helm plugins..."
    "${DOTFILES_DIR}/helm/plugins.sh"
}

step_claude() {
    load_brew
    log_info "Setting up Claude Code..."
    "${DOTFILES_DIR}/claude/install-claude.sh"
}

step_macos() {
    local macos_defaults="${DOTFILES_DIR}/macos/defaults.sh"
    if [[ -f "${macos_defaults}" ]]; then
        chmod +x "${macos_defaults}"
        log_info "Applying macOS system defaults..."
        "${macos_defaults}"
        log_success "macOS defaults applied."
    fi
}

run_step() {
    local step="$1"
    if ! declare -F "step_${step}" >/dev/null; then
        log_error "Unknown step: ${step}. Valid steps: ${STEPS[*]}"
        exit 1
    fi
    "step_${step}"
}

if [[ $# -eq 0 ]]; then
    log_info "Starting dotfiles setup from ${DOTFILES_DIR} (Architecture: ${ARCH})..."
    for step in "${STEPS[@]}"; do
        run_step "${step}"
    done
    log_success "Dotfiles initialization complete!"
else
    for step in "$@"; do
        run_step "${step}"
    done
fi
