#!/bin/sh

_haraka_configure_general () {
    mv "${HARAKA_CONFIG_DIR}/plugins" "${HARAKA_CONFIG_DIR}/plugins.bak";
    echo 26214400 > "${HARAKA_CONFIG_DIR}/databytes";
    echo "${FQDN}" > "${HARAKA_CONFIG_DIR}/me";
    echo "${PRODUCT_NAME} MX" > "${HARAKA_CONFIG_DIR}/smtpgreeting";
}

_haraka_configure_plugins_list () {
    echo "spf
clamd
rspamd
dkim_verify
wildduck" > "${HARAKA_CONFIG_DIR}/plugins";
    if [ "${_USE_SSL}" = 'true' ]; then
        echo 'tls' >> "${HARAKA_CONFIG_DIR}/plugins";
    fi
}


_haraka_configure_tls () {
    [ "${_USE_SSL}" = 'false' ] && return;
    echo "
key=${TLS_KEY}
cert=${TLS_CERT}" > "${HARAKA_CONFIG_DIR}/tls.ini";
}


_haraka_configure_rspamd () {
    echo '
host = localhost
port = 11333
add_headers = always
[dkim]
enabled = true

[header]
bar = X-Rspamd-Bar
report = X-Rspamd-Report
score = X-Rspamd-Score
spam = X-Rspamd-Spam

[check]
authenticated = true
private_ip = true

[reject]
spam = false

[soft_reject]
enabled = true

[rmilter_headers]
enabled = true

[spambar]
positive = +
negative = -
neutral = /' > "${HARAKA_CONFIG_DIR}/rspamd.ini";
}


_haraka_configure_clamav () {
    echo '
clamd_socket = /run/clamav/clamd.sock
[reject]
virus=true
error=false' > "${HARAKA_CONFIG_DIR}/clamd.ini";
}


_haraka_configure_wildduck () {
    cp "${HARAKA_INSTALL_DIR}/plugins/wildduck/config/wildduck.yaml" \
       "${HARAKA_CONFIG_DIR}/wildduck.yaml";

    local COMS FPATH;
    FPATH="${HARAKA_INSTALL_DIR}/config/wildduck.yaml";

    COMS="[
    $(printf "${_COCOF_ADD}" /mongo/url "\"${MONGODB_HOST}\""),
    $(printf "${_COCOF_ADD}" /redis/port ${_REDIS_PORT}),
    $(printf "${_COCOF_ADD}" /redis/host "\"${_REDIS_HOSTNAME}\""),
    $(printf "${_COCOF_ADD}" /redis/db ${_REDIS_DB}),
    $(printf "${_COCOF_ADD}" /srs/secret "\"${_SRS_SECRET}\""),
    $(printf "${_COCOF_ADD}" /gelf/enabled ${_GRAYLOG_ENABLE}),
    $(printf "${_COCOF_ADD}" /gelf/hostname "\"${FQDN}\""),
    $(printf "${_COCOF_ADD}" /gelf/options/graylogPort ${_GRAYLOG_PORT:-1}),
    $(printf "${_COCOF_ADD}" /gelf/options/graylogHostname "\"${_GRAYLOG_HOSTNAME}\"")
    ]";

    cocof "${FPATH}" "${COMS}";
}


_symlink_local_config_folder () {
    rm -r "${HARAKA_INSTALL_DIR}/config";
    ln -s "${HARAKA_CONFIG_DIR}" "${HARAKA_INSTALL_DIR}/config";
}

configure_haraka () {
    # Only configure Haraka if the user has not mounted his own
    # configuration files at $HARAKA_CONFIG_DIR.
    #
    # Haraka is a bit different here: The folder at $HARAKA_INSTALL_DIR
    # does not actually contain the source of Haraka, but rather an
    # Haraka application. Therefor it's configuration folder must
    # remain in this 'application' folder.
    # That's why we must create a symlink to $HARAKA_CONFIG_DIR.
    _create_dir_if_empty "${HARAKA_CONFIG_DIR}";
    if [ $? -ne 0 ]; then
        _symlink_local_config_folder;
        return 1;
    fi

    cp -r "${HARAKA_INSTALL_DIR}/config"/* "${HARAKA_CONFIG_DIR}";
    _symlink_local_config_folder;

    _haraka_configure_general;
    _haraka_configure_plugins_list;
    _haraka_configure_tls;
    _haraka_configure_rspamd;
    _haraka_configure_clamav;
    _haraka_configure_wildduck;

    # Copy configuration files over to user mount, if available
    _is_dir_empty "${HARAKA_CONFIG_DIR}";
    if [ $? -eq 0 -a -d "${HARAKA_CONFIG_DIR}" ]; then
        cp -r "${CONFIG_DIR}"/* "${HARAKA_CONFIG_DIR}";
    fi
    return 0;
}


start_haraka () {
    cd "${HARAKA_INSTALL_DIR}";
    NODE_ENV=production node ./node_modules/.bin/haraka -c .;
    return $?;
}
