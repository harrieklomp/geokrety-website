#!/bin/bash
START_TIME=$SECONDS
! find . -type f -not \( -path './website/szef/*' -o -path './website/templates/colorbox/*' -o -path './website/templates/compile/*' -o -path './website/templates/rating/*' -o -path './website/templates/jpgraph/*' -o -path './website/templates/htmlpurifier/*' \) \( -name '*.php' -o -name '*.js' -o -name '*.html' -o -name '*.txt' -o -name '*.css' -o -name '*.xml' \) -exec file -m /dev/null "{}" ";" | grep CRLF
ELAPSED_TIME=$(($SECONDS - $START_TIME))
cmdresult=$?

if [ $cmdresult ]; then
    echo -e "$0 \033[32mSUCCESS\033[m after ${ELAPSED_TIME} s"
else
    echo -e "$0 \033[31mFAILED\033[m after ${ELAPSED_TIME} s"
fi
