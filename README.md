# ldd_utilities
Miscellaneous utilities for working with local data dictionaries in PDS4


## IngestLddView

### Html

The first utility is IngestLddView, which will convert an Ingest LDD file into a (more) human-readable form.

This will include every class in the dictionary, starting from any class that has the element flag. From there, it will show nested classes and attributes. If the namespace prefix is correct, it will also show the XPath expression for each element, and the human readable description of the schematron rules for that element.

IngestLddView can be invoked with the following command

`xsltproc IngestLddView.xsl [ingest ldd file] > [htmlfile]`

or

`saxon -xsl:IngestLddView.xsl -s:[ingest ldd file] -o:[htmlfile]`

### Graphviz

A graphviz companion to IngestLddView is IngestLddDot. This will convert an Ingest LDD file into a graphviz
dot file, which can be used to quickly visualize the relationships between classes, as well as find problems
such as orphaned classes, attributes or rules. IngestLDDDot is invoked the same way as IngestLDDView:

`xsltproc IngestLddView.xsl [ingest ldd file] > [dotfile]`

or

`saxon -xsl:IngestLddView.xsl -s:[ingest ldd file] -o:[dotfile]`

From there, your dot file can be converted to a graphical format.

For instance, to get a pdf, run:

`dot -O -Tpdf [dotfile]`

### Known issues:
Need to add support for xs:any
The output is not exactly attractive. Need to format it for easier comprehension.
