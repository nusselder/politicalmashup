<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pm="http://www.politicalmashup.nl" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd pm xsl dc" version="2.0">
    <xsl:output indent="yes" encoding="UTF-8"/>
    
    <!-- Required parameters, that should be set in the importing stylesheet. -->
    <xsl:param name="identifier" as="xs:string"/>
    
    
    <!-- Functions that generate resolver links. -->
    <xsl:function name="pm:resolver-href-xml" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <!--<xsl:value-of select="concat($id,'?view=xml')"/>-->
        <xsl:value-of select="$id"/>
    </xsl:function>
    <xsl:function name="pm:resolver-href-rdf" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:value-of select="concat($id,'?view=rdf')"/>
    </xsl:function>
    <xsl:function name="pm:resolver-href-html" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:value-of select="concat($id,'?view=html')"/>
    </xsl:function>
    <xsl:function name="pm:resolver-href-html-context" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:value-of select="concat($identifier,'?view=html#',$id)"/>
    </xsl:function>
    <xsl:function name="pm:a" as="element()">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="target" as="xs:string"/>
        <a href="{$href}" class="{$target}">
            <xsl:copy-of select="$content"/>
        </a>
    </xsl:function>
    <xsl:function name="pm:resolver-a" as="element()">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:a($href, $content, 'politicalmashup')"/>
    </xsl:function>
    <xsl:function name="pm:internal-a" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:a(concat('#',$id), $content, 'internal')"/>
    </xsl:function>
    <xsl:function name="pm:external-a" as="element()">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:a($href, $content, 'external')"/>
    </xsl:function>
    
    
    <!-- Three types of links: internal, external, politicalmashup. -->
    <xsl:function name="pm:resolver-a-xml" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:resolver-a(pm:resolver-href-xml($id), $content)"/>
    </xsl:function>
    <xsl:function name="pm:resolver-a-html" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:resolver-a(pm:resolver-href-html($id), $content)"/>
    </xsl:function>
    <xsl:function name="pm:resolver-a-html-context" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:resolver-a(pm:resolver-href-html-context($id), $content)"/>
    </xsl:function>
    <xsl:function name="pm:resolver-a-rdf" as="element()">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:copy-of select="pm:resolver-a(pm:resolver-href-rdf($id), $content)"/>
    </xsl:function>
    

    <!--
        Removed from within span:
        <xsl:copy-of select="pm:resolver-a-html(@pm:id,'H')"/>
    -->
    <!--<xsl:template name="context-links">
        <span class="reference-links">
            <xsl:copy-of select="pm:resolver-a-xml(@pm:id,'X')"/>
            <!-\-<xsl:copy-of select="pm:resolver-a-html(@pm:id,'H')"/>-\->
            <xsl:copy-of select="pm:resolver-a-html-context(@pm:id,'C')"/>
            <xsl:copy-of select="pm:resolver-a-rdf(@pm:id,'R')"/>
        </span>
    </xsl:template>-->
    <!-- Changed template to call creation-template with default types.
         Override "context-links" template in calling template to set other links.
    -->
    <xsl:template name="context-links">
        <xsl:call-template name="create-context-links">
            <!-- Default Xml, Context (html), Rdf. Also possible Html (of only this element). -->
            <xsl:with-param name="link-types" select="('X','C','R')"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="create-context-links">
        <xsl:param name="link-types" as="xs:string*"/>
        <xsl:variable name="context" select="."/>
        <span class="reference-links">
            <xsl:for-each select="$link-types">
                <xsl:choose>
                    <xsl:when test=". = ('x','X')">
                        <xsl:copy-of select="pm:resolver-a-xml($context/@pm:id,'X')"/>
                    </xsl:when>
                    <xsl:when test=". = ('h','H')">
                        <xsl:copy-of select="pm:resolver-a-html($context/@pm:id,'H')"/>
                    </xsl:when>
                    <xsl:when test=". = ('c','C')">
                        <xsl:copy-of select="pm:resolver-a-html-context($context/@pm:id,'C')"/>
                    </xsl:when>
                    <xsl:when test=". = ('r','R')">
                        <xsl:copy-of select="pm:resolver-a-rdf($context/@pm:id,'R')"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </span>
    </xsl:template>
    
    
    
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
                    <!--
                        New members often only have large images.
                        The actual image can for instance be found by loading some xml: http://www.theyworkforyou.com/gadget/dat.php?pid=[1234567]
                        But the theyworkforyou people might not quite like that. Also, you could request an api key.
                    -->
                    <!--<xsl:value-of select="concat('http://www.theyworkforyou.com/images/mpsL/',substring-after($member-ref,'uk.m.'),'.jpeg')"/>-->
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
</xsl:stylesheet>