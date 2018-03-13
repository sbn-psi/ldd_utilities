# ldd_utilities
Miscellaneous utilities for working with local data dictionaries in PDS4


## IngestLddView

The first utility is IngestLddView, which will convert an Ingest LDD file into a (more) human-readable form.

This will include every class in the dictionary, starting from any class that has the element flag. From there, it will show nested classes and attributes. If the namespace prefix is correct, it will also show the XPath expression for each element, and the human readable description of the schematron rules for that element.

IngestLddView can be invoked with the following command

`xsltproc IngestLddView.xsl [ingest ldd file] > [htmlfile]`

### Known issues:
Need to add support for xs:any
The output is not exactly attractive. Need to format it for easier comprehension.
