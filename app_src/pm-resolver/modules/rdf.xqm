xquery version "1.0";

module namespace pmrdf = "http://politicalmashup.nl/resolver/rdf";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace bio="http://purl.org/vocab/bio/0.1/";
declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace dbpediaOntology="http://dbpedia.org/ontology/";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace parlipro="http://purl.org/vocab/parlipro#";

declare namespace res="http://www.w3.org/2005/sparql-results#";
declare namespace mime="http://purl.org/NET/mediatypes/";

declare variable $pmrdf:baseURI := "http://resolver.politicalmashup.nl/";
declare variable $pmrdf:vocabURI := "http://purl.org/vocab/parlipro#";
declare variable $pmrdf:source := "http://www.parlement.com";
declare variable $pmrdf:nlSparqlInterface := "http://nl.dbpedia.org/sparql?";

declare function pmrdf:createType($class) {
    (: outputs the "typing" triple :)
    let $classURI := concat($pmrdf:vocabURI, string($class))
    
    return
        <rdf:type>
            <rdf:Description rdf:about="{$classURI}"></rdf:Description>
        </rdf:type>
};

declare function pmrdf:createExternalLink($text, $type) {

    if ($type eq 'extref') then <rdf:Description rdf:about="{concat('https://zoek.officielebekendmakingen.nl/',$text,'.html')}"/>
    else if ($type eq 'dossierref') then <rdf:Description rdf:about="{concat('https://zoek.officielebekendmakingen.nl/dossier/',$text)}"/>
    else $text
};

declare function pmrdf:processParagraph($p, $showType) {

    (: outputs the RDF view of pm:paragraph :)
    let $pId := $p/@pm:id            
    let $typeTriple := if ($showType) then pmrdf:createType("Paragraph") else ()
    let $text := ""
    (: uncomment the next line if proceedings together with textual triples are needed :)
    (: let $text := if ($showType) then <rdf:value>{$p/text()}</rdf:value> else () :) 
    
    return
        <rdf:Description rdf:about="{$pId}">
            {$typeTriple}
            {$text}            
        </rdf:Description>
};

declare function pmrdf:processStageDirection($sd, $showType) {

    (: outputs the RDF view of pm:stage-direction :)
    let $sdId := $sd/@pm:id
    let $typeTriple := if ($showType) then pmrdf:createType("StageDirection") else ()
    
    return
        <rdf:Description rdf:about="{$sdId}">
            {$typeTriple}
                        
            {
                if (fn:exists($sd/node())) then pmrdf:transformToRdfRecursive($sd/node())
                else ()
            }            
        </rdf:Description>            
};

declare function pmrdf:createPartyRef($speech) {
    (: outputs the <partyRef> triple :)
    
    let $partyRef := string($speech/@pm:party-ref)
    return
        <parlipro:refParty>
            <rdf:Description rdf:about="{$partyRef}"></rdf:Description>
        </parlipro:refParty>
};

declare function pmrdf:createMemberRef($speech) {
    (: outputs the <memberRef> triple :)
 
    let $memberRef := string($speech/@pm:member-ref)
    return
        <parlipro:refMember>
            <rdf:Description rdf:about="{$memberRef}"></rdf:Description>
        </parlipro:refMember>

};

declare function pmrdf:processSpeech($speech, $showType) {

    (: outputs the RDF view of pm:speech :)
    let $speechId := string($speech/@pm:id)
    let $typeTriple := if ($showType) then pmrdf:createType("Speech") else ()
    
    let $partyTriple :=    
        if ($showType and fn:exists($speech/@pm:party-ref))   
            then pmrdf:createPartyRef($speech)
        else ()
        
    let $memberTriple :=    
        if ($showType and fn:exists($speech/@pm:member-ref))
            then pmrdf:createMemberRef($speech)
        else ()
 
    return
        <rdf:Description rdf:about="{$speechId}">
            {$typeTriple}
            {$partyTriple}
            {$memberTriple}                        
            
            {
                if (fn:exists($speech/node())) then pmrdf:transformToRdfRecursive($speech/node())
                else ()
            }            
        </rdf:Description>	
};

declare function pmrdf:processScene($scene, $showType) {

    (: outputs the RDF view of pm:speech :)    
    let $sceneId := string($scene/@pm:id)  
    let $typeTriple := if ($showType) then pmrdf:createType("Scene") else ()
    
    return
        <rdf:Description rdf:about="{$sceneId}">
            {$typeTriple}
            
            {
                if (fn:exists($scene/node())) then pmrdf:transformToRdfRecursive($scene/node())
                else ()
            }            
        </rdf:Description>  
};

declare function pmrdf:processTopic($topic, $showType) {
    
    (: outputs the RDF view of pm:topic :)
    let $topicId := string($topic/@pm:id)
    let $typeTriple := if ($showType) then pmrdf:createType("Topic") else ()

    (: if there are <tagged> elements add them to the topic :)
    
    let $taggedElements :=
        if ($showType and exists($topic//pm:tagged)) then
            let $references := $topic//pm:tagged/pm:tagged-entity[@pm:reference]
                for $ref in $references
                    return <dcterms:references>
                                {pmrdf:createExternalLink(string($ref/@pm:reference), string($ref/@pm:sub-type))}
                            </dcterms:references>
        else ()
    return 
        <rdf:Description rdf:about="{$topicId}">
            {$typeTriple}
            {$taggedElements}
            
            {
                if (exists($topic/node())) then pmrdf:transformToRdfRecursive($topic/node())
                else ()
            }    
        </rdf:Description>
};

declare function pmrdf:processProceedings($proceedings, $showType) {

    (:  outputs the RDF view of pm:proceedings :)    
    let $procId := $proceedings/@pm:id
    let $typeTriple := if ($showType) then pmrdf:createType("ParliamentaryProceedings") else ()
    
    return
        <rdf:Description rdf:about="{$procId}">
            {$typeTriple}
            
            {pmrdf:transformToRdfRecursive($proceedings)}            
        </rdf:Description>     
};

declare function pmrdf:processParty($party) {

    (:  outputs the RDF view of pm:party :)

    let $pId := $party/@pm:id
    (: we are interested in the DBpeida links only :)
    let $links := $party//pm:link[@pm:linktype="dbpedia"]
    return
        <rdf:Description rdf:about="{$pId}">
            {pmrdf:createType("PoliticalParty")}
            {
                for $link in $links
                return
                    <owl:sameAs>
                        <rdf:Description rdf:about="{$link}"></rdf:Description>
                    </owl:sameAs>                   
            }            
        </rdf:Description>  
};

declare function pmrdf:processMember($member) {

    (:  outputs the RDF view of pm:member :)

    let $mId := $member/@pm:id
    let $xsdDate := "http://www.w3.org/2001/XMLSchema#date"
    (: We are interested in the DBpedia links only :)
    let $links := $member//pm:link[@pm:linktype="dbpedia"]

    let $male := "http://dbpedia.org/resource/Male"
    let $female := "http://dbpedia.org/resource/Female"
    
    let $gender := string($member//pm:gender)
    let $genderTriple :=
        if (exists($gender))
        then if ($gender="male") then
                                            <foaf:gender>
                                                <rdf:Description rdf:about="{$male}"/>
                                            </foaf:gender>
                     else if ($gender="female") then 
                                            <foaf:gender>
                                                <rdf:description rdf:about="{$female}"/>
                                            </foaf:gender>
                     else ()
        else ()

    let $birthday := $member//pm:born/@pm:date
    let $birthdayTriple :=
        if (exists($birthday))
        then <foaf:birthday rdf:datatype="{string($xsdDate)}">{string($birthday)}</foaf:birthday>
        else ()
    
    let $birthPlace := $member//pm:born/@pm:place
    let $birthPlaceTriple :=
        if (exists($birthPlace))
        then <dbpediaOntology:birthPlace>{string($birthPlace)}</dbpediaOntology:birthPlace>
        else ()
    
    let $deathDate := $member//pm:deceased/@pm:date    
    let $deathDateTriple :=
        if (exists($deathDate))
        then <dbpediaOntology:deathDate rdf:datatype="{string($xsdDate)}">{string($deathDate)}</dbpediaOntology:deathDate>
        else ()
    
    let $deathPlace := $member//pm:deceased/@pm:place
    let $deathPlaceTriple :=
        if (exists($deathPlace))
        then <dbpediaOntology:deathPlace>{string($deathPlace)}</dbpediaOntology:deathPlace>
        else ()
    
    return
        <rdf:Description rdf:about="{$mId}">

            {pmrdf:createType("ParliamentMember")}
            
            <bio:biography>
                <bio:Biography>
                    <dcterms:provenance>
                        <rdf:Description rdf:about="{$pmrdf:source}"></rdf:Description>
                    </dcterms:provenance>
                    {$genderTriple}
                    {$birthdayTriple}
                    {$birthPlaceTriple}
                    {$deathDateTriple}
                    {$deathPlaceTriple}
                </bio:Biography>
            </bio:biography>
            {
                for $link in $links
                  return
                    <owl:sameAs>
                        <rdf:Description rdf:about="{$link}"></rdf:Description>
                    </owl:sameAs>                    
            }            
        </rdf:Description>     
};

declare function pmrdf:processRoot($nodes, $showType) {        

        (:  according to this http://schema.politicalmashup.nl/schemas.html
            the third child of the root element depends on the document type
            and can be <proceedings>, <party>, <member> and <debate-summary>
        
            this function handles the first three types:
             - checks the third child of the root element and processes it accrording to its name :)

        (: get the third element :)
        let $thirdElement := $nodes[self::root]/*[3]    
        return
            typeswitch ($thirdElement)
                case element(pm:proceedings) return
                
                    let $typeTriple := if ($showType) then pmrdf:createType("ParliamentaryProceedings") else ()
        
                    let $procId := string($thirdElement/@pm:id)
                    let $meta := $thirdElement/../meta
                    let $format := "http://purl.org/NET/mediatypes/application/rdf+xml"
                    let $contrib := $meta/dc:contributor/text()
                    
                    let $xsdDate := "http://www.w3.org/2001/XMLSchema#date"
                    let $date := $meta/dc:date/text()
                    let $sourceURI := concat(resolve-uri($thirdElement/@pm:id, $pmrdf:baseURI), '?view=xml')
                    
                    let $legPeriod := string($meta//pm:legislative-period/text())
                    let $country := string($meta//dc:coverage/country/@dcterms:ISO3166-1)
                    let $language := string($meta//dc:language/pm:language/@dcterms:ISO639-2)
                    
                    return
                    (: in case the third element is proceedings we add meta information :)
                        <rdf:Description rdf:about="{$procId}">
                            {$typeTriple}
                            <dc:identifier>
                                <rdf:Description rdf:about="{string($procId)}"></rdf:Description>                
                            </dc:identifier>
                            <dc:format>
                                <rdf:Description rdf:about="{string($format)}"></rdf:Description>
                            </dc:format>
                            <dc:contributor>
                                <rdf:Description rdf:about="{string($contrib)}"></rdf:Description>
                            </dc:contributor>
                            <dc:date rdf:datatype="{string($xsdDate)}">
                                {string($date)}
                            </dc:date>
                            <dc:source>
                                <rdf:Description rdf:about="{string($sourceURI)}"></rdf:Description>
                            </dc:source>
                            
                            <parlipro:legislativePeriod>{$legPeriod}</parlipro:legislativePeriod>
                            <dcterms:ISO3166-1>{$country}</dcterms:ISO3166-1>
                            <dcterms:ISO639-2>{$language}</dcterms:ISO639-2>
                            
                            {
                                let $parts := $thirdElement/node()
                                for $part in $parts
                                return pmrdf:transformToRdfRecursive($part)
                            }
            
                        </rdf:Description>
            
                case element(pm:party) return pmrdf:processParty($thirdElement)        
                case element(pm:member) return pmrdf:processMember($thirdElement)
        
        default return concat("Warning! Element not defined in RDF: ", $thirdElement/name())    
};

declare function pmrdf:transformToRdfRecursive($nodes as node()*) as item()* {

    (:  recursive processing of the nodes:
        passes the nodes to the corresponding function handler with the second parameter false() 
        so that no specific information for these nodes will be added to the RDF view :)

    for $node in $nodes
    return 
        typeswitch ($node)
            case element(pm:p) return <dcterms:hasPart> {pmrdf:processParagraph($node,false())} </dcterms:hasPart>
            case element(pm:stage-direction) return <dcterms:hasPart> {pmrdf:processStageDirection($node, false())} </dcterms:hasPart>
            case element(pm:speech) return <dcterms:hasPart> {pmrdf:processSpeech($node, false())} </dcterms:hasPart>
            case element(pm:scene) return <dcterms:hasPart> {pmrdf:processScene($node, false())} </dcterms:hasPart>
            case element(pm:topic) return <dcterms:hasPart> {pmrdf:processTopic($node, false())} </dcterms:hasPart>
        default return ()
};

declare function pmrdf:transformToRdf($node as node()?) as item()* {

    (: initial processing of the input nodes: passes the first node to the corresponding function handler 
        with the second parameter true() to signal to the handler to add descriptive information specific to this node :)
        typeswitch ($node)
            case element(pm:p) return pmrdf:processParagraph($node, true())
            case element(pm:stage-direction) return pmrdf:processStageDirection($node, true())
            case element(pm:speech) return pmrdf:processSpeech($node, true())
            case element(pm:scene) return pmrdf:processScene($node, true())
            case element(pm:topic) return pmrdf:processTopic($node, true())
            case element(pm:proceedings) return pmrdf:processProceedings($node, true())
            case element(root) return pmrdf:processRoot($node, true())
            case document-node() return pmrdf:processRoot($node/root, true())
        default return 
            concat("Warning! Element not defined in RDF: ",$node/name())
  };


declare function pmrdf:transform($xml) {

 <rdf:RDF  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:owl="http://www.w3.org/2002/07/owl#"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:dcterms="http://purl.org/dc/terms/"
            xmlns:mime="http://purl.org/NET/mediatypes/"
            xmlns:bio="http://purl.org/vocab/bio/0.1/"
            xmlns:dbpediaOntology="http://dbpedia.org/ontology/"
            xmlns:foaf="http://xmlns.com/foaf/0.1/"
            xmlns:pm="http://www.politicalmashup.nl"
            xmlns:parlipro="http://purl.org/vocab/parlipro#"
            xml:base="http://resolver.politicalmashup.nl/">

  { pmrdf:transformToRdf($xml) }
  

</rdf:RDF>

};
