#!/bin/bash
# Check that exactly 2 arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <prompt> <filename>"
  exit 1
fi

PROMPT="$1"
FILENAME="$2"

echo "--> Prompt: $PROMPT"
echo "--> Filename: $FILENAME"

curl -X 'POST' \
  'https://kokoro.virtualbeck.com/v1/audio/speech' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "kokoro",
    "input": "'"$PROMPT"'",
    "voice": "af_sarah",
    "response_format": "mp3",
    "speed": 1,
    "stream": true,
    "return_download_link": false
  }' > ~/docker-data/virtualbeck_blog/theme_papermod/static/audio/$FILENAME.mp3
