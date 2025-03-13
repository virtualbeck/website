---
author: Mike
title: "traefik notes"
date: 2024-06-21
draft: false
tags: ["traefik"]
---

Listen to this article:
{{< audio "/audio/traefik.mp3" >}}<br>

Maybe this will help you!

<!--more-->

I wanted to take some time to document the work I've finally marked off the TODO list; setting up [traefik](https://github.com/traefik/traefik) and various services therein. Perhaps this will help you, but really it's just my attempt get the info posted here so I can reference it later if needed, and move on.

What is traefik? `Traefik (pronounced traffic) is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.` <-- ripped from github page. I'm using it to host my services (including this page you're reading now). Some are public, some are private. Some are public behind an auth mechanism. What follows is essentially a dump of my docker-compse.yaml with some secrets/personal obfuscation, with some inline comments to describe what is going on.

```yaml
version: "3.8"
services:
  traefik:
    image: traefik
    # Enables the web UI and tells Traefik to listen to docker
    container_name: "traefik"
    command:
      - "--api=true"
      - "--api.dashboard=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.file.directory=/config/"
      - "--providers.file.watch=true"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      - "--certificatesresolvers.myresolver.acme.email=personal@email.com"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
      - "--log.level=INFO"
      - "--log.filePath=/logs/traefik.log"
      - "--accesslog=true"
      - "--accesslog.filePath=/logs/access.log"
      - "--accesslog.bufferingsize=50"
    ports:
      - "8082:8080"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./letsencrypt:/letsencrypt"
      - "./logs/:/logs/"
      - "./config/:/config/"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`traefik.virtualbeck.com`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.service=api@internal"
      - "traefik.http.routers.api.tls=true"
      - "traefik.http.routers.api.tls.certresolver=myresolver"
      - "traefik.http.routers.api.middlewares=authelia@docker"

    depends_on:
      - "authelia"

  authelia:
    # Authentication!
    image: "authelia/authelia:4.38.8"
    container_name: "authelia"
    restart: unless-stopped
    expose:
      - 9091
    volumes:
      - "~/authelia:/config"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.authelia.rule=Host(`login.virtualbeck.com`)"
      - "traefik.http.routers.authelia.entrypoints=websecure"
      - "traefik.http.routers.authelia.tls.certresolver=myresolver"
      - "traefik.http.routers.authelia.tls=true"
      - "traefik.http.middlewares.authelia.forwardAuth.address=http://authelia:9091/api/verify?rd=https://login.virtualbeck.com/"
      - "traefik.http.middlewares.authelia.forwardAuth.trustForwardHeader=true"
      - "traefik.http.middlewares.authelia.forwardAuth.authResponseHeaders=Remote-User,Remote-Groups,Remote-Email,Remote-Name"

  virtualbeck_nginx:
    # This blog, how recursive!
    image: nginx:latest
    container_name: virtualbeck_blog
    restart: unless-stopped
    volumes:
      - "~/virtualbeck_blog/public:/usr/share/nginx/html:ro"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.virtualbeck_blog.rule=Host(`blog.virtualbeck.com`)"
      - "traefik.http.routers.virtualbeck_blog.entrypoints=websecure"
      - "traefik.http.routers.virtualbeck_blog.tls.certresolver=myresolver"

  whoami:
    # A container that exposes an API to show its IP address
    image: traefik/whoami
    container_name: "whoami"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami.virtualbeck.com`)"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.tls.certresolver=myresolver"
      - "traefik.http.routers.whoami.middlewares=authelia"

  mini2:
    # VSCode for my mini2 server, /home/linux/ context
    image: lscr.io/linuxserver/code-server:latest
    container_name: "mini2"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
    volumes:
      - "/home/linux:/linux"
    ports:
      - 8443:8443
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mini2.rule=Host(`mini2.virtualbeck.com`)"
      - "traefik.http.routers.mini2.entrypoints=websecure"
      - "traefik.http.routers.mini2.tls.certresolver=myresolver"
      - "traefik.http.routers.mini2.middlewares=authelia"

  #ollama:
  #  # Ollama makes it easy to get up and running with large language models locally.
  #  # Run this docker container on a local server with a gpu, and point open-webui
  #  # at it as the UI

  #  image: ollama/ollama
  #  restart: unless-stopped
  #  ports:
  #    - "11434:11434"
  #  volumes:
  #    - "~/ollama:/root/.ollama"
  #  #deploy:
  #  #  resources:
  #  #    reservations:
  #  #      devices:
  #  #      - driver: nvidia
  #  #        count: 1
  #  #        capabilities: [gpu]

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    volumes:
      - "~/open-webui:/app/backend/data"
    ports:
      - 3000:8080
    environment:
      - "OLLAMA_BASE_URL=http://192.168.1.65:11434" #nixos
      - "DEFAULT_MODELS=llama3"
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ollama.rule=Host(`ollama.virtualbeck.com`)"
      - "traefik.http.routers.ollama.entrypoints=websecure"
      - "traefik.http.routers.ollama.tls.certresolver=myresolver"
      - "traefik.http.routers.ollama.middlewares=authelia"
```

You can also host a service that is running on another local host with the `file` provider context. You just mention that, as I did above, and include a matching config file in the directory specified there. Something like this:

`"--providers.file.directory=/config/"`

This way, you can specify the _correct_ IP:PORT for traefik to use, rather than rely on labels. If you try to specify with labels, you will end up with an IP address assigned by docker within the host machine where traefik is running... which is fine if you don't want things to work. Check this example out:

```yaml
http:
  routers:
    route-to-local-ip:
      rule: "Host(`local-service.virtualbeck.com`)"
      service: route-to-local-ip-service
      priority: 1000
      entryPoints:
        - websecure
      middlewares:
        - authelia@docker
      tls:
        certresolver:
          - myresolver

  services:
    route-to-local-ip-service:
      loadBalancer:
        servers:
          - url: "http://192.168.1.123:5592"
```

That's about it. Thanks for reading, and let me know if you have any questions.
