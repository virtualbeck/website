+++
author= "Mike"
title= "asahi linux"
date= "2024-12-15"
draft= "false"
tags= ["asahi","linux","llama3.2","LLM","apple","silicon"]
+++

A few years ago, I was made aware of a project by just a few people to get linux running on the (then) new apple M1 silcon. It was and is a large effort and was completed rather quickly. I didn't have any computers that had the M1 chip to test, but recently I was able to grab an M2 Mac Mini and load up asahi linux onto it and test.

First of all, huge kudos to the team who reverse-engineered the solution, and released the open source project for all to enjoy! What an accomplishment. You can find the homepage [here](https://asahilinux.org/), along with step-by-step instructions on how to get up and running. Wonderful!

I installed the UI on the first go round, and took it for a spin for a few days. The overall user experience was good, but not as polished or smooth as I'd like. Perhaps it was fedora DE that I didn't like, but to me this would be more useful as an always-on, low power server to offload compute to in the form of containers.

And that's about where I've landed. I run docker containers on this and it just sits on my shelf, running silently. Small LLM models happily run on this (8gb RAM only), such as the new (as of this writing) llama3.2:3b, running with [ollama](https://ollama.com/library/llama3.2). It returns about 10 tokens per second, which is about reading speed. Again, the fan is always silent on this computer. Lovely!

I've been very impressed, and truly hope that the asahi linux team releases support for future apple silicon models. 

Side note: I was able to dual-boot this machine, so it runs MacOS too, and ollama runs natively on Apple silicon...and it is fast. Try it out [here](https://ollama.com/download/mac)