#!/bin/sh

init_runtime_env_variables () {

    _init_general_env_vars;
    _init_api_env_vars;
    _init_configprofile_env_vars;
    _init_imap_env_vars;
    _init_calculated_vars;
}


_init_calculated_vars () {
    _init_redis_calc_vars;
    _init_graylog_calc_vars;
}


_init_general_env_vars () {
    # Simple (too general) domain recognizing regular expression.
    local _DOMAIN_REGEX='[^[:space:]]\{1,63\}\.\+[^[:space:].]\+$';
    _check_value 'FQDN' "${_DOMAIN_REGEX}" 'exit';
    _check_value 'MAIL_DOMAIN' "${_DOMAIN_REGEX}" "${FQDN}";
    _check_value 'PRODUCT_NAME' '.\+' 'Wildduck Mail';
    _check_value 'MONGODB_HOST' '.\+' 'mongodb://mongodb:27017/wildduck';
    _check_value 'REDIS_HOST' '.\+' 'redis://redis:6379/8';

    export TLS_KEY="${TLS_KEY}";
    export TLS_CERT="${TLS_CERT}";
    export GRAYLOG_HOST_PORT="${GRAYLOG_HOST_PORT}";
}


_init_api_env_vars () {
    local PROTO='http';
    _check_value 'API_ENABLE' 'true\|false' 'true';
    _check_value 'API_USE_HTTPS' 'true\|false' 'true';
    [ "${API_USE_HTTPS}" = 'true' ] && PROTO="${PROTO}s";
    _check_value 'API_URL' '.\+' "${PROTO}://${FQDN}";
    _check_value 'API_TOKEN_SECRET' '.\+' "$(_get_random_string)";
}


_init_configprofile_env_vars () {
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


_init_imap_env_vars () {
    _check_value 'IMAP_PROCESSES' '[[:digit:]]\+$' '2';
    _check_value 'IMAP_RETENTION' '[[:digit:]]\+$' '4';
    _check_value 'IMAP_DISABLE_STARTTLS' 'true\|false' 'false';
}


_init_redis_calc_vars () {
    # Split REDIS_HOST into components as we need the components in the
    # configuration files.
    export REDIS_PORT="$(_get_url_part "${REDIS_HOST}" port)";
    export REDIS_HOSTNAME="$(_get_url_part "${REDIS_HOST}" hostname)";
    export REDIS_DB="$(_get_url_part "${REDIS_HOST}" path)";
}


_init_graylog_calc_vars () {
    export GRAYLOG_PORT="$(_get_url_part "${GRAYLOG_HOST_PORT}" port)";
    export GRAYLOG_HOSTNAME="$(_get_url_part "${GRAYLOG_HOST_PORT}" hostname)";
}
