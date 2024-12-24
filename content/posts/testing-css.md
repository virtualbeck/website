+++
author= "Mike"
title= "testing-css"
date= "2024-12-23"
draft= "false"
tags= ["css"]
+++

{{< rawhtml >}}
<div>
  <p class="blurring-text">.blurring-text {</p>
  <p class="blurring-text">  opacity: 1;</p>
  <p class="blurring-text">  animation: blurEffect 200s infinite;</p>
  <p class="blurring-text">  will-change: transform, opacity, filter;<\p>
  <p class="blurring-text">}</p>

  <p class="blurring-text">@keyframes blurEffect {</p>
  <p class="blurring-text">  0% {filter: blur(0);}</p>
  <p class="blurring-text">  100% {filter: blur(1px);}</p>
  <p class="blurring-text">}</p>
</div>
{{< /rawhtml >}}
