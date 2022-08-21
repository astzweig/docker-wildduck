FROM node:14-alpine as builder
LABEL org.label-schema.vendor = "Astzweig GmbH & Co. KG"
LABEL org.label-schema.version = "2.0.0"
LABEL org.label-schema.description = "A docker container to run nodemailer/wildduck mailserver."
LABEL org.label-schema.vcs-url = "https://github.com/astzweig/docker-wildduck"
LABEL org.label-schema.schema-version = "1.0"
RUN apk add --no-cache dumb-init;

# Info: If changed, please also change the variables in the next stage
ARG INSTALL_DIR=/var/nodemailer
ARG SCRIPTS_DIR=/root/scripts
ENV INSTALL_DIR ${INSTALL_DIR}
ENV SCRIPTS_DIR ${SCRIPTS_DIR}

ARG WILDDUCK_GIT_REPO=https://github.com/nodemailer/wildduck.git
ARG WILDDUCK_GIT_CID=9c61d147dfeaf773876ff4c06c552eeb9448d9f8

ARG HARAKA_VERSION=2.8.25
ARG HARAKA_WD_PLUGIN_GIT_REPO=https://github.com/nodemailer/haraka-plugin-wildduck.git
ARG HARAKA_WD_PLUGIN_GIT_CID=9091e67f0716c3b078c98d51d4df93c5555958f8

ARG ZONEMTA_GIT_REPO=https://github.com/zone-eu/zone-mta-template.git
ARG ZONEMTA_GIT_CID=a9a175d7533faa5de074671070eeb671341f96e4
ARG ZONEMTA_WD_PLUGIN_GIT_REPO=https://github.com/nodemailer/zonemta-wildduck.git
ARG ZONEMTA_WD_PLUGIN_GIT_CID=4ba8f8b17a5592ef08dc6199140cb4abdaed3e2d

COPY ./scripts/[0-9][0-9]-*.sh ${SCRIPTS_DIR}/
# Scripts are named like: {ORDER PREFIX}-{NAME}.sh.
# Run files in sequence as induced by their order prefix (00-99).
RUN for file in ${SCRIPTS_DIR}/[0-9][0-9]-*.sh; do \
        chmod u+x "${file}"; \
        source "${file}"; \
    done

COPY ./scripts/[^0-9]*.sh ${SCRIPTS_DIR}/
COPY ./scripts/bin /usr/local/bin
RUN chmod +x ${SCRIPTS_DIR}/entrypoint.sh; \
    chmod +x /usr/local/bin/*;

VOLUME ["/etc/nodemailer"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ${SCRIPTS_DIR}/entrypoint.sh
