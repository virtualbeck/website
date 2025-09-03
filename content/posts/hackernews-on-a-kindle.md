---
author: Mike
title: hacker news on a kindle
date: 2025-09-02
draft: false
tags: ["hacker news", "kindle"]
---

Have you ever wanted to get a digest of the "best" hackernews stories on your kindle? Well, look no further!
I've cobbled together a few technologies to create and host a repo of "books" in which each book is a day of the best links from hackernews.
Each chapter is an article. I had AI write most of this. If you like to contribute, great! The repo will be on github shortly.

TODO: Publish code.

In the meantime - here is the jist of the code that builds the epub.

```
#!/bin/bash

# start readability-js-server
docker run -d -p 3000:3000 --name readability-js-server phpdockerio/readability-js-server:1.7.2

echo "Letting readability-js-server warm up for 10 sec..."
sleep 10

command -v jq >/dev/null 2>&1 || { echo >&2 "This script requires 'jq' but it's not installed. Aborting."; exit 1; }
command -v pandoc >/dev/null 2>&1 || { echo >&2 "This script requires 'pandoc' but it's not installed. Aborting."; exit 1; }

OUTPUT_FILE="hn_articles.json"
TMP_FILE=$(mktemp)
echo "[" > "$TMP_FILE"

html=$(curl -s "https://news.ycombinator.com/best")
urls=$(echo "$html" | grep -oP '<span class="titleline"><a href="\K[^"]+')

first=true

for url in $urls; do
    echo "Fetching: $url"

    response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"url\": \"$url\"}" \
        http://localhost:3000)

    # Ensure JSON is valid
    if ! echo "$response" | jq . >/dev/null 2>&1; then
        echo "Invalid JSON received, skipping: $url"
        continue
    fi

    # Check and optionally generate title
    title=$(echo "$response" | jq -r '.title // empty')
    textContent=$(echo "$response" | jq -r '.textContent // empty')

    if [[ -z "$title" && -n "$textContent" ]]; then
        echo "Generating title with Ollama..."
        
        prompt="Generate a concise, descriptive title for the following text:\n\n$textContent. Only offer 1 descriptive title, and not alternatives, and just return the title."
    
        ollama_payload=$(jq -n \
            --arg model "llama3.2:3b" \
            --arg prompt "$prompt" \
            --argjson stream false \
            '{model: $model, prompt: $prompt, stream: $stream}')
    
        ollama_response=$(curl -s http://ollama:11434/api/generate \
            -H "Content-Type: application/json" \
            -d "$ollama_payload")
        
        title=$(echo "$ollama_response" | jq -r '.response // empty' | tr -d '\n')
        echo "Generated title: $title"
    fi

    # Compose filtered output with fallback title
    filtered=$(jq -n --arg url "$url" \
                     --arg title "$title" \
                     --arg textContent "$textContent" \
                     --arg excerpt "$(echo "$response" | jq -r '.excerpt // empty')" \
                     --arg length "$(echo "$response" | jq -r '.length // empty')" \
        '{
            url: $url,
            title: ($title | select(. != "")),
            textContent: ($textContent | select(. != "")),
            excerpt: ($excerpt | select(. != "")),
            length: ($length | select(. != ""))
        }')

    # Skip empty object
    if [ -z "$filtered" ] || [ "$filtered" = "{}" ]; then
        echo "No usable content from $url"
        continue
    fi

    # Add to JSON array
    if [ "$first" = true ]; then
        echo "$filtered" >> "$TMP_FILE"
        first=false
    else
        echo "," >> "$TMP_FILE"
        echo "$filtered" >> "$TMP_FILE"
    fi
done

echo "]" >> "$TMP_FILE"
mv "$TMP_FILE" "$OUTPUT_FILE"

echo "Saved final output to $OUTPUT_FILE"

### Temporary working directory
WORKDIR=$(mktemp -d)
CHAPTERS=()

# Date-based filename
TODAY=$(date +%F)
EPUB_FILE="hn-digest-$TODAY.epub"

echo "Building EPUB: $EPUB_FILE"

# Read array of JSON objects safely
mapfile -t articles < <(jq -c '.[]' "$OUTPUT_FILE")

index=1
for article in "${articles[@]}"; do
    title=$(echo "$article" | jq -r '.title // "Untitled"')
    url=$(echo "$article" | jq -r '.url')
    excerpt=$(echo "$article" | jq -r '.excerpt // empty')
    length=$(echo "$article" | jq -r '.length // empty')
    content=$(echo "$article" | jq -r '.textContent // empty')

    [ -z "$content" ] && continue

    chapter_file="$WORKDIR/chapter_$index.md"
    CHAPTERS+=("$chapter_file")

    {
        echo "# $title"
        echo
        echo "*Source: [$url]($url)*"
        [ -n "$length" ] && echo "*Length: $length characters*"
        [ -n "$excerpt" ] && echo -e "\n> $excerpt\n"
        echo
        echo "$content"
    } > "$chapter_file"

    echo "Wrote chapter: $chapter_file"
    index=$((index + 1))
done

# Build EPUB with Pandoc
if [ ${#CHAPTERS[@]} -gt 0 ]; then
    pandoc "${CHAPTERS[@]}" -o "$EPUB_FILE" \
        --metadata title="Hacker News Digest - $TODAY" \
        --toc --toc-depth=2
    echo "EPUB created: $EPUB_FILE"
    mv $EPUB_FILE ~/docker-data/books/ingest/$EPUB_FILE
    if [ "echo $?" == 0 ]; then
        rm $EPUB_FILE
    else
        echo "Filetransfer to books folder failed. Please check and transfer manually if needed."
    fi

else
    echo "No valid chapters found — EPUB not created."
fi

# stop readability-js-server
docker stop readability-js-server
docker rm readability-js-server

# Cleanup (optional)
rm -r "$WORKDIR"
```
