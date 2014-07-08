xquery version "3.0" encoding "UTF-8";
(:   
Evaluation deliverable ODE II - Work Package 6- Amsterdam Municipality
Arjan Nusselder, May 13, 2014
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace folia = "http://ilk.uvt.nl/FoLiA";
declare namespace local ="local";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";

import module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation" at "evaluation.xqm";
 


declare function local:main() {

  (: Allow all collections? :)
  let $accepted-collections := string-join(export:build-collection-tree(true()),',')
  
  (: What do we do. :)
  let $accepted-actions := "create new evaluation,describe documents,match documents,view results,list evaluations" 

  let $accepted-ids := string-join(for $i in collection($evaluation:data)//evaluation order by xs:integer($i/@id) ascending return xs:string($i/@id),",")

  (: Query requested information. :)
  let $request := export:request-parameters( (<view default="table" accept="table"/>,
                                              <evaluation-id accept="{$accepted-ids}"/>,
                                              <submit default="no" accept="no,yes"/>
                                              ) )

  (: Construct options to show in the form. :)
  let $options := export:options( (<evaluation-id explanation="which evaluation to view" select="{$accepted-ids}"/>,
                                   <submit explanation="are you sure you want to view all details?" select="no,yes"/>
                                  ), $request)

let $xml-output := if ($request/@submit eq 'yes') then local:display-details($request) else ()


let $introduction-html :=
    <div>
      <p>Display all details on an evaluation. To view, set submit to "yes" (don't look at the details if you are supposed to participate in that evaluation).</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, '(Post) evaluation details.')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output


};


(: Select the appropriate document collection. :)
declare function local:select-collection($request as element(request)) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()
};


(: Display documents :)
declare function local:display-details($request) {

  let $eval-doc := doc(concat($evaluation:data,'/',$request/@evaluation-id,'.xml'))

  let $headers := (
    export:xml-util-description('Evaluation of document summaries.'),
    export:xml-util-headers( ('match', 'two sentence description', 'terms', 'entities', 'id', 'guessed id') )
    )
  
  let $items :=
    for $document in $eval-doc//document
    let $id := $document/@id
    let $guessed-id := $document/@guessed-id
    
    (: Document descriptors. :)
    let $source := doc(concat($settings:data-root,'/',$eval-doc//evaluation/@collection,'/',$id,'.xml'))
  
    let $cloud-terms := evaluation:source-terms($source)
  
    (: Show terms in decreasing size, regardless of actual probabilities. :)
    let $terms := for $term at $pos in $cloud-terms return <span style="font-size:{200-(10*$pos)}%">{xs:string($term)}<br/></span>
  
    (: Show wikis. :)
    let $wikis := for $wiki in $source//dc:relation/pm:link[@pmx:linktype eq 'named-entity'] order by xs:integer($wiki/@pmx:entity-occurence) descending
                  return <span><a href="{$wiki}" style="color:#446;">{util:unescape-uri(substring-after($wiki,'/wiki/'),'UTF-8')}</a> ({xs:string($wiki/@pmx:entity-occurence)})<br/></span>
    
    return
      export:xml-row(
        (
        export:xml-item(if ($id eq $guessed-id) then 'equal' else 'not equal', <options background="{if ($id eq $guessed-id) then '#afa' else '#faa'}"/>),
        export:xml-item(<span style="color:#622;font-family:sans-serif;">{$terms}</span>, <options copy="true"/>),
        export:xml-item(<span style="color:#446;font-family:sans-serif;">{$wikis}</span>, <options copy="true"/>),
        export:xml-item(<span style="font-family:sans-serif;font-size:120%;margin:0 5px;display:inline-block;width:15em;">{xs:string($document/@description)}</span>, <options copy="true"/>),
        export:xml-item(concat('../../resolver/',$id,'?view=entities'),<options link="true" display="{$id}"/>),
        export:xml-item(export:link-resolver($guessed-id,'entities'),<options link="true" display="guess"/>)
        )
      )
      
  return export:xml-output( ($headers, $items) )

};




local:main()
