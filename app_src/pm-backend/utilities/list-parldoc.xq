declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";


let $request := export:request-parameters( (<subtype default="all" accept="all,amendment,motion,other"/>, <view default="table" accept="csv,table,xml"/>, <votes default="both" accept="both,with,without"/>) )

let $collection := collection('/db/data/permanent/d/nl/parldoc')

let $subtype := string($request/@subtype)
let $show-votes := string($request/@votes)

let $documents := if ($subtype eq 'all') then $collection
                  else $collection[.//meta[.//@pm:sub-type eq $subtype]]
                  
let $documents := if ($request/@votes eq 'with') then $collection[.//pm:event]
                  else if ($request/@votes eq 'without') then $collection[empty(.//pm:event)]
                  else $documents
                  
                  

(: Construct export output. :)
let $column-names := export:xml-util-headers( ('kamerstuk', 'sub-type', 'date', 'nr of votes') )

let $items :=
  for $document in $documents
  let $subtype := $document//meta//@pm:sub-type
  let $identifier := $document//dc:identifier
  let $date := $document//dc:date
  let $nr-votes := count($document//pm:event)
  order by $date descending
  return
    export:xml-row(
      (
      export:xml-item(export:link-resolver($identifier, 'html'), <options display="{$identifier}" link="true"/>),
      export:xml-item($subtype),
      export:xml-item($date),
      export:xml-item(if ($nr-votes ge 1) then $nr-votes else '')
      (:export:xml-item(count($document//pm:event[pm:vote])):)
      )
    )


let $xml-output := export:xml-output( ($column-names, $items) )
let $views :=
    <div>
      { export:html-util-generate-parameter-links($request, 'view', ('table','csv')) }
      { export:html-util-generate-parameter-links($request, 'subtype', ('all','amendment','motion','other')) }
      { export:html-util-generate-parameter-links($request, 'votes', ('both','with','without')) }
    </div>
let $output := if ($request/@view eq 'table') then ($views, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()
               
let $output := export:output($request/@view, $output, 'Overview Parliamentary Documents')
                                
let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output