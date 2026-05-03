#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.config/dotfiles"
ZSH_DIR="$DOTFILES_DIR/zsh"
GIT_DIR="$DOTFILES_DIR/git"
NANO_DIR="$DOTFILES_DIR/nano"

mkdir -p "$ZSH_DIR" "$GIT_DIR" "$NANO_DIR"

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
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

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
