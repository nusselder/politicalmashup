<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd pm xsl dc" version="2.0">
    <xsl:function name="pm:link-if-available">
        <xsl:param name="text"/>
        <xsl:param name="ref"/>
        <xsl:choose>
            <xsl:when test="$ref and $ref ne ''">
                <a href="{pm:resolver-url($ref)}" class="politicalmashup">
                    <xsl:value-of select="$text"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <em>
                    <xsl:value-of select="$text"/>
                </em>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template match="pm:vote" mode="content">
        <div class="vote" id="{@pm:id}">
            <a name="{@pm:id}"/>
            <div class="vote-attributes">
                <h5>Uitslag: <span class="outcome-{@pm:outcome}">
                        <xsl:value-of select="@pm:outcome"/>
                    </span>
                </h5>
            </div>
            <div class="vote-attributes">
                Soort stemming: <xsl:value-of select="@pm:vote-type"/>
            </div>
            <div class="vote-about">
                Document type: <xsl:value-of select="pm:about/@pm:voted-on"/>
            </div>
            <div class="vote-about">
                Onderwerp: <xsl:value-of select="pm:about/@pm:title"/>
            </div>
            <xsl:variable name="links" as="node()*">
                <xsl:if test="pm:about/@pm:doc-ref">
                    <a href="{concat('http://resolver.politicalmashup.nl/',pm:about/@pm:doc-ref,'?view=html-paper')}" class="politicalmashup">
                        <xsl:value-of select="string-join((./pm:about/pm:information/pm:dossiernummer, ./pm:about/pm:information/pm:ondernummer),'-')"/>
                    </a>
                </xsl:if>
                <!--<a href="{concat('http://resolver.politicalmashup.nl/nl.paper.amend.d.kst-',./pm:about/@pm:ref,'?view=html-paper')}" class="internal">intern</a>
                <a href="{concat('https://zoek.officielebekendmakingen.nl/kst-',./pm:about/@pm:ref,'.html')}" class="external">extern</a>-->
            </xsl:variable>
            <div class="vote-dossier">
                <!-- TODO: add a reference to our internal format whilst transforming.. -->
                Kamerstuk: <xsl:value-of select="string-join((./pm:about/pm:information/pm:dossiernummer, ./pm:about/pm:information/pm:ondernummer, ./pm:about/pm:information/pm:part),' ')"/>
                <xsl:if test="$links">
                    (links: <xsl:copy-of select="$links"/>)    
                </xsl:if>
            </div>
            <div class="vote-submit">
                Indieners:
                <xsl:for-each select="./pm:about/pm:information/pm:submitted-by/pm:actor/pm:person">
                    <xsl:copy-of select="pm:link-if-available(@pm:speaker, @pm:member-ref)"/>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </div>
            <div class="vote-division">
                <xsl:variable name="voted-aye" as="node()*">
                    <xsl:for-each select="pm:division/pm:actor[@pm:vote eq 'aye']/pm:organization">
                        <xsl:copy-of select="pm:link-if-available(@pm:name, @pm:ref)"/>
                        <xsl:if test="../@pm:mentioned eq 'true'">
                            <span class="vote-meta">(expliciet genoemd)</span>
                        </xsl:if>
                        <xsl:if test="../@pm:mentioned eq 'false'">
                            <span class="vote-meta">(impliciet gevonden)</span>
                        </xsl:if>
                        <br/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="voted-no" as="node()*">
                    <xsl:for-each select="pm:division/pm:actor[@pm:vote eq 'no']/pm:organization">
                        <xsl:copy-of select="pm:link-if-available(@pm:name, @pm:ref)"/>
                        <xsl:if test="../@pm:mentioned eq 'true'">
                            <span class="vote-meta">(expliciet genoemd)</span>
                        </xsl:if>
                        <xsl:if test="../@pm:mentioned eq 'false'">
                            <span class="vote-meta">(impliciet gevonden)</span>
                        </xsl:if>
                        <br/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="voted-else" as="node()*">
                    <xsl:for-each select="pm:division/pm:actor[@pm:vote ne 'aye' and @pm:vote ne 'no']/pm:organization">
                        <xsl:copy-of select="pm:link-if-available(@pm:name, @pm:ref)"/>
                        <xsl:if test="../@pm:mentioned eq 'true'">
                            <span class="vote-meta">(expliciet genoemd)</span>
                        </xsl:if>
                        <xsl:if test="../@pm:mentioned eq 'false'">
                            <span class="vote-meta">(impliciet gevonden)</span>
                        </xsl:if>
                        <br/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="not(empty($voted-aye))">
                    <h5>Stemmen voor:</h5>
                    <xsl:copy-of select="$voted-aye"/>
                </xsl:if>
                <xsl:if test="not(empty($voted-no))">
                    <h5>Stemmen tegen:</h5>
                    <xsl:copy-of select="$voted-no"/>
                </xsl:if>
                <xsl:if test="not(empty($voted-else))">
                    <h5>Stemmen onbekend:</h5>
                    <xsl:copy-of select="$voted-else"/>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>