#!/bin/bash

# Build the site
hugo

if [ $? -eq 0 ]
then
  echo "Successfully built site."

  # Run spelling check after the site build
  echo "Running spelling check..."
  find content/ -name "*.md" ! -name "rich-content.md" ! -name "placeholder-text.md" ! -name "markdown-syntax.md" -exec hunspell -l {} \; | sort -u | while read word; do
    # Find the file containing the misspelled word, show context, and color the misspelled word yellow
    grep -H -o -E '\b(\w+\s){0,2}'"$word"'\s(\w+\s){0,2}\w+\b' content/**/*.md | \
    sed "s/\b$word\b/\x1b[33m&\x1b[0m/g"
  done | sort -u

  # Prompt user for confirmation to continue or exit after spelling check
  read -p "--> Do you want to continue with deployment despite spelling errors? (y/n): " user_input
  if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
    echo "Proceeding with deployment..."

    # Commit and push changes
    git add -A
    commit_ret=$(git commit -m "$(date) commit to master")
    if [[ $commit_ret == *"nothing to commit"* ]]; then
      echo "No changes to commit, exiting publish step."
      exit 0
    else
      git push
      scp -r public/ /home/linux/docker-data/virtualbeck_blog/
      cd ~/docker-data/traefik && docker-compose restart virtualbeck_nginx
    fi
  else
    echo "Deployment aborted due to spelling errors."
    exit 1
  fi
else
  echo "Build failed..." >&2
  exit 1
fi

