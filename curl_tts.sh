curl -X 'POST' \
  'https://kokoro.virtualbeck.com/v1/audio/speech' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "model": "kokoro",
  "input": "'"$1"'",
  "voice": "af_bella",
  "response_format": "mp3",
  "speed": 1,
  "stream": true,
  "return_download_link": false
}'
