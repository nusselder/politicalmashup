<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pmx="http://www.politicalmashup.nl/extra" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" exclude-result-prefixes="xs" version="2.0">
    <xsl:import href="default-include.xsl"/>
    <!-- N.B. There apparently is some strange bug in saxon, that xpath version are not properly set. Using an import statement fixes this **THIS IS A HACK UGLY FIX** -->
    <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
    <xsl:template match="/">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="pm:member">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <!-- Add latest party-affilitation, because general party information is removed from view. -->
            <xsl:variable name="latest-party" as="node()*">
                <xsl:for-each select="//pm:membership[@pm:body = ('commons','senate')]">
                    <xsl:sort select="pm:period/@pm:from" order="ascending"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <pmx:party-affiliation pm:party-ref="{string($latest-party[last()]/@pm:party-ref)}">
                <xsl:value-of select="string($latest-party[last()]/@pm:party-name)"/>
            </pmx:party-affiliation>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="pm:curriculum | pm:memberships"/>
</xsl:stylesheet>