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
else 
  echo "build failed.." >&2 
  exit 0
fi

scp -r public/ /home/linux/docker-data/virtualbeck_blog/

cd ~/docker-data/traefik && docker-compose restart virtualbeck_nginx
