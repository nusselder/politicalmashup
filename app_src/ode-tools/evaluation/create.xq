xquery version "3.0" encoding "UTF-8";
(:   
Evaluation deliverable ODE II - Work Package 6- Amsterdam Municipality
Arjan Nusselder, May 13, 2014
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace folia = "http://ilk.uvt.nl/FoLiA";
declare namespace local ="local";

import module namespace util="http://exist-db.org/xquery/util";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";

import module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation" at "evaluation.xqm";
 


declare function local:main() {

  (: Allow all collections? :)
  let $accepted-collections := string-join(export:build-collection-tree(true()),',')
  
  (: What do we do. :)
  let $accepted-actions := "create new evaluation,describe documents,match documents,view results,list evaluations" 

  (: Query requested information. :)
  let $request := export:request-parameters( (<view default="table" accept="table"/>,
                                              <collection accept="{$accepted-collections}"/>,
                                              <documents default="10" type="xs:integer"/>,
                                              <evaluation-name/>,
                                              <submit default="no" accept="no,yes"/>
                                              ) )

  (: Construct options to show in the form. :)
  let $options := export:options( (<collection explanation="create for which collection" select="{$accepted-collections}"/>,
                                   <documents explanation="number of documents to evaluate"/>,
                                   <evaluation-name explanation="set a name for this evaluation"/>,
                                   <submit explanation="are you sure you want to create a new evaluation?" select="no,yes"/>
                                  ), $request)



let $collection := local:select-collection($request)

let $xml-output := local:create-new-evaluation($request, $collection)


let $introduction-html :=
    <div>
      <p>Create a new summary evaluation.</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Evaluation / step 0 - create new')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output


};


(: Select the appropriate document collection. :)
declare function local:select-collection($request as element(request)) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()
};


(: Select a random sample of documents. Optionally, avoid already evaluated documents. :)
declare function local:select-sample-documents($request as element(request), $collection, $only-new as xs:boolean) {

  (: For now, testing evaluation, non-random first X documents. :)
  subsequence($collection,1,xs:integer($request/@documents))
};


declare function local:random-list($max) {
  for $number in (1 to $max)
  order by util:random()
  return $number
};

(: Setup new evaluation. :)
declare function local:create-new-evaluation($request as element(request), $collection) {

  (: Create new id one higher. 1 + either 0 or the highest already present id :)
  let $id := 1 + (0, for $i in collection($evaluation:data)//evaluation order by xs:integer($i/@id) ascending return xs:integer($i/@id))[last()]
  
  let $random-order := local:random-list(xs:integer($request/@documents))
  (: Create evaluation document references. :)
  (:let $documents := (<document id="ode.d.something" two-sentence-description="Beschrijving" guessed-id="ode.d.someother"/>):)
  
  let $sample := local:select-sample-documents($request, $collection, false())
  let $documents :=
    for $d at $pos in $sample
    return <document id="{$d//dc:identifier}" order="{$pos}" random-order="{$random-order[$pos]}" description="" guessed-id="" guessed-order=""/>
  
  
  (: Statuses: new,described,guessed,finished :)
  
  (: Create evaluation document. :)
  let $evaluation-document :=
    <evaluation id="{$id}" name="{$request/@evaluation-name}" status="new" collection="{$request/@collection}">
      <documents>
        {$documents}
      </documents>
      <score>
        <agreement number-of-agreements=""/>
      </score>
    </evaluation>

  let $stored-evaluation-document := if ($request/@submit eq "yes")
    then xmldb:store(
      $evaluation:data,     (: Store at collection :)
      concat($id,'.xml'),   (: New filename :)
      $evaluation-document, (: Actual content :)
      'application/xml')    (: Store as xml :)
    else ()
  
  
  let $headers := (
    export:xml-util-description('Evaluation of document summaries.'),
    export:xml-util-headers( ('details', 'describe documents', 'id', 'name') )
    )
  
  let $items :=
    if ($request/@submit eq "yes") then
      export:xml-row(
        (
        export:xml-item(concat('details.xq?evaluation-id=',$id),<options link="true" display="view details"/>),
        export:xml-item(concat('describe-document.xq?evaluation-id=',$id),<options link="true" display="step 1 - describe"/>),
        export:xml-item($id),
        export:xml-item($request/@evaluation-name)
        )
      )
    else ()
      
  return export:xml-output( ($headers, $items) )
  
};




local:main()