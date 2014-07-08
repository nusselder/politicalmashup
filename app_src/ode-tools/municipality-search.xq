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
import module namespace export="http://politicalmashup.nl/modules/export" at 'municipality-search-export.xqm';


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
  let $terms-limit := xs:integer($request/@terms)
  let $scope := subsequence($scope,1,$limit)
  
  let $headers := (
    export:xml-util-description(concat($request/@search, ' count after date, before query: ', $count-before)),
    export:xml-util-description(concat($request/@search, ' count after query: ', $count-after))
    )
      
  let $items :=
    for $element in $scope
    let $date := $element/ancestor::root//dc:date
    let $pm-id := $element/@pm:id
    let $doc-id := root($element)//dc:identifier
    let $cloud := root($element)//pmx:clouds/cloud[@pos eq 'all'][xs:decimal(@w) eq 0.05]//term[position() le $terms-limit]
    
    return
      export:xml-row(
        (
        export:xml-item($date),
        export:xml-item(export:link-resolver($doc-id,'entities',$pm-id,$request/@query),<options link="true" display="{$pm-id}"/>),
        export:xml-item($cloud,<options copy="true"/>),
        export:xml-item(local:text-snippet($element), <options copy="true"/>)
        )
      )
  return export:xml-output( ($items,$headers), true() )
};


declare function local:select-scope($collection, $request) {
  let $scope := $collection
  
  (: Filter dates. :)
  let $scope := if ($request/@start-date) then $scope[.//dc:date ge xs:date($request/@start-date)] else $scope
  let $scope := if ($request/@end-date) then $scope[.//dc:date le xs:date($request/@end-date)] else $scope
    
  let $scope := if ($request/@search eq 'document') then $scope//pmx:document
                else if ($request/@search eq 'titel') then $scope//pmx:title
                else if ($request/@search eq 'tekst') then $scope//pmx:text
                else ()
  return $scope
};



let $search-fields := 'document,titel,tekst'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <search default="document" accept="{$search-fields}"/>,
                                            <start-date type="xs:date"/>, <end-date type="xs:date"/>,
                                            <terms type="xs:integer" default="10"/>,
                                            <query type="ft:query"/>, <limit default="20" type="xs:integer"/>) )

(:let $options := export:options( (
                                  <query explanation="any query string, valid according to lucene query rules"/>,
                                  <search explanation="detail level of returned search results; all document, just the title, or the text" select="{$search-fields}"/>,
                                  <start-date explanation="proper date-string in iso-format (yyyy-mm-dd), e.g. '2006-05-24'"/>,
                                  <end-date explanation="proper date-string in iso-format (yyyy-mm-dd), e.g. '2006-05-24'"/>,
                                  <terms explanation="experiment with number of cloud terms to show"/>,
                                  <limit explanation="limit displayed results to this number"/>,
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>
                                ),
                                $request):)
                                
let $options := export:options( (
                                  <search explanation="Niveau zoekopdracht: hele document, alleen in de titel of alleen in de tekst." select="{$search-fields}"/>,
                                  <start-date explanation="Begindatum, in iso-formaat (b.v. 2011-05-24)."/>,
                                  <end-date explanation="Einddatum, in iso-formaat."/>,
                                  <limit explanation="Maximum aantal getoonde resultaten."/>,
                                  <terms explanation="tijdelijk: aantal getoonde cloud-terms"/>
                                ),
                                $request)


let $collection := if ($request/@query) then collection(concat($settings:data-root,'/d/ode')) else ()
let $scope := local:select-scope($collection, $request)

let $xml-output := local:xml-output($scope, $request)

let $introduction-html :=
    <div class="introduction">
      <form method="get" action="">
        <div>
          <p style="font-size:14px;font-weight:bold;">Demonstrator zoekmachine Amsterdamse Schriftelijke Vragen.</p>
          <p>Zoekresultaten tonen de publicatie <span class="intr-datum">datum</span> (indien aanwezig) en <span class="intr-link">link</span> naar het document.<br/>
             Daaronder de meest onderscheidende <span class="intr-term">woorden</span> in dat document.<br/>
             Ten slotte een kort <span class="intr-fragment">tekstfragment</span> waarin de zoekterm stond.</p>
          <p>Rechts staan een aantal extra zoek opties.</p>
        </div>
        {export:html-util-generate-search-form($options, $request)}
        <div class="querybox">
          <input name="query" type="text" value="{$request/@query}"/>
          <button type="submit">Zoeken</button>
        </div>
      </form>
    </div>
    
let $search-form := ()

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Zoeken in Amsterdamse Schriftelijke Vragen')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output