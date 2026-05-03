# Project-specific automation
autoload -Uz add-zsh-hook
auto_matrix_venv() {
  local matrix_root="/home/pi/matrix"
  local matrix_venv="$matrix_root/venv"

  if [[ "$PWD" == $matrix_root(|/*) ]]; then
    if [[ -f "$matrix_venv/bin/activate" && "$VIRTUAL_ENV" != "$matrix_venv" ]]; then
      source "$matrix_venv/bin/activate"
    fi
  elif [[ "$VIRTUAL_ENV" == "$matrix_venv" ]]; then
    deactivate 2>/dev/null
  fi
}
add-zsh-hook chpwd auto_matrix_venv
auto_matrix_venv
