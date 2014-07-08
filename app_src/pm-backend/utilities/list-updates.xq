xquery version "1.0" encoding "UTF-8";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmd = "http://www.politicalmashup.nl/docinfo";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace util="http://exist-db.org/xquery/util";

import module namespace export="http://politicalmashup.nl/modules/export";

declare function local:get-collection($request) as node()* {
  let $sub-collections := if ($request/@collection) then tokenize(string($request/@collection),'\|') else ''
  let $collections := for $sub-collection in $sub-collections return collection(concat('/db/data/permanent/',$sub-collection))
  return $collections
};

declare function local:documents-transformed-since($request) {
  let $date-since := string($request/@since)
  let $collection := local:get-collection($request)
  let $collection-since := $collection[.//pmd:transformer/@pmd:datetime ge xs:dateTime($date-since)]
  
  let $column-names := export:xml-util-headers( ('datetime', 'identifier', 'resolver', 'collection') )
  let $description := export:xml-util-description( concat('Documents transformed since: ', $date-since) )
  
  let $items :=
    for $document in $collection-since
    let $date-transformed := $document//pmd:transformer[last()]/@pmd:datetime
    let $identifier := $document//dc:identifier
    order by $date-transformed descending
    return
      export:xml-row(
        (
        export:xml-item($date-transformed),
        export:xml-item($identifier),
        export:xml-item(export:link-resolver($identifier), <options link="true"/>),
        export:xml-item(substring-after(util:collection-name($document),'permanent/'))
        )
      )

  let $xml := export:xml-output( ($description, $column-names, $items) )
  
  return $xml
};


let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <since type="xs:dateTime"/>, <collection/>) )

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

let $xml-output := if ($request/@since) then local:documents-transformed-since($request) else export:xml-output(())

let $output := if ($request/@view eq 'table') then export:html-output($xml-output)
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'List updated documents')

return $output