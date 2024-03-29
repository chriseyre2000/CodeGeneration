<!--?xml version="1.0" encoding="utf-8"?-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" standalone="yes" />
  <xsl:preserve-space elements="*" />
  <xsl:param name="entity"/>
<xsl:template match="/">public class <xsl:value-of select="$entity" />Entity 
{
<xsl:for-each select="model/entity[@name=$entity]/attribute"> public <xsl:value-of select="@type" /><xsl:text>&#xA0;</xsl:text><xsl:value-of select="@name" /> {get; set;}
</xsl:for-each>}</xsl:template>
</xsl:stylesheet>