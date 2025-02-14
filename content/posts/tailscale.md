---
author: Mike
title: tailscale + code-server = heartemoji
date: 2025-02-12
description: "Running a local service as a sidecar container through tailscale"
tags: ["tailscale","sidecar","containers","docker","ssh","tls","linux","code-server"]
draft: false
---

A lot of what I'm going to say here is a reguritation of [this great post](https://tailscale.com/blog/docker-tailscale-guide) from tailscale. If you want to just skip to that document, I will not hold it against you. If you'd like to see how I've implemented a tailscale container with a code-server sidecar container and serve it over my tailnet, then read on!

Tailscale is an excellent implementation of [wireguard](https://www.wireguard.com/), which is a VPN. Tailscale is installed on your clients, and lets you connect to your devices as if you were local. You get your own "tailnet", which is kind of like your DNS domain. It looks like "tailXXXX.ts.net", where the X are numbers. Running a service like code-server (or whatever container) would be available on your tailnet at `code-server.tail1234.ts.net`, so long as you are connected to _your_ tailnet. You can also, with one boolean change make this sidecar service avilable to anyone on the internet. How much do I pay for this? Zero, baby! It's free tier is up to 3 users (I'm using 1), and up to 100 clients (I think I may have 6). Plenty of headroom.

[Code-server](https://github.com/coder/code-server) is [vscode](https://github.com/Microsoft/vscode), but in the browser. It is essentailly running a code editor on a server somewhere. Think of it as your dev environment, accessible anywhere. This makes the choice of your company's issued workstation and OS much more trivial, as you will be coding in an IDE that you know and love, and it can be customized and saved to your liking. I'm running this locally, but you could easily run it on a cloud provider and have similar results.

Ok, so how do you set this up? It's pretty simple. TODO: write more content here