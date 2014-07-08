xquery version "3.0" encoding "UTF-8";
(:   
ODE II, "Brandweer/Vergunningen" analysis.
Arjan Nusselder, January 07, 2014
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace folia = "http://ilk.uvt.nl/FoLiA";
declare namespace local = "local";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";


declare function local:select-collection($request) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()
};

declare function local:get-term($node, $as-lemma as xs:boolean) {
    if ($as-lemma) then $node/folia:lemma/@class else $node/folia:t
};


declare function local:count-terms($collection, $request as element(request)) {
  let $headers := (
    export:xml-util-description('Terms (token count per type)'),
    export:xml-util-headers( ('count','pos','term','search') )
    )
  
  let $lemma-tokens := $collection//folia:w
  let $pos-filters := tokenize($request/@pos-filters,'\|')
  let $lemma-tokens := $lemma-tokens[folia:pos/@class = $pos-filters]
  
  let $as-lemma := if ($request/@type eq 'lemma') then true() else false()

  let $counts :=
    for $l in $lemma-tokens
      let $lemma := local:get-term($l,$as-lemma)
      group by $lemma
      return <l l="{$lemma}" c="{count($l)}" p="{distinct-values(for $p in $l return $p/folia:pos/@class)}"/>
  
  let $items :=
    for $l in $counts
    let $query := concat('&quot;',$l/@l,'&quot;')
    order by xs:integer($l/@c) descending
    return
      export:xml-row(
        (
        export:xml-item($l/@c),
        export:xml-item($l/@p),
        export:xml-item($l/@l),
        export:xml-item(concat('demo-ode-folia-search.xq?query=',$query,'&amp;collection=d%2Fodebekm&amp;search=folia%3At&amp;limit=40'), <options display="{$query}" link="true" disable-quote-escape="true"/>)
        )
      )

  return export:xml-output( ($headers, $items) )
};


declare function local:count-bigrams($collection, $request as element(request)) {
  let $headers := (
    export:xml-util-description('Bigrams (token count per type)'),
    export:xml-util-headers( ('count','term','search') )
    )
  
  let $pos-filters := tokenize($request/@pos-filters,'\|')
  let $as-lemma := if ($request/@type eq 'lemma') then true() else false()

  (: Create dual words. :)
  let $bigrams :=
    for $s in $collection//folia:s
    let $ws := ($s/folia:w)[./folia:pos/@class = $pos-filters]
    return
      for $w at $pos in $ws[position() lt last()]
      return
          concat(local:get-term($w,$as-lemma),' ',local:get-term($ws[position() eq $pos+1],$as-lemma))

  (: Count :)
  let $counts :=
    for $b in $bigrams
      let $word := $b
      group by $word
      return <l l="{$word}" c="{count($b)}"/>
  
  
  let $items :=
    for $l in $counts
    let $query := string-join(tokenize($l/@l,' '),' AND ')
    order by xs:integer($l/@c) descending
    return
      export:xml-row(
        (
        export:xml-item($l/@c),
        export:xml-item($l/@l),
        export:xml-item(concat('demo-ode-folia-search.xq?query=',$query,'&amp;collection=d%2Fodebekm&amp;search=folia%3At&amp;limit=40'), <options display="{$query}" link="true"/>)
        )
      )

  return export:xml-output( ($headers, $items) )
};


declare function local:best-cloud-term($clouds as element(cloud)*) as xs:string? {
  local:best-cloud-term($clouds,'all')
};
declare function local:best-cloud-term($clouds as element(cloud)*, $pos as xs:string, $min as xs:decimal) as xs:string* {
  ($clouds[@pos eq $pos][xs:decimal(@w) eq 0.05]//term[string-length(.) ge 3])[xs:decimal(@prob) ge $min]
};
declare function local:best-cloud-term($clouds as element(cloud)*, $pos as xs:string) as xs:string? {
  ($clouds[@pos eq $pos][xs:decimal(@w) eq 0.05]//term[string-length(.) ge 3])[1]
};


declare function local:cloud-terms($collection, $request as element(request)) {
  let $headers := (
    export:xml-util-description('Top noun/verb from cloud per document.'),
    export:xml-util-headers( ('noun, verb','noun>0.4','verb>0.4','document') )
    )
  
  let $items :=
    for $doc in $collection
    let $doc-id := $doc//dc:identifier
    let $clouds := $doc//pmx:clouds/cloud
    let $top-noun := local:best-cloud-term($clouds,'N')
    let $top-verb := local:best-cloud-term($clouds, 'WW')
    let $best-nouns := local:best-cloud-term($clouds,'N', 0.4)
    let $best-verbs := local:best-cloud-term($clouds, 'WW', 0.4)
    return
      export:xml-row(
        (
        export:xml-item(concat($top-noun,' ',$top-verb)),
        export:xml-item(string-join($best-nouns,' / ')),
        export:xml-item(string-join($best-verbs,' / ')),
        export:xml-item(export:link-resolver($doc-id,'html'),<options link="true" display="{$doc-id}"/>)
        )
      )

  return export:xml-output( ($headers, $items) )
};





let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $count-queries := 'terms,bigrams,cloud-terms'

let $pos-filters := 'N,SPEC,TW,LET,WW,VZ,LID,VG,ADJ,BW,VNW,TSW'
let $default-pos-filters := 'N|SPEC|WW|ADJ|BW|VNW|TSW'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            <count default="terms" accept="{$count-queries}"/>,
                                            <type default="word" accept="word,lemma"/>,
                                            <pos-filters default="{$default-pos-filters}" accept="{$pos-filters}" tokenize-split="\|" tokenize-join="|"/>,
                                            <collection accept="{$accepted-collections}"/>) )

let $options := export:options( (
                                  <count explanation="choose example query" select="{$count-queries}"/>,
                                  <type explanation="collect original words, or lemmatisation" select="word,lemma"/>,
                                  <pos-filters explanation="count only these POS's (from N|SPEC|TW|LET|WW|VZ|LID|VG|ADJ|BW|VNW|TSW)"/>,
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>,
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>
                                ),
                                $request)


let $collection := local:select-collection($request)

let $xml-output := if ($request/@count eq 'terms') then local:count-terms($collection,$request)
                   else if ($request/@count eq 'bigrams') then local:count-bigrams($collection,$request)
                   else if ($request/@count eq 'cloud-terms') then local:cloud-terms($collection,$request)
                   else ()


let $introduction-html :=
    <div>
      <p>Analysis of official announcements.</p>
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'ODE-II FoLiA Demo Counts')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output