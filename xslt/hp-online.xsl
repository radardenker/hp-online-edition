<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="xsl"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  
  <xsl:output method="xhtml"  encoding="UTF-8" omit-xml-declaration="yes" indent="yes"/>
  
  <!-- templates -->
  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
	<title>Haṭhapradīpikā Online</title>
	<link href="style.css?rnd=132" rel="stylesheet" type="text/css"/>
      </head>
      <xsl:apply-templates select="TEI/text/body"/>
    </html>
  </xsl:template>

  <!-- if nothing else matches: identity transformation for text nodes -->
  <xsl:template match="text()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template>
  
  <!-- main template -->
  <xsl:template match="body">
    <body>
      <div id="content">
	<h1>Haṭhapradīpikā Online</h1>
	<xsl:apply-templates/>
      </div>
      </body>
  </xsl:template>
  
  <xsl:template match="lg[not(ancestor::note)]">
    <xsl:variable name="correspkey" select="concat('#', @xml:id )"/>
    <div class="main">
      <div class="hpmeta">
	<div class="text">
	
	  <div class="hp">
	    <span class="number">
	      <xsl:value-of select="replace(@xml:id, 'hp0*(\d+)_0*(\d+)', 'HP $1.$2')"/>
	    </span>
	    <xsl:apply-templates/>
	  </div>
	  
	  <div class="translation">
	    <xsl:apply-templates select="document('../xml/HP1-TranslComm-tei.xml')//note[@type='translation' and @target=$correspkey]"/>
	  </div>
	  
	  <details class="philcomm-d">
	    <summary>Philological Commentary</summary>
	    <div class="philcomm">
	      <xsl:apply-templates select="document('../xml/HP1-TranslComm-tei.xml')//note[@type='philcomm' and @target=$correspkey]"/>
	    </div>
	  </details>
	  
	</div>

	<div class="crit">
	  <div class="apparatus">
	    <h3>Readings</h3>
	      <xsl:for-each select="descendant::app">
		<xsl:call-template name="apparatus"/>
	      </xsl:for-each>
	    </div>
	    <details class="marma-d">
	      <summary>More Readings</summary>
	      <div class="marma">
		<xsl:apply-templates select="document('../xml/Marmasthanas-tei.xml')//note[@type='marma' and @target=$correspkey]"/>
	      </div>
	    </details>
	  </div>
	</div>

	<details class="jyotsna-d">
	  <summary>Jyotsna Commentary</summary>
	  <div class="jyotsna">
	    <xsl:apply-templates select="document('../xml/Jyotsna-tei.xml')//note[@type='jyotsna' and @target=$correspkey]"/>
	  </div>
	</details>
    </div>
  </xsl:template>
  
  <!-- lemma-choice -->
  <xsl:template match="app[descendant::rdg] | app[descendant::lem]">
    <mark>
      <xsl:choose>
	<xsl:when test="lem">
	  <xsl:apply-templates select="lem/node()"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="descendant::rdg[1]/node()"/>
	</xsl:otherwise>
      </xsl:choose>
    </mark>
  </xsl:template>

  <!-- apparatus -->
  <xsl:template name="apparatus">
    <div class="app">
      <xsl:choose>
	<xsl:when test="lem">
	    <xsl:apply-templates select="lem" mode="lemma"/>
	    <xsl:text> ]</xsl:text>
	    <xsl:text> </xsl:text>
	    <xsl:for-each select="descendant::rdg[not(position() = last())]">
	      <xsl:apply-templates select="."/><xsl:text>, </xsl:text>
	    </xsl:for-each>
	    <xsl:apply-templates select="descendant::rdg[position() = last()]"/>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:apply-templates select="descendant::rdg[1]" mode="lemma"/>
	    <xsl:text> ]</xsl:text>
	    <xsl:text> </xsl:text>
	    <xsl:for-each select="descendant::rdg[position() > 1][not(position() = last())]">
	      <xsl:apply-templates select="."/><xsl:text>, </xsl:text>
	    </xsl:for-each>
	    <xsl:apply-templates select="descendant::rdg[position() = last()]"/>
	</xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="lem|rdg" mode="lemma">
    <xsl:variable name="correspkey" select="concat('#', @xml:id )"/>
    <span class="lem">
      <xsl:apply-templates/>
    </span>
    <xsl:call-template name="sigla"/>
  </xsl:template>

  <xsl:template match="lem|rdg">
    <xsl:variable name="correspkey" select="concat('#', @xml:id )"/>
    <xsl:apply-templates/>
    <xsl:call-template name="sigla"/>
  </xsl:template>

  <xsl:template name="sigla">
     <xsl:if test="@wit">
      <xsl:text> (</xsl:text>
      <xsl:variable name="tree" select="//*"/>
      <xsl:for-each select="tokenize(@wit,'\s+')">
	<xsl:variable name="token" select="."/>
	<xsl:if test="position()>=2">
	  <xsl:text> </xsl:text>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="starts-with(., '#')">
	    <xsl:variable name="idkey" select="substring-after(., '#')"/>
	    <xsl:element name="span">
	      <xsl:attribute name="class">siglum</xsl:attribute>
	      <xsl:attribute name="title">
		<xsl:value-of select="normalize-space($tree[@xml:id = $idkey])"/>
	      </xsl:attribute>
	      <xsl:value-of select="substring-after(., '#')"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="."/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- simple html equivalents -->  
  <xsl:template match="l[not(ancestor::note)]">
    <p class="hpvers"><xsl:apply-templates/></p>
  </xsl:template>

  
  <xsl:template match="p">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <!-- non-main stanzas -->
  <xsl:template match="lg[ancestor::note]">
    <div class="lg">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

   <xsl:template match="l[ancestor::note]">
    <p class="vers"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- footnotes -->
  <xsl:template match="note[@place='bottom']">
    <xsl:element name="span">
      <xsl:attribute name="class">fn</xsl:attribute>
      <xsl:attribute name="title">
	<xsl:value-of select="."/>
      </xsl:attribute>
      <xsl:text>*</xsl:text>
    </xsl:element>
  </xsl:template>
  
  <!-- lists -->
  <xsl:template match="list">
    <ul class="list">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="list/label[following-sibling::item]">
    <li><span class="label"><xsl:apply-templates/>: </span>
    <xsl:value-of select="following-sibling::item[1]"/></li>
  </xsl:template>
  
  <xsl:template match="item[not(preceding-sibling::label)]">
    <li><xsl:apply-templates/></li>
  </xsl:template>

   <xsl:template match="item[preceding-sibling::label]"/>
  
  <!-- headings -->
  <xsl:template match="head">
    <h3><xsl:apply-templates/></h3>
  </xsl:template>

  <!-- emphasis -->
  <xsl:template match="hi">
    <i><xsl:apply-templates/></i>
  </xsl:template>
  
  <!--deletions -->
  
</xsl:stylesheet>