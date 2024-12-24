+++
author= "Mike"
title= "testing-css"
date= "2024-12-23"
draft= "false"
tags= ["css"]
+++

{{< rawhtml >}}
<div>
  <p class="blurring-text">
  .blurring-text {
  opacity: 1;
  animation: blurEffect 200s infinite;
  will-change: transform, opacity, filter;  
}

@keyframes blurEffect {
  0% {
    filter: blur(0);
  }
  100% {
    filter: blur(1px);
  }
}

  </p>
</div>
{{< /rawhtml >}}
