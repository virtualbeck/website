---
title: umami
date: 2025-02-08
author: Mike
tags: ["umami", "tracking", "page views"]
draft: false
---

Recently, I saw on a blog ([this one](https://garry.net/posts)) a page view counter. Having seen these on webpages for over 30 years now, I was struck that I had no idea how they worked. So like any other curiosity, I started searching around.

The first thought I had was that this was some sort of script that went and fetched a value from a database on page load, and either did an increment then, or afterwards. Probably afterwards, so as to keep the webpage snappy.

That well may be the way it is done. I'm still not sure. As I'm writing this post, I have yet to implememnt a `page views:` into the header of the html. But, I think I've stood up a portion of the solution which I'd like to write about here.

In my search for finding this, I was sure to mention to the google gods that whatever I chose, it should play well with Hugo, the static site generator I use to generate this whole site. One of the first results was a Hugo message board where a user was asking advice on the same topic, to which they were told: "Why don't you just let google analytics do this?"

Evidently, Hugo (or at least the theme I'm using, papermod) has support baked in for google analytics. I clicked the link, and it brought me to the docs on how to do so via Hugo. It was just one line. I'd put my google-analytics-id in the base config file, and re-build. Okay - well what does that look like from my standpoint of setting up that part of google?

The portal was a signup, and honestly it gave me an uneasy feeling. Like, google would have all the analytics of my website in exchange for a measley page view implementation. So, I kept looking. That lead me to a project named [umami](https://umami.is).

You can click on the link above to read more about it, but I'll give you the gist here. It is an open-source web analytics tool that treats data privacy as a first-class citizen. It is lightweight, and can be self-hosted. So, that is what I'm doing now. I've spun up an umami docker container, and have it running at [umami.virtualbeck.com](https://umami.virtualbeck.com). It collects all sorts of stats, and they are automatically anonymized so as to not identify users. This makes umami GDPR compliant.

It can also track actions on the website, like clicks. I have not implemented that yet - but I have implemented the most basic data collection that it comes packaged with. I can basically see page-views and view duration, along with what device and general location (country scale).

I just added a few lines to my docker compose file, and let traefik handle the rest. Read more about traefik [here](../traefik). I'll list the full setup in my docker compose file below. It refernces an endpoint cloudflare, but that is a cloudflare tunnel, which points back to my home server, so as to serve the traffic without opening up any ports to access my ssytems directly. Read more about it [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). It's great, and it's free.

So the next step is how to implement a page view counter from data gethered by umami. If you see a page view counter on this website, it means my future-self has succeeded. If not, perhaps you're too fast in reading this and I haven't had time to implement it. Or perhaps I've died. Probably not though. I'll have a writeup for that implementation when it is completed. Thanks for reading!

```
  umami:
    image: ghcr.io/umami-software/umami:postgresql-v2.15
    container_name: umami
    expose:
      - 3000
    environment:
      DATABASE_URL: postgresql://REDACTED:REDACTED@db:5432/umami
      DATABASE_TYPE: postgresql
      APP_SECRET: REDACTED
      COLLECT_API_ENDPOINT: /api/get
      TRACKER_SCRIPT_NAME: fetch.js
    depends_on:
      db:
        condition: service_healthy
    init: true
    restart: always
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.umami.rule=Host(`umami.virtualbeck.com`)"
      - "traefik.http.routers.umami.entrypoints=cloudflare"
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/api/heartbeat"]
      interval: 5s
      timeout: 5s
      retries: 5

  db:
    image: postgres:15-alpine
    container_name: postgres_umami
    environment:
      POSTGRES_DB: umami
      POSTGRES_USER: REDACTED
      POSTGRES_PASSWORD: REDACTED
    volumes:
      - umami-db-data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  umami-db-data:
```
