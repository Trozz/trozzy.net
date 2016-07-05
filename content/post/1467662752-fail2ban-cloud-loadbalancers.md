+++
date = "2016-07-04T21:06:14+01:00"
draft = false
title = "fail2ban cloud loadbalancers"
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

[ ] Fail2Ban

[ ] PHP

[ ] [PHP Script](https://raw.githubusercontent.com/sidgtl/rackban/master/scripts/rackban.php)


```bash
yum install php-cli fail2ban
wget https://raw.githubusercontent.com/sidgtl/rackban/master/scripts/rackban.php -o $HOME/rackban.php
```

```bash
apt-get install php-cli fail2ban
wget https://raw.githubusercontent.com/sidgtl/rackban/master/scripts/rackban.php -o $HOME/rackban.php
```

```bash
pacman -S php fail2ban
wget https://raw.githubusercontent.com/sidgtl/rackban/master/scripts/rackban.php -o $HOME/rackban.php
```

## Configure and Test it

Before continuing we need to update the script with your Rackspace Cloud details, I would also suggest testing the script to ensure that it working.

#### Update Config
```php
private $accountId = "12345678";

// Your Rackspace username
private $username = "exampleuser";

// Your Rackspace API key
private $apiKey = "kh45kh345k34k345h3k45h";

// Your Rackspace load balancer ID
private $loadBalancer = "123456";

// Your Racspace region (ord, dfw, iad, lon, syd, hkg)
private $region = "lon";
```

#### Test script

```bash
php -f $HOME/rackban.php ban 10.0.0.1
```

```bash
php -f $HOME/rackban.php unban 10.0.0.1
```


## Configure Fail2Ban
After you have tested that the script is working you can proceed to create the custom action for Fail2Ban, the configuration file `/etc/fail2ban/action.d/rackban.conf`

*Replace {PATH_TO_PHP} with the full path to PHP e.g. /usr/bin/php*

*Replace {PATH} with the path to rackban.php e.g. /home/trozz*

```
[Definition]
actionstart =
actionstop =
actioncheck =
actionban = {PATH_TO_PHP} -f {PATH}/rackban.php ban <ip>
actionunban = {PATH_TO_PHP} -f {PATH}/rackban.php unban <ip>
```

Finally you would need to update the action that is performed for your Fail2Ban jail.

```
[apache-auth]
enabled = true
port     = http,https
logpath  = %(apache_error_log)s
action = rackban
```


And there you have it with this setup you will now automatically ban people that connect through your Cloud Load Balancer
