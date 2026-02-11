function current_gcp_project() {
  if [ -n "${CLOUDSDK_ACTIVE_CONFIG_NAME:-}" ]; then
    echo "${CLOUDSDK_ACTIVE_CONFIG_NAME}"
  fi
}

function init_gcloud_project() {
  local selected
  selected=$(
    {
      gcloud config configurations list --format="value(name)" 2>/dev/null
      echo "[new]"
    } | fzf --prompt="gcloud config> "
  ) || return

  if [ "$selected" = "[new]" ]; then
    printf "Config name: " && read -r config_name
    [ -z "$config_name" ] && return 1
    printf "Project ID: " && read -r project_id
    [ -z "$project_id" ] && return 1

    gcloud config configurations create "$config_name"
    gcloud config set project "$project_id" --configuration="$config_name"
    selected="$config_name"
  fi

  local line="export CLOUDSDK_ACTIVE_CONFIG_NAME=${selected}"

  if [ -f .envrc ] && grep -q "CLOUDSDK_ACTIVE_CONFIG_NAME" .envrc; then
    sed -i '' "s|^export CLOUDSDK_ACTIVE_CONFIG_NAME=.*|${line}|" .envrc
    echo "Updated .envrc: ${selected}"
  else
    echo "$line" >> .envrc
    echo "Added to .envrc: ${selected}"
  fi

  direnv allow
}

function init_aws_profile() {
  local selected
  selected=$(
    {
      aws configure list-profiles 2>/dev/null
      echo "[new]"
    } | fzf --prompt="aws profile> "
  ) || return

  if [ "$selected" = "[new]" ]; then
    printf "Profile name: " && read -r profile_name
    [ -z "$profile_name" ] && return 1
    aws configure --profile "$profile_name"
    selected="$profile_name"
  fi

  local line_profile="export AWS_PROFILE=${selected}"
  local line_region=""

  printf "Region (leave empty to skip): " && read -r region
  [ -n "$region" ] && line_region="export AWS_DEFAULT_REGION=${region}"

  if [ -f .envrc ] && grep -q "AWS_PROFILE" .envrc; then
    sed -i '' "s|^export AWS_PROFILE=.*|${line_profile}|" .envrc
    echo "Updated .envrc: AWS_PROFILE=${selected}"
  else
    echo "$line_profile" >> .envrc
    echo "Added to .envrc: AWS_PROFILE=${selected}"
  fi

  if [ -n "$line_region" ]; then
    if [ -f .envrc ] && grep -q "AWS_DEFAULT_REGION" .envrc; then
      sed -i '' "s|^export AWS_DEFAULT_REGION=.*|${line_region}|" .envrc
    else
      echo "$line_region" >> .envrc
    fi
    echo "Region: ${region}"
  fi

  direnv allow
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
