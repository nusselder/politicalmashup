xquery version "1.0" encoding "UTF-8";
(:   
Deliverables for Amendment+Vote Project
Arjan Nusselder, June 20, 2012
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace kwic="http://exist-db.org/xquery/kwic";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";


declare function local:text-snippet($element){
  let $expanded := kwic:expand($element)
  return
    <span class="snippet">
      { kwic:get-summary($expanded, ($expanded//exist:match)[1], <config width="30"/>) }
    </span>
};



declare function local:xml-output($scope, $request) {
  let $count-before := count($scope)
  let $scope := ft:query($scope,string($request/@query))
  let $count-after := count($scope)
  let $limit := xs:integer($request/@limit)
  let $scope := subsequence($scope,1,$limit)
  
  let $headers := (
    export:xml-util-description(concat($request/@search, ' count after date, before query: ', $count-before)),
    export:xml-util-description(concat($request/@search, ' count after query: ', $count-after)),
    export:xml-util-headers( ('date', 'id', 'speaker', 'party', 'role', 'snippet') )
    )
      
  let $items :=
    for $element in $scope
    let $date := $element/ancestor::root//dc:date
    let $pm-id := $element/@pm:id
    let $doc-id := root($element)//dc:identifier
    let $speech := $element/ancestor-or-self::pm:speech
    let $speaker-item := if (starts-with($request/@collection,'nl')) then export:xml-item(export:link-resolver($speech/@pm:member-ref,'html'),<options link="true" display="{$speech/@pm:speaker}"/>)
                         else export:xml-item($speech/@pm:speaker)
    let $party-item := if (starts-with($request/@collection,'nl')) then export:xml-item(export:link-resolver($speech/@pm:party-ref,'html'),<options link="true" display="{$speech/@pm:party}"/>)
                         else export:xml-item($speech/@pm:party)
    
    return
      export:xml-row(
        (
        export:xml-item($date),
        export:xml-item(export:link-resolver($doc-id,'html',$pm-id,$request/@query),<options link="true" display="{$pm-id}"/>),
        $speaker-item,
        $party-item,
        export:xml-item($speech/@pm:role),
        export:xml-item(local:text-snippet($element), <options copy="true"/>)
        )
      )
  return export:xml-output( ($headers, $items) )
};

declare function local:select-collection($request) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()

  (:let $proceedings-collections := export:data-util-proceedings-collections()
  (\:let $collection-path := string($proceedings-collections/collection[@name eq string($request/@collection)]/@collection-path):\)
  let $collection-path := if ($request/@collection eq 'ode') then '/db/data/permanent/d/ode' else string($proceedings-collections/collection[@name eq string($request/@collection)]/@collection-path)
  return if ($collection-path ne '') then collection( $collection-path ) else ():)
};


declare function local:select-scope($collection, $request) {
  let $scope := $collection
  
  (: Filter dates. :)
  let $scope := if ($request/@start-date) then $scope[.//dc:date ge xs:date($request/@start-date)] else $scope
  let $scope := if ($request/@end-date) then $scope[.//dc:date le xs:date($request/@end-date)] else $scope
    
  let $scope := if ($request/@search eq 'pm:p') then $scope//pm:p
                else if ($request/@search eq 'pm:speech') then $scope//pm:speech
                else if ($request/@search eq 'pmx:document') then $scope//pmx:document
                else if ($request/@search eq 'pmx:title') then $scope//pmx:title
                else if ($request/@search eq 'pmx:text') then $scope//pmx:text
                else ()
  return $scope
};


let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $search-fields := 'pm:speech,pm:p,pmx:document,pmx:title,pmx:text'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <search default="speech" accept="{$search-fields}"/>, <start-date type="xs:date"/>, <end-date type="xs:date"/>,
                                            <query type="ft:query"/>, <collection accept="{$accepted-collections}"/>, <limit default="20" type="xs:integer"/>) )

let $options := export:options( (
                                  <query explanation="any query string, valid according to lucene query rules"/>,
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>,
                                  <search explanation="detail level of returned search results; one speech could be equal to multiple paragraphs" select="{$search-fields}"/>,
                                  <start-date explanation="proper date-string in iso-format (yyyy-mm-dd), e.g. '2006-05-24'"/>,
                                  <end-date explanation="proper date-string in iso-format (yyyy-mm-dd), e.g. '2006-05-24'"/>,
                                  <limit explanation="limit displayed results to this number"/>,
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>
                                ),
                                $request)


let $collection := if ($request/@query) then local:select-collection($request) else ()
let $scope := local:select-scope($collection, $request)

let $xml-output := local:xml-output($scope, $request)

let $introduction-html :=
    <div>
      <p>Demonstration of search functionality for the available data.</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Zoeken in handelingen')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output