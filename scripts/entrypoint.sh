#!/bin/sh

source "${SCRIPTS_DIR}/00-define_variables.sh";
source "${SCRIPTS_DIR}/_utils.sh";
source "${SCRIPTS_DIR}/_init-env-vars.sh";
source "${SCRIPTS_DIR}/_wildduck.sh";

main () {
    init_runtime_env_variables;
    configure_wildduck;

    start_wildduck &
    local WILDDUCK_PID=$!;
    wait $WILDDUCK_PID;
}

main "$@";
