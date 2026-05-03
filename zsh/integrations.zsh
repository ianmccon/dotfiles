# Editor
export EDITOR='nano'

# Optional enhancements (load when present)
[[ -f "/usr/share/doc/fzf/examples/completion.zsh" ]] && source "/usr/share/doc/fzf/examples/completion.zsh"
[[ -f "/usr/share/doc/fzf/examples/key-bindings.zsh" ]] && source "/usr/share/doc/fzf/examples/key-bindings.zsh"
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

if [[ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# fast-syntax-highlighting (replaces zsh-syntax-highlighting)
if [[ -f "$HOME/.local/share/zsh-plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.local/share/zsh-plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
elif [[ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# zsh-history-substring-search (must load AFTER syntax-highlighting)
[[ -f "$HOME/.local/share/zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && \
  source "$HOME/.local/share/zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

# zoxide — frecency-based cd replacement
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Ctrl+R: timestamped fuzzy history picker
fzf_history_widget() {
  local selected cmd
  selected=$(awk -F';' '
    /^: [0-9]+:[0-9]+;/ {
      ts=$1
      sub(/^: /, "", ts)
      split(ts, a, ":")
      epoch=a[1]
      cmd=$2
      sub(/^[ \t]+/, "", cmd)
      printf("%s  %s\\n", strftime("%Y-%m-%d %H:%M", epoch), cmd)
    }
  ' "$HISTFILE" 2>/dev/null | tac | awk '!seen[$0]++' | fzf --height 40% --reverse --prompt='history> ')

  [[ -z "$selected" ]] && return 0
  cmd="${selected#*  }"
  LBUFFER="$cmd"
  zle redisplay
}
zle -N fzf_history_widget
bindkey '^R' fzf_history_widget
