# Prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'

prompt_precmd() {
  vcs_info
  if [[ -n "$VIRTUAL_ENV" ]]; then
    PROMPT_VENV="%F{green}[${VIRTUAL_ENV:t}]%f "
  else
    PROMPT_VENV=""
  fi
}
precmd_functions+=(prompt_precmd)

setopt PROMPT_SUBST
PROMPT='${PROMPT_VENV}%F{cyan}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}\n%(?.%F{green}❯%f.%F{red}❯%f) '
RPROMPT='%(?..%F{red}[%?]%f )%F{yellow}%D{%H:%M}%f'
