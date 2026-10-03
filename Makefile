.DEFAULT_GOAL := help
STEPS := prereqs brew links gpg zsh helm claude macos

.PHONY: help all check $(STEPS)

help: ## List the available targets
	@grep -hE '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'

all: ## Run every step in order
	@./install.sh

prereqs: ## Rosetta 2 and Xcode Command Line Tools
	@./install.sh prereqs

brew: ## Homebrew and the Brewfile
	@./install.sh brew

links: ## Symlink git and VS Code config
	@./install.sh links

gpg: ## Create the gpg2 symlink
	@./install.sh gpg

zsh: ## Custom zsh config, oh-my-zsh and plugins
	@./install.sh zsh

helm: ## Helm plugins
	@./install.sh helm

claude: ## Claude CLI, plugin and skills
	@./install.sh claude

macos: ## macOS defaults
	@./install.sh macos

check: ## Syntax check scripts and verify the Brewfile
	@for f in install.sh helm/plugins.sh claude/install-claude.sh macos/defaults.sh; do bash -n $$f && echo "ok $$f"; done
	@brew bundle check --file=Brewfile
