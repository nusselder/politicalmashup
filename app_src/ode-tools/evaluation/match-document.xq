xquery version "3.0" encoding "UTF-8";
(:   
 : Evaluation deliverable ODE II - Work Package 6- Amsterdam Municipality
 : Step 2: form to match document to description.
 :
 : Arjan Nusselder, May 13, 2014
 :)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";

import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation" at "evaluation.xqm";

(: tmp load settings to test pdf link :)
import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';


declare function local:main() { 

  (: Limit evaluation ids to those existing. :)
  let $accepted-evaluation-ids := string-join(evaluation:ids(),",")
  
  let $request-evaluation-id := <evaluation-id type="xs:integer" accept="{$accepted-evaluation-ids}"/>
  let $request-guessed-id := <guessed-id/>
  
  (: Get evaluation-id, check acceptable document numbers. :)
  let $request := export:request-parameters( $request-evaluation-id )
  let $eval-doc := evaluation:doc($request)
  let $accepted-document-numbers := string-join(evaluation:document-order-string($eval-doc),",")
  let $request-document-number := <document-number type="xs:integer" accept="{$accepted-document-numbers}" default="1"/>
  
  (: GET information. :)
  let $request := export:request-parameters( ($request-evaluation-id, $request-document-number, $request-guessed-id) )

  (: Update the evaluation data document, if applicable. :)
  let $updated := local:update-evaluation($request, $eval-doc)

  (: Generate links to documents. :)
  let $link-request := export:request-parameters( ($request-evaluation-id, $request-document-number) )
  let $document-number-links := evaluation:document-number-links($link-request, $eval-doc, 'guessed-id')

  (: Join body content. :)
  let $body-html :=
    <div>
      <div class="evaluation-description">
        <h2>Match documents to descriptions</h2>
        <p>Presented below are a <span style="background:#ddd;text-decoration:none;">short description</span>, and a <span style="border-bottom:1px dashed #ccc;text-decoration:none;">list of documents</span>. In total, there are ten descriptions and ten documents.<br/>
           You are asked to select, for each description, the document that best matches that description.</p>
        <p>Each document is listed with a number, the option to select it, a link to view the document, and a notification for which description it was picked.<br/>
           Before answering the questions, please quickly read through each of the ten documents presented below.</p>
      </div>
      <div class="evaluation-form">
        {$document-number-links}
        {local:description-form($request, $updated)}
      </div>
    </div>

      
  (: Finalise html output. :)
  let $output := evaluation:output-html($body-html, 'Evaluation / step 2 - match documents.', $evaluation:style)
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
    <p style="min-height:4em;width:55%;background:#ddd;padding:1em 0;margin-bottom:0;">{xs:string($document/@description)}</p>
    <button type="submit" style="width:55%;height:30px;">Update Selection {$updated}</button>
    {
    (: From export function, bit overkill.. :)
    for $option in $request/@*[name() ne 'guessed-id']
    let $name := $option/name()
    where empty($options/*[name() eq $name])
    return
       <input name="{$name}" type="hidden" value="{$option}"/>
    }
    {local:display-single-document($request)}
  </form>
  </div>
};


declare function local:update-evaluation($request, $eval-doc) {

  let $updateable := if ($request/@document-number and $request/@guessed-id) then $eval-doc//documents/document[xs:integer(@order) eq xs:integer($request/@document-number)] else ()
  
  return
    if ($updateable) then
      let $null := update value $updateable/@guessed-id with $request/@guessed-id
      return <span class="button-update">*updated*</span>
    else ()
};


declare function local:display-single-document($request) {

  let $document-number := xs:integer($request/@document-number)

  let $eval-doc := doc(concat($evaluation:data,'/',$request/@evaluation-id,'.xml'))
  
  let $guessed-document-of-current-active := xs:string($eval-doc//document[xs:integer(@order) eq xs:integer($request/@document-number)]/@guessed-id)
  let $guessed-document-of-current-active := if ($guessed-document-of-current-active eq '') then () else $guessed-document-of-current-active
  
  let $document := $eval-doc//documents/document[xs:integer(@order) eq $document-number]
  
  return
    <div class="single-document">
      {
      for $d in $eval-doc//documents/document
      
      (: Is this document selected for the currently shown description? :)
      let $selected := if ($guessed-document-of-current-active and $guessed-document-of-current-active eq $d/@id) then attribute {'checked'} {'checked'} else ()
      
      (: Has this document been picked for another description? :)
      let $guessed-for := $eval-doc//document[@guessed-id eq xs:string($d/@id)]/@order
      let $guessed-for := if ($guessed-for) then string-join($guessed-for,', ') else ()
      
      (: Some style signifier. :)
      let $class-status := if ($selected) then ' selected' else if ($guessed-for) then ' guessed' else ()

      (: Radio option output. :)
      let $radio-input := <input type="radio" name="guessed-id" value="{$d/@id}" id="gi-l{$d/@order}">{$selected}</input>
      let $radio-label := <label for="gi-l{$d/@order}"><span style="display:inline-block;width:1.4em;text-align:right;">{xs:string($d/@random-order)}</span> | select</label>
      (:let $radio-view-document-link := <a href="../../resolver/{$d/@id}?view=entities">view</a>:)
      
      let $view-resolver := <a href="../../resolver/{$d/@id}?view=entities">resolver</a>
      let $view-simple := <a href="view-document.xq?evaluation-id={$request/@evaluation-id}&amp;from-document={$request/@document-number}&amp;view-document={$d/@random-order}">simple</a>
      let $source-document := doc(concat($settings:data-root,'/',$eval-doc//evaluation/@collection,'/',$d/@id,'.xml'))
      let $view-pdf := <a href="{$source-document//dc:source/pm:link[@pm:linktype eq 'pdf']/@pm:source}">pdf</a>
      let $radio-view-document-link := <span>{$view-simple}, {$view-pdf}</span>

      (: Order by the generated random order, as opposed to the normal order of the descriptions. :)
      order by xs:integer($d/@random-order)
      
      (: Return a single line for each document option. :)
      return
        <p class="radio-line{$class-status}">{$radio-input} {$radio-label} | {$radio-view-document-link} | picked for description: {$guessed-for}</p>
      }
    </div>
};


local:main()

