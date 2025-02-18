---
author: Mike
title: "Plex running in docker"
date: 2019-03-10
tags: ["plex","bash","docker"]
draft: false
---

Let’s write a script to run Plex in docker<!--more-->

Plex is great. Host all your media in your own hardware. Upgrading Plex from a binary is not great. Letting docker run latest is the easiest way I’ve found to upgrade. First, you have to make a few dirs, but it is straight-forward.

```bash
mkdir -p /mnt/data/plex/db
mkdir -p /mnt/data/plex/tmp
```

Great, now we have our folder structure. Now we will create a script to start plex in docker. Open a new file: nano startPlex.sh and copy this into it.

```bash
#!/bin/bash

docker run \
-d \ # run in daemon mode
--name plex \
--network=host \ # use NIC card of host machine
-e TZ="America/Chicago" \ # enter your timezone
-e PLEX_CLAIM="claim-xxxyyyzzz" \ # https://www.plex.tv/claim/
-h localhost \ # hostname
-v /mnt/data/plex/db:/config \ # mapping config dir
-v /mnt/data/plex/tmp:/transcode \ # mapping transcode dir
-v /mnt/data:/data \ # mapping data dir
--restart=always \ # restart in event of a failed container
linuxserver/plex:latest # image source
```

After that, just make the file executable by running chmod +x startPlex.sh and then ./startPlex.sh. That’s it! You should have plex running in your own docker container!

Update Feb 17th, 2025:
I actually use docker compose now to run plex in docker, but the sentiment is the same. Here's my new docker-compose.yml for you to chew on!

```bash
TODO: add docker-compose.yml content here
```