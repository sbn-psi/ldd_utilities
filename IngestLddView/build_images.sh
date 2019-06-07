set -e

SCRIPT_DIR=`dirname $0`
LDD_FILE=$1
LDD_BASE=`basename ${LDD_FILE} .xml`

if [ ! -e IngestLddPlantUml.xsl ]
then
    wget https://raw.githubusercontent.com/sbn-psi/ldd_utilities/master/IngestLddView/IngestLddPlantUml.xsl
fi

saxon -xsl:"${SCRIPT_DIR}"/IngestLddPlantUml.xsl -s:"${LDD_FILE}" -o:"${LDD_BASE}".uml
plantuml "${LDD_BASE}".uml

mv "${LDD_BASE}".png images

for class in `saxon -xsl:ExtractClasses.xsl -s:"${LDD_FILE}"`; do
    echo $class
    saxon -xsl:"${SCRIPT_DIR}"/IngestLddPlantUml.xsl -s:"${LDD_FILE}" -o:"${class}".uml class="${class}"
    plantuml "${class}".uml

    mv "${class}".png images
done
