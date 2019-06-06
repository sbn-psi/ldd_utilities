set -e

SCRIPT_DIR=`dirname $0`
CLASSES="NucSpec_Observation_Properties Energy_Calibration Calibration_Reference Instrument_Settings Polynomial Polynomial_Term State_Table State_Table_Entry Applicable_Records State_Time First_Last First_Count Detectors Detector State_Time_ET State_Time_SCLK State_Time_UTC"
LDD_FILE=SBN_NUCSPEC_1A00_0000.xml
LDD_BASE=`basename ${LDD_FILE} .xml`

if [ ! -e IngestLddPlantUml.xsl ]
then
    wget https://raw.githubusercontent.com/sbn-psi/ldd_utilities/master/IngestLddView/IngestLddPlantUml.xsl
fi

saxon -xsl:"${SCRIPT_DIR}"/IngestLddPlantUml.xsl -s:"${LDD_FILE}" -o:"${LDD_BASE}".uml
plantuml "${LDD_BASE}".uml

mv "${LDD_BASE}".png images

for class in $CLASSES; do
    echo $class
    saxon -xsl:"${SCRIPT_DIR}"/IngestLddPlantUml.xsl -s:"${LDD_FILE}" -o:"${class}".uml class="${class}"
    plantuml "${class}".uml

    mv "${class}".png images
done
