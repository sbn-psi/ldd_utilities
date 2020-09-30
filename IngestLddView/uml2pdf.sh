UMLFILE=$1
BASENAME=$(echo "$UMLFILE" | sed -e 's/.plantuml//')
SVGFILE="$BASENAME".svg
PDFFILE="$BASENAME".pdf

plantuml -tsvg $UMLFILE &&  inkscape -o $PDFFILE --export-type=pdf $SVGFILE