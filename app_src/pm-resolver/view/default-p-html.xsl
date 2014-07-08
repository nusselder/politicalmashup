<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:pm="http://www.politicalmashup.nl" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd pm xsl dc" version="2.0">
    <xsl:import href="default-include.xsl"/>
    <!-- N.B. There apparently is some strange bug in saxon, that xpath version are not properly set. Using an import statement fixes this **THIS IS A HACK UGLY FIX** -->
    <xsl:output method="xhtml" media-type="text/html" indent="yes" omit-xml-declaration="yes"/>
    <xsl:template match="pm:party">
        <div class="party">
            <h1>Partij:</h1>
            <xsl:copy-of select="pm:field('ID',@pm:id)"/>
            <xsl:apply-templates select="pm:name"/>
            <xsl:apply-templates select="pm:alternative-names"/>
            <xsl:apply-templates select="dc:relation"/>
            <xsl:apply-templates select="pm:history"/>
            <xsl:apply-templates select="pm:links"/>
            <xsl:apply-templates select="pm:seats"/>
        </div>
    </xsl:template>
    <xsl:template match="pm:name">
        <xsl:copy-of select="pm:field('Naam',.)"/>
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
    <xsl:template match="pm:history">
        <h2>Geschiedenis</h2>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="pm:formation">
        <xsl:copy-of select="pm:field('Formatie',@pm:date)"/>
    </xsl:template>
    <xsl:template match="pm:abolition">
        <xsl:copy-of select="pm:field('Opgeheven',@pm:date)"/>
    </xsl:template>
    <xsl:template match="pm:ancestors">
        <h3>Voortgekomen uit:</h3>
        <xsl:apply-templates select="pm:party-ref"/>
    </xsl:template>
    <xsl:template match="pm:descendants">
        <h3>Opgegaan in:</h3>
        <xsl:apply-templates select="pm:party-ref"/>
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
    <xsl:template match="pm:seats">
        <h2>Zittingen</h2>
        <xsl:apply-templates select="pm:session"/>
    </xsl:template>
    <xsl:template match="pm:session">
        <h3>Sessie</h3>
        <xsl:copy-of select="pm:field('kamer',@pm:house)"/>
        <xsl:copy-of select="pm:field('zetels',@pm:seats)"/>
        <xsl:copy-of select="pm:field('periode',concat(pm:period/@pm:from,' / ',pm:period/@pm:till))"/>
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
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of select="//pm:party/@pm:id"/>
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
                    <xsl:apply-templates select="//pm:party"/>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>