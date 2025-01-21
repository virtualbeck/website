+++
author = "Mike"
title = "pinterest"
date = "2025-01-21"
description = "Grab an image from pinterest without any fuss"
tags = ["pinterest","images","linux"]
draft = false
+++
Ever find the perfect picture on Pinterest just to dash you hopes and/or dreams when you go to save it? Yeah, me too. I've written a bash function that will give you a url to the source image, so you can click on that and do what you want with it.

There are some bash dependencies, but they are usually included with your distro:
```bash
wget,grep,sort,cut,uniq
```

```bash
function getPinterestOriginalImage_URLasArgument() {
wget -q -O- $1 \
  | grep originals \
  | grep -Eo 'https://i.pinimg.com/originals/.*./?\.jpg' \
  | sort | cut -d '"' -f 1 | uniq
}
```

Just add this to your functions in ~/.bashrc, source it, and go! Sorry Windows users, no love here.
