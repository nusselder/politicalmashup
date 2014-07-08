<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd pm xsl dc" version="2.0">
    <xsl:import href="common-link.xsl"/>
    <xsl:import href="nl-votes.xsl"/>
    <xsl:param name="query"/>

    <!-- N.B. There apparently is some strange bug in saxon, that xpath version are not properly set. Using an import statement fixes this **THIS IS A HACK UGLY FIX** -->
    <xsl:output indent="yes" omit-xml-declaration="yes" method="xhtml" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>
    
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
    
    
    <!-- Given a global member id, return a link to their profile page. -->
    <xsl:function name="pm:member-href-url">
        <xsl:param name="member-ref"/>
        <xsl:variable name="url">
            <xsl:choose>
                <xsl:when test="starts-with($member-ref,'se.m')">
                    <xsl:value-of select="concat('http://www.riksdagen.se/webbnav/index.aspx?nid=1111&amp;iid=',substring-after($member-ref,'se.m.'))"/>
                </xsl:when>
                <xsl:when test="starts-with($member-ref,'no.m')">
                    <xsl:value-of select="concat('http://www.stortinget.no/nn/Representanter-og-komiteer/Representantene/Representantfordeling/Representant/?perid=',substring-after($member-ref,'no.m.'))"/>
                </xsl:when>
                <xsl:when test="starts-with($member-ref,'uk.m')">
                    <xsl:value-of select="concat('http://www.theyworkforyou.com/mp/?pid=',substring-after($member-ref,'uk.m.'))"/>
                </xsl:when>
                <xsl:when test="starts-with($member-ref,'nl.m')">
                    <xsl:value-of select="concat('http://resolver.politicalmashup.nl/',$member-ref,'?view=html')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$url"/>
    </xsl:function>
    <xsl:function name="pm:party-href-url">
        <xsl:param name="party-ref"/>
        <xsl:variable name="url">
            <xsl:choose>
                <xsl:when test="starts-with($party-ref,'nl.p')">
                    <xsl:value-of select="concat('http://resolver.politicalmashup.nl/',$party-ref,'?view=html')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$url"/>
    </xsl:function>
    <xsl:function name="pm:resolver-url">
        <xsl:param name="ref"/>
        <xsl:copy-of select="concat('http://resolver.politicalmashup.nl/',$ref,'?view=html')"/>
    </xsl:function>
    
    <!-- Given a global member id, return a link to their profile image.  -->
    <xsl:function name="pm:member-href-image">
        <xsl:param name="member-ref"/>
        <xsl:variable name="url">
            <xsl:choose>
                <xsl:when test="starts-with($member-ref,'se.m')">
                    <xsl:value-of select="concat('http://data.riksdagen.se/filarkiv/bilder/ledamot/',substring-after($member-ref,'se.m.'),'_192.jpg')"/>
                </xsl:when>
                <xsl:when test="starts-with($member-ref,'no.m')">
                    <!-- NOTE: this does not always work, id's starting with '_' or with names with non-ascii in it, may have a different image id. -->
                    <xsl:value-of select="concat('http://www.stortinget.no/Personimages/PersonImages_Large/',substring-after($member-ref,'no.m.'),'_stort.jpg')"/>
                </xsl:when>
                <xsl:when test="starts-with($member-ref,'uk.m')">
                    <xsl:value-of select="concat('http://www.theyworkforyou.com/images/mps/',substring-after($member-ref,'uk.m.'),'.jpg')"/>
                </xsl:when>
                <xsl:when test="starts-with($member-ref,'nl.m')">
                    <xsl:variable name="local-id" select="substring-after($member-ref,'nl.m.')"/>
                    <xsl:variable name="sub-folder" select="replace($member-ref,'nl.m.([0-9][0-9][0-9])[0-9][0-9]','$1')"/>
                    <xsl:value-of select="concat('http://www.parlement.com/9235000/p/',$sub-folder,'/',$local-id,'mr.jpg')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$url"/>
    </xsl:function>
    <xsl:template match="/">
        <html>
            <xsl:call-template name="head"/>
            <xsl:call-template name="body"/>
        </html>
    </xsl:template>
    <xsl:template name="head">
        <head>
            <title>
                <xsl:value-of select="//pm:paper/@pm:id"/>
            </title>
            <link rel="stylesheet" type="text/css" href="static/css/default.css"/>
            <script type="text/javascript" src="static/js/default.js"/>
        </head>
    </xsl:template>
    <xsl:template name="body">
        <body onload="highlight_hash();">
            <xsl:call-template name="menu"/>
            <xsl:call-template name="content"/>
        </body>
    </xsl:template>
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
            <img src="static/img/politicalmashup-small.png" alt="PoliticalMashup logo" class="logo"/>
        </div>
    </xsl:template>
    <xsl:template name="sources">
        <div id="sources">
            <div>source(s):
                <xsl:for-each select="//dc:source/pm:link[@pm:source ne '']">
                    <xsl:copy-of select="pm:external-a(@pm:source, string(@pm:linktype))"/>
                </xsl:for-each>
            </div>
            <xsl:for-each select="//dc:relation/pm:event">
                <div>
                    <a href="{concat('http://resolver.politicalmashup.nl/',@pm:doc-ref,'?view=html#',pm:vote/@pm:id)}" class="politicalmashup">vote source</a>
                </div>
            </xsl:for-each>
            <div>date: <xsl:value-of select="//dc:date"/>
            </div>
            <div class="last">
                <xsl:for-each select="//pm:house">
                    house: <xsl:value-of select="@pm:house"/>
                    <br/>[<xsl:value-of select="."/>]
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="summary"/>
    <xsl:template name="lucene-query"/>
    <!--<xsl:template name="index">
        <div id="lucene-query">
            <a class="source-link external">
                <xsl:attribute name="href" select="//dc:source/pm:link[@pm:linktype eq 'html']/@pm:source"/>
                Bron (kamerstuk)
            </a>
            <br/>
            <xsl:for-each select="//dc:relation/pm:event">
                <a href="{concat('http://resolver.politicalmashup.nl/',@pm:doc-ref,'?view=html#',pm:vote/@pm:id)}" class="politicalmashup">Bron (stemming)</a>
                <br/>
            </xsl:for-each>
        </div>
    </xsl:template>-->
    <xsl:template name="index"/>
    <xsl:template name="content">
        <div id="content">
            <xsl:apply-templates select="/" mode="content"/>
            <xsl:if test="//pm:event/pm:vote">
                <h3>Stemming</h3>
                <xsl:apply-templates select="//pm:event/pm:vote" mode="content"/>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="root" mode="content">
        <xsl:apply-templates select="//pm:parliamentary-document" mode="content"/>
    </xsl:template>
    <xsl:template match="pm:parliamentary-document" mode="content">
        <div class="topic" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <!--<h2>
                <xsl:value-of select="@pm:title"/>
            </h2>-->
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:block" mode="content">
        <div class="speech" id="{@pm:id}" style="padding-left:20px;">
            <a name="{@pm:id}"/>
            <h4>
                <xsl:value-of select="@pm:section-identifier"/>
            </h4>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:p" mode="content">
        <a name="{@pm:id}"/>
        <p id="{@pm:id}">
            <xsl:apply-templates select="./*|text()" mode="content"/>
        </p>
    </xsl:template>
    <xsl:template match="pm:note" mode="content">
        <xsl:text> </xsl:text>
        <span class="note">
            <xsl:for-each select="pm:p">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="*|text()" mode="content"/>
            </xsl:for-each>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="pm:heading[not(../@pm:type eq 'section')]" mode="content">
        <a name="{@pm:id}"/>
        <p id="{@pm:id}">
            <em>
                <xsl:apply-templates select="./*|text()" mode="content"/>
            </em>
        </p>
    </xsl:template>
    <xsl:template match="pm:heading[../@pm:type eq 'section']" mode="content"/>
    <xsl:template match="pm:tagged[@pm:type eq 'named-entity'][./pm:tagged-entity/@pm:sub-type eq 'member-ref']" mode="content">
        <em>
            <!-- Make <tagged> handling more general, this works only for member-refs. -->
            <xsl:choose>
                <xsl:when test="starts-with(./pm:tagged-entity/@pm:member-ref,'nl.m.')">
                    <a href="{concat('http://resolver.politicalmashup.nl/',./pm:tagged-entity/@pm:member-ref,'?view=html')}" class="politicalmashup">
                        <xsl:apply-templates select="./*|text()" mode="content"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="./*|text()" mode="content"/>
                </xsl:otherwise>
            </xsl:choose>
        </em>
    </xsl:template>
    <xsl:template match="pm:tagged[@pm:type eq 'reference'][./pm:tagged-entity/@pm:sub-type eq 'extref']" mode="content">
        <em>
            <a href="{concat('https://zoek.officielebekendmakingen.nl/',./pm:tagged-entity/@pm:reference,'.html')}" class="external">
                <xsl:apply-templates select="./*|text()" mode="content"/>
            </a>
        </em>
    </xsl:template>
    <xsl:template match="pm:tagged[@pm:type eq 'reference'][./pm:tagged-entity/@pm:sub-type eq 'doc-ref']" mode="content">
        <a href="{concat('http://resolver.politicalmashup.nl/',./pm:tagged-entity/@pm:reference,'?view=html')}" class="politicalmashup">
            <xsl:apply-templates select="./*|text()" mode="content"/>
        </a>
    </xsl:template>
    <xsl:template name="speech-header">
        <xsl:variable name="member-link" select="pm:member-href-url(@pm:member-ref)"/>
        <xsl:variable name="party-link" select="pm:party-href-url(@pm:party-ref)"/>
        <xsl:variable name="member-img" select="pm:member-href-image(@pm:member-ref)"/>
        <h4>
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
                <img alt="member profile picture" src="{$member-img}"/>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="pm:stage-direction" mode="content">
        <div class="stage-direction" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <xsl:apply-templates select="./pm:*" mode="content"/>
        </div>
    </xsl:template>
    <xsl:template match="exist:match" mode="content">
        <em class="query-match">
            <xsl:apply-templates select="./*|text()" mode="content"/>
        </em>
    </xsl:template>
    <xsl:template match="text()" mode="content">
        <xsl:value-of select="."/>
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
</xsl:stylesheet>