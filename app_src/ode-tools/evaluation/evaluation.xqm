xquery version "3.0" encoding "UTF-8";
(:   
 : Evaluation deliverable ODE II - Work Package 6- Amsterdam Municipality
 : Semi-generic functions used for evaluation only.
 :
 : Arjan Nusselder, May 13, 2014
 :)

module namespace evaluation="http://www.politicalmashup.nl/ode/tools/evaluation";

import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';

declare namespace local ="local";
declare namespace pmx = "http://www.politicalmashup.nl/extra";

(: Location of evaluation data collection. :)
declare variable $evaluation:data := '/db/apps/ode-tools/evaluation/data/';


(: Number of parsimonious terms to show. :)
declare variable $evaluation:terms-limit := 10;

(: Parsimonious w (lambda) to use. :)
declare variable $evaluation:terms-w := 0.1;

(: Parsimonious term part-of-speech to use. :)
declare variable $evaluation:terms-pos := 'all';

(: Some additional css rules. :)
declare variable $evaluation:style := '
      p{font-family:sans-serif;}
      div.get-options a{color:#444;text-decoration:none;}
      div.get-options a:hover{border-bottom:2px solid #444;}
      div.get-options span.active a{color:#444;border-bottom:2px solid #444;}
      div.get-options span.done a{border-top:2px solid #0a0;}
      div.get-options span.todo a{border-top:2px solid #a00;}
      div.get-options{border:2px dashed #aaa;border-left:none;border-right:none;}
      div.get-options p{color:#aaa;}
      div.search-form{margin:1em 0 0;}
      div.search-form textarea,div.search-form button{border:1px solid #666;vertical-align:top;margin:0;}
      div.search-form textarea{width:40%;height:50px;padding:5px;}
      div.search-form button{width:10%;height:62px;}
      div.single-document{border-bottom:2px dashed #aaa;}
      .eval-terms, .eval-terms p{color:#622;}
      .eval-entities p{color:#666;}
      .eval-entities, .eval-entities p a{color:#446;}
      .eval-entities a{text-decoration:none;}
      .eval-entities a:hover{text-decoration:underline;}
      .evaluation-description span {text-decoration:underline;}
      div.single-document div{display:inline-block;vertical-align:top;}
      div.single-document div.eval-terms{margin:0 0 0 6px;width:18em;}
      div.single-document div.eval-entities{margin:0;}
      span.button-update{color:#0a0;}
      
      p.radio-line{font-family:sans-serif;margin:0.5 0 0 0;padding:0;border-bottom:1px dashed #ccc;border-left:2px solid #fff;}
      p.radio-line input{vertical-align:bottom;}
      p.radio-line.selected{border-left:2px solid #444;}
      p.radio-line label:hover{border-bottom:1px solid #444;}
      p.radio-line.guessed{color:#aaa;}
      p.radio-line a{color:#448;text-decoration:none;}
      p.radio-line.guessed a{color:#aaa;}
      p.radio-line a:hover{text-decoration:underline;}
      ';


(:~
 : Get parsimonious terms from a source document.
 : 
 : @param $source-document document containing <pmx:clouds> wordcloud element.
 : @return Sequence of <term> elements.
 :)
declare function evaluation:source-terms($source-document as document-node()?) as element(term)* {
  $source-document//pmx:clouds/cloud[@pos eq $evaluation:terms-pos][xs:decimal(@w) eq $evaluation:terms-w]//term[position() le $evaluation:terms-limit]
};


(:~
 : Adaptation of the export:output-html() function.
 : 
 : @param $parts body content.
 : @param $title title of the output.
 : @param $style additional css style rules.
 : @return Full <html> document (without doctype headers).
 :)
declare function evaluation:output-html($parts as element()*, $title as xs:string, $style as xs:string) as element() {
  <html>
    <head>
      {if ($title ne '') then <title>{$title}</title> else ()}
      {export:html-css()}
      {if ($style ne '') then <style>{$style}</style> else ()}
    </head>
    <body>
      {$parts}
    </body>
  </html>
};


(:~
 : Load evaluation document containing the (current) results.
 : 
 : @param $request standard export:request() element.
 : @return document containing the currently requested evaluation information.
 :)
declare function evaluation:doc($request as element(request)) as document-node()? {
  if ($request/@evaluation-id) then
    doc(concat($evaluation:data,'/',$request/@evaluation-id,'.xml'))
  else ()
};


(:~
 : Load source document specified in the current evaluation + document-number.
 : 
 : @param $request standard export:request() element.
 : @return source document (<root>...</root>).
 :)
declare function evaluation:source-document($request as element(request)) as document-node()? {
  if ($request/@document-number) then
    let $eval-doc := evaluation:doc($request)
    let $document-id := $eval-doc//documents/document[@order eq $request/@document-number]/@id
    return
      if ($document-id) then doc(concat($settings:data-root,'/',$eval-doc//evaluation/@collection,'/',$document-id,'.xml'))
      else ()
  else ()
};


(:~
 : List of document-order numbers for a given evaluation, in order.
 : 
 : @param $eval-doc evaluation:doc() output.
 : @return ordered sequence of integers.
 :)
declare function evaluation:document-order-int($eval-doc) as xs:integer* {
  for $o in $eval-doc//document/@order let $int-o := xs:integer($o) order by $int-o return $int-o
};


(:~
 : List of document-order numbers for a given evaluation.
 : 
 : @param $eval-doc evaluation:doc() output.
 : @return sequence of strings.
 :)
declare function evaluation:document-order-string($eval-doc as document-node()?) as xs:string* {
  for $o in $eval-doc//document/@order return xs:string($o)
};


(:~
 : List of available evaluation ids, in order.
 : 
 : @return ordered sequence of strings.
 :)
declare function evaluation:ids() as xs:string* {
  for $i in collection($evaluation:data)//evaluation order by xs:integer($i/@id) ascending return xs:string($i/@id)
};


(:~
 : Create a list of document-number links + 'next' link.
 : Adaptation of export:html-util-generate-parameter-links().
 : 
 : @param $request export:request() element containing *only* the current active options/GET-parameters that should be included in the link.
 : @param $values the ordered list of integer values the document-number can (must) take.
 : @return HTML <div> element containing <a> links with specified GET parameters set.
 :)
declare function evaluation:document-number-links($request as element(request), $eval-doc as document-node()?, $check as xs:string) as element() {
  let $current-value := xs:integer($request/@document-number)
  let $target-values := evaluation:document-order-int($eval-doc)
  let $name := if ($check eq 'description') then 'Documents' else if ($check eq 'guessed-id') then 'Descriptions' else ()
  return
    <div class="get-options">
      <p>{$name}: | {
        
        (: Generate individual links. :)
        for $value in $target-values
        let $new-request := export:request-update($request, <request document-number="{$value}"/>)
        
        let $option-active := if ($value eq $current-value) then ' active' else ''
        let $option-status := if (normalize-space($eval-doc//document[@order eq xs:string($value)]/@*[name() eq $check]) ne '') then ' done' else ' todo'
        let $option-class := concat('option',$option-active,$option-status)
        
        return
          <span class="{$option-class}"> <a href="{export:request-to-get-string($new-request)}">{$value}</a> | </span>

        , (: Add 'next' link. :)
        if ( $current-value ne $target-values[last()] ) then
          let $next-request := export:request-update($request, <request document-number="{$current-value + 1}"/>)
          return <span class="option"> <a href="{export:request-to-get-string($next-request)}">next</a></span>
        else ()
        }
      </p>
    </div>
};

