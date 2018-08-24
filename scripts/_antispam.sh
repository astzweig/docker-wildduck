#!/bin/sh

configure_antispam () {
    [ ! -d /run/clamav ] && mkdir /run/clamav;
    chown clamav:clamav /run/clamav;

    _create_dir_if_empty "${CLAMD_DATABSE_DIR}";
    chown clamav:clamav "${CLAMD_DATABSE_DIR}";
    echo "DatabaseDirectory ${CLAMD_DATABSE_DIR}" >> /etc/clamav/clamd.conf;
    echo "DatabaseDirectory ${CLAMD_DATABSE_DIR}" \
        >> /etc/clamav/freshclam.conf;

    [ ! -d /run/rspamd ] && mkdir /run/rspamd;
    if [ ! -f /etc/rspamd/local.d/dmarc.conf ]; then
        echo "servers = \"${REDIS_HOSTNAME}\";" \
            > /etc/rspamd/local.d/dmarc.conf;
    fi

    # Update the virus database if necessary
    freshclam;
}

start_antispam () {
    rspamd -i;
    clamd;
    freshclam -d -c 10;
}
