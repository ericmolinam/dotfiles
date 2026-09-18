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
