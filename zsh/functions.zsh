# Create and enter directory
mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
}

# Matrix helpers
matrix-run() {
  cd /home/pi/matrix && ./run.sh
}

matrix-test() {
  cd /home/pi/matrix && python3 run_tests.py
}

# Fuzzy helpers
fh() {
  history 1 | fzf --tac --no-sort --query="$LBUFFER"
}

fcd() {
  local dir
  dir=$(find . -type d 2>/dev/null | fzf) && cd "$dir"
}

fe() {
  local file
  file=$(find . -type f 2>/dev/null | fzf) && "$EDITOR" "$file"
}
