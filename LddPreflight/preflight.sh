#!/usr/bin/env bash

LDD_FILE=$1
SCRIPTDIR=$(dirname "$0")
OUTPUT=$(basename "${LDD_FILE}.txt")

validate "${LDD_FILE}" | tee "${SCRIPTDIR}"/"${OUTPUT}"
./preflight.py "${LDD_FILE}" | tee -a "${SCRIPTDIR}"/"${OUTPUT}"