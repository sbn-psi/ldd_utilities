#! /bin/bash
set -e

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1

saxon -xsl:"${SCRIPT_DIR}"/IngestLddPlantUml.xsl -s:"${LDD_FILE}" -o:"${LDD_FILE}".plantuml
