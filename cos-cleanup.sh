#!/usr/bin/env sh
set -e

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh

sudo rm -fr *.flags
sudo rm -fr "$HOOK_BUILD_DIR"
sudo rm -fr ROOT
