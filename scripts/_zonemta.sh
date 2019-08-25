#!/bin/sh

_zonemta_configure_interface () {
    local COMS FPATH;
    FPATH="${ZONEMTA_CONFIG_DIR}/interfaces/feeder.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" /feeder/processes 2),
    $(printf "${_COCOF_ADD}" /feeder/port ${_OUTBOUND_SMTP_PORT}),
    $(printf "${_COCOF_ADD}" /feeder/host '"0.0.0.0"'),
    $(printf "${_COCOF_ADD}" /feeder/secure ${_USE_SSL}),
    $(printf "${_COCOF_ADD}" /feeder/starttls ${ENABLE_STARTTLS}),
    $(printf "${_COCOF_ADD}" /feeder/authentication true)
    ]";

    cocof "${FPATH}" "${COMS}";
    echo "# @include \"${WILDDUCK_CONFIG_DIR}/tls.toml\"" >> "${FPATH}";
}


_zonemta_configure_dbs () {
    echo "# @include \"${WILDDUCK_CONFIG_DIR}/dbs.toml\"" \
         > "${ZONEMTA_CONFIG_DIR}/dbs-production.toml";
}


_zonemta_configure_pools () {
    echo "[[default]]
address=\"0.0.0.0\"
name=\"${FQDN}\"" > "${ZONEMTA_CONFIG_DIR}/pools.toml";
}


_zonemta_configure_loop_breaker () {
    local COMS FPATH SECURE='false';
    FPATH="${ZONEMTA_CONFIG_DIR}/plugins/loop-breaker.toml";

    # According to Json Pointer RFC 6901 a slash must be encoded as
    # '~1'.
    COMS="[
    $(printf "${_COCOF_ADD}" '/modules~1zonemta-loop-breaker/secret' \
        "\"${_OUTBOUND_SMTP_SECRET}\"")
    ]";

    cocof "${FPATH}" "${COMS}";
}


_zonemta_configure_default_headers () {
    local COMS FPATH
    FPATH="${ZONEMTA_CONFIG_DIR}/plugins/default-headers.toml";

    COMS="[
    $(printf "${_COCOF_ADD}" '/futureDate' \
        "\"${_OUTBOUND_SMTP_ALLOW_FUTURE_DATE}\"")
    ]";

    cocof "${FPATH}" "${COMS}";
}


_zonemta_configure_wildduck () {
    echo "[wildduck]
enabled=[\"receiver\", \"sender\"]
interfaces=[\"feeder\"]
hostname=\"${FQDN}\"
authlogExpireDays=30
[wildduck.srs]
    enabled=true
    # SRS secret value. Must be the same as in the MX side
    secret=\"${_SRS_SECRET}\"
    rewriteDomain=\"${MAIL_DOMAIN}\"
[wildduck.dkim]
# @include \"${WILDDUCK_CONFIG_DIR}/dkim.toml\"
" > "${ZONEMTA_CONFIG_DIR}/plugins/wildduck.toml";
}


configure_zonemta () {
    # only configure ZoneMTA if the user has not mounted his own
    # configuration files at $ZONEMTA_CONFIG_DIR.
    [ "${USE_OWN_SETTINGS}" = 'true' ] && return 0;

    _zonemta_configure_interface;
    _zonemta_configure_dbs;
    _zonemta_configure_pools;
    _zonemta_configure_loop_breaker;
    _zonemta_configure_default_headers;
    _zonemta_configure_wildduck;
    return 0;
}


start_zonemta () {
    cd "${ZONEMTA_INSTALL_DIR}";
    NODE_ENV=production node index.js \
        --config="${ZONEMTA_CONFIG_DIR}/zonemta.toml";
    return $?;
}
