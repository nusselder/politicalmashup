xquery version "3.0" encoding "UTF-8";
(:   
Evaluation deliverable ODE II - Work Package 6- Amsterdam Municipality
Arjan Nusselder, May 13, 2014
:)

(:declare namespace dc = "http://purl.org/dc/elements/1.1/";:)
(:declare namespace pm = "http://www.politicalmashup.nl";:)
(:declare namespace pmx = "http://www.politicalmashup.nl/extra";:)
(:declare namespace folia = "http://ilk.uvt.nl/FoLiA";:)
(:declare namespace exist ="http://exist.sourceforge.net/NS/exist";:)
declare namespace local ="local";

(:import module namespace kwic="http://exist-db.org/xquery/kwic";:)
(:import module namespace xmldb="http://exist-db.org/xquery/xmldb";:)

(:import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';:)
import module namespace export="http://politicalmashup.nl/modules/export";

import module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation" at "evaluation.xqm";


declare function local:main() {

  (: What do we do. :)
  let $accepted-actions := "create new evaluation,describe documents,match documents,view results,list evaluations" 

  (: Query requested information. :)
  let $request := export:request-parameters( (<view default="table" accept="table,csv"/>) )

  (: Construct options to show in the form. :)
  let $options := export:options( (), $request)


let $xml-output := local:list-evaluations($request)


let $introduction-html :=
    <div>
      <p>List of evaluations, done or otherwise. Columns show the name and collection of the evaluation, and links to the description step, matching step, detailed overview, and raw xml.</p>
    </div>

let $output := if ($request/@view eq 'table') then ($introduction-html, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else ()

let $output := export:output($request/@view, $output, 'List evaluations')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output
};


(: List existing evaluation and their status. :)
declare function local:list-evaluations($request as element(request)) {

  (: Select evaluations. :)
  let $evaluations := collection($evaluation:data)//evaluation
  
  
  let $headers := (
    export:xml-util-description('List of available evaluations.'),
    export:xml-util-headers( ('name', 'collection', 'describe', 'match', 'details', 'xml') )
    )
  
  let $items :=
    for $e in $evaluations
    return
      export:xml-row(
        (
        export:xml-item($e/@name),
        export:xml-item($e/@collection),
        export:xml-item(concat('describe-document.xq?evaluation-id=',$e/@id), <options link="true" display="desc {$e/@id}"/>),
        export:xml-item(concat('match-document.xq?evaluation-id=',$e/@id), <options link="true" display="match {$e/@id}"/>),
        export:xml-item(concat('details.xq?evaluation-id=',$e/@id), <options link="true" display="{$e/@id} details"/>),
        export:xml-item(concat('data/',$e/@id,'.xml'), <options link="true" display="{$e/@id}.xml"/>)
        )
      )

  return export:xml-output( ($headers, $items) )  
};


local:main()