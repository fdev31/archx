#!/bin/sh
TEMPLATE=messages.pot
SRC="../../installer.py"
xgettext $SRC --output $TEMPLATE
for pofile in */LC_MESSAGES/messages.po ; do
    msgmerge --update --no-fuzzy-matching --backup=off $pofile $TEMPLATE
    msgfmt $pofile --output-file ${pofile%.po}.mo
done
