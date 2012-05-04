if [[ ! -o interactive ]]; then
    return
fi

compctl -K _denv denv

_denv() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(denv commands)"
  else
    completions="$(denv completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
