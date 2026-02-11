function current_gcp_project() {
  if [ -n "${CLOUDSDK_ACTIVE_CONFIG_NAME:-}" ]; then
    echo "${CLOUDSDK_ACTIVE_CONFIG_NAME}"
  fi
}

gcsavro() {
  for f in $(gsutil ls "$1"); do
    gsutil cat "$f" | avro-tools tojson - | jq
  done
}

function ghql() {
  local src
  src=$(ghq list | fzf --preview "/bin/ls -laTp $(ghq root)/{} | tail -n+4 | awk '{print \$9\"/\"\$6\"/\"\$7 \" \" \$10}'")
  [ -n "$src" ] && cd "$(ghq root)/$src"
}

function gitc() {
  local branches branch
  branches=$(git branch | sed -e 's/^\* //g' | sed -e 's/^  //g' | cut -d " " -f 1) &&
    branch=$(echo "$branches" | fzf --preview "git log --graph --full-history --color --first-parent {}") &&
    git checkout "$branch"
}

function git-delete-merged-branch() {
  local target_branch=${1:-main}
  local exclude_branches='main|master|develop'
  local branches_to_delete=()

  git checkout -q "$target_branch" || return 1

  while read -r branch; do
    merge_base=$(git merge-base "$target_branch" "$branch")
    if [[ $(git cherry "$target_branch" $(git commit-tree $(git rev-parse "$branch^{tree}") -p "$merge_base" -m _)) == "-"* ]]; then
      branches_to_delete+=("$branch")
    fi
  done < <(git for-each-ref refs/heads/ '--format=%(refname:short)' | grep -Ev "$exclude_branches")

  if [ ${#branches_to_delete[@]} -eq 0 ]; then
    echo "No merged branches found to delete."
    return 0
  fi

  echo "The following branches will be deleted:"
  printf '%s\n' "${branches_to_delete[@]}"

  printf "Do you want to delete these branches? [Y/n] "
  read answer
  case $answer in
    [Yy]* )
      for branch in "${branches_to_delete[@]}"; do
        git branch -D "$branch"
        echo "Deleted branch: $branch"
      done
      ;;
    * )
      echo "Operation cancelled. No branches were deleted."
      ;;
  esac
}
