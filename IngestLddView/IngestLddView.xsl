<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:p="http://pds.nasa.gov/pds4/pds/v1"
>
  <xsl:param name="ns"/>
  <xsl:template match="/">
    <html>
      <head>
        <style>
          h1 {font-size:125%; font-weight:bold; margin:0px; background-color:lightgray}
          ul {margin:0px;}
          div.type {border:thin black solid;}
          div.enumValues {font-style: italic}
          div.doc {font-style: italic}
          div.attribute {border: thin black solid; margin:10px; padding:10px}
          div.class {border: thin black solid; margin:10px; padding:10px}
          div.choice {border: thin blue solid; margin:10px; padding:10px}
          div.path {font-style: italic}
        </style>
      </head>
      <body>
        <xsl:apply-templates select="p:Ingest_LDD"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="p:Ingest_LDD">
    <h1><xsl:value-of select="p:name"/></h1>

    <h2>Elements</h2>
    <xsl:for-each select="p:DD_Class[p:element_flag='true']">
      <h3><xsl:value-of select="p:name"/></h3>
      <xsl:apply-templates select=".">
        <xsl:with-param name="parent"></xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="p:DD_Class">
    <xsl:param name="parent"/>
    <xsl:variable name="path"><xsl:value-of select="$parent"/><xsl:value-of select="$ns"/>:<xsl:value-of select="p:name"/></xsl:variable>

    <div class="class">
      <div class="path"><xsl:value-of select="$path"/></div>
      <div>
        <xsl:value-of select="p:definition"/>
      </div>
      <h3>Members:</h3>
      <xsl:apply-templates select="p:DD_Association">
        <xsl:with-param name="parent"><xsl:value-of select="$path"/>/</xsl:with-param>
      </xsl:apply-templates>

      <xsl:if test="//p:DD_Rule[substring($path, string-length($path) - string-length(p:rule_context) +1) = p:rule_context]">
        <h3>Rules:</h3>
        <xsl:apply-templates select="//p:DD_Rule[substring($path, string-length($path) - string-length(p:rule_context) +1) = p:rule_context]"/>
      </xsl:if>
    </div>
  </xsl:template>


  <xsl:template match="p:DD_Association">
    <xsl:param name="parent"/>
    <xsl:variable name="local_identifier"><xsl:value-of select="p:local_identifier"/></xsl:variable>
    <div>
      <h4><xsl:value-of select="p:local_identifier"/><xsl:if test='p:minimum_occurrences'> (<xsl:value-of select="p:minimum_occurrences"/>-<xsl:value-of select="p:maximum_occurrences"/>)</xsl:if></h4>
      <xsl:choose>
        <xsl:when test="p:reference_type='attribute_of'">
          <xsl:apply-templates select="//p:DD_Attribute[p:local_identifier=$local_identifier]">
            <xsl:with-param name="parent"><xsl:value-of select="$parent"/></xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="p:reference_type='component_of'">
          <xsl:apply-templates select="//p:DD_Class[p:local_identifier=$local_identifier]">
            <xsl:with-param name="parent"><xsl:value-of select="$parent"/></xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="p:DD_Association[p:local_identifier='XSChoice#']">
    <xsl:param name="parent"/>

    <h4><xsl:value-of select="p:minimum_occurrences"/>-<xsl:value-of select="p:maximum_occurrences"/> of the following:</h4>
    <div class='choice'>
      <xsl:for-each select="p:local_identifier[not(.='XSChoice#')]">
        <xsl:variable name="local_identifier"><xsl:value-of select="."/></xsl:variable>

        <div>
          <h4><xsl:value-of select="."/></h4>
          <xsl:choose>
            <xsl:when test="../p:reference_type='attribute_of'">
              <xsl:apply-templates select="//p:DD_Attribute[p:local_identifier=$local_identifier]">
                <xsl:with-param name="parent"><xsl:value-of select="$parent"/></xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="../p:reference_type='component_of'">
              <xsl:apply-templates select="//p:DD_Class[p:local_identifier=$local_identifier]">
                <xsl:with-param name="parent"><xsl:value-of select="$parent"/></xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
          </xsl:choose>
        </div>
      </xsl:for-each>
    </div>
   </xsl:template>

  <xsl:template match="p:DD_Attribute">
    <xsl:param name="parent"/>
    <xsl:variable name="path"><xsl:value-of select="$parent"/><xsl:value-of select="$ns"/>:<xsl:value-of select="p:name"/></xsl:variable>

    <div class="attribute">
      <div class="path"><xsl:value-of select="$path"/></div>
      <xsl:if test="p:nillable_flag='true'">Nillable.</xsl:if>
      <xsl:value-of select="p:definition"/>
      <xsl:apply-templates select="p:DD_Value_Domain"/>

      <xsl:if test="//p:DD_Rule[substring($path, string-length($path) - string-length(p:rule_context) +1) = p:rule_context]">
        <h4>Rules:</h4>
        <xsl:apply-templates select="//p:DD_Rule[substring($path, string-length($path) - string-length(p:rule_context) +1) = p:rule_context]"/>
      </xsl:if>

    </div>

  </xsl:template>

  <xsl:template match="p:DD_Value_Domain[p:DD_Permissible_Value]">
    <xsl:param name="parent"/>
    <div>Values:</div>
    <xsl:apply-templates select="p:DD_Permissible_Value"/>
  </xsl:template>

  <xsl:template match="p:DD_Permissible_Value">
    <li><b><xsl:value-of select="p:value"/></b>: <xsl:value-of select="p:value_meaning"/></li>
  </xsl:template>


  <xsl:template match="p:DD_Value_Domain">
    Non-enumerated.
    <xsl:if test="p:formation_rule">
      <div>
        Pattern: <xsl:value-of select="p:formation_rule"/>
      </div>
    </xsl:if>
    <xsl:if test="p:pattern">
      <div>
        Pattern: <xsl:value-of select="p:pattern"/>
      </div>
    </xsl:if>
    <xsl:if test="p:value_data_type">
      <div>
        Data Type: <xsl:value-of select="p:value_data_type"/>
      </div>
    </xsl:if>
    <xsl:if test="p:unit_of_measure_type">
      <div>
        Unit Type: <xsl:value-of select="p:unit_of_measure_type"/>
      </div>
    </xsl:if>
    <xsl:if test="p:minimum_value">
      <div>
        Min: <xsl:value-of select="p:minimum_value"/> <xsl:value-of select="p:specified_unit_id"/>
      </div>
    </xsl:if>
    <xsl:if test="p:maximum_value">
      <div>
        Max: <xsl:value-of select="p:maximum_value"/> <xsl:value-of select="p:specified_unit_id"/>
      </div>
    </xsl:if>
    <xsl:if test="p:minimum_characters">
      <div>
        Min length: <xsl:value-of select="p:minimum_characters"/>
      </div>
    </xsl:if>
    <xsl:if test="p:maximum_characters">
      <div>
        Max length: <xsl:value-of select="p:minimum_characters"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="p:DD_Rule">
    <xsl:apply-templates select="p:DD_Rule_Statement"/>
  </xsl:template>

  <xsl:template match="p:DD_Rule_Statement">
    <div><xsl:value-of select="p:rule_message"/></div>
  </xsl:template>
</xsl:stylesheet>
