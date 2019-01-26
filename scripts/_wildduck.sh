#!/bin/sh

_wildduck_configure_default () {
    local COMS FPATH SECURE='false';
    FPATH="${WILDDUCK_CONFIG_DIR}/default.toml";
    COMS="[
    $(printf "${_COCOF_ADD}" /processes "\"${IMAP_PROCESSES}\""),
    $(printf "${_COCOF_ADD}" /emailDomain "\"${MAIL_DOMAIN}\""),
    $(printf "${_COCOF_ADD}" /totp/cipher \"aes192\"),
    $(printf "${_COCOF_ADD}" /totp/secret "\"${_TOTP_SECRET}\""),
    $(printf "${_COCOF_ADD}" /u2f/appId "\"${API_URL}\""),
    $(printf "${_COCOF_ADD}" /smtp/setup/hostname "\"${FQDN}\""),
    $(printf "${_COCOF_ADD}" /smtp/setup/secure ${_USE_SSL}),
    $(printf "${_COCOF_ADD}" /smtp/setup/port ${_SMTP_PORT}),
    $(printf "${_COCOF_ADD}" /log/gelf/enabled ${_GRAYLOG_ENABLE}),
    $(printf "${_COCOF_ADD}" /log/gelf/hostname "\"${FQDN}\""),
    $(printf "${_COCOF_ADD}" /log/gelf/options/graylogPort ${_GRAYLOG_PORT:-1}),
    $(printf "${_COCOF_ADD}" /log/gelf/options/graylogHostname "\"${_GRAYLOG_HOSTNAME}\"")
    ]";

    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_api () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/api.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /enabled ${API_ENABLE}),
    $(printf "${_COCOF_ADD}" /port ${_API_PORT}),
    $(printf "${_COCOF_ADD}" /host "\"0.0.0.0\""),
    $(printf "${_COCOF_ADD}" /secure ${_USE_SSL}),
    $(printf "${_COCOF_ADD}" /accessToken "\"${API_TOKEN_SECRET}\""),
    $(printf "${_COCOF_ADD}" /accessControl/enabled ${_API_ACCESS_CONTROL_ENABLE}),
    $(printf "${_COCOF_ADD}" /accessControl/secret "\"${_API_ACCESS_CONTROL_SECRET}\""),
    $(printf "${_COCOF_ADD}" /mobileconfig/identifier "\"${CONFIGPROFILE_ID}\""),
    $(printf "${_COCOF_ADD}" /mobileconfig/displayName "\"${CONFIGPROFILE_DISPLAY_NAME}\""),
    $(printf "${_COCOF_ADD}" /mobileconfig/organization "\"${CONFIGPROFILE_DISPLAY_ORGANIZATION}\""),
    $(printf "${_COCOF_ADD}" /mobileconfig/displayDescription "\"${CONFIGPROFILE_DISPLAY_DESC}\""),
    $(printf "${_COCOF_ADD}" /mobileconfig/accountDescription "\"${CONFIGPROFILE_ACCOUNT_DESC}\"")
    ]";
    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_dbs () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/dbs.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /mongo "\"${MONGODB_HOST}\""),
    $(printf "${_COCOF_ADD}" /redis/host "\"${_REDIS_HOSTNAME}\""),
    $(printf "${_COCOF_ADD}" /redis/port ${_REDIS_PORT}),
    $(printf "${_COCOF_ADD}" /redis/db ${_REDIS_DB})
    ]";

    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_dkim () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/dkim.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /cipher "\"aes192\""),
    $(printf "${_COCOF_ADD}" /secret "\"${_DKIM_SECRET}\"")
    ]";

    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_imap () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/imap.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /name "\"${PRODUCT_NAME} IMAP\""),
    $(printf "${_COCOF_ADD}" /enabled 'true'),
    $(printf "${_COCOF_ADD}" /port ${_IMAP_PORT}),
    $(printf "${_COCOF_ADD}" /host "\"0.0.0.0\""),
    $(printf "${_COCOF_ADD}" /secure ${_USE_SSL}),
    $(printf "${_COCOF_ADD}" /retention ${IMAP_RETENTION}),
    $(printf "${_COCOF_ADD}" /disableSTARTTLS ${_IMAP_DISABLE_STARTTLS}),
    $(printf "${_COCOF_ADD}" /setup/hostname "\"${FQDN}\""),
    $(printf "${_COCOF_ADD}" /setup/secure ${_USE_SSL}),
    $(printf "${_COCOF_ADD}" /tls/ciphers '"ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS"'),
    $(printf "${_COCOF_ADD}" /tls/secureProtocol '"SSLv23_server_method"'),
    $(printf "${_COCOF_ADD}" /tls/secureOptions 100663296)
    ]";

    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_lmtp () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/lmtp.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /enabled false)
    ]";

    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_pop3 () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/pop3.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /enabled false)
    ]";

    cocof "${FPATH}" "${COMS}";
}


_wildduck_configure_tls () {
    local COMS FPATH;
    FPATH="${WILDDUCK_CONFIG_DIR}/tls.toml";

    [ "${_USE_SSL}" = 'false' ] && return;

    COMS="[
    $(printf "${_COCOF_ADD}" /key "\"${TLS_KEY}\""),
    $(printf "${_COCOF_ADD}" /cert "\"${TLS_CERT}\"")
    ]";

    cocof "${FPATH}" "${COMS}";
}


configure_wildduck () {
    # only configure wildduck if the user has not mounted his own
    # configuration files at $WILDDUCK_CONFIG_DIR.
    [ "${USE_OWN_SETTINGS}" = 'true' ] && return 0;

    _wildduck_configure_default;
    _wildduck_configure_api;
    _wildduck_configure_dbs;
    _wildduck_configure_imap;
    _wildduck_configure_lmtp;
    _wildduck_configure_pop3;
    _wildduck_configure_tls;
    return 0;
}


start_wildduck () {
    cd "${WILDDUCK_INSTALL_DIR}";
    NODE_ENV=production node server.js \
        --config="${WILDDUCK_CONFIG_DIR}/default.toml";
    return $?;
}
