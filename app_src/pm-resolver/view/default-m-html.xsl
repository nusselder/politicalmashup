<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:pm="http://www.politicalmashup.nl" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd pm xsl dc" version="2.0">
    <xsl:import href="default-include.xsl"/>
    <!-- N.B. There apparently is some strange bug in saxon, that xpath version are not properly set. Using an import statement fixes this **THIS IS A HACK UGLY FIX** -->
    <xsl:output method="xhtml" media-type="text/html" indent="yes" omit-xml-declaration="yes"/>
    <xsl:template match="pm:member">
        <div class="member">
            <h1>Persoon:</h1>
            <img src="{pm:member-href-image(@pm:id)}"/>
            <xsl:copy-of select="pm:field('ID',@pm:id)"/>
            <xsl:apply-templates select="pm:name"/>
            <!--<xsl:apply-templates select="pm:alternative-names"/>-->
            <xsl:apply-templates select="pm:personal"/>
            <xsl:apply-templates select="pm:links"/>
            <xsl:apply-templates select="pm:biographies"/>
            <xsl:apply-templates select="pm:memberships"/>
            <xsl:apply-templates select="pm:curriculum"/>
            <xsl:variable name="latest-party" as="node()*">
                <xsl:for-each select="//pm:membership[@pm:body = ('commons','senate')]">
                    <xsl:sort select="pm:period/@pm:from" order="ascending"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <h3>Laatst actieve partij</h3>
            <xsl:copy-of select="pm:field-link('Partij',$latest-party[last()]/@pm:party-name,concat('http://resolver.politicalmashup.nl/',$latest-party[last()]/@pm:party-ref,'?view=html'))"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:name">
        <xsl:copy-of select="pm:field('Naam',./pm:full)"/>
    </xsl:template>
    <xsl:template match="pm:alternative-names">
        <div clss="alternative-names">
            <h2>Alternatieve namen</h2>
            <xsl:apply-templates select="pm:name"/>
        </div>
    </xsl:template>
    <xsl:template match="dc:relation[owl:sameAs]">
        <h2>Relatie: zelfde als</h2>
        <xsl:apply-templates select="owl:sameAs"/>
    </xsl:template>
    <xsl:template match="owl:sameAs">
        <xsl:copy-of select="pm:field-link('Partij',@rdf:resource,concat('http://resolver.politicalmashup.nl/',@rdf:resource,'?view=html'))"/>
    </xsl:template>
    <xsl:template match="pm:party-ref">
        <xsl:copy-of select="pm:field-link('Partij',@pm:party-ref,concat('http://resolver.politicalmashup.nl/',@pm:party-ref,'?view=html'))"/>
    </xsl:template>
    <xsl:template match="pm:links">
        <h2>Links</h2>
        <xsl:apply-templates select="pm:link"/>
    </xsl:template>
    <xsl:template match="pm:link">
        <xsl:copy-of select="pm:field-link(@pm:description,.,.)"/>
    </xsl:template>
    <xsl:template match="pm:personal">
        <h2>Persoonlijk</h2>
        <xsl:apply-templates select="pm:gender"/>
    </xsl:template>
    <xsl:template match="pm:gender">
        <xsl:copy-of select="pm:field('geslacht',.)"/>
    </xsl:template>
    <xsl:template match="pm:session">
        <h3>Sessie</h3>
        <xsl:copy-of select="pm:field('kamer',@pm:house)"/>
        <xsl:copy-of select="pm:field('zetels',@pm:seats)"/>
        <xsl:copy-of select="pm:field('periode',concat(pm:period/@pm:from,' / ',pm:period/@pm:till))"/>
    </xsl:template>
    <xsl:template match="pm:biographies">
        <h3>Biografie</h3>
        <xsl:apply-templates select="pm:biography"/>
    </xsl:template>
    <xsl:template match="pm:biography">
        <xsl:copy-of select="pm:field('biografie',.)"/>
    </xsl:template>
    <!-- TODO: should the memberships and curriculum really be empty? -->
    <!--<xsl:template match="pm:curriculum">
        <h2>Curriculum</h2>
        <xsl:apply-templates select="pm:function"/>
    </xsl:template>-->
    <xsl:template match="pm:curriculum"/>
    <xsl:template match="pm:function">
        <xsl:copy-of select="pm:field('functie',./pm:name)"/>
    </xsl:template>
    <!--<xsl:template match="pm:memberships">
        <h2>Zittingen</h2>
        <xsl:apply-templates select="pm:membership"/>
        </xsl:template>-->
    <xsl:template match="pm:memberships"/>
    <xsl:template match="pm:membership">
        <h3>Zitting</h3>
        <xsl:copy-of select="pm:field('In', if (@pm:body eq 'commons') then                                               'Tweede Kamer'                                             else if (@pm:body eq 'senate') then                                               'Eerste Kamer'                                             else if (@pm:body eq 'government') then                                               concat('Kabinet', ' (', string(pm:name), ')')                                             else                                               @pm:body)"/>
        <xsl:copy-of select="pm:field('Van', pm:period/@pm:from)"/>
        <xsl:copy-of select="pm:field('Tot', pm:period/@pm:till)"/>
        <xsl:copy-of select="pm:field('Bron', @pm:source)"/>
    </xsl:template>
    <xsl:function name="pm:field">
        <xsl:param name="field"/>
        <xsl:param name="value"/>
        <div class="field-container">
            <span class="field">
                <xsl:value-of select="concat($field,': ')"/>
            </span>
            <span class="value">
                <xsl:value-of select="$value"/>
            </span>
        </div>
    </xsl:function>
    <xsl:function name="pm:field-link">
        <xsl:param name="field"/>
        <xsl:param name="value"/>
        <xsl:param name="url"/>
        <div class="field-container">
            <span class="field">
                <xsl:value-of select="concat($field,': ')"/>
            </span>
            <span class="value">
                <a href="{$url}">
                    <xsl:value-of select="$value"/>
                </a>
            </span>
        </div>
    </xsl:function>
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
            <head>
                <title>
                    <xsl:value-of select="//pm:full"/> - PoliticalMashup
                </title>
                <style>
                    div.field-container {padding: 5px 14px;font: 12px verdana;}
                    span.field {border-bottom: 1px solid #eee;}
                    span.value {border-bottom: 1px solid #aaa;}
                    h1 {font: 20px verdana;border-bottom: 1px solid #ddd;padding: 2px;}
                    h2 {font: 18px verdana;border-bottom: 1px solid #ddd;padding: 6px;}
                    h3 {font: 14px verdana;border-bottom: 1px solid #ddd;padding: 5px 14px;}
                    div.content {margin:20px 50px;}
                </style>
            </head>
            <body>
                <div class="content">
                    <xsl:apply-templates select="//pm:member"/>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>