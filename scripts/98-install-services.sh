#!/bin/sh

get_repo_at_cid () {
    # Download the specified git repo and checkout the specified ref.
    # Delete the .git folder afterwards.
    # Run as:
    # get_repo_at_cid <REPO_URL> <DOWNLOAD_DIR> <GIT_COMMIT>
    local REPO_URL="${1}";
    local DOWNLOAD_DIR="${2}"
    local GIT_CID="${3}";

    git clone "${REPO_URL}" "${DOWNLOAD_DIR}";
    cd "${DOWNLOAD_DIR}";
    git checkout "${GIT_CID}";
    rm -fr .git;
}


install_wildduck () {
    get_repo_at_cid "${WILDDUCK_GIT_REPO}" \
                    "${WILDDUCK_INSTALL_DIR}" \
                    "${WILDDUCK_GIT_CID}";

    cd "${WILDDUCK_INSTALL_DIR}";
    npm install --unsafe-perm --production;

    mkdir -p "${WILDDUCK_CONFIG_DIR}";
    mv "${WILDDUCK_INSTALL_DIR}/config"/* "${WILDDUCK_CONFIG_DIR}";
    return 0;
}


install_haraka () {
    npm install --unsafe-perm -g Haraka@"${HARAKA_VERSION}";
    haraka -i "${HARAKA_INSTALL_DIR}";
    cd "${HARAKA_INSTALL_DIR}";
    npm install --unsafe-perm --save haraka-plugin-rspamd Haraka@"${HARAKA_VERSION}";
    mkdir -p "${HARAKA_INSTALL_DIR}/queue";

    get_repo_at_cid "${HARAKA_WD_PLUGIN_GIT_REPO}" \
                    "${HARAKA_INSTALL_DIR}/plugins/wildduck" \
                    "${HARAKA_WD_PLUGIN_GIT_CID}";

    cd "${HARAKA_INSTALL_DIR}/plugins/wildduck";
    cocof ./package.json '[{"op": "add", "path": "/dependencies/wildduck", "value": "file:'"${WILDDUCK_INSTALL_DIR}"'"}]';
    npm install --unsafe-perm --production;

    mkdir -p "${HARAKA_CONFIG_DIR}";
    mv "${HARAKA_INSTALL_DIR}/config"/* "${HARAKA_CONFIG_DIR}";
    rm -r "${HARAKA_INSTALL_DIR}/config";
    ln -s "${HARAKA_CONFIG_DIR}" "${HARAKA_INSTALL_DIR}/config";
    return 0;
}


install_zonemta () {
    get_repo_at_cid "${ZONEMTA_GIT_REPO}" \
                    "${ZONEMTA_INSTALL_DIR}" \
                    "${ZONEMTA_GIT_CID}";

    get_repo_at_cid "${ZONEMTA_WD_PLUGIN_GIT_REPO}" \
                    "${ZONEMTA_INSTALL_DIR}/plugins/wildduck" \
                    "${ZONEMTA_WD_PLUGIN_GIT_CID}";

    cd "${ZONEMTA_INSTALL_DIR}";
    npm install --unsafe-perm --production;

    cd "${ZONEMTA_INSTALL_DIR}/plugins/wildduck";
    cocof ./package.json '[{"op": "add", "path": "/dependencies/wildduck", "value": "file:'"${WILDDUCK_INSTALL_DIR}"'"}]';
    npm install --unsafe-perm --production;

    # Remove example plugins.
    rm -r "${ZONEMTA_INSTALL_DIR}/plugins"/*.js;
    rm -r "${ZONEMTA_INSTALL_DIR}"/config/plugins/example-*;

    mkdir -p "${ZONEMTA_CONFIG_DIR}";
    mv "${ZONEMTA_INSTALL_DIR}/config"/* "${ZONEMTA_CONFIG_DIR}";
    rm -fr "${ZONEMTA_CONFIG_DIR}/plugins/dkim.toml";
    return 0;
}


mkdir -p "${INSTALL_DIR}";
install_wildduck;
install_haraka;
install_zonemta;
