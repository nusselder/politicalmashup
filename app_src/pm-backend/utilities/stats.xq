xquery version "1.0" encoding "UTF-8";
(: 
Author: Arjan Nusselder
Created : Oktober 2011
Last update : July 2013
Purpose: Show statistics over collections.
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";


declare function local:select-collection($request) {
  let $proceedings-collections := export:data-util-proceedings-collections()
  let $collection-path := string($proceedings-collections/collection[@name eq string($request/@collection)]/@collection-path)
  let $collection := if ($collection-path ne '') then collection($collection-path) else ()
  return if ($request/@house eq 'all') then $collection
         else $collection[.//pm:house/@pm:house eq string($request/@house)]
};


(: Analyse collection :)
declare function local:analyse-elements($collection, $divide) {
  if ($collection) then
    export:xml-row(
      (
      if (empty($divide)) then () else export:xml-item($divide),
      export:xml-item(count($collection//pm:proceedings)),
      export:xml-item(count($collection//pm:topic)),
      export:xml-item(count($collection//pm:scene)),
      export:xml-item(count($collection//pm:speech)),
      export:xml-item(count($collection//pm:p)),
      export:xml-item(count(distinct-values($collection//dc:date)))
      )
    )
  else ()
};


(: Analyse members :)
declare function local:analyse-member-refs($collection, $divide) {
  let $speeches := $collection//pm:speech
  let $speech-count := count($speeches)
  let $ref-count := count($speeches[matches(@pm:member-ref,'\.m\.[^,]+$')])
  return
  if ($collection) then
    export:xml-row(
      (
      if (empty($divide)) then () else export:xml-item($divide),
      export:xml-item($speech-count),
      export:xml-item($ref-count),
      export:xml-item(count($speeches[empty(@pm:member-ref)])),
      export:xml-item(count($speeches[@pm:member-ref eq ''])),
      export:xml-item(count(distinct-values($speeches/@pm:member-ref))),
      export:xml-item(round-half-to-even(($ref-count div $speech-count) * 100,4))
      )
    )
  else ()
};


declare function local:analyse($collection, $divide, $request) {
  if ($request/@speakers eq 'true') then local:analyse-member-refs($collection, $divide)
  else local:analyse-elements($collection, $divide)
};


declare function local:headers($request) {
 (: Headers :)  
  let $header-names := if ($request/@speakers eq 'true') then ('speeches', 'member-ref matches .m.', 'empty member-ref', "member-ref eq ''", 'unique member-refs', 'percentage correct member ids')
                       else ('proceedings', 'topics', 'scenes', 'speeches', 'paragraphs', 'unique dates')
  
  let $header-names := if ($request/@divide eq 'year') then ('year', $header-names)
                       else if ($request/@divide eq 'period') then ('period', $header-names)
                       else $header-names
  
  return export:xml-util-headers( $header-names )
};


(: Count one country. :)
declare function local:element-statistics($collection, $request) {
  
  let $headers := local:headers($request) 
  
  let $years := if ($request/@divide eq 'year') then for $year in distinct-values(for $date in $collection//dc:date return substring($date,1,4)) order by $year return $year else ()
  
  let $periods := if ($request/@divide eq 'period') then export:data-util-legislative-periods($collection) else ()

  let $items :=
  
    if ($request/@divide eq 'period') then
      for $period in $periods
      let $period-collection := $collection[.//pm:legislative-period eq $period]
      return
        local:analyse($period-collection, $period, $request)
      
    else if ($request/@divide eq 'year') then
      for $year in $years
      let $year-collection := $collection[.//dc:date[starts-with(.,$year)]]
      return
        local:analyse($year-collection, $year, $request)
      
    else
      local:analyse($collection, (), $request)
      
      
  return export:xml-output( ($headers, $items) )
};


let $accepted-collections := string-join(export:data-util-proceedings-collections()/collection/@name,',')

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            <collection accept="{$accepted-collections}"/>,
                                            <house default="all" accept="all,commons,senate,other"/>,
                                            <speakers default="false" accept="true,false"/>,
                                            <divide default="none" accept="none,year,period"/>) )

let $options := export:options( ( <collection explanation="count element statistics" select="{$accepted-collections}"/>,
                                  <house explanation="count only the specified house" select="all,commons,senate,other"/>,
                                  <speakers explanation="count member references instead of elements" select="true,false"/>,
                                  <divide explanation="subdivide results per year, or per legislative period; only data with that info explicitly defined, is returned" select="none,period,year"/>
                                ),
                                $request)


let $collection := local:select-collection($request)
(:let $scope := local:select-scope($collection, $request):)

let $xml-output := local:element-statistics($collection, $request)


let $links-to-overviews :=
    <div>
      { export:html-util-generate-parameter-links($request, 'view', ('table','csv')) }
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($links-to-overviews, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Statistics on the data sets.')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output
