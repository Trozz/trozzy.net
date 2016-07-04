+++
date = "2016-07-04T21:06:14+01:00"
draft = true
title = "1467662752 fail2ban cloud loadbalancers"
tags = [ "rackspace", "api", "fail2ban", "load balancers" ]
categories = [
  "Rackspace",
  "API",
  "fail2ban"
]

+++

Cloud Load Balancers (LBaaS) can be used for numerous reasons, the most commonly that is for distrobuting traffic between multiple servers instead of using HAProxy or a dedicated Load Balancer, there are possitives and negatives to this however in my view load balancing as a service is a fantastic service, with some draw backs which I am sure I will detail in future posts.

Anywho on to the actural reason you are reading this

## Challenge

When using any form of Load Balancing you cannot simply block the IP address of the requests as this will be the Load Balancers IP address, all hope is not lost however as the stand is to send along an additional header such as `X-Forwarded-For` or `X-Real-IP`, I am not sure where the latter came from but the former is the most likely to be seen, using this additional header we can get the users IP address, this can be used within system logging or your application, in the situation that we are going to discuss we are relying on the system logging the IP address correctly.

_Please be aware that I am not the author of this script so use with caution **I do however plan to create a Python version**_

## Required software

[] Fail2Ban
[] PHP


```bash
