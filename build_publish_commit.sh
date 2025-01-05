#!/bin/bash

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
    # remove old generated stylesheet(s)
    rm /home/linux/docker-data/virtualbeck_blog/public/assets/css/stylesheet.*.css 
    
    cp -a public/ /home/linux/docker-data/virtualbeck_blog/
    cd ~/docker-data/traefik && docker-compose restart virtualbeck_nginx
  fi
else
  echo "Build failed..." >&2
  exit 1
fi
