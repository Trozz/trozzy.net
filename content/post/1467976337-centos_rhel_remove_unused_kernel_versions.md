+++
categories = ["CentOS", "RHEL", "General"]
date = "2016-07-08T12:13:18+01:00"
description = ""
draft = false
tags = ["RHEL", "CentOS"]
title = "CentOS / RedHat remove unused kernel versions"

+++

I notice many servers tend to have many kernels, alot of the time people do not clean these up, this can obviously lead to `/boot` becoming full, there are a few ways that the unused kernels can be removed, _Remember you should be running the latest kernel when possible_

The suggested method would be to use `package-cleanup` which is part of the `yum-utils` package.

```
yum install yum-utils
```

Once yum-utils is installed you can clean the unused kernels with the following command

```
package-cleanup --oldkernels --count=2
```

This command would keep 2 kernel versions, you can obviously change this to however many you would prefer to keep.

Another method which I would **not** suggest is to use something like the following to compare the running kernel against a `rpm` list and then remove the ones not in use.

```
rpm -qa | grep kernel | grep -v $(uname -r) | xargs -i yum remove -y {}
```
