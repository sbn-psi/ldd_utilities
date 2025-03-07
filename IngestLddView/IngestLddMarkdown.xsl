<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://pds.nasa.gov/pds4/pds/v1"
  xmlns:xs="http://www.w3.org/2001/XMLSchema-datatypes"
  exclude-result-prefixes="p"
>
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:param name="ns"><xsl:value-of select="/p:Ingest_LDD/p:namespace_id"/></xsl:param>
  <xsl:param name="dictfile"/>
  <xsl:param name="imversion"/>
  <xsl:param name="lddversion"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="p:Ingest_LDD"/>
  </xsl:template>

  <xsl:template match="p:Ingest_LDD">
    <xsl:text>---&#10;</xsl:text>
    <xsl:text>title: </xsl:text><xsl:text>PDS4 </xsl:text><xsl:value-of select="p:name"/><xsl:text> Local Data Dictionary User’s Guide&#10;</xsl:text>
    <xsl:text>date: </xsl:text><xsl:value-of select="p:last_modification_date_time"/><xsl:text>&#10;</xsl:text>
    <xsl:text>author: </xsl:text><xsl:value-of select="p:full_name"/><xsl:text>&#10;</xsl:text>
    <xsl:text>---&#10;</xsl:text>
    <xsl:text>## Introduction&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="p:comment"/><xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Purpose of this User’s Guide&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Audience&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Applicable Documents&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>## How to Include the </xsl:text><xsl:value-of select="p:name"/><xsl:text> Local Data Dictionary in a PDS4 Label&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Data Dictionary Files&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>There are several forms that a discipline dictionary can take. It can either be an ingest file, or a schema file coupled with a schematron file. The ingest file is used for authoring the dictionary, while the schema and schematron files, which are compiled from the ingest file, are used to actually validate a product label.&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Including the schema file in a label&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>In order to use the schema file, the Product_Observational element of your product label will need to have references to the dictionary added to it, as follows:&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>```xml&#10;</xsl:text>
    <xsl:text>&lt;Product_Observational&#10;</xsl:text>
    <xsl:text>   xmlns="http://pds.nasa.gov/pds4/pds/v1"&#10;</xsl:text>
    <xsl:text>   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"&#10;</xsl:text>
    <xsl:text>   xmlns:</xsl:text><xsl:value-of select='$ns'/><xsl:text>="http://pds.nasa.gov/pds4/</xsl:text><xsl:value-of select='$ns'/><xsl:text>/v1"&#10;</xsl:text>
    <xsl:text>   xsi:schemaLocation="http://pds.nasa.gov/pds4/pds/v1 &#10;</xsl:text>
    <xsl:text>      https://pds.nasa.gov/pds4/pds/v1/PDS4_PDS_</xsl:text><xsl:value-of select='$imversion'/><xsl:text>.xsd&#10;</xsl:text>
    <xsl:text>      http://pds.nasa.gov/pds4/</xsl:text><xsl:value-of select='$ns'/><xsl:text>/v1 &#10;</xsl:text>
    <xsl:text>      https://pds.nasa.gov/pds4/</xsl:text><xsl:value-of select='$ns'/><xsl:text>/v1/PDS4_</xsl:text><xsl:value-of select='upper-case($ns)'/><xsl:text>_</xsl:text><xsl:value-of select='$imversion'/><xsl:text>_</xsl:text><xsl:value-of select='$lddversion'/><xsl:text>.xsd"&gt; &#10;</xsl:text>
    <xsl:text>```&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>This example assumes that the </xsl:text><xsl:value-of select="p:name"/><xsl:text> is the only dictionary in your label. If you have multiple dictionaries, you will need to make other modifications.&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Including the schematron in a label&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>In order to use the schematron file, the xml prolog of your product label will need to have references to the dictionary added to it, as follows:&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>```xml&#10;</xsl:text>
    <xsl:text>&#60;?xml-model &#10;</xsl:text>
    <xsl:text>    href="https://pds.nasa.gov/pds4/</xsl:text><xsl:value-of select='$ns'/><xsl:text>/v1/PDS4_</xsl:text><xsl:value-of select='upper-case($ns)'/><xsl:text>_</xsl:text><xsl:value-of select='$imversion'/><xsl:text>_</xsl:text><xsl:value-of select='$lddversion'/><xsl:text>.xsd" &#10;</xsl:text>
    <xsl:text>    schematypens="http://purl.oclc.org/dsdl/schematron"?&gt;&#10;</xsl:text>
    <xsl:text>````&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>### Including the data dictionary elements&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>The data dictionary defines XML elements that can be used in a `Discipline_Area`. A minimal example of the discipline area follows:&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>```xml&#10;</xsl:text>
    <xsl:text>&lt;Discipline_Area&gt;&#10;</xsl:text>
    <xsl:apply-templates select="p:DD_Class[p:element_flag='true']" mode='sample'>
      <xsl:with-param name='indent' select='"  "'/>
    </xsl:apply-templates>
    <xsl:text>&lt;/Discipline_Area&gt;&#10;</xsl:text>
    <xsl:text>```&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>## Organization of Classes and Attributes&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>![Dictionary Diagram](images/</xsl:text><xsl:value-of select='replace($dictfile, ".xml", ".png")'/><xsl:text>)&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select='p:DD_Class' mode="org"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>## Definitions&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select='p:DD_Class | p:DD_Attribute' mode="def">
      <xsl:sort select="lower-case(p:name)"/>
    </xsl:apply-templates>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>## Examples&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
</xsl:template>



  <xsl:template match="p:DD_Class" mode="org">
    <xsl:variable name="name"><xsl:value-of select='p:name'/></xsl:variable>
    <xsl:text>&#10;</xsl:text>  
    <xsl:text>### </xsl:text><xsl:value-of select="$name"/><xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <!--<xsl:text>![</xsl:text><xsl:value-of select='$name'/><xsl:text>](images/</xsl:text><xsl:value-of select='p:name'/><xsl:text>.png)&#10;</xsl:text>-->
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select='p:definition'/><xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>#### </xsl:text><xsl:value-of select='$name'/><xsl:text> Subelements&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select='p:DD_Association'>
      <xsl:for-each select="p:identifier_reference[. != 'XSChoice#']">* <xsl:value-of select='.'/><xsl:text>&#10;</xsl:text></xsl:for-each>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test='//p:DD_Rule[ends-with(p:rule_context, $name)]/p:DD_Rule_Statement'>
      <xsl:text>&#10;</xsl:text>
      <xsl:text>#### </xsl:text><xsl:value-of select='$name'/><xsl:text> Rules&#10;</xsl:text>
      <xsl:apply-templates select='//p:DD_Rule[ends-with(p:rule_context, $name)]/p:DD_Rule_Statement' mode='org'/>
    </xsl:if>
  </xsl:template>

  <xsl:template match='p:DD_Rule_Statement' mode='org'>
    <xsl:variable name="rule_message">
      <xsl:choose>
        <xsl:when test='p:rule_description'><xsl:value-of select='p:rule_description'/></xsl:when>
        <xsl:otherwise><xsl:value-of select='p:rule_message'/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>  * </xsl:text><xsl:value-of select='$rule_message'/><xsl:text>&#10;</xsl:text>    
  </xsl:template>

  <xsl:template match="p:DD_Class" mode="sample">
    <xsl:param name="indent"></xsl:param>
    <xsl:value-of select="$indent"/><xsl:text>&lt;</xsl:text><xsl:value-of select='$ns'/><xsl:text>:</xsl:text><xsl:value-of select='p:name'/><xsl:text>&gt;&#10;</xsl:text>
      <xsl:apply-templates select = 'p:DD_Association[p:minimum_occurrences > 0]' mode="sample">
        <xsl:with-param name="indent" select="$indent"/>
      </xsl:apply-templates>
    <xsl:value-of select="$indent"/><xsl:text>&lt;/</xsl:text><xsl:value-of select='$ns'/><xsl:text>:</xsl:text><xsl:value-of select='p:name'/><xsl:text>&gt;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="p:DD_Attribute" mode="sample">
    <xsl:param name="indent">0</xsl:param>
    <xsl:value-of select="$indent"/><xsl:text>&lt;</xsl:text><xsl:value-of select='$ns'/><xsl:text>:</xsl:text><xsl:value-of select='p:name'/><xsl:text>&gt;value&gt;/</xsl:text><xsl:value-of select='$ns'/><xsl:text>:</xsl:text><xsl:value-of select='p:name'/><xsl:text>&gt;&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="p:DD_Association" mode="sample">
    <xsl:param name="indent">0</xsl:param>  
    <xsl:for-each select="p:identifier_reference[. != 'XSChoice#'][. != 'pds.Internal_Reference'][. != 'pds.Local_Internal_Reference'] | p:local_identifier[. != 'XSChoice#'][. != 'pds.Internal_Reference'][. != 'pds.Local_Internal_Reference']">
      <xsl:variable name="local_id_reference"><xsl:value-of select='.'/></xsl:variable>
      <xsl:apply-templates select='//p:DD_Class[p:local_identifier=$local_id_reference] | //p:DD_Attribute[p:local_identifier=$local_id_reference]' mode='sample'>
        <xsl:with-param name="indent" select="concat($indent, '  ')"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="p:DD_Class" mode="def">
    <xsl:text>### </xsl:text><xsl:value-of select="p:name"/> -- class<xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select='p:definition'/><xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="p:DD_Attribute" mode="def">
    <xsl:text>### </xsl:text><xsl:value-of select="p:name"/> -- attribute<xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select='p:definition'/><xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
