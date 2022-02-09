#! /bin/bash
set -e

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1

echo "Creating html file..."
saxon -xsl:"${SCRIPT_DIR}"/IngestLddView.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".html

echo "Creating dot file..."
saxon -xsl:"${SCRIPT_DIR}"/IngestLddDot.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".dot

echo "Creating pdf file..."
dot -Tpdf -O "${LDD_FILE}".dot

echo "Creating uml pdf file..."
saxon -xsl:"${SCRIPT_DIR}"/IngestLddPlantUml.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".uml
plantuml -tsvg "${LDD_FILE}".uml 
open "${LDD_FILE}".svg