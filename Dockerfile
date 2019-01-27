FROM alpine:latest as builder
LABEL org.label-schema.vendor = "Astzweig UG(haftungsbeschränkt) & Co. KG"
LABEL org.label-schema.version = "1.1.1"
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
ARG WILDDUCK_GIT_CID=bda1cbd878e5c02dabea54886059e1fd54514054

ARG HARAKA_VERSION=2.8.21
ARG HARAKA_WD_PLUGIN_GIT_REPO=https://github.com/nodemailer/haraka-plugin-wildduck.git
ARG HARAKA_WD_PLUGIN_GIT_CID=99cfee567c481ad5aadab76d26282b1517ee64d0

ARG ZONEMTA_GIT_REPO=https://github.com/zone-eu/zone-mta-template.git
ARG ZONEMTA_GIT_CID=9f0391e7c736061f34dc25ff9442d82a26d9fad4
ARG ZONEMTA_WD_PLUGIN_GIT_REPO=https://github.com/nodemailer/zonemta-wildduck.git
ARG ZONEMTA_WD_PLUGIN_GIT_CID=c5667b34a2bbb71811967135d1f7ac459d2063bb

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
