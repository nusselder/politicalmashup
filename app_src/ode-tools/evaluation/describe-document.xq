xquery version "3.0" encoding "UTF-8";
(:   
 : Evaluation deliverable ODE II - Work Package 6- Amsterdam Municipality
 : Step 1: form to describe documents based on terms/entities.
 :
 : Arjan Nusselder, May 13, 2014
 :)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";

import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation" at "evaluation.xqm";
 


declare function local:main() { 

  (: Limit evaluation ids to those existing. :)
  let $accepted-evaluation-ids := string-join(evaluation:ids(),",")
  
  let $request-evaluation-id := <evaluation-id type="xs:integer" accept="{$accepted-evaluation-ids}"/>
  let $request-description := <description/>
  
  (: Get evaluation-id, check acceptable document numbers. :)
  let $request := export:request-parameters( $request-evaluation-id )
  let $eval-doc := evaluation:doc($request)
  let $accepted-document-numbers := string-join(evaluation:document-order-string($eval-doc),",")
  let $request-document-number := <document-number type="xs:integer" accept="{$accepted-document-numbers}" default="1"/>
  
  (: GET information. :)
  let $request := export:request-parameters( ($request-evaluation-id, $request-document-number, $request-description) )

  (: Update the evaluation data document, if applicable. :)
  let $updated := local:update-evaluation($request, $eval-doc)

  (: Generate links to documents. :)
  let $link-request := export:request-parameters( ($request-evaluation-id, $request-document-number) )
  let $document-number-links := evaluation:document-number-links($link-request, $eval-doc, 'description')

  (: Join body content. :)
  let $body-html :=
    <div>
      <div class="evaluation-description">
        <h2>Describe documents</h2>
        <p>Below a summary of a document is given by a set of <span class="eval-terms">distinctive terms</span> (left), and a list of <span class="eval-entities">entities</span> with their occurences (right).<br/>
           The most distinctive term has the largest size. Entities link to their respective Wikipedia page.</p>
        <p>Please write a two sentence description of what you think the document is about, given the below terms and entities.</p>
      </div>
      <div class="evaluation-form">
        {$document-number-links}
        {local:description-form($request, $updated)}
        {local:display-single-document($request)}
      </div>
    </div>
    
      
  (: Finalise html output. :)
  let $output := evaluation:output-html($body-html, 'Evaluation / step 1 - describe documents.', $evaluation:style)
  let $serialization := export:set-serialization( 'html' )
  return $output
};


declare function local:description-form($request as element(request), $updated) as element() {

  let $eval-doc := doc(concat($evaluation:data,'/',$request/@evaluation-id,'.xml'))
  let $document := $eval-doc//documents/document[position() eq xs:integer($request/@document-number)]
  
  (: Construct options to show in the form, being empty except for hidden request options. :)
  let $options := export:options( (), $request)
  
  return
  <div class="search-form">
  <form method="get" action="">
    <textarea name="description">{xs:string($document/@description)}</textarea>
    <button type="submit">Update Description {$updated}</button>
    {
    (: From export function, bit overkill.. :)
    for $option in $request/@*[name() ne 'description']
    let $name := $option/name()
    where empty($options/*[name() eq $name])
    return
       <input name="{$name}" type="hidden" value="{$option}"/>
    }
  </form>
  </div>
};





declare function local:update-evaluation($request, $eval-doc) {

  let $updateable := if ($request/@document-number and $request/@description) then $eval-doc//documents/document[position() eq xs:integer($request/@document-number)] else ()
  
  return
    if ($updateable) then
      let $null := update value $updateable/@description with $request/@description
      return <span class="button-update">*updated*</span>
    else ()
};



declare function local:display-single-document($request) {

  let $source := evaluation:source-document($request)
  
  let $cloud-terms := evaluation:source-terms($source)
  
  (: Show terms in decreasing size, regardless of actual probabilities. :)
  let $terms := for $term at $pos in $cloud-terms return <span style="font-size:{200-(10*$pos)}%">{xs:string($term)}<br/></span>
  
  (: Show wikis. :)
  let $wikis := for $wiki in $source//dc:relation/pm:link[@pmx:linktype eq 'named-entity'] order by xs:integer($wiki/@pmx:entity-occurence) descending
                return <span><a href="{$wiki}" style="color:#446;">{util:unescape-uri(substring-after($wiki,'/wiki/'),'UTF-8')}</a> ({xs:string($wiki/@pmx:entity-occurence)})<br/></span>
  
  return
    <div class="single-document">
      <div class="eval-terms"><h4>terms</h4><p>{$terms}</p></div>
      <div class="eval-entities"><h4>entities</h4><p>{$wikis}</p></div>
    </div>
};



local:main()
