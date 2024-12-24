+++
author= "Mike"
title= "testing-css"
date= "2024-12-23"
draft= "false"
tags= ["css"]
+++

{{< rawhtml >}}
<div class="blurring-text">
  <p>.blurring-text {
    opacity: 1;
    animation: blurEffect 200s infinite;
    will-change: transform, opacity, filter;
  }</p>

  <p class="blurring-text">@keyframes blurEffect {</p>
  <p class="blurring-text">  0% {filter: blur(0);}</p>
  <p class="blurring-text">  100% {filter: blur(5px);}</p>
  <p class="blurring-text">}</p>
</div>
{{< /rawhtml >}}
