---
author: Mike
title: "Bash plus Slack"
date: 2019-12-27
tags: ["slack", "bash"]
draft: false
---

Listen to this article:
{{< audio "/audio/TITLE_PLACEHOLDER.mp3" >}}<br>

Let’s write a script to take and upload pictures<!--more-->

Bash scripting has always been my goto tool in my line of work. My friend wanted to have his Slack profile picture updated every 5 mins, so he wrote a program in Go to accomplish this. I am not that savvy with Go (yet), and I wanted to do my own implementation in Bash. Below is the code, only 4 lines really. Let’s look at each line and see what it is going on.

```bash
# !/bin/bash

# Upload a new picture to Slack profile to indicate your presence
# put it in your crontab to send every 5 mins
# */5 8–17 * * 1–5 /home/mike/slackProfilePic.sh
# capture image from webcam (use /dev/video0 for default webcam)
streamer -f jpeg -o /home/mike/image.jpeg -c /dev/video1
# introduce blur
convert -blur 0x2 /home/mike/image.jpeg /home/mike/image.jpeg
# send to slack (get your slack token here: https://api.slack.com/custom-integrations/legacy-tokens)
curl https://slack.com/api/users.setPhoto -F “image=@/home/mike/image.jpeg” -F “token=xoxp-123–456–789”
# remove image
rm /home/mike/image.jpeg
```

## Walkthrough

- `#!/bin/bash` This is called the shebang, and it just tells the computer where the program bash lives. Any line that starts with a # means that is it a comment
- `# */5 8–17 * * 1–5 slackProfilePic.sh` is a comment, but also an example of how the script can be ran by the computer over and over on a cadence by cron (more here). This specific cron entry will run every 5 mins between the hours of 8am and 5pm, Monday through Friday.
- `streamer -f jpeg -o /home/mike/image.jpeg -c /dev/video1` The capture line. Streamer is a program that captures audio/video. We are using it to just grab one frame from our webcam, and store it on disk in jpeg format. Read more about streamer here.
- `convert -blur 0x2 /home/mike/image.jpeg /home/mike/image.jpeg` The blur line (optional). This line was included to introduce a bit of blur to the newly captured image. I wanted to convey presence without sacrificing privacy. You may choose to change the amount of blur or do something completely different before uploading to Slack.
- `curl https://slack.com/api/users.setPhoto -F “image=@/home/mike/image.jpeg” -F “token=xoxp-123–456–789”` The upload line. Here, a curl request is used to send the new image to your Slack profile picture, using your Slack token. Much more can be found here about curl, and you can get your own token (and replace this one) here.
- `rm /home/mike/image.jpeg` The cleanup line. This line merely removes the local copy of the image we just uploaded to Slack.

That’s it! I hope you found this useful, and are able to convey your online presence (or lack thereof) using the tools available through Linux.
