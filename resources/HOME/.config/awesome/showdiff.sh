#!/bin/sh
diff -u /etc/xdg/awesome/rc.lua rc.lua | pygmentize -l diff
