#!/bin/sh
if [ -e .apps_downloaded ]; then
    exit 0
fi
wget 'https://rufus.akeo.ie/downloads/rufus-2.11p.exe' -O rufus.exe
touch .apps_downloaded
