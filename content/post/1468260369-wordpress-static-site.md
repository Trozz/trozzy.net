+++
categories = ["wordpress", "nginx"]
date = "2016-07-11T19:11:27+01:00"
description = ""
draft = false
tags = ["wordpress"]
title = "Using Wordpress as a Static Site"

+++

Many people prefer to use Wordpress over platforms such as Hugo, Ghost et al. many of these situations don't need a blogging platform but instead choose Wordpress due to the array of plugins and ease of management, however this obviously have a overhead compared to a static site.

### Why use it
There can be many reasons that someone decides to use Wordpress over a flat file content management system (CMS) or even just a normal static site, some advantages and disadvantages are listed below


#### advantage
* Large community
* Many plugins
* Easy to administrate

#### disadvantage
* Increased load time
* Vulnerabilities
* Issues with Caching

### What can be done
Many people look to Varnish for caching sites such as Wordpress however not many people realise that Nginx has the ability to cache built in.


#### So how do you get Nginx to cache
Add the following code to the head of you virtual host code outside of the `server` tags

```
fastcgi_cache_path /var/www/cache/website-cache levels=1:2 keys_zone=website:60m inactive=90m;
fastcgi_cache_key "$scheme$request_method$host$request_uri";
fastcgi_cache_use_stale error timeout invalid_header http_500;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
```

Then you need to add the following to the location that processes the PHP code.

```
fastcgi_cache website;
fastcgi_cache_valid  60m;
```

#### But what about wp-admin
With the above example `wp-admin` would also be cached, this obviously would not be great for the administration of a site, to work around this we can add the following

```
if ($request_method = POST) {
        set $skip_cache 1;
}
if ($query_string != "") {
        set $skip_cache 1;
}
if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
        set $skip_cache 1;
}
if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
        set $skip_cache 1;
}
```

Then within the location that you added `fastcgi_cache` you can add

```
fastcgi_cache_bypass $skip_cache;
fastcgi_no_cache $skip_cache;
```

Basically if the variable `skip_cache` is set to `1` then Nginx will not refer to the cache for that page.

### Full Nginx configuration
Below is a full configuration using these settings and some more.

```
fastcgi_cache_path /var/www/cache/domain-cache levels=1:2 keys_zone=domain:60m inactive=90m;
fastcgi_cache_key "$scheme$request_method$host$request_uri";
fastcgi_cache_use_stale error timeout invalid_header http_500;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;

geo $clear_cache_users {
  localhost 1;
}

server{
	listen		80 default_server;
	location /.well-known/acme-challenge {
		alias /var/www/letsencrypt;
	}

	location	/ {
		return 301 https://$host$request_uri;
	}
}

server{
	listen		443 ssl http2 default_server;
	server_name	domain;

	index index.php;

	ssl_certificate /var/www/ssl-gen/certs/domain/fullchain.pem;
	ssl_certificate_key /var/www/ssl-gen/certs/domain/privkey.pem;

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on;
	ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
	ssl_ecdh_curve secp384r1;
	ssl_session_cache shared:SSL:10m;
	ssl_session_tickets off;
	ssl_stapling on;
	ssl_stapling_verify on;
	resolver 8.8.8.8 8.8.4.4 valid=300s;
	resolver_timeout 5s;
	add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
	add_header X-Frame-Options DENY;
	add_header X-Content-Type-Options nosniff;

	## END SSL

	root /var/www/vhosts/domain/public_html/;

	access_log  /var/log/nginx/domain.access.log;
	access_log  /var/log/nginx/domain.apachestyle.access.log  apachestandard;
	error_log  /var/log/nginx/domain.error.log;

	## Cache Stuff
	set $skip_cache 0;

	if ($request_method = POST) {
		set $skip_cache 1;
	}
  ## ^^ Need a better way to do this as Nginx doesn't support if X and Y
	if ($query_string != "") {
		set $skip_cache 1;
	}
	if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
		set $skip_cache 1;
	}
	if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
		set $skip_cache 1;
	}

  location ~ /purge(/.*) {
    if ($clear_cache_users) {
      fastcgi_cache_purge website "$scheme$request_method$host$1";
    }
	}

	location = /favicon.ico { access_log off; log_not_found off; }
	location = /robots.txt { access_log off; log_not_found off; }
	location ~ /\. { deny  all; access_log off; log_not_found off; }

	## Increase Security and stop compromises (hopefully)!
	location ~* /wp-includes/.*.php$ { deny all; access_log off; log_not_found off;	}
	location ~* /wp-content/.*.php$ {	deny all;	access_log off;	log_not_found off; }
	location ~* /(?:uploads|files)/.*.php$ { deny all; access_log off; log_not_found off; }
	location = /xmlrpc.php { deny all;	access_log off; log_not_found off; }
  ## ^^ obviously not great but it removed alot of attacks as long as you don't plan on using JetPack




	location / {
		try_files $uri $uri/ /index.php?q=$uri&$args;
	}

	location ~ \.php$ {
		proxy_intercept_errors on;
		error_page 500 501 502 503 = @fallback;
		fastcgi_buffers 8 256k;
		fastcgi_buffer_size 128k;
		fastcgi_intercept_errors on;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_pass unix:/var/run/hhvm/hhvm.sock;
		fastcgi_cache_bypass $skip_cache;
	  fastcgi_no_cache $skip_cache;
		fastcgi_cache domain;
		fastcgi_cache_valid  60m;
    include fastcgi_params;
	}

	location @fallback {
		fastcgi_buffers 8 256k;
		fastcgi_buffer_size 128k;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_index index.php;
		fastcgi_pass unix:/var/run/php-website.sock;
    fastcgi_cache_bypass $skip_cache;
    fastcgi_no_cache $skip_cache;
    fastcgi_cache domain;
    fastcgi_cache_valid  60m;
    include fastcgi_params;
	}


	location ~* \.(ico|gif|jpe?g|png|svg|eot|otf|woff|woff2|ttf|ogg|css|js)$ {
	expires max;
	break;
	}

}
```

## Conclusion
While I do not agree with using Wordpress for a static site is overkill and requires far too many resources that what is needed I can understand why some people would choose to use it, hopefully this type of configuration will help some of those sites respond quicker.

Using the above configuration I got the following from [Loader.io](https://loader.io/)

[![](/img/post/thumb-1468260369-wordpress-static-site.png)](/img/post/1468260369-wordpress-static-site.png)
