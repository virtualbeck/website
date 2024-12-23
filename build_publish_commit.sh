#!/bin/bash

# build
hugo

if [ $? -eq 0 ] 
then 
  echo "Successfully built site, deploying.."
  #commit
  git add -A
  git commit -m "$(date) commit to master"
  git push
  if [[ $? == *"nothing to commit"* ]]; then
    echo "no changes, exiting publish step"
    exit 0
  else
    echo "bouncing container"
    scp -r public/ /home/linux/docker-data/virtualbeck_blog/
    cd ~/docker-data/traefik && docker-compose restart virtualbeck_nginx
  fi
else 
  echo "build failed.." >&2 
  exit 1
fi
