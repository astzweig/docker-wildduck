#!/bin/sh

source "${SCRIPTS_DIR}/00-define_variables.sh";
source "${SCRIPTS_DIR}/_utils.sh";
source "${SCRIPTS_DIR}/_init-env-vars.sh";
source "${SCRIPTS_DIR}/_wildduck.sh";
source "${SCRIPTS_DIR}/_haraka.sh";

main () {
    init_runtime_env_variables;
    configure_wildduck;
    configure_haraka;

    start_wildduck &
    local WILDDUCK_PID=$!;

    start_haraka &
    local HARAKA_PID=$!;

    wait $WILDDUCK_PID;
    wait $HARAKA_PID;
}

main "$@";
