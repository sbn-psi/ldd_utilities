#! /bin/bash
set -e

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1
DEST_BASE=$(basename $LDD_FILE)

saxon -xsl:"${SCRIPT_DIR}"/LddStats.xsl -s:"${LDD_FILE}" -o:"${DEST_BASE}".txt

cat "${DEST_BASE}".txt
