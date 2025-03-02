---
author: Mike
title: tailscale and code-server
date: 2025-02-12
description: "Running a local service as a sidecar container through tailscale"
tags:
  [
    "tailscale",
    "sidecar",
    "containers",
    "docker",
    "ssh",
    "tls",
    "linux",
    "code-server",
  ]
draft: false
---

Listen to this article:
{{< audio "/audio/TITLE_PLACEHOLDER.mp3" >}}<br>

A lot of what I'm going to say here is a reguritation of [this great post](https://tailscale.com/blog/docker-tailscale-guide) from tailscale. If you want to just skip to that document, I will not hold it against you. If you'd like to see how I've implemented a tailscale container with a code-server sidecar container and serve it over my tailnet, then read on!

Tailscale is an excellent implementation of [wireguard](https://www.wireguard.com/), which is a VPN. Tailscale is installed on your clients, and lets you connect to your devices as if you were local. You get your own "tailnet", which is kind of like your DNS domain. It looks like "tailXXXX.ts.net", where the X are numbers. Running a service like code-server (or whatever container) would be available on your tailnet at `code-server.tail1234.ts.net`, so long as you are connected to _your_ tailnet. You can also, with one boolean change make this sidecar service avilable to anyone on the internet. How much do I pay for this? Zero, baby! It's free tier is up to 3 users (I'm using 1), and up to 100 clients (I think I may have 6). Plenty of headroom.

[Code-server](https://github.com/coder/code-server) is [vscode](https://github.com/Microsoft/vscode), but in the browser. It is essentailly running a code editor on a server somewhere. Think of it as your dev environment, accessible anywhere. This makes the choice of your company's issued workstation and OS much more trivial, as you will be coding in an IDE that you know and love, and it can be customized and saved to your liking. I'm running this locally, but you could easily run it on a cloud provider and have similar results.

Ok, so how do you set this up? It's pretty simple. Have a look at the 2 files needed below. The first is the docker-compose.yml. 

 - Side note: There is one additional file needed for this, which it the `.env` file. It sits right beside the docker-compose.yml. I have one that has one line entry: `SERVICE_NAME=code-server`. I'm not enchanted by how docker compose files handle variable interpolation (service names and volumes apperently can't be interpolated??), but this is a bit of a time saver rhebric. 

```yml
services:
  # main tailscale service
  ts-code-server:
    image: tailscale/tailscale:latest
    container_name: ts-${SERVICE_NAME}
    hostname: ${SERVICE_NAME} # ${SERVICE_NAME}.tail5080.ts.net endpoint
    environment:
      - TS_AUTHKEY=tskey-auth-oaiwdkslfriwe3FAKE-KEYpafokmdfkmaopw94efoisdfklw
      - TS_EXTRA_ARGS=--advertise-tags=tag:container
      - TS_SERVE_CONFIG=/config/${SERVICE_NAME}.json
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
    volumes:
      - ${PWD}/ts-${SERVICE_NAME}/state:/var/lib/tailscale
      - ${PWD}/ts-${SERVICE_NAME}/config:/config
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - net_admin
    restart: unless-stopped
  # sidecar
  code-server:
    image: coder/code-server
    container_name: ${SERVICE_NAME}
    volumes:
      # ~/docker-data on host machine is /home/coder/workspace/ in container
      - ~/docker-data:/home/coder/workspace
    restart: unless-stopped
    network_mode: service:ts-${SERVICE_NAME} # <-- this is where the magic happens
    depends_on:
      - ts-${SERVICE_NAME}

volumes:
  ts-code-server:
    driver: local
```

The tailscale config file (listed above in docker-compose.yml as `ts-code-server/config/code-server.json`)

```json
{
  "TCP": { "443": { "HTTPS": true } },
  "Web": {
    "${TS_CERT_DOMAIN}:443": {
      "Handlers": { "/": { "Proxy": "http://127.0.0.1:8080" } }
    }
  },
  "AllowFunnel": { "${TS_CERT_DOMAIN}:443": false }
}
```

Finally, in your tailscale admin dashboard, make sure you have `MagicDNS` and `HTTPS Certificates` both _ENABLED_. You can obviosly add more volumes to your sidecar docker container if you want more local filesystems mapped to your container, but this should get you going. That's it! You have your own code-server running on you docker container, which it accessable from anywhere, when you are on your tailnet.

If you feel spicy and want to open it (or another container) to the whole world, set the last line in you tailscale config AllowFunnel --> true. As a side note here, you also have to open up your ACL for funnel, [as per the docs](https://tailscale.com/kb/1223/funnel#funnel-node-attribute). Here's the snippet in my ACLs that did the trick:

```json
"nodeAttrs": [
		{"target": ["tag:container"], "attr": ["funnel"]},
	]
```

This is saying that if the tailscale agent is tagged with `container`, then add support for the attribute `funnel`. Then the true/false AllowFunnel will work properly. I think that is it.
