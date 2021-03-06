#!/usr/bin/env sh
# Clean up the workspace

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh

sudo rm -fr stdout.log
sudo rm -fr *.flag
sudo rm -fr "$HOOK_BUILD_DIR"
sudo rm -fr $ROOTNAME
sudo rm -fr "$_ORIG_ROOT_FOLDER"/*
