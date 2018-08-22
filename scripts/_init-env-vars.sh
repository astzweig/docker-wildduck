#!/bin/sh

init_runtime_env_variables () {
    # Initialize environment variables. Variables prefixed with an
    # underscore are 'calculated' variables. That means their value is
    # inferred by the values of other variables.

    # === General ===
    # Simple (too general) domain recognizing regular expression.
    local _DOMAIN_REGEX='[^[:space:]]\{1,63\}\.\+[^[:space:].]\+$';
    _check_value 'FQDN' "${_DOMAIN_REGEX}" 'exit';
    _check_value 'MAIL_DOMAIN' "${_DOMAIN_REGEX}" "${FQDN}";
    _check_value 'PRODUCT_NAME' '.\+' 'Wildduck Mail';
    _check_value 'MONGODB_HOST' '.\+' 'mongodb://mongodb:27017/wildduck';

    # === General: Redis ===
    _check_value 'REDIS_HOST' '.\+' 'redis://redis:6379/8';
    # Split REDIS_HOST into components as we need the components in the
    # configuration files.
    export _REDIS_PORT="$(_get_url_part "${REDIS_HOST}" port)";
    export _REDIS_HOSTNAME="$(_get_url_part "${REDIS_HOST}" hostname)";
    export _REDIS_DB="$(_get_url_part "${REDIS_HOST}" path)";

    # === General ===
    export TLS_KEY="${TLS_KEY}";
    export TLS_CERT="${TLS_CERT}";
    export _USE_SSL='false';
    [ -n "${TLS_KEY}" -a -n "${TLS_CERT}" ] && export _USE_SSL='true';
    _check_value 'ENABLE_STARTTLS' 'true\|false' 'false';
    if [ "${ENABLE_STARTTLS}" = 'true' -a "${_USE_SSL}" = 'false' ]; then
        export ENABLE_STARTTLS='false';
    fi

    # === General: Graylog ===
    export GRAYLOG_HOST_PORT="${GRAYLOG_HOST_PORT}";
    export _GRAYLOG_PORT="$(_get_url_part "${GRAYLOG_HOST_PORT}" port)";
    export _GRAYLOG_HOSTNAME="$(_get_url_part "${GRAYLOG_HOST_PORT}" \
        hostname)";
    export _GRAYLOG_ENABLE='false';
    if [ -n "${_GRAYLOG_HOSTNAME}" -a -n "${_GRAYLOG_PORT}" ]; then
        export _GRAYLOG_ENABLE='true';
    fi


    # === API ===
    local PROTO='http';
    _check_value 'API_ENABLE' 'true\|false' 'true';
    _check_value 'API_USE_HTTPS' 'true\|false' 'true';
    _check_value 'API_TOKEN_SECRET' '.\+' '';

    export _API_ACCESS_CONTROL_ENABLE='false';
    export _API_ACCESS_CONTROL_SECRET="$(_get_random_string)";
    [ -n "${API_TOKEN_SECRET}" ] && export _API_ACCESS_CONTROL_ENABLE='true';

    export _API_PORT=80;
    if [ "${API_USE_HTTPS}" = 'true' -a "${_USE_SSL}" = 'true' ]; then
        PROTO="${PROTO}s";
        export _API_PORT=443;
    fi

    _check_value 'API_URL' '.\+' "${PROTO}://${FQDN}";


    # === Configprofile ===
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


    # === dir vars ===
    # These variables do not have an underscore prefix, though they are
    # 'calculated'. This is to keep path variables consistent across
    # the whole code base.
    export CONFIG_DIR='/etc/nodemailer';
    export WILDDUCK_CONFIG_DIR="${CONFIG_DIR}/wildduck";
    export HARAKA_CONFIG_DIR="${CONFIG_DIR}/haraka";


    # === IMAP ===
    _check_value 'IMAP_PROCESSES' '[[:digit:]]\+$' '2';
    _check_value 'IMAP_RETENTION' '[[:digit:]]\+$' '4';
    export _IMAP_DISABLE_STARTTLS='true';
    export _IMAP_PORT=143;
    if [ "${_USE_SSL}" = 'true' ]; then
        export _IMAP_PORT=993;
        if [ "${ENABLE_STARTTLS}" = 'true' ]; then
            export _IMAP_DISABLE_STARTTLS='false';
        fi
    fi


    # === Misc ===
    export _COCOF_ADD='{"op": "add", "path": "%s", "value": %s}';
    export _TOTP_SECRET="$(_get_random_string)";
    export _SRS_SECRET="$(_get_random_string)";
    export _DKIM_SECRET="$(_get_random_string)";
    export _SMTP_PORT='587';
    [ "${_USE_SSL}" = 'true' ] && export SMTP_PORT='465';
}
