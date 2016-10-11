#!/bin/sh
if [[ $(grep cf_full_purge config.toml) =~ true$ ]]; then
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$DOMAIN/purge_cache" \
-H "X-Auth-Email: $EMAIL" \
-H "X-Auth-Key: $KEY" \
-H "Content-Type: application/json" \
--data '{"purge_everything":true}'
else
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$DOMAIN/purge_cache" \
-H "X-Auth-Email: $EMAIL" \
-H "X-Auth-Key: $KEY" \
-H "Content-Type: application/json" \
--data '{"files":["https://www.trozzy.net/", "https://www.trozzy.net/post/"]}';
fi
