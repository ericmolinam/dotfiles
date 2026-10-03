## Installation

Clone this repository to `~/dotfiles` and run:

```bash
cd ~/dotfiles
./install.sh
```

The script is safe to run multiple times:
- If a tool or package is already installed, it is skipped.
- Symlinks check existing targets and create automatic `.backup` copies before replacing if needed.
- `~/.zprofile` and `~/.zshrc` lines are checked before appending to avoid duplicate entries.

## Make targets

`make help` lists them. `make all` runs every step in order. Run one step with `make brew`, `make links`, `make gpg`, `make zsh`, `make helm`, `make claude`, `make macos` or `make prereqs`. `make check` checks script syntax and the Brewfile. `./install.sh <step>` does the same as `make <step>`.

## What gets installed

| Step | Source | Content |
|---|---|---|
| Homebrew | `Brewfile` | CLI tools (jq, yq, gh, tfenv, helm@3, sops, awscli, bat, git-delta, glow, go, node, lazydocker, herdr, hunk, ...) and casks (Brave, Claude, Docker, VS Code, Bitwarden, Slack, Rectangle, Maccy, DockDoor) |
| Config links | `git/`, `vscode/` | `~/.gitconfig`, `~/.gitignore_global`, VS Code settings |
| Shell | `zsh/.zshrc_custom`, `zsh/.zshrc_omz` | PATH and aliases; oh-my-zsh (agnoster, plugins `git kube-ps1 aws zsh-autosuggestions`) |
| gpg | `install.sh` | `gpg2` symlink to `gpg` (Homebrew `gnupg2`) |
| Helm | `helm/plugins.sh` | plugins `secrets`, `unittest` |
| Claude Code | `claude/install-claude.sh` | CLI, plugin `atlassian@claude-plugins-official`, skills `herdr`, `find-skills`, `terraform-skill` |
| macOS | `macos/defaults.sh` | system defaults |

Terraform versions are managed with `tfenv`. Company specific tools and env vars (Kodify plugin, `AWS_PROFILE`, `KODIFY_EMAIL`) are not tracked here.
