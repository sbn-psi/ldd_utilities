# Windows notes

## Overview

The tool stack needed for Windows is somewhat different from what you would use on macOS and Linux. Mitch Gordon at SETI has provided the following notes on getting IngestLddView to work on windows.

## Notes 

<https://github.com/sbn-psi/ldd_utilities>

 

- Need .Net (or Java). I installed .Net Core
- Need Saxon (or xsltproc) - XML stylesheet processor. I installed Saxon.Both updated my path as part of the installation.
- Download and install graphviz. You'll have to manually update the path.
- Download the two stylesheets. Should be .xsl, not .htm. Even if it claims to be .xsl, open it - there should be no "<meta" tags in the file.

 

Making the output files, for simplicity I put the ingest file in the same directory as the stylesheets.

 

On the command line I use "Transform" which is an executable within the Saxon package. Unfortunately I have another "Transform" somewhere, so I used the explicit path. Because the file specification includes a space in one directory name, the quotes are required in the command line statements below. [I'm tempted to try to rename the executable to SxnTransform, but that's for another day.] The following examples use the HST LDD.
 
### A. Generate the html summary of the LDD

  `C:\Program Files\Saxonica\SaxonHE9.8N\bin\"Transform -s:ingest_hst_1900_1.0.xml -xsl:IngestLddView.xsl -o:hst.html`

### B. Generate the diagram of the dictionary as a PDF. This requires two steps:

   1) generate a dot file, and 2) feed that to the "dot" executable in the graphviz package.
   `C:\Program Files\Saxonica\SaxonHE9.8N\bin\"Transform -s:ingest_hst_1900_1.0.xml -xsl:IngestLddDot.xsl -o:hst.dot`
   2) `dot -O -Tpdf hst.dot`

 