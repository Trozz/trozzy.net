+++
date = "2016-07-04T15:13:47+01:00"
draft = false
title = "Resetting rax_service_level_automation metadata"
tags = [ "rackspace", "api", "openstack" ]
categories = [
  "Rackspace",
  "API"
]

+++

During my previous time at Rackspace numerous users have had issues where their Managed Cloud Server would enter a failed status, this is commonly due to the post-build automation failing, the reasons for this can include novaclient not running, SSH running on a different port, package installation issues et al.

This would commonly result in the user having to contact Rackspace to resolve the issue, while you should continue to contact Rackspace about this to ensure that the managed software is correctly installed, the below would allow you to update the metadata that is set due to this failure.

## Retreiving the metadata

Rackspace Cloud uses metadata for a number of tasks relating to a cloud server, the common one is for this service level automation, you can view your systems metadata with the below code snippets;

```bash
curl -X GET -H "X-Auth-Token: {auth_token}"  https://{datacentre}.servers.api.rackspacecloud.com/v2/{tenant_id}//servers/{server_id}/metadata/rax_service_level_automation
```

```bash
supernova {profile_name} show {server_id}
```

## Resetting the metadata

As previously mentoned you should contact Rackspace support before resetting the metadata yourself, however to use many of the options within the control panel the metadata must be completed

```bash
curl -X PUT -d '{ "meta" : { "rax_service_level_automation" : "Complete" } }' -H "X-Auth-Token: {auth_token}"  https://{datacentre}.servers.api.rackspacecloud.com/v2/{tenant_id}//servers/{server_id}/metadata/rax_service_level_automation
```

```bash
supernova {profile_name} meta {server_id} set rax_service_level_automation=Compelete
```

## Deleteing the metadata

When a machine is built you can remove the metadata by running one of the following commands;

```bash
curl -X DELETE -H "X-Auth-Token: {auth_token}"  https://{datacentre}.servers.api.rackspacecloud.com/v2/{tenant_id}//servers/{server_id}/metadata/rax_service_level_automation
```

```bash
supernova {profile_name} meta {server_id} delete rax_service_level_automation
```
