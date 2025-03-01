#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_DIR=${SCRIPT_DIR}/../..

VERSION=$(date "+%Y%m%d_%H%M")

PRODUCTION_VARIANT=stage
TARGET_HOST_URL=build-darwin-${PRODUCTION_VARIANT}.defold.com
TARGET_HOST=i-05303831267023ab0
TARGET_USER=ec2-user
TARGET_DIR=/usr/local/extender-${PRODUCTION_VARIANT}
TARGET_KEY=~/.ssh/defold2_ec2.pem

source ${SCRIPT_DIR}/standalone/publish-standalone.sh

check_uncommitted_changes ${SOURCE_DIR}
build_artifact ${SOURCE_DIR}
deploy_artifact ${SOURCE_DIR} ${TARGET_DIR} ${VERSION} ${TARGET_HOST} ${TARGET_USER} ${TARGET_KEY} ${PRODUCTION_VARIANT}

SERVER=https://${TARGET_HOST_URL}

echo "**********************************"
echo "Checking the server version at ${SERVER}:"
wget -q -O - $SERVER
echo ""
echo "**********************************"
