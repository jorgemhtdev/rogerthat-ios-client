#!/bin/bash

# Run this script in MCResources/UI folder

RESULT=__checkStringResult.txt

rm -f ${RESULT}

for xib in `ls *.xib`; do
  NAME=`echo $xib | cut -d'.' -f1`
  echo Processing ${NAME}.xib
  echo ${NAME} >> ${RESULT}
  echo "" >> ${RESULT}
  ibtool --generate-strings-file ${NAME}.tmp_strings ${NAME}.xib
  iconv -f UTF-16 -t UTF-8 ${NAME}.tmp_strings > ${NAME}.tmp_strings_utf8
  cat ${NAME}.tmp_strings_utf8 | egrep -va '^/\*' | grep -v '" = "_' | grep -v '^$' >> ${RESULT}
  echo "----------------" >> ${RESULT}
  echo "" >> ${RESULT}
  rm ${NAME}.tmp_strings
  rm ${NAME}.tmp_strings_utf8
done
