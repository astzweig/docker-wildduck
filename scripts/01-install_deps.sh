#!/bin/sh
apk add --no-cache nodejs;  # needed to run services.
apk add --no-cache rspamd clamav;  # antispam tools.
apk add --no-cache openssl;  # needed to generate dkim keys at runtime.
apk add --no-cache curl;  # needed to run API requests.
apk add --no-cache --virtual build-deps git python python3-dev npm make g++;

apk add --no-cache python3;  # needed to run cocof tool, to edit
pip3 install cocof;          # configuration files.
