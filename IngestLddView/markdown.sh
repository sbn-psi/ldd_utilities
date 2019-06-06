#! /bin/bash
set -e

if [ ! -e pandoc.css ]; then
    wget https://gist.githubusercontent.com/killercup/5917178/raw/40840de5352083adb2693dc742e9f75dbb18650f/pandoc.css
fi

PDF_ENGINE=pdflatex

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1

saxon -xsl:"${SCRIPT_DIR}"/IngestLddMarkdown.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".md dictfile="${LDD_FILE}"

pandoc --css pandoc.css --pdf-engine=${PDF_ENGINE} -o "${LDD_FILE}".pdf ${LDD_FILE}.md