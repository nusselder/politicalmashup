xquery version "3.0" encoding "UTF-8";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace folia = "http://ilk.uvt.nl/FoLiA";
declare namespace local = "local";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace functx="http://www.functx.com";


declare function local:select-collection($request) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()
};



declare function local:summarise-entity-names($entity-names as xs:string*) as xs:string {
  let $collapsed := for $en in $entity-names
                    let $name := xs:string($en)
                    group by $name
                    return <en n="{$name}" c="{count($en)}"/>
(:                    return concat($name,' (',count($en),')'):)
  let $strings := for $en in $collapsed order by xs:decimal($en/@c) descending return concat($en/@n,' (',$en/@c,')')
  return string-join($strings,', ')
};



declare function local:documents($collection, $request as element(request)) {

  let $wiki-link := local:fix-wikilink-input($request)
  
  let $headers := (
    export:xml-util-description(concat('Documents with entity: ',$wiki-link)),
    export:xml-util-headers( ('document','date','count in document',if ($request/@collection ne 'd/ode') then 'first occurence in document' else ()) )
    )
  
  
  let $document-links := $collection//dc:relation/pm:link[. eq $wiki-link]
  
  let $document-links := if ($request/@month) then $document-links[substring(root()//dc:date,1,7) eq $request/@month] else $document-links
  
  let $items :=
    for $link in $document-links
    let $doc-id := root($link)//dc:identifier
    let $doc-date := root($link)//dc:date
    let $first-occurence := $link/pmx:reference[1]/@pmx:entity-element
    let $count := $link/@pmx:entity-occurence
    order by xs:integer($count) descending
    return
      export:xml-row(
        (
        export:xml-item(export:link-resolver($doc-id,'entities'),<options link="true" display="{$doc-id}"/>),
        export:xml-item($doc-date),
        export:xml-item($count),
        if ($request/@collection ne 'd/ode') then export:xml-item(export:link-resolver($doc-id,'entities',$first-occurence),<options link="true" display="{$first-occurence}"/>) else ()
        )
      )

  return export:xml-output( ($headers, $items) )
};


(: Escape input entity query, because xml (and index!) contains escaped strings. :)
declare function local:fix-wikilink-input($request) {
  (: Cut off the escaped part after the wiki link, then unescape the entity (in case input is actually escaped already), and escape the string, then combine again. :)
  concat(
    substring-before($request/@entity,'/wiki/'), '/wiki/',
    replace(
      encode-for-uri(    
        util:unescape-uri(substring-after($request/@entity,'/wiki/'),'UTF-8')
      ), '%2F', '/'
    )
  )
};



let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $count-queries := 'entities,documents'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            (:<count accept="{$count-queries}"/>,:)
                                            <entity/>,
                                            <month/>,
                                            <collection accept="{$accepted-collections}"/>) )

let $options := export:options( (
                                  (:<count explanation="choose example query" select="{$count-queries}"/>,:)
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>,
                                  <entity explanation="entity as wikilink to search for"/>,
                                  <month explanation="filter results for specific month, as 'yyyy-mm'"/>,
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>,
                                  <entity-escaped value="{local:fix-wikilink-input($request)}" explanation="escaped wiki link used for querying"/>
                                ),
                                $request)


let $collection := local:select-collection($request)

(:let $xml-output := if ($request/@count eq 'entities') then local:entities($collection,$request)
                   else if ($request/@count eq 'documents') then local:documents($collection,$request)
                   else ():)
let $xml-output := local:documents($collection,$request)

let $introduction-html :=
    <div>
      <p>Search for documents containing pre-computed entities.</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'ODE-II FoLiA Entity Search')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output