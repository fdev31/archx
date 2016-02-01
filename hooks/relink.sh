#!/bin/bash

for FILE in $(find . -name "*.sh") ; do
    if [[ $FILE == ./alternatives* ]] ; then
        continue
    fi
    if [[ $FILE == ./*/* ]] ; then
        BN=${FILE##*/}
        PROFILE=${FILE#*/}
        PROFILE=${PROFILE%%/*}
        ORIG="./alternatives/install/$BN"
        if [ -e "$ORIG" ]; then
            echo ${BN}
            ./makeprofile.sh ${PROFILE} ${ORIG}
        fi
    fi
done
