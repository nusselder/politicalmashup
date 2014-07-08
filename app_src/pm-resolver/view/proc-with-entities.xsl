<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd pm xsl dc">
    <!--
        Transformer for political proceedings documents.
    -->      
    
    <!-- N.B. There apparently is some strange bug in saxon, that xpath version are not properly set. Using an import statement fixes this. If necessary, include the empty default-include.xsl **THIS IS A HACK UGLY FIX** -->
    <xsl:import href="common-link.xsl"/>
    <xsl:import href="nl-votes.xsl"/>
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
            
            <!--<xsl:if test="//folia:s">-->
            <xsl:if test="true()">
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
            <xsl:call-template name="index"/>
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
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </div>
            <div>date: <xsl:value-of select="//dc:date"/>
            </div>
            <div class="last">house: <xsl:value-of select="//pm:house/@pm:house"/>
                <br/>[<xsl:value-of select="//pm:house"/>]</div>
        </div>
    </xsl:template>
    <xsl:template name="summary">
        <div id="summary">
            <div class="topics">topics: <xsl:value-of select="count(//pm:topic)"/>
            </div>
            <div class="scenes">scenes: <xsl:value-of select="count(//pm:scene)"/>
            </div>
            <div class="speeches">speeches: <xsl:value-of select="count(//pm:speech)"/>
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
    <xsl:template name="index">
        <div id="index">
            <ul>
                <xsl:apply-templates select="//pm:topic" mode="menu"/>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="pm:topic" mode="menu">
        <xsl:variable name="max-title-length" select="30" as="xs:integer"/>
        <xsl:variable name="count" select="if (./pm:scene) then count(./pm:scene) else count(./pm:speech)"/>
        <xsl:variable name="title" select="if (string-length(@pm:title) gt $max-title-length) then concat(substring(@pm:title,0,$max-title-length - 3),'...') else @pm:title"/>
        <xsl:variable name="topic-title">
            <xsl:value-of select="position()"/>. <span class="item-title">
                <xsl:value-of select="$title"/>
            </span> (<xsl:value-of select="$count"/>)
        </xsl:variable>
        <li>
            <a href="#{@pm:id}" class="internal">
                <xsl:copy-of select="$topic-title"/>
                <xsl:if test="string-length(@pm:title) gt $max-title-length">
                    <div class="full">
                        <xsl:value-of select="@pm:title"/>
                    </div>
                </xsl:if>
            </a>
        </li>
        <xsl:for-each select=".//pm:scene">
            <xsl:variable name="type-title" select="if (not(empty(@pm:speaker))) then @pm:speaker else substring(@pm:title,0,22)"/>
            <xsl:variable name="scene-title">
                <xsl:value-of select="position()"/>. <span class="item-title">
                    <xsl:value-of select="$type-title"/>
                </span> (<xsl:value-of select="count(.//pm:speech)"/>)
            </xsl:variable>
            <li class="indent">
                <a href="#{@pm:id}" class="internal">
                    <xsl:copy-of select="$scene-title"/>
                </a>
            </li>
        </xsl:for-each>
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
        <xsl:apply-templates select="//pm:topic" mode="content"/>
    </xsl:template>
    <xsl:template match="pm:topic" mode="content">
        <div class="topic" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <h2>
                <xsl:call-template name="context-links"/>
                <xsl:value-of select="@pm:title"/>
            </h2>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:scene" mode="content">
        <div class="scene" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <h3>
                <xsl:call-template name="context-links"/>
                <xsl:value-of select="if (not(empty(@pm:speaker))) then @pm:speaker else substring(@pm:title,0,25)"/>
            </h3>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:speech" mode="content">
        <div class="speech" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <xsl:call-template name="speech-header"/>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template name="speech-header">
        <xsl:variable name="member-link" select="pm:member-href-url(@pm:member-ref)"/>
        <xsl:variable name="party-link" select="pm:party-href-url(@pm:party-ref)"/>
        <xsl:variable name="member-img" select="pm:member-href-image(@pm:member-ref)"/>
        <h4>
            <xsl:call-template name="context-links"/>
            <xsl:choose>
                <xsl:when test="$member-link ne ''">
                    <a href="{$member-link}" class="politicalmashup">
                        <xsl:value-of select="@pm:speaker"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@pm:speaker"/>
                </xsl:otherwise>
            </xsl:choose>    
            (<xsl:value-of select="@pm:function"/>)
            <xsl:choose>
                <xsl:when test="@pm:party and $party-link ne ''">
                    (<a href="{$party-link}" class="politicalmashup">
                        <xsl:value-of select="@pm:party"/>
                    </a>)
                </xsl:when>
                <xsl:when test="@pm:party">
                    (<xsl:value-of select="@pm:party"/>)
                </xsl:when>
            </xsl:choose>
        </h4>
        <xsl:if test="$member-img ne ''">
            <div class="speaker-image">
                <a href="{$member-link}">
                    <img alt="no member profile picture" src="{$member-img}"/>
                </a>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="pm:stage-direction" mode="content">
        <div class="stage-direction" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <xsl:call-template name="context-links"/>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <!-- Handle headers/footers/pagebreaks (from nl-sgd) differently. -->
    <xsl:template match="pm:stage-direction[@pm:type = ('header','footer','pagebreak')]" mode="content">
        <div class="stage-direction stage-direction-meta" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <xsl:call-template name="context-links"/>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:p" mode="content">
        <a name="{@pm:id}"/>
        <p id="{@pm:id}">
            <xsl:call-template name="context-links"/>
            <xsl:apply-templates select="./*|text()" mode="content"/>
            <xsl:call-template name="include-summary-display-element-entities">
                <xsl:with-param name="element-id" select="@pm:id"/>
            </xsl:call-template>
        </p>
    </xsl:template>
    <xsl:template match="exist:match" mode="content">
        <em class="query-match">
            <xsl:apply-templates select="./*|text()" mode="content"/>
        </em>
    </xsl:template>
    <xsl:template match="text()" mode="content">
        <xsl:value-of select="."/>
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
    <xsl:template match="pm:chair" mode="content">
        <div class="chair-declaration">
            <em>
                Voorzitter:
                <a href="{pm:member-href-url(@pm:member-ref)}" class="politicalmashup">
                    <xsl:value-of select="@pm:speaker"/>
                </a>
            </em>
        </div>
    </xsl:template>
    <xsl:template match="pm:pagebreak" mode="content">
        <div class="pagebreak">
            <em>
                <a href="{@pm:source}" class="external" title="Origineel van onderstaande pagina {@pm:originalpagenr}">
                    pagina <xsl:value-of select="@pm:originalpagenr"/>
                </a>
            </em>
        </div>
    </xsl:template>
    <xsl:template match="pm:members[@pm:status eq 'present']" mode="content">
        <div class="members-present">
            <xsl:for-each select="pm:person">
                <em>
                    <xsl:choose>
                        <xsl:when test="@pm:member-ref ne ''">
                            <a href="{concat('http://resolver.politicalmashup.nl/',@pm:member-ref,'?view=html')}" class="politicalmashup">
                                <xsl:value-of select="@pm:speaker"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@pm:speaker"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@pm:function"> (<xsl:value-of select="@pm:function"/>)</xsl:if>,
                </em>
            </xsl:for-each>
        </div>
    </xsl:template>
</xsl:stylesheet>