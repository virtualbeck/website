+++
author= "Mike"
title= "testing-css"
date= "2024-12-23"
draft= "false"
tags= ["css"]
+++

{{< rawhtml >}}
<div class="blurring-text">
  <p>.blurring-text {\n
    opacity: 1;\n
    animation: blurEffect 200s infinite;\n
    will-change: transform, opacity, filter;\n
  }</p>

  <p class="blurring-text">@keyframes blurEffect {</p>
  <p class="blurring-text">  0% {filter: blur(0);}</p>
  <p class="blurring-text">  100% {filter: blur(5px);}</p>
  <p class="blurring-text">}</p>
</div>
{{< /rawhtml >}}
