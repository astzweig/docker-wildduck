#!/bin/sh

source "${SCRIPTS_DIR}/_utils.sh";
source "${SCRIPTS_DIR}/_init-env-vars.sh";

main () {
    init_runtime_env_variables;
}

main "$@";
