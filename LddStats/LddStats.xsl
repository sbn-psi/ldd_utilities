<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://pds.nasa.gov/pds4/pds/v1"
  exclude-result-prefixes="p"
>
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:param name="ns"><xsl:value-of select="/p:Ingest_LDD/p:namespace_id"/></xsl:param>
  <xsl:template match="/">
    <xsl:value-of select="$ns"/>,<xsl:value-of select="count(//p:DD_Class)"/>,<xsl:value-of select="count(//p:DD_Class[p:element_flag='true'])"/>,<xsl:value-of select="count(//p:DD_Attribute)"/>,<xsl:value-of select="count(//p:DD_Rule_Statement)"/>,<xsl:value-of select="count(//p:DD_Association/p:identifier_reference[substring(., 1, 4) = 'pds.'])"/>,<xsl:value-of select="count(//p:DD_Association/p:identifier_reference[substring(., 1, 9) = 'XSChoice#'])"/>,<xsl:value-of select="count(//p:DD_Association) div count(//p:DD_Class)"/>,<xsl:value-of select="count(//p:DD_Association[p:reference_type = 'component_of']) div count(//p:DD_Class)"/>,<xsl:value-of select="count(//p:DD_Association[p:reference_type = 'attribute_of']) div count(//p:DD_Class)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


</xsl:stylesheet>
