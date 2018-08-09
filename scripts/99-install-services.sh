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

    return 0;
}


mkdir -p "${INSTALL_DIR}";
install_wildduck;
