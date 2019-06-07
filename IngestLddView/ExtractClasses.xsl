<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://pds.nasa.gov/pds4/pds/v1"
  xmlns:xs="http://www.w3.org/2001/XMLSchema-datatypes"
  exclude-result-prefixes="p"
>
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//p:DD_Class"/>
    </xsl:template>

    <xsl:template match="p:DD_Class">
        <xsl:value-of select="p:name"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>