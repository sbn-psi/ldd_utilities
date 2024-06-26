#! /bin/bash
set -e

if [ ! -e pandoc.css ]; then
    wget https://gist.githubusercontent.com/killercup/5917178/raw/40840de5352083adb2693dc742e9f75dbb18650f/pandoc.css
fi

PDF_ENGINE=wkhtmltopdf

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1
IMVERSION=$2
LDDVERSION=$3

saxon -xsl:"${SCRIPT_DIR}"/IngestLddMarkdown.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".md dictfile="${LDD_FILE}" imversion="${IMVERSION}" lddversion="${LDDVERSION}"

pandoc --css pandoc.css --toc --pdf-engine=${PDF_ENGINE} -o "${LDD_FILE}".pdf ${LDD_FILE}.md
pandoc --css pandoc.css --toc -o "${LDD_FILE}".html ${LDD_FILE}.md