#!/bin/bash

# remove old css stylesheet(s)
rm public/assets/css/stylesheet.*.css

# Build the site
hugo

if [ $? -eq 0 ]
then
  echo "Successfully built site. Proceeding with deployment..."
  # Commit and push changes
  git add -A
  commit_ret=$(git commit -m "$(date) commit to master")
  if [[ $commit_ret == *"nothing to commit"* ]]; then
    echo "No changes to commit, exiting publish step."
    exit 0
  else
    git push
    cp -a public/ /home/linux/docker-data/virtualbeck_blog/
    cd ~/docker-data/traefik && docker-compose restart virtualbeck_nginx
  fi
else
  echo "Build failed..." >&2
  exit 1
fi
