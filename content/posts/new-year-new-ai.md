---
author: Mike
title: "new year, new ai"
date: 2025-01-16
draft: false
---

Listen to this article:
{{< audio "/audio/ai_slop.mp3" >}}<br>

Because new year, new me felt too contrived. I'm going to have a new section of the website called [ai_slop](https://blog.virtualbeck.com/ai_slop/) where I'm ~~forcing~~ asking a local llm (probably lamma3.2:3b) to write webpages based on user input.

This is, of course, crap content. That needs to be clear upfront. I've tucked it away in the site from the frontpage so as not to risk anyone from accidently reading it and thinking that these are _my_ thoughts.

I'm doing this because I thought it might be a fun exercise. Posting this here now as a placeholder, and I'll update below the script I'm using locally when I get more time. Look in the upper right hand for the link, and enjoy (or not)!

````bash
#!/bin/bash

# Check if exactly 1 argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <prompt>"
  exit 1
fi

PROMPT="$1"

# Fetch the list of models using curl and jq
MODELS=$(curl -s minim2:8080/api/tags | jq -r '.models[].name')

# Print the available models with numbering
echo "Available models:"
echo "$MODELS" | nl -s '. '

# Ask the user to select a model
echo "Please select a model by entering the number:"
read -r choice

# Determine the model based on user input
MODEL=$(echo "$MODELS" | sed -n "${choice}p")

if [[ -z "$MODEL" ]]; then
  echo "Invalid selection. Exiting."
  exit 1
fi

# Output the prompt for validation
echo "--> Prompt: $PROMPT"
echo "--> Model: $MODEL"
echo "--> Processing..."

# set vars for page, and touch it
DATE=$(date "+%Y_%m_%d_%H%M%S_CST")
PAGE=~/personal/webpage_generator/$DATE.md
touch $PAGE

# Remove newlines and unwanted whitespace from PROMPT
PROMPT_CLEANED=$(echo "$PROMPT" | tr -d '\n' | sed 's/[[:space:]]\+/ /g' | sed "s/'/\\\'/g" | sed 's/"/\\\"/g' | sed 's/\\/\\\\/g')

# generate content
API_RESPONSE=$(curl -s minim2:8080/api/generate -d "$(printf '{"model": "%s", "prompt": "%s", "stream": false}' "$MODEL" "$PROMPT_CLEANED")" | jq -r '.')
CONTENT=$(jq -r '.response' <<<"$API_RESPONSE")
TOTAL_DURATION=$(jq -r '.total_duration' <<<"$API_RESPONSE")
TITLE=$(curl -s minim2:8080/api/generate -d "$(printf '{"model": "%s", "prompt": "Generate a short 3 words or less title based on this prompt for a blog: %s. Only reply with the short title. Make sure it is short, 3 words or less.", "stream": false}' "$MODEL" "$PROMPT_CLEANED")" | jq -r '.response')

# generate front matter for HUGO
echo '---' > $PAGE
echo author: "$MODEL" >> $PAGE
echo title: "$TITLE" >> $PAGE
echo date: "$(date +%Y-%m-%d)" >> $PAGE
echo 'draft: false' >> $PAGE
echo 'type: post' >> $PAGE
echo '---' >> $PAGE

# append content to webpage
echo "$CONTENT" >> $PAGE

# append prompt to webpage end
echo "" >> $PAGE
echo '```bash' >> $PAGE
echo "Prompt:" >> $PAGE
echo $PROMPT_CLEANED | fold -w 80 -s >> $PAGE #poor man's word wrap
echo Total duration: \~$(echo $TOTAL_DURATION/1000000000 | bc) seconds >> $PAGE
echo '```' >> $PAGE

# print out remaned PAGE to user
echo "--> Here is what the page named "$(basename $PAGE)" looks like:"
cat $PAGE

# Ask the user to confirm if they want to publish the page
read -p "--> Do you want to publish this page? (y/n): " CONFIRM

if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
  # Define the destination folder and the file to move
  DEST_FOLDER="/home/linux/docker-data/virtualbeck_blog/theme_papermod/content/ai_slop/"
  FILE_TO_MOVE="$PAGE"

  # Move the file to the destination folder
  if mv "$FILE_TO_MOVE" "$DEST_FOLDER"; then
    # Execute the predefined script to publish the page
    cd ~/docker-data/virtualbeck_blog/theme_papermod/
    ./build_publish_commit.sh
  else
    color echo "Error: Failed to move the file."
  fi
else
  read -p "--> Do you want to keep this page? (y/n): " CONFIRM
  if [[ "$CONFIRM" == "n" || "$CONFIRM" == "N" ]]; then
    rm $PAGE
  else
    echo "Page "$(basename $PAGE)" not moved or published"
  fi
fi

cd ~/personal/webpage_generator
````
