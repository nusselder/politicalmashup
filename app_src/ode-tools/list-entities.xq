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


declare function local:entities($collection, $request as element(request)) {
  let $headers := (
    export:xml-util-description('List of entities'),
    export:xml-util-headers( ('entity search','entity graph','nr of documents','words','wikilink') )
    )
  
  
   let $counts :=
    for $link in $collection//dc:relation/pm:link
      let $wiki := string($link)
      group by $wiki
      (:return <e w="{$wiki}" c="{count($link)}" p="{string-join(distinct-values(for $l in $link return $l/pmx:reference/@pmx:entity-name),', ')}"/>:)
      return <e w="{$wiki}" c="{count($link)}" p="{local:summarise-entity-names(for $l in $link return $l/pmx:reference/@pmx:entity-name)}"/>
  
  let $items :=
    for $l in $counts
    order by xs:integer($l/@c) descending
    return
      export:xml-row(
        (
        export:xml-item(concat('entity-search.xq?collection=',$request/@collection,'&amp;entity=',$l/@w),<options display="{util:unescape-uri($l/@w,'UTF-8')}" link="true"/>),
        export:xml-item(concat('timeline/entity-graph-monthly.xq?collection=',$request/@collection,'&amp;entity=',$l/@w),<options display="{util:unescape-uri($l/@w,'UTF-8')}" link="true"/>),
        export:xml-item($l/@c),
        export:xml-item($l/@p),
        export:xml-item($l/@w,<options link="true"/>)
        )
      )

  return export:xml-output( ($headers, $items) )
};



(: Escape input entity query, because xml (and index!) contains escaped strings. :)
declare function local:fix-wikilink-input($request) {
  (: Cut off the escaped part after the wiki link, then unescape the entity (in case input is actually escaped already), and escape the string, then combine again. :)
  concat(
    substring-before($request/@entity,'/wiki/'), '/wiki/',
    encode-for-uri(
      util:unescape-uri(substring-after($request/@entity,'/wiki/'),'UTF-8')
    )
  )
};



let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $count-queries := 'entities,documents'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            (:<count accept="{$count-queries}"/>,:)
                                            (:<entity/>,:)
                                            <collection accept="{$accepted-collections}"/>) )

let $options := export:options( (
                                  (:<count explanation="choose example query" select="{$count-queries}"/>,:)
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>,
                                  (:<entity explanation="entity as wikilink to search for"/>,:)
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>
                                  (:,
                                  <entity-escaped value="{local:fix-wikilink-input($request)}" explanation="escaped wiki link used for querying"/>:)
                                ),
                                $request)


let $collection := local:select-collection($request)

(:let $xml-output := if ($request/@count eq 'entities') then local:entities($collection,$request)
                   else if ($request/@count eq 'documents') then local:documents($collection,$request)
                   else ():)
let $xml-output := local:entities($collection,$request)


let $introduction-html :=
    <div>
      <p>List pre-computed entities occuring in the data.</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'ODE-II FoLiA Entity Search')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output