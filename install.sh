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

log_info "Starting dotfiles setup from ${DOTFILES_DIR} (Architecture: ${ARCH})..."

# 1. Rosetta 2
if [[ "${ARCH}" == "arm64" ]]; then
    if arch -x86_64 /usr/bin/true 2>/dev/null; then
        log_info "Rosetta 2 is already installed."
    else
        log_info "Installing Rosetta 2..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        log_success "Rosetta 2 installed."
    fi
fi

# 2. Xcode Command Line Tools
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

# 3. Homebrew
if [[ "${ARCH}" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi
BREW_BIN="${BREW_PREFIX}/bin/brew"

if command -v brew >/dev/null 2>&1; then
    BREW_BIN="$(command -v brew)"
    log_info "Homebrew found at ${BREW_BIN}."
elif [[ -x "${BREW_BIN}" ]]; then
    log_info "Homebrew found at ${BREW_BIN}."
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_success "Homebrew installed."
fi

eval "$("${BREW_BIN}" shellenv)"

ZPROFILE="${HOME}/.zprofile"
SHELLENV_CMD="eval \"\$(${BREW_BIN} shellenv)\""
if [[ -f "${ZPROFILE}" ]] && grep -qF "${BREW_BIN} shellenv" "${ZPROFILE}"; then
    log_info "Homebrew shellenv already configured in ${ZPROFILE}."
else
    log_info "Adding Homebrew shellenv to ${ZPROFILE}..."
    echo -e "\n# Homebrew environment\n${SHELLENV_CMD}" >> "${ZPROFILE}"
    log_success "Homebrew added to ${ZPROFILE}."
fi

# 4. Install packages via Brewfile
BREWFILE="${DOTFILES_DIR}/Brewfile"
if [[ -f "${BREWFILE}" ]]; then
    log_info "Updating Homebrew formulae..."
    brew update --quiet
    log_info "Running brew bundle to install CLI tools, apps, and extensions..."
    brew bundle install --file="${BREWFILE}"
    log_success "Brewfile packages are up to date."
else
    log_warn "No Brewfile found at ${BREWFILE}. Skipping package installation."
fi

# 5. Dotfiles configuration
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

log_info "Linking configuration files..."

# Git config & global ignore
create_symlink "${DOTFILES_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
create_symlink "${DOTFILES_DIR}/git/.gitignore_global" "${HOME}/.gitignore_global"

# VS Code settings
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
create_symlink "${DOTFILES_DIR}/vscode/settings.json" "${VSCODE_USER_DIR}/settings.json"

# Custom zsh sourcing in ~/.zshrc
ZSHRC="${HOME}/.zshrc"
CUSTOM_SOURCE="[[ -f \"${DOTFILES_DIR}/zsh/.zshrc_custom\" ]] && source \"${DOTFILES_DIR}/zsh/.zshrc_custom\""
if [[ -f "${ZSHRC}" ]] && grep -qF ".zshrc_custom" "${ZSHRC}"; then
    log_info "Custom zsh config already sourced in ${ZSHRC}."
else
    log_info "Adding custom zsh config source to ${ZSHRC}..."
    echo -e "\n# Sourced from dotfiles\n${CUSTOM_SOURCE}" >> "${ZSHRC}"
    log_success "Custom zsh aliases & config sourced in ${ZSHRC}."
fi

# 6. macOS defaults
MACOS_DEFAULTS="${DOTFILES_DIR}/macos/defaults.sh"
if [[ -f "${MACOS_DEFAULTS}" ]]; then
    chmod +x "${MACOS_DEFAULTS}"
    log_info "Applying macOS system defaults..."
    "${MACOS_DEFAULTS}"
    log_success "macOS defaults applied."
fi

log_success "Dotfiles initialization complete!"
