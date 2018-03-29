#! /bin/bash
set -e

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1

saxon -xsl:"${SCRIPT_DIR}"/IngestLddView.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".html

saxon -xsl:"${SCRIPT_DIR}"/IngestLddDot.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".dot

dot -Tpdf -O "${LDD_FILE}".dot