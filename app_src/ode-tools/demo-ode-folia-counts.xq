xquery version "1.0" encoding "UTF-8";
(:   
Deliverables for Amendment+Vote Project
Arjan Nusselder, June 20, 2012
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace folia = "http://ilk.uvt.nl/FoLiA";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace kwic="http://exist-db.org/xquery/kwic";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";

declare function local:select-collection($request) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()
};


declare function local:count-terms($collection, $pos as xs:string) {
  let $headers := (
    export:xml-util-description(concat('Number of words of type ',$pos,'.')),
    export:xml-util-headers( ('count') )
    )
  
  let $terms := if ($pos eq '---') then $collection//folia:w else $collection//folia:w[folia:pos/@class eq $pos] 
  
  let $items :=
      export:xml-row(
        (
        export:xml-item(count($terms))
        )
      )
      
  return export:xml-output( ($headers, $items) )
};


declare function local:count-sentences($collection, $pos as xs:string) {
  let $headers := (
    export:xml-util-description('Number of sentences.'),
    export:xml-util-headers( ('count',concat('with at least three ',$pos)) )
    )
  
  let $sentences := $collection//folia:s
  let $long-sentences := if ($pos eq '---') then $sentences[count(folia:w) ge 3] else $sentences[count(.//folia:pos/@class eq $pos) ge 3] 
  
  let $items :=
      export:xml-row(
        (
        export:xml-item(count($sentences)),
        export:xml-item(count($long-sentences))
        )
      )
      
  return export:xml-output( ($headers, $items) )
};


declare function local:count-documents-per-month($collection) {
  let $headers := (
    export:xml-util-description('Number of documents in each given month.'),
    export:xml-util-headers( ('month','count') )
    )
    
  let $months := for $document in $collection
                 let $date := if ($document//dc:date) then substring($document//dc:date,1,7) else 'no-date'
                 order by $date
                 return $date  
  
  let $items :=
      for $month in distinct-values($months)
      return
      export:xml-row(
        (
        export:xml-item($month),
        export:xml-item(count($months[. eq $month]))
        )
      )
      
  return export:xml-output( ($headers, $items) )
};


declare function local:count-search-per-month($collection, $query as xs:string, $highlight as xs:integer) {
  let $headers := (
    export:xml-util-description(concat('Number of documents in each given month for query: ',$query,'.')),
    export:xml-util-headers( ('month','count') )
    )
    
  let $months := for $document in $collection
                 let $date := if ($document//dc:date) then substring($document//dc:date,1,7) else 'no-date'
                 order by $date
                 return $date  
  
  let $document-matches := $collection/root[ft:query(pmx:document,$query)]
  let $document-months := for $document in $document-matches
                          let $date := if ($document//dc:date) then substring($document//dc:date,1,7) else 'no-date'
                          order by $date
                          return $date
  
  let $items :=
      for $month in distinct-values($months)
      let $search-count := count($document-months[. eq $month])
      let $options := if ($search-count ge $highlight) then <options background="#faa"/> else <options/>
      return
      export:xml-row(
        (
        export:xml-item($month,$options),
        export:xml-item($search-count,$options)
        )
      )
      
  return export:xml-output( ($headers, $items) )
};


let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $search-fields := 'pm:speech,pm:p,pmx:document,pmx:title,pmx:text,folia:t'

let $count-queries := 'terms,documents-per-month,sentences,search-per-month'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            <count default="terms" accept="{$count-queries}"/>,
                                            <collection accept="{$accepted-collections}"/>, <limit default="20" type="xs:integer"/>,
                                            <pos default="" accept="---,N,ADJ,WW"/>,
                                            <query type="ft:query" default="subsid*"/>,
                                            <highlight type="xs:integer" default="5"/>) )

let $options := export:options( (
                                  <count explanation="choose example query" select="{$count-queries}"/>,
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>,
                                  <pos explanation="count part-of-speech for 'terms' and 'sentences'" select="---,N,ADJ,WW"/>,
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>,
                                  <query explanation="query term for search-per-month"/>,
                                  <highlight explanation="highlight more the X for search-per-month"/>
                                ),
                                $request)


let $collection := local:select-collection($request)

let $xml-output := if ($request/@count eq 'terms') then local:count-terms($collection,$request/@pos)
                   else if ($request/@count eq 'documents-per-month') then local:count-documents-per-month($collection)
                   else if ($request/@count eq 'sentences') then local:count-sentences($collection,$request/@pos)
                   else if ($request/@count eq 'search-per-month') then local:count-search-per-month($collection,xs:string($request/@query),xs:integer($request/@highlight))
                   else ()


let $introduction-html :=
    <div>
      <p>Example queries utilising FoLiA annotations.</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'ODE-II FoLiA Demo Counts')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output