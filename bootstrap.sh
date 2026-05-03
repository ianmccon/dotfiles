#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.config/dotfiles"
ZSH_DIR="$DOTFILES_DIR/zsh"
GIT_DIR="$DOTFILES_DIR/git"
NANO_DIR="$DOTFILES_DIR/nano"

PLUGINS_DIR="$HOME/.local/share/zsh-plugins"
mkdir -p "$ZSH_DIR" "$GIT_DIR" "$NANO_DIR" "$PLUGINS_DIR"

# Install/update Zsh plugins (shallow clones)
_clone_or_pull() {
  local repo="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only --quiet
  else
    git clone --depth=1 "$repo" "$dest"
  fi
}
_clone_or_pull https://github.com/zsh-users/zsh-completions.git \
  "$PLUGINS_DIR/zsh-completions"
_clone_or_pull https://github.com/zsh-users/zsh-history-substring-search.git \
  "$PLUGINS_DIR/zsh-history-substring-search"
_clone_or_pull https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  "$PLUGINS_DIR/fast-syntax-highlighting"

# Install apt extras (ignore errors if offline)
sudo apt-get install -y zoxide 2>/dev/null || true

# Ensure core dotfiles files exist; do not overwrite existing content.
for f in \
  "$ZSH_DIR/options.zsh" \
  "$ZSH_DIR/history.zsh" \
  "$ZSH_DIR/completion.zsh" \
  "$ZSH_DIR/integrations.zsh" \
  "$ZSH_DIR/keybindings.zsh" \
  "$ZSH_DIR/prompt.zsh" \
  "$ZSH_DIR/project.zsh" \
  "$ZSH_DIR/aliases.zsh" \
  "$ZSH_DIR/functions.zsh" \
  "$GIT_DIR/config" \
  "$NANO_DIR/nanorc"

do
  [[ -f "$f" ]] || touch "$f"
done

# Write/refresh ~/.zshrc loader.
cat > "$HOME/.zshrc" <<'EOF'
# Zsh loader (modular dotfiles setup)
for f in \
  "$HOME/.config/dotfiles/zsh/options.zsh" \
  "$HOME/.config/dotfiles/zsh/history.zsh" \
  "$HOME/.config/dotfiles/zsh/completion.zsh" \
  "$HOME/.config/dotfiles/zsh/integrations.zsh" \
  "$HOME/.config/dotfiles/zsh/keybindings.zsh" \
  "$HOME/.config/dotfiles/zsh/prompt.zsh" \
  "$HOME/.config/dotfiles/zsh/project.zsh" \
  "$HOME/.config/dotfiles/zsh/aliases.zsh" \
  "$HOME/.config/dotfiles/zsh/functions.zsh"
do
  [[ -f "$f" ]] && source "$f"
done

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
EOF

# Ensure ~/.gitconfig includes shared git config.
if [[ ! -f "$HOME/.gitconfig" ]]; then
  cat > "$HOME/.gitconfig" <<'EOF'
[include]
	path = ~/.config/dotfiles/git/config
EOF
elif ! grep -q "~/.config/dotfiles/git/config" "$HOME/.gitconfig"; then
  {
    echo
    echo "[include]"
    echo "\tpath = ~/.config/dotfiles/git/config"
  } >> "$HOME/.gitconfig"
fi

# Ensure ~/.nanorc includes shared nano config.
if [[ ! -f "$HOME/.nanorc" ]]; then
  echo 'include "~/.config/dotfiles/nano/nanorc"' > "$HOME/.nanorc"
elif ! grep -q "~/.config/dotfiles/nano/nanorc" "$HOME/.nanorc"; then
  echo 'include "~/.config/dotfiles/nano/nanorc"' >> "$HOME/.nanorc"
fi

echo "Dotfiles bootstrap complete."
echo "Run: source ~/.zshrc"
