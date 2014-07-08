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
declare namespace folia = "http://ilk.uvt.nl/FoLiA";

import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation" at "evaluation.xqm";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';


declare function local:main() { 

  (: Limit evaluation ids to those existing. :)
  let $accepted-evaluation-ids := string-join(evaluation:ids(),",")
  
  (: GET information. :)
  let $request := export:request-parameters( (<evaluation-id type="xs:integer" accept="{$accepted-evaluation-ids}"/>, <view-document type="xs:integer"/>, <from-document type="xs:integer"/>) )
  
  let $link-back := if ($request/@from-document) then <p><a href="match-document.xq?evaluation-id={$request/@evaluation-id}&amp;document-number={$request/@from-document}">back</a></p> else ()
  
  (: Get evaluation-id, check acceptable document numbers. :)
  let $eval-doc := evaluation:doc($request)

  let $source-document-id := $eval-doc//documents/document[@random-order eq $request/@view-document]/@id
  let $source-document := doc(concat($settings:data-root,'/',$eval-doc//evaluation/@collection,'/',$source-document-id,'.xml'))
  
  (:let $pdf-link := <p><a href="{$source-document//dc:source/pm:link[@pm:linktype eq 'pdf']/@pm:source}">pdf</a></p>:)
  let $pdf-link := ()

  (: Join body content. :)
  let $body-html :=
    <div>
      <div class="evaluation-description">
        {$pdf-link}
        {$link-back}
        <h2>Document {xs:string($request/@view-document)}</h2>
        <div>
          {
          for $s in $source-document//folia:s
          return <p style="font-size:12px;border:1px solid #eee;">{normalize-space($s/folia:t)}</p>
          }
        </div>
      </div>
    </div>
    
      
  (: Finalise html output. :)
  let $output := evaluation:output-html($body-html, 'Evaluation / step 2 - read documents.', $evaluation:style)
  let $serialization := export:set-serialization( 'html' )
  return $output
};

local:main()
