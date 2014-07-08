<?xml version="1.0" encoding="UTF-8"?>
<!--<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:imdi="http://www.mpi.nl/IMDI/Schema/IMDI" xmlns:folia="http://ilk.uvt.nl/folia">-->
<xsl:stylesheet xmlns:imdi="http://www.mpi.nl/IMDI/Schema/IMDI" xmlns="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pmx="http://www.politicalmashup.nl/extra" xmlns:folia="http://ilk.uvt.nl/FoLiA" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:pm="http://www.politicalmashup.nl" version="1.0">


<!-- FoLiA v0.10 -->
    <xsl:template match="folia:meta">
    <!-- ignore -->
    </xsl:template>
    <xsl:template match="folia:text">
        <div class="text">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="folia:div">
        <div class="div">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="folia:p">
        <p id="{@xml:id}">
            <xsl:choose>
                <xsl:when test=".//folia:s or .//folia:w">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test=".//folia:t[not(@class) and not(ancestor::folia:original) and not(ancestor::folia:suggestion) and not(ancestor::folia:alternative) and not(ancestor-or-self::*/auth)]">
                    <xsl:call-template name="textcontent"/>
                </xsl:when>
            </xsl:choose>
        </p>
    </xsl:template>
    <xsl:template match="folia:gap">
        <pre class="gap">
            <xsl:value-of select="folia:content"/>
        </pre>
    </xsl:template>
    <xsl:template match="folia:head">
        <xsl:choose>
            <xsl:when test="count(ancestor::folia:div) = 1">
                <h1>
                    <xsl:call-template name="headinternal"/>
                </h1>
            </xsl:when>
            <xsl:when test="count(ancestor::folia:div) = 2">
                <h2>
                    <xsl:call-template name="headinternal"/>
                </h2>
            </xsl:when>
            <xsl:when test="count(ancestor::folia:div) = 3">
                <h3>
                    <xsl:call-template name="headinternal"/>
                </h3>
            </xsl:when>
            <xsl:when test="count(ancestor::folia:div) = 4">
                <h4>
                    <xsl:call-template name="headinternal"/>
                </h4>
            </xsl:when>
            <xsl:when test="count(ancestor::folia:div) = 5">
                <h5>
                    <xsl:call-template name="headinternal"/>
                </h5>
            </xsl:when>
            <xsl:otherwise>
                <h6>
                    <xsl:call-template name="headinternal"/>
                </h6>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="headinternal">
        <span id="{@xml:id}" class="head">
            <xsl:choose>
                <xsl:when test=".//folia:s">
                    <xsl:apply-templates select=".//folia:s|folia:whitespace|folia:br"/>
                </xsl:when>
                <xsl:when test=".//folia:w">
                    <xsl:apply-templates select=".//folia:w|folia:whitespace|folia:br"/>
                </xsl:when>
                <xsl:when test=".//folia:t[not(@class) and not(ancestor::folia:original) and not(ancestor::folia:suggestion) and not(ancestor::folia:alternative) and not(ancestor-or-self::*/auth) and not(ancestor::folia:str)]">
                    <xsl:call-template name="textcontent"/>
                </xsl:when>
            </xsl:choose>
        </span>
    </xsl:template>
    <xsl:template match="folia:list">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="folia:listitem">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="folia:s">
    <!--<span id="{@xml:id}" class="s">-->
        <p id="{@xml:id}" class="s folia-s">
            <xsl:choose>
                <xsl:when test=".//folia:w">
                    <xsl:apply-templates select=".//folia:w|folia:whitespace|folia:br"/>
                </xsl:when>
                <xsl:when test=".//folia:t[not(@class) and not(ancestor::folia:original) and not(ancestor::folia:suggestion) and not(ancestor::folia:alternative) and not(ancestor-or-self::*/auth)]">
                    <xsl:call-template name="textcontent"/>
                </xsl:when>
            </xsl:choose>
        </p>
    </xsl:template>
    <xsl:template match="folia:w">
        <xsl:variable name="wid" select="@xml:id"/>
        <xsl:if test="not(ancestor::folia:original) and not(ancestor::folia:suggestion) and not(ancestor::folia:alternative) and not(ancestor-or-self::*/auth)">
            <span id="{@xml:id}">
                <xsl:attribute name="class">word<xsl:if test="//folia:wref[@id=$wid and not(ancestor::folia:altlayers)]"> sh</xsl:if>
                    <xsl:if test=".//folia:correction or .//folia:errordetection"> cor</xsl:if>
                    <xsl:if test="//folia:wref[@id=$wid]"> folia-class-<xsl:value-of select="//folia:wref[@id=$wid]/parent::folia:entity/@class"/>
                    </xsl:if>
                    <xsl:if test="//folia:wref[@id=$wid]/parent::folia:entity/folia:sense"> folia-has-wiki</xsl:if>
                </xsl:attribute>
                <xsl:call-template name="textcontent"/>
                <xsl:call-template name="tokenannotations"/>
            </span>
            <xsl:choose>
                <xsl:when test="@space = 'no'"/>
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template name="textcontent">
        <span class="t">
            <xsl:value-of select="string(.//folia:t[not(ancestor-or-self::*/@auth)         and not(ancestor::folia:morpheme) and not(ancestor::folia:str) and not(@class)])"/>
        </span>
    </xsl:template>
    <xsl:template name="tokenannotation_text">
        <xsl:if test="folia:t">
            <xsl:for-each select="folia:t">
                <span class="attrlabel">Text
                <xsl:if test="count(../folia:t) &gt; 1">
                    (<xsl:value-of select="@class"/>)
                  </xsl:if>
                </span>
                <span class="attrvalue">
                    <xsl:value-of select=".//text()"/>
                </span>
                <br/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="tokenannotations">
        <span class="attributes">
     <!--<span class="attrlabel">ID</span><span class="attrvalue"><xsl:value-of select="@xml:id" /></span><br />-->
            <xsl:call-template name="tokenannotation_text"/>
            <xsl:if test=".//folia:phon">
                <xsl:for-each select=".//folia:phon[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                    <span class="attrlabel">Phonetics</span>
                    <span class="attrvalue">
                        <xsl:value-of select="@class"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//folia:pos">
                <xsl:for-each select=".//folia:pos[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                    <span class="attrlabel">PoS</span>
                    <span class="attrvalue">
                        <xsl:value-of select="@class"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//folia:lemma">
                <xsl:for-each select=".//folia:lemma[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                    <span class="attrlabel">Lemma</span>
                    <span class="attrvalue">
                        <xsl:value-of select="@class"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//folia:sense">
                <xsl:for-each select=".//folia:sense[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                    <span class="attrlabel">Sense</span>
                    <span class="attrvalue">
                        <xsl:value-of select="@class"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//folia:subjectivity[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                <xsl:for-each select=".//folia:subjectivity">
                    <span class="attrlabel">Subjectivity</span>
                    <span class="attrvalue">
                        <xsl:value-of select="@class"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//folia:metric">
                <xsl:for-each select=".//folia:metric[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                    <span class="attrlabel">Metric <xsl:value-of select="@class"/>
                    </span>
                    <span class="attrvalue">
                        <xsl:value-of select="@value"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test=".//folia:errordetection">
                <xsl:for-each select=".//folia:errordetection[not(ancestor-or-self::*/@auth) and not(ancestor-or-self::*/morpheme)]">
                    <span class="attrlabel">Error detected</span>
                    <span class="attrvalue">
                        <xsl:value-of select="@class"/>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="folia:correction">
            <!-- TODO: Expand to support all token annotations -->
                <xsl:if test="folia:correction/folia:suggestion/folia:t">
                    <span class="attrlabel">Suggestion(s) for text correction</span>
                    <span class="attrvalue">
                        <xsl:for-each select="folia:correction/folia:suggestion/folia:t">
                            <em>
                                <xsl:value-of select="."/>
                            </em>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </span>
                    <br/>
                </xsl:if>
                <xsl:if test="folia:correction/folia:original/folia:t">
                    <span class="attrlabel">Original pre-corrected text</span>
                    <span class="attrvalue">
                        <xsl:for-each select="folia:correction/folia:original/folia:t">
                            <em>
                                <xsl:value-of select="."/>
                            </em>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </span>
                    <br/>
                </xsl:if>
            </xsl:if>
            <xsl:if test=".//folia:morphology">
                <xsl:for-each select=".//folia:morphology[not(ancestor-or-self::*/@auth)]">
                    <span class="attrlabel">Morphology</span>
                    <span class="attrvalue">
                        <xsl:for-each select="folia:morpheme">
                            <span class="morpheme">
                                <xsl:value-of select="./folia:t[not(@class) or @class='current']"/>
                                <xsl:if test="@class">
                                    <span class="details">(<xsl:value-of select="@class"/>)</span>
                                </xsl:if>
                                <xsl:if test="@function">
                                    <span class="details">[<xsl:value-of select="@function"/>]</span>
                                </xsl:if>
                                <xsl:text> </xsl:text>
                            </span>
                        </xsl:for-each>
                    </span>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <span class="spanannotations">
                <xsl:call-template name="spanannotations">
                    <xsl:with-param name="id" select="@xml:id"/>
                </xsl:call-template>
            </span>
        </span>
    </xsl:template>
    <xsl:template name="span">
        <xsl:param name="id"/>
        <xsl:text> </xsl:text>
        <span class="span">
            <xsl:for-each select=".//folia:wref">
                <xsl:variable name="wrefid" select="@id"/>
                <xsl:choose>
                    <xsl:when test="@t">
                        <xsl:value-of select="@t"/>
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="//folia:w[@xml:id=$wrefid]">
                            <xsl:value-of select="//folia:w[@xml:id=$wrefid]/folia:t[not(ancestor::folia:original) and not(ancestor::folia:suggestion) and not(ancestor::folia:alternative) and not(ancestor-or-self::*/auth)]"/>
                        </xsl:if>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </span>
    </xsl:template>
    <xsl:template name="spanannotations">
        <xsl:param name="id"/>
        <xsl:variable name="entities" select="ancestor::*"/>
        <xsl:for-each select="$entities">
            <xsl:for-each select="folia:entities">
                <xsl:for-each select="folia:entity">
                    <xsl:if test=".//folia:wref[@id=$id]">
                        <span class="attrlabel">Entity</span>
                        <span class="attrvalue">
                            <span class="spanclass">
                                <xsl:value-of select="@class"/>
                            </span>
                            <xsl:call-template name="span">
                                <xsl:with-param name="id" select="$id"/>
                            </xsl:call-template>
                        </span>
                        <br/>
                        <xsl:if test=".//folia:sense">
                            <xsl:variable name="first-wiki-link" select="(.//folia:sense)[1]"/>
                            <span class="attrlabel">Wikilink</span>
                            <span class="attrvalue">
                                <a href="{$first-wiki-link/text()}">
                                    <xsl:value-of select="$first-wiki-link/text()"/>
                                </a> (conf. <xsl:value-of select="$first-wiki-link/@confidence"/>)</span>
                            <br/>
                        </xsl:if>
                        <xsl:if test="@class='loc' or @class='org'">
                            <xsl:variable name="span-tmp">
                                <xsl:call-template name="span">
                                    <xsl:with-param name="id" select="$id"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <span class="attrlabel">Map Search</span>
                            <span class="attrvalue">
                                <a href="https://maps.google.nl/?q={normalize-space($span-tmp)},%20Amsterdam">
                                    <xsl:value-of select="normalize-space($span-tmp)"/>
                                </a>
                            </span>
                            <br/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:variable name="ancestors" select="ancestor::*"/>
        <xsl:for-each select="$ancestors">
            <xsl:for-each select="folia:chunking">
                <xsl:for-each select="folia:chunk">
                    <xsl:if test=".//folia:wref[@id=$id]">
                        <span class="attrlabel">Chunk</span>
                        <span class="attrvalue">
                            <span class="spanclass">
                                <xsl:value-of select="@class"/>
                            </span>
                            <xsl:call-template name="span">
                                <xsl:with-param name="id" select="$id"/>
                            </xsl:call-template>
                        </span>
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="$ancestors">
            <xsl:for-each select="folia:syntax">
                <xsl:for-each select="//folia:su">
                    <xsl:if test=".//folia:wref[@id=$id]">
                        <span class="attrlabel">Syntactic Unit</span>
                        <span class="attrvalue">
                            <span class="spanclass">
                                <xsl:value-of select="@class"/>
                            </span>
                            <xsl:call-template name="span">
                                <xsl:with-param name="id" select="$id"/>
                            </xsl:call-template>
                        </span>
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="$ancestors">
            <xsl:for-each select="folia:semroles">
                <xsl:for-each select="folia:semrole">
                    <xsl:if test=".//folia:wref[@id=$id]">
                        <span class="attrlabel">Semantic Role</span>
                        <span class="attrvalue">
                            <span class="spanclass">
                                <xsl:value-of select="@class"/>
                            </span>
                            <xsl:call-template name="span">
                                <xsl:with-param name="id" select="$id"/>
                            </xsl:call-template>
                        </span>
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="$ancestors">
            <xsl:for-each select="folia:coreferences">
                <xsl:for-each select="folia:coreferencechain">
                    <xsl:if test=".//folia:wref[@id=$id]">
                        <span class="attrlabel">Coreference Chain</span>
                        <span class="attrvalue">
                            <span class="spanclass">
                                <xsl:value-of select="@class"/>
                            </span>
                            <xsl:for-each select="folia:coreferencelink">
                                <xsl:call-template name="span">
                                    <xsl:with-param name="id" select="$id"/>
                                </xsl:call-template>
                                <xsl:text> - </xsl:text>
                            </xsl:for-each>
                            <br/>
                        </span>
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="$ancestors">
            <xsl:for-each select="folia:dependencies">
                <xsl:for-each select="folia:dependency">
                    <xsl:if test=".//folia:wref[@id=$id]">
                        <span class="attrlabel">Dependency</span>
                        <span class="attrvalue">
                            <span class="spanclass">
                                <xsl:value-of select="@class"/>
                            </span>
                            <xsl:text> </xsl:text>
                            <xsl:for-each select="folia:hd">
                                <strong>Head:</strong>
                                <xsl:call-template name="span">
                                    <xsl:with-param name="id" select="$id"/>
                                </xsl:call-template>
                            </xsl:for-each>
                            <xsl:for-each select="folia:dep">
                                <strong>Dep:</strong>
                                <xsl:call-template name="span">
                                    <xsl:with-param name="id" select="$id"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </span>
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="folia:whitespace">
        <br/>
        <br/>
    </xsl:template>
    <xsl:template match="folia:br">
        <br/>
    </xsl:template>
    <xsl:template match="folia:figure">
        <div class="figure">
            <img>
                <xsl:attribute name="src">
                    <xsl:value-of select="@src"/>
                </xsl:attribute>
                <xsl:attribute name="alt">
                    <xsl:value-of select="folia:desc"/>
                </xsl:attribute>
            </img>
            <xsl:if test="folia:caption">
                <div class="caption">
                    <xsl:apply-templates select="folia:caption/*"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="folia:table">
        <table>
            <xsl:apply-templates select="folia:tablehead"/>
            <tbody>
                <xsl:apply-templates select="folia:row"/>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="folia:tablehead">
        <thead>
            <xsl:apply-templates select="folia:row"/>
        </thead>
    </xsl:template>
    <xsl:template match="folia:row">
        <tr>
            <xsl:apply-templates select="folia:cell"/>
        </tr>
    </xsl:template>
    <xsl:template match="folia:cell">
        <td>
            <xsl:apply-templates select="folia:p|folia:s|folia:w"/>
        </td>
    </xsl:template>
</xsl:stylesheet>