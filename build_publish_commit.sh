#!/bin/bash

# Define the path to the local dictionary file
LOCAL_DICTIONARY="local_dictionary.txt"

# Build the site
hugo

if [ $? -eq 0 ]
then
  echo "Successfully built site."

  # Run spelling check after the site build and store misspelled words in an array
  echo "Running spelling check..."
  MISSPELLED_WORDS=()

  find content/ -name "*.md" ! -name "rich-content.md" ! -name "placeholder-text.md" ! -name "markdown-syntax.md" -exec hunspell -l {} \; | sort -u | while read word; do
    # Store the misspelled word in the array
    MISSPELLED_WORDS+=("$word")

    # Find the file containing the misspelled word, show context, and color the misspelled word yellow
    grep -H -o -E '\b(\w+\s){0,2}'"$word"'\s(\w+\s){0,2}\w+\b' content/**/*.md | \
    sed "s/\b$word\b/\x1b[33m&\x1b[0m/g"
  done

  # Prompt user for confirmation to continue or exit after spelling check
  read -p "Do you want to continue with deployment despite spelling errors? (y/n): " user_input
  if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
    echo "Proceeding with deployment..."

    # Ask the user if they want to add any misspelled words to the local dictionary
    for word in "${MISSPELLED_WORDS[@]}"; do
      read -p "Do you want to add the word '$word' to the local dictionary? (y/n): " add_word
      if [[ "$add_word" == "y" || "$add_word" == "Y" ]]; then
        # Add the word to the local dictionary if it's not already there
        if ! grep -Fxq "$word" "$LOCAL_DICTIONARY"; then
          echo "$word" >> "$LOCAL_DICTIONARY"
          echo "Added '$word' to the local dictionary."
        else
          echo "'$word' is already in the local dictionary."
        fi
      fi
    done

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

