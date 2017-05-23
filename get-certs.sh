#!/usr/bin/env bash

set -eu

SSL_BUCKET="s3://{$CERTS_BUCKET}/"
CERT_DIR="/opt/traefik/certs/"

# Pull list of vanity domains
if [ ! -z "${S3_CONF_PATH}" ]
then
  if [[ "${S3_CONF_PATH}" = prod* ]]
  then
    # Download all certs for Traefik to use
    aws s3 sync "${SSL_BUCKET}" "${CERT_DIR}" --delete
    chmod 600 "${CERT_DIR}"/*
  else
    # QA and UAT do not use SSL
    echo "INFO: Not prod, dont dowload SSL certs"
  fi
else
    echo "ERR: downloading conf: No S3_CONF_PATH variable present"
    exit 1
fi

