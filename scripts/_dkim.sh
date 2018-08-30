#!/bin/sh

add_dkim_for_mail_domain () {
    local AUTH_HEADER;
    [ -n "${API_TOKEN_SECRET}" ] && \
        AUTH_HEADER="X-Access-Token: ${API_TOKEN_SECRET}";

    # Wait until API server is up
    while ! curl --output /dev/null --silent \
        --fail -H "${AUTH_HEADER}" ${API_URL}/users; do
        sleep 2;
    done

    generate_dkim "${MAIL_DOMAIN}";
}
