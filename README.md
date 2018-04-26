# ldd_utilities
Miscellaneous utilities for working with local data dictionaries in PDS4


## IngestLddView

The first utility is IngestLddView, which will convert an Ingest LDD file into files that are easier for a non-XML user to use and visualize.

### Requirements

You will need an XML stylesheet processor such xsltproc or saxon to transform your dictionary.

xsltproc is available at <http://xmlsoft.org/XSLT/xsltproc2.html>

Saxon is available at <https://sourceforge.net/projects/saxon/files/Saxon-HE/9.8/> 

### Getting the stylesheets

You can download both stylesheets from GitHub. Unless you have GitHub experience, use the links below:

[HTML version](https://raw.githubusercontent.com/sbn-psi/ldd_utilities/master/IngestLddView/IngestLddDot.xsl)

[Graphviz Version](https://raw.githubusercontent.com/sbn-psi/ldd_utilities/master/IngestLddView/IngestLddDot.xsl)


### Html

IngestLddView will convert an Ingest LDD file into a (more) human-readable html document.

This will include every class in the dictionary, starting from any class that has the element flag. From there, it will show nested classes and attributes. If the namespace prefix is correct, it will also show the XPath expression for each element, and the human readable description of the schematron rules for that element.

IngestLddView can be invoked with the following command

`xsltproc IngestLddView.xsl [ingest ldd file] > [htmlfile]`

or

`saxon -xsl:IngestLddView.xsl -s:[ingest ldd file] -o:[htmlfile]`

### Graphviz

A graphviz companion to IngestLddView is IngestLddDot. This will convert an Ingest LDD file into a graphviz
dot file, which can be used to quickly visualize the relationships between classes, as well as find problems
such as orphaned classes, attributes or rules. IngestLDDDot is invoked the same way as IngestLDDView:

`xsltproc IngestLddDot.xsl [ingest ldd file] > [dotfile]`

or

`saxon -xsl:IngestLddDot.xsl -s:[ingest ldd file] -o:[dotfile]`

From there, your dot file can be converted to a graphical format.

For instance, to get a pdf, run:

`dot -O -Tpdf [dotfile]`

### Known issues:
Need to add support for xs:any
The output is not exactly attractive. Need to format it for easier comprehension.
