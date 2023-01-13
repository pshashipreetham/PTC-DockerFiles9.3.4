#!/bin/bash
set -e

# export all variables to be sure they are visible to docker-helper
set -a

# build the configuration file
/opt/template-processor/bin/template-processor run-commands

# create a password file for the given keystore password
if [ "${KEYSTORE_PASSWORD}" != "" ]; then
    /opt/security-tool/bin/security-common-cli createTokenFile "${KEYSTORE_PASSWORD_FILE_PATH}/keystore-password" "${KEYSTORE_PASSWORD}"
    echo "Security Tool ($?) -- Created keystore password file"
fi

# extract environment variables with syntax SECRET_# with value "key;value"
python3 /opt/parse_environment.py

echo "success" > status.txt
