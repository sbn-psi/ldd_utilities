<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://pds.nasa.gov/pds4/pds/v1"
  xmlns:xs="http://www.w3.org/2001/XMLSchema-datatypes"
  exclude-result-prefixes="p"
>
  <xsl:output method="html" encoding="utf-8"/>
  <xsl:param name="ns"><xsl:value-of select="/p:Ingest_LDD/p:namespace_id"/></xsl:param>
  <xsl:param name="dictfile"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="p:Ingest_LDD"/>
  </xsl:template>

  <xsl:template match="p:Ingest_LDD">
# PDS4 <xsl:value-of select="p:name"/> Local Data Dictionary User’s Guide
<xsl:value-of select="p:last_modification_date_time"/>, <xsl:value-of select="p:full_name"/>

## Introduction
   
<xsl:value-of select="p:comment"/>

### Purpose of this User’s Guide

### Audience

### Applicable Documents

## How to Include the <xsl:value-of select="p:name"/> Local Data Dictionary in a PDS4 Label

### Data Dictionary Files

There are several forms that a discipline dictionary can take. It can either be an ingest file, or a schema file coupled with a schematron file. The ingest file is used for authoring the dictionary, while the schema and schematron files, which are compiled from the ingest file, are used to actually validate a product label.

### Including the schema file in a label


In order to use the schema file, the Product_Observational element of your product label will need to have references to the dictionary added to it, as follows:

```xml
[Product_Observational
   xmlns="http://pds.nasa.gov/pds4/pds/v1"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:<xsl:value-of select='$ns'/>="http://pds.nasa.gov/pds4/<xsl:value-of select='$ns'/>/v1"
   xsi:schemaLocation="http://pds.nasa.gov/pds4/pds/v1 
                       https://pds.nasa.gov/pds4/pds/v1/PDS4_PDS_1900.xsd
                       http://pds.nasa.gov/pds4/<xsl:value-of select='$ns'/>/v1 
                       https://pds.nasa.gov/pds4/nucspec/v1/<xsl:value-of select='replace($dictfile, ".xml", ".xsd")'/>"] 
```

This example assumes that the <xsl:value-of select="p:name"/> is the only dictionary in your label. If you have multiple dictionaries, you will need to make other modifications.

### Including the schematron in a label

In order to use the schematron file, the xml prolog of your product label will need to have references to the dictionary added to it, as follows:

```xml
[?xml-model 
    href="https://pds.nasa.gov/pds4/<xsl:value-of select='$ns'/>/v1/<xsl:value-of select='replace($dictfile, ".xml", ".sch")'/>" 
    schematypens="http://purl.oclc.org/dsdl/schematron"?]
````

### Including the data dictionary elements

The data dictionary defines XML elements that can be used in a `Discipline_Area`. A minimal example of the discipline area follows:

```xml
[Discipline_Area]
<xsl:apply-templates select="p:DD_Class[p:element_flag='true']" mode='sample'>
  <xsl:with-param name='indent' select='"  "'/>
</xsl:apply-templates>
[/Discipline_Area]
```

## Organization of Classes and Attributes

![Image](images/<xsl:value-of select='replace($dictfile, ".xml", ".png")'/>)


<xsl:apply-templates select='p:DD_Class' mode="org"/>

## Definitions

<xsl:apply-templates select='p:DD_Class | p:DD_Attribute' mode="def">
  <xsl:sort select="lower-case(p:name)"/>
</xsl:apply-templates>

## Examples
  </xsl:template>



  <xsl:template match="p:DD_Class" mode="org">
### <xsl:value-of select="p:name"/>
    <xsl:text>&#10;</xsl:text>
![<xsl:value-of select='p:name'/>](images/<xsl:value-of select='p:name'/>.png)
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select='p:definition'/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="p:DD_Class" mode="sample">
    <xsl:param name="indent"></xsl:param>
    <xsl:value-of select="$indent"/>[<xsl:value-of select='$ns'/>:<xsl:value-of select='p:name'/>]
      <xsl:apply-templates select = 'p:DD_Association[p:minimum_occurrences > 0]' mode="sample">
        <xsl:with-param name="indent" select="$indent"/>
      </xsl:apply-templates>
    <xsl:value-of select="$indent"/>[/<xsl:value-of select='$ns'/>:<xsl:value-of select='p:name'/>]
  </xsl:template>

  <xsl:template match="p:DD_Attribute" mode="sample">
    <xsl:param name="indent">0</xsl:param>
    <xsl:value-of select="$indent"/>[<xsl:value-of select='$ns'/>:<xsl:value-of select='p:name'/>]value[/<xsl:value-of select='$ns'/>:<xsl:value-of select='p:name'/>]
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
### <xsl:value-of select="p:name"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select='p:definition'/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="p:DD_Attribute" mode="def">
### <xsl:value-of select="p:name"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select='p:definition'/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
