<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pmx="http://www.politicalmashup.nl/extra" xmlns:folia="http://ilk.uvt.nl/FoLiA" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd pm xsl dc xsi pmx folia">


    <!-- pm:select-cloud(document-node, pos-tag=('all,WW,N,ADJ'), method=('parsimonious'), w=(0.1))
        
        Select the relevant wordcloud from the document.
        Should return at most one cloud element.
    -->
    <xsl:function name="pm:include-summary-select-cloud" as="element(cloud)?">
        <xsl:param name="doc" as="document-node()"/>
        <xsl:param name="pos" as="xs:string"/>
        <xsl:param name="method" as="xs:string"/>
        <xsl:param name="w" as="xs:decimal"/>
        <xsl:sequence select="$doc//pmx:clouds/cloud[xs:decimal(@w) eq $w][@method eq $method][@pos eq $pos]"/>
    </xsl:function>


    <!-- include-summary-head-script-d3-cloud(relative-static-location=('.','..'), cloud=(pm:include-summary-select-cloud(...)))
        
        Output <script> code (place in <head>) that sets up the d3 wordcloud visualisation.
    -->
    <xsl:template name="include-summary-head-script-d3-cloud"> <!-- add? xmlns="http://www.w3.org/1999/xhtml" -->
        <xsl:param name="relative-static-location"/>
        <xsl:param name="cloud"/>
        
        <!-- Only output if there is a cloud present. -->
        <xsl:if test="$cloud">
            <script src="{$relative-static-location}static/js/d3-clouds/lib/d3/d3.js"/>
            <script src="{$relative-static-location}static/js/d3-clouds/d3.layout.cloud.js"/>
            <script>
                <xsl:variable name="wordcloudcontent">
                    <xsl:for-each select="$cloud/terms/term[position() le 10]">
                        <xsl:value-of select="concat('{text:&#34;',.,'&#34;, size:',@prob,'*800},')"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="concat('var wordcloudcontent = [',$wordcloudcontent,'];')"/>
                <!-- firsft attr: size of svg (bounding box); translate: set where the middle is....; cloud().size: cloud-generation-size. N.B. if word-size defined too large above, not all words will fit.. -->
                
                <![CDATA[
                    var fill = d3.scale.category20();
                    
                    function draw(words) {
                    d3.select("#folia-d3-cloud").append("svg")
                    .attr("width", 800)
                    .attr("height", 200)
                    .append("g")
                    .attr("transform", "translate(400,100)")
                    .selectAll("text")
                    .data(words)
                    .enter().append("text")
                    .style("font-size", function(d) { return d.size + "px"; })
                    .style("font-family", "Impact")
                    .style("fill", function(d, i) { return fill(i); })
                    .attr("text-anchor", "middle")
                    .attr("transform", function(d) {
                    return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
                    })
                    .text(function(d) { return d.text; });
                    };
                    
                    function makecloud() {
                    d3.layout.cloud().size([800, 200])
                    .words(wordcloudcontent)
                    .padding(5)
                    .rotate(function() { return ~~(Math.random() * 2) * 90; })
                    .font("Impact")
                    .fontSize(function(d) { return d.size; })
                    .on("end", draw)
                    .start();
                    }
                    ]]></script>
        </xsl:if>
    </xsl:template>


    <!-- include-summary-body-script-d3-cloud(cloud=(pm:include-summary-select-cloud(...)))
        
        Output <script> code (place *at the end* of <body>) that actually runs/loads the d3 wordcloud visualisation.
    -->
    <xsl:template name="include-summary-body-script-d3-cloud"> <!-- add? xmlns="http://www.w3.org/1999/xhtml" -->
        <xsl:param name="cloud"/>
        
        <!-- Only output if there is a cloud present. -->
        <xsl:if test="$cloud">
            <script>
                makecloud();
            </script>
        </xsl:if>
    </xsl:template>

<!--
/pmx:clouds/cloud[@pos eq 'all'][xs:decimal(@w) eq 0.05]//term[position() le $terms-limit]
-->

    <!-- include-summary-display-clouds(cloud=(pm:include-summary-select-cloud(...)))
        
        Output table with word cloud top terms and visualisation.
    -->
    <xsl:template name="include-summary-display-clouds">
        <xsl:param name="cloud" as="element(cloud)"/>
        <xsl:param name="max-display-terms" as="xs:integer"/>
        <xsl:param name="max-wordle-terms" as="xs:integer"/>
        
        <!-- Only output if there is a cloud present. -->
        <xsl:if test="$cloud">
            <h2>Summary</h2>
            
            <!-- Container. -->
            <div class="folia-meta">
                <div class="muni-cloud">
                    <xsl:value-of select="string-join($cloud//term[position() le $max-display-terms],' . ')"/>
                </div>
                <div id="folia-d3-cloud"/>
                <div>
                    <form action="http://www.wordle.net/advanced" method="POST" class="wordle-post">
                        <xsl:variable name="term-counts" as="xs:string*">
                            <xsl:for-each select="$cloud//term[position() le $max-wordle-terms]">
                                <xsl:value-of select="concat(.,':',@prob)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <textarea name="wordcounts">
                            <xsl:value-of select="string-join($term-counts,'&#xA;')"/>
                        </textarea>
                        <button type="submit">Bekijk gewogen woorden in http://wordle.net</button>
                    </form>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="include-summary-display-entity-links">
        <xsl:param name="dc-identifier" as="xs:string"/>
        <xsl:variable name="max-display-in-document-links" select="1" as="xs:integer"/>
        <xsl:variable name="min-entity-confidence" select="0.9" as="xs:decimal"/> <!-- Unused, as only 0.9 entities are present in the first place, but could be used on reference basis? -->
        <!--<xsl:if test="//dc:relation/pm:link[@pmx:linktype eq 'named-entity'][xs:decimal(@pmx:entity-confidence) ge $min-entity-confidence]">-->
        <xsl:if test="//dc:relation/pm:link[@pmx:linktype eq 'named-entity']">
            <h2>Entities</h2>
            <div class="folia-meta">
                <table>
                    <tr>
                        <th>Text</th>
                        <th>#</th>
                        <th>wiki link</th>
                        <th>first occ.</th>
                        <th>member</th>
                        <th>type</th>
                    </tr>
                    <!--<xsl:for-each select="//dc:relation/pm:link[@pmx:linktype eq 'named-entity'][xs:decimal(@pmx:entity-confidence) ge $min-entity-confidence]">-->
                    <xsl:for-each select="//dc:relation/pm:link[@pmx:linktype eq 'named-entity']">
                        <xsl:sort select="xs:integer(@pmx:entity-occurence)" order="descending"/>
                        <xsl:sort select="pmx:reference[1]/@pmx:entity-name"/>
                        <tr>
                            <td>
                                <xsl:value-of select="string-join(distinct-values(pmx:reference/@pmx:entity-name),', ')"/>
                            </td>
                            <td>
                                <xsl:value-of select="@pmx:entity-occurence"/>
                            </td>
                            <td>
                                <a href="{.}" class="external">
                                    <xsl:value-of select="substring-after(.,'wikipedia.org/wiki/')"/>
                                </a>
                            </td>
                            <td>
                                <xsl:for-each select="(pmx:reference/@pmx:entity-element)[position() le $max-display-in-document-links]">
                                    <a href="#{.}" class="internal">
                                        <xsl:value-of select="substring-after(.,$dc-identifier)"/>
                                    </a>
                                </xsl:for-each>
                            </td>
                            <td>
                                <xsl:if test="@pm:member-ref">
                                    <a href="{concat('http://resolver.politicalmashup.nl/',@pm:member-ref,'?view=html')}" class="politicalmashup">
                                        <xsl:value-of select="@pm:member-ref"/>
                                    </a>
                                </xsl:if>
                            </td>
                            <td>
                                <span class="folia-class-{@pmx:entity-types}">
                                    <xsl:value-of select="@pmx:entity-types"/>
                                </span>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </div>
        </xsl:if>
    </xsl:template>
    
    
    <!-- For a given element id, find if there are entities referring to that entity. If so, display them. -->
    <xsl:template name="include-summary-display-element-entities">
        <xsl:param name="element-id" as="xs:string"/>
        <xsl:variable name="references" select="//dc:relation/pm:link[@pmx:linktype eq 'named-entity']/pmx:reference[@pmx:entity-element eq $element-id]"/>
        <xsl:if test="$references">
            <span class="paragraph-entities">Entities:
                <xsl:for-each-group select="$references" group-by="@pmx:entity-name">
                    <xsl:text> </xsl:text>
                    <a href="{xs:string(current-group()[1]/..)}" class="external">
                        <xsl:value-of select="current-group()[1]/@pmx:entity-name"/>
                    </a>
                    <xsl:if test="count(current-group()) gt 1"> (<xsl:value-of select="count(current-group())"/>)</xsl:if>
                    <xsl:if test="position() ne last()">,</xsl:if>
                </xsl:for-each-group>
            </span>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>