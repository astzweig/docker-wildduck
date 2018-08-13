#!/bin/sh

init_runtime_env_variables () {
    # Simple (too general) domain recognizing regular expression.
    local _DOMAIN_REGEX='[^[:space:]]\{1,63\}\.\+[^[:space:].]\+$';
    _check_value 'FQDN' "${_DOMAIN_REGEX}" 'exit';
    _check_value 'MAIL_DOMAIN' "${_DOMAIN_REGEX}" "${FQDN}";
    _check_value 'PRODUCT_NAME' '.\+' 'Wildduck Mail';
    _check_value 'TLS_KEY' '\.+' '/etc/tls-keys/privkey.pem';
    _check_value 'TLS_CERT' '\.+' '/etc/tls-keys/fullchain.pem';
    _check_value 'MONGODB_HOST' '.\+' 'mongodb://mongodb:27017/wildduck';
    _check_value 'REDIS_HOST' '.\+' 'redis://redis:6379/8';

    # Split REDIS_HOST into components as we need the components in the
    # configuration files.
    _check_value 'REDIS_PORT' '.\+' "$(echo "${REDIS_HOST}" | \
        sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')";
    _check_value 'REDIS_HOSTNAME' '.\+' "$(echo "${REDIS_HOST}" | \
        sed -e 's,.*://,,' -e 's,^\([^:/]\+\)[:/].*,\1,')";
    _check_value 'REDIS_DB' '.\+' "$(echo "${REDIS_HOST}" | \
        sed -e 's,.*/,,')";

    _init_api_env_variables;
    _init_configprofile_env_variables;
}


_init_api_env_variables () {
    local PROTO='http';
    _check_value 'API_ENABLE' 'true\|false' 'true';
    _check_value 'API_USE_HTTPS' 'true\|false' 'true';
    [ "${API_USE_HTTPS}" = 'true' ] && PROTO="${PROTO}s";
    _check_value 'API_URL' '.\+' "${PROTO}://${FQDN}";
    _check_value 'API_TOKEN_SECRET' '.\+' "$(_get_random_string)";
}


_init_configprofile_env_variables () {
    # default identifier for mobilconfig is the first two parts of the
    # reversed FQDN with '.wildduck' appended.
    local REV_FQDN="$(echo $FQDN | \
        awk '{n = split($0,v,"."); print v[n]"."v[n-1]}').wildduck";
    _check_value 'CONFIGPROFILE_ID' '.\+' "${REV_FQDN}";
    _check_value 'CONFIGPROFILE_DISPLAY_NAME' '.\+' "${PRODUCT_NAME}";
    _check_value 'CONFIGPROFILE_DISPLAY_ORGANIZATION' '.\+' 'Unknown';
    _check_value 'CONFIGPROFILE_DISPLAY_DESC' '.\+' \
        'Install this profile to setup {email}';
    _check_value 'CONFIGPROFILE_ACCOUNT_DESC' '.\+' '{email}';
}
