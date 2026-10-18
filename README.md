macOS configuration managed with GNU Stow.

---

```sh
xcode-select --install
```

Install [Homebrew](https://brew.sh):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow Homebrew's printed instructions to add `brew shellenv` to `~/.zprofile`
and load it in the current terminal. This file is not managed by Stow.

```sh
git clone https://github.com/ericmolinam/dotfiles.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"
brew bundle
```

Review `Brewfile` first and remove any applications you no longer want.

Skip either clone if its destination already exists.

```sh
git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
```

```sh
cd "$HOME/dotfiles"
backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
for file in .zshrc .gitconfig .gitignore_global; do
  if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
    mv "$HOME/$file" "$backup_dir/"
  fi
done

stow --simulate --verbose --no-folding --target="$HOME" git zsh
```

If the preview reports no conflicts, apply the links and restart the shell:

```sh
stow --verbose --no-folding --target="$HOME" git zsh
exec zsh -l
```

Optional setup:

Run either script as needed; the macOS script changes system preferences.

```sh
bash "$HOME/dotfiles/scripts/setup-claude.sh"
bash "$HOME/dotfiles/scripts/macos-defaults.sh"
```

Unlink configuration:

```sh
cd "$HOME/dotfiles"
stow --delete --no-folding --target="$HOME" git zsh
```