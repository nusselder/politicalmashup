<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pmx="http://www.politicalmashup.nl/extra" xmlns:folia="http://ilk.uvt.nl/FoLiA" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd pm xsl dc" version="2.0">
    <!--
        Transformer for political proceedings documents.
    -->  
    
    <!-- N.B. There apparently is some strange bug in saxon, that xpath version are not properly set. Using an import statement fixes this. If necessary, include the empty default-include.xsl **THIS IS A HACK UGLY FIX** -->
    <xsl:import href="common-link.xsl"/>
    <xsl:import href="folia-include.xsl"/>
    <xsl:import href="include-summary.xsl"/>
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="yes" method="xhtml" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>


    <!-- Lucene query, if supplied. -->
    <xsl:param name="query"/>
    <xsl:param name="namespace"/>
    <xsl:param name="relative-static-location" as="xs:string">
        <xsl:value-of select="if ($namespace ne '') then '../' else ''"/>
    </xsl:param>
    
    <!-- Wordcloud parameters. -->
    <xsl:param name="cloud" select="pm:include-summary-select-cloud(/,'all','parsimonious',0.1)"/>
    
    <!-- Identifier of the current document or document-part. -->
    <xsl:param name="identifier" as="xs:string">
        <xsl:choose>
            <xsl:when test="//dc:identifier">
                <xsl:value-of select="//dc:identifier"/>
            </xsl:when>
            <!-- When no dc:identifier available, the root element should have a @pm:id.. (confirmed by "feeling" this is correct). -->
            <xsl:otherwise>
                <xsl:variable name="parts" select="tokenize(/*/@pm:id,'\.d\.')"/>
                <xsl:variable name="local-id" select="tokenize($parts[2],'\.')[1]"/>
                <xsl:value-of select="concat($parts[1],'.d.',$local-id)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    
    
    <!-- Overrides for included templates. -->
    <xsl:template name="context-links">
        <xsl:call-template name="create-context-links">
            <xsl:with-param name="link-types" select="('X','C')"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <!--
        Build the HTML document.
    -->
    <xsl:template match="/">
        <html>
            <xsl:call-template name="head"/>
            <xsl:call-template name="body"/>
        </html>
    </xsl:template>
    <xsl:template name="head">
        <head>
            <meta http-equiv="Content-type" content="text/html;charset=UTF-8"/>
            <title>
                <xsl:value-of select="//dc:identifier"/>
            </title>
            <link rel="stylesheet" type="text/css" href="{$relative-static-location}static/css/default.css"/>
            <script type="text/javascript" src="{$relative-static-location}static/js/default.js"/>
            <xsl:if test="//folia:s">
                <link rel="stylesheet" type="text/css" href="{$relative-static-location}static/css/folia.css"/>
            </xsl:if>
            
            <!-- TODO, only add when summary is present? -->
            <link rel="stylesheet" type="text/css" href="{$relative-static-location}static/css/summary.css"/>
            <xsl:call-template name="include-summary-head-script-d3-cloud">
                <xsl:with-param name="relative-static-location" select="$relative-static-location"/>
                <xsl:with-param name="cloud" select="$cloud"/>
            </xsl:call-template>
        </head>
    </xsl:template>
    <xsl:template name="body">
        <!-- create common onload function with arguments? -->
        <!--<body onload="highlight_hash();">-->
        <body>
            <xsl:call-template name="menu"/>
            <xsl:call-template name="content"/>
            <xsl:call-template name="include-summary-body-script-d3-cloud">
                <xsl:with-param name="cloud" select="$cloud"/>
            </xsl:call-template>
        </body>
    </xsl:template>
    
    
    <!--
        Menu templates.
    -->
    <xsl:template name="menu">
        <div id="menu">
            <xsl:call-template name="logo"/>
            <xsl:call-template name="sources"/>
            <xsl:call-template name="summary"/>
            <xsl:call-template name="lucene-query"/>
            <xsl:call-template name="folia-legend"/>
        </div>
    </xsl:template>
    <xsl:template name="logo">
        <div class="logo">
            <img src="{$relative-static-location}static/img/politicalmashup-small.png" alt="PoliticalMashup logo" class="logo"/>
        </div>
    </xsl:template>
    <xsl:template name="sources">
        <div id="sources">
            <div>source(s):
                <xsl:for-each select="//dc:source/pm:link[@pm:source ne '']">
                    <xsl:copy-of select="pm:external-a(@pm:source, string(@pm:linktype))"/>
                </xsl:for-each>
            </div>
            <div>date: <xsl:value-of select="//dc:date"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="summary">
        <div id="summary">
            <div class="topics">documents: <xsl:value-of select="count(//pmx:document)"/>
            </div>
            <div class="scenes">titles: <xsl:value-of select="count(//pmx:title)"/>
            </div>
            <div class="speeches">texts: <xsl:value-of select="count(//pmx:text)"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="lucene-query">
        <!-- Exclude results withing pm:vote elements, which are duplicates of actual text anyway. -->
        <xsl:variable name="hits" select="//exist:match[not(ancestor::pm:vote)]"/>
        <xsl:if test="$hits">
            <xsl:variable name="distinct-hits-quoted" as="node()*">
                <xsl:for-each select="distinct-values($hits)">
                    <xsl:value-of select="concat('“',.,'”')"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="distinct-hits" select="string-join($distinct-hits-quoted,', ')"/>
            <div id="lucene-query">
                <div>
                    Query: “<xsl:value-of select="$query"/>”<br/>
                    Hits: <xsl:value-of select="count($hits)"/>
                    <br/>
                    Matched values: <xsl:value-of select="$distinct-hits"/>
                    <br/>
                    Matches in document:<br/>
                </div>
                <div id="lucene-query-matches">
                    <xsl:for-each select="$hits">
                        <a class="lucene-match internal" href="#{(./ancestor::*[@pm:id])[last()]/@pm:id}">
                            <xsl:value-of select="."/>
                        </a>
                        <br/>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="folia-legend">
        <xsl:if test="//folia:s">
            <div class="other">
                <span class="folia-class-loc">loc</span> action,<br/>
                <span class="folia-class-per">per</span> son,<br/>
                <span class="folia-class-org">org</span> anisation,<br/>
                <span class="folia-class-pro">pro</span> duct,<br/>
                <span class="folia-class-misc">misc</span> ellaneous,<br/>
                <span class="folia-has-wiki">has wikilink</span>
            </div>
        </xsl:if>
    </xsl:template>
    
    
    <!--
        Content templates.
    -->
    <xsl:template name="content">
        <div id="content">
            <div class="topic summary">
                <xsl:call-template name="include-summary-display-clouds">
                    <xsl:with-param name="cloud" select="$cloud"/>
                    <xsl:with-param name="max-display-terms" select="10"/>
                    <xsl:with-param name="max-wordle-terms" select="20"/>
                </xsl:call-template>
                <xsl:call-template name="include-summary-display-entity-links">
                    <xsl:with-param name="dc-identifier" select="$identifier"/>
                </xsl:call-template>
            </div>
            <xsl:apply-templates select="/" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="root" mode="content">
        <xsl:apply-templates select="//pmx:document" mode="content"/>
    </xsl:template>
    <xsl:template match="pmx:document" mode="content">
        <div class="topic" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <h2>
                <xsl:call-template name="context-links"/>
                <!--<xsl:value-of select="@pm:title"/>-->
                <xsl:value-of select="substring(//dc:identifier,1,60)"/>
            </h2>
            <xsl:apply-templates select="*|text()" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="pmx:title" mode="content">
        <xsl:if test="*|text()">
            <div class="scene generic" id="{@pm:id}">
                <a name="{@pm:id}"/>
                <h3>
                    <xsl:call-template name="context-links"/>
                    Titel
                </h3>
                <xsl:apply-templates select="*|text()" mode="content"/>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="pmx:text" mode="content">
        <div class="scene generic" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <h3>
                <xsl:call-template name="context-links"/>
                Tekst
            </h3>
            <xsl:apply-templates select="*|text()" mode="content"/>
        </div>
    </xsl:template>
    
    <!--<xsl:template match="folia:s" mode="content">
        <div>
            <xsl:apply-templates select="folia:t" mode="content"/>
        </div>
    </xsl:template>-->
    <xsl:template match="folia:s" mode="content">
        <xsl:apply-templates select="."/>
    </xsl:template>
    
    <!-- Anything not otherwise defined. -->
    <xsl:template match="*" mode="content">
        <div>
            <xsl:apply-templates select="*|text()" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="text()" mode="content">
        <p>
            <xsl:value-of select="."/>
        </p>
    </xsl:template>
    


    <!-- Old proceedings stuff. -->
    <xsl:template match="pm:p" mode="content">
        <a name="{@pm:id}"/>
        <p id="{@pm:id}">
            <xsl:call-template name="context-links"/>
            <xsl:apply-templates select="./*|text()" mode="content"/>
        </p>
    </xsl:template>
    <xsl:template match="exist:match" mode="content">
        <em class="query-match">
            <xsl:apply-templates select="./*|text()" mode="content"/>
        </em>
    </xsl:template>


    <!-- TODO: move all pm:tagged to a separate view-include, for reuse in other views. -->
    <xsl:template match="pm:tagged[./pm:tagged-entity/@pm:sub-type eq 'dossierref'][not(contains((ancestor::*/@pm:id)[1],'nl.proc.sgd.'))]" mode="content">
        <em>
            <!-- Make <tagged> handling more general, this works only for dutch dossier links. -->
            <a href="{concat('https://zoek.officielebekendmakingen.nl/dossier/',./pm:tagged-entity/@pm:reference)}" class="external">
                <xsl:apply-templates select="./*|text()" mode="content"/>
            </a>
        </em>
    </xsl:template>
    <xsl:template match="pm:tagged[@pm:type eq 'named-entity'][./pm:tagged-entity/@pm:sub-type eq 'member-ref']" mode="content">
        <em>
            <!-- Make <tagged> handling more general, this works only for dutch dossier links. -->
            <a href="{concat('http://resolver.politicalmashup.nl/',./pm:tagged-entity/@pm:member-ref,'?view=html')}" class="politicalmashup">
                <xsl:apply-templates select="./*|text()" mode="content"/>
            </a>
        </em>
    </xsl:template>
    <xsl:template match="pm:tagged[@pm:type eq 'reference'][./pm:tagged-entity/@pm:sub-type eq 'extref']" mode="content">
        <em>
            <a href="{concat('https://zoek.officielebekendmakingen.nl/',./pm:tagged-entity/@pm:reference,'.html')}" class="external">
                <xsl:apply-templates select="./*|text()" mode="content"/>
            </a>
        </em>
    </xsl:template>
    <xsl:template match="pm:tagged" mode="content">
        <xsl:apply-templates select="./*|text()" mode="content"/>
    </xsl:template>
</xsl:stylesheet>