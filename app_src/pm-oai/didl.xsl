<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pmd="http://www.politicalmashup.nl/docinfo" xmlns:pm="http://www.politicalmashup.nl" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/root">
        <xsl:variable name="id" select="string(meta/dc:identifier)"/>
        <didl:DIDL xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dip="urn:mpeg:mpeg21:2002:01-DIP-NS" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dii="urn:mpeg:mpeg21:2002:01-DII-NS" xmlns:didl="urn:mpeg:mpeg21:2002:02-DIDL-NS" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dcterms="http://purl.org/dc/terms/" xsi:schemaLocation="urn:mpeg:mpeg21:2002:02-DIDL-NS                           http://standards.iso.org/ittf/PubliclyAvailableStandards/MPEG-21_schema_files/did/didl.xsd                           urn:mpeg:mpeg21:2002:01-DII-NS http://standards.iso.org/ittf/PubliclyAvailableStandards/MPEG-21_schema_files/dii/dii.xsd                           urn:mpeg:mpeg21:2005:01-DIP-NS http://standards.iso.org/ittf/PubliclyAvailableStandards/MPEG-21_schema_files/dip/dip.xsd ">
            <didl:Item>
                <didl:Descriptor>
                    <didl:Statement mimeType="application/xml">
                        <dii:Identifier>
                            <xsl:value-of select="concat('urn:nbn:nl:ui:35-', $id)"/>
                        </dii:Identifier>
                    </didl:Statement>
                </didl:Descriptor>

        <!-- dcterms:modified goes here -->
                <didl:Descriptor>
                    <didl:Statement mimeType="application/xml">
                        <dcterms:modified>
                            <xsl:value-of select="pmd:docinfo/pmd:transformer[last()]/@pmd:datetime"/>
                        </dcterms:modified>
                    </didl:Statement>
                </didl:Descriptor>
                <didl:Component>
                    <didl:Resource mimeType="application/xml">
                        <xsl:attribute name="ref">
                            <xsl:value-of select="concat('http://resolver.politicalmashup.nl/', $id)"/>
                        </xsl:attribute>
                    </didl:Resource>
                </didl:Component>
                <didl:Item>
                    <didl:Descriptor>
                        <didl:Statement mimeType="application/xml">
                            <rdf:type rdf:resource="info:eu-repo/semantics/descriptiveMetadata"/>
                        </didl:Statement>
                    </didl:Descriptor>
                    <didl:Component>
                        <didl:Resource mimeType="application/xml">
                            <xsl:apply-templates select="meta"/>
                        </didl:Resource>
                    </didl:Component>
                </didl:Item>
            </didl:Item>
        </didl:DIDL>
    </xsl:template>
    <xsl:template match="meta">
        <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/                                    http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
            <xsl:apply-templates select="@*|node()"/>
        </oai_dc:dc>
    </xsl:template>
    <xsl:template match="dc:coverage | dc:language | dc:relation | dc:source | dc:subject">
        <xsl:copy>
            <xsl:value-of select="normalize-space(string-join(.//text(), ' '))"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:transform>