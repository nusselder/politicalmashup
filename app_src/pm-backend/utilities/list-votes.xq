xquery version "1.0" encoding "UTF-8";
(:   
Deliverables for Amendment+Vote Project
Arjan Nusselder, June 20, 2012
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace pmutil="http://politicalmashup.nl/modules/util";

declare function local:matching-period($node, $date) {
    pmutil:date-in-range($date, $node/pm:period/@pm:from, $node/pm:period/@pm:till)
};


declare function pm:ob-parldoc-search-link($dossiernumber, $subnumber) {
  let $url := concat("https://zoek.officielebekendmakingen.nl/zoeken/resultaat/?zkt=Uitgebreid&amp;pst=ParlementaireDocumenten&amp;dpr=Alle&amp;spd=20120823&amp;epd=20120823&amp;dosnr=",$dossiernumber,"&amp;nro=",$subnumber,"&amp;kmr=EersteKamerderStatenGeneraal|TweedeKamerderStatenGeneraal|VerenigdeVergaderingderStatenGeneraal&amp;sdt=KenmerkendeDatum&amp;par=Agenda|Handeling|Kamerstuk|Aanhangsel+van+de+Handelingen|Kamervragen+zonder+antwoord|Niet-dossierstuk|Bijlage&amp;dst=Onopgemaakt|Opgemaakt|Opgemaakt+na+onopgemaakt&amp;isp=true&amp;pnr=1&amp;rpp=10")
  return $url
};

declare function pm:get-party-from-id-date-house($member-ref, $date, $house, $member-collection) {
  let $member := $member-collection[.//dc:identifier eq string($member-ref)]
  let $membership := $member//pm:membership[@pm:body eq $house][local:matching-period(., $date)]
  return $membership[1]/@pm:party-ref
};


declare function pm:xml-votes($col-proc, $legislative-period) {
  
  let $col-proc := $col-proc[.//pm:legislative-period eq $legislative-period]
  
  let $amendment-votes := $col-proc//pm:vote
  
  let $party-refs := for $p in distinct-values($amendment-votes//pm:organization/@pm:ref)[. ne ''] order by $p return $p
  
  (: TODO: string-join op alle votes van een partij, om dubbelen duidelijk te zien?
     might not be necessary, since nowhere the "first" is taken.. :) 
  
  let $column-names := export:xml-util-headers( ('house', 'legislative-period', 'session-number', 'date of vote', 'dossier nummer', 'onder nummer', 'type',
                                  'outcome', 'stemmings type', 'bron amendement op OB', 'link amendement HTML op PM', 'link stemming XML op PM',
                                  'link stemming in context HTML op PM', 'bron stemming op OB',
                                  for $party-ref in $party-refs return $party-ref,
                                  'indiener 1, naam volgens stemming', 'indiener 1, id volgens stemming', 'indiener 1, partij', 'indiener 2, naam volgens stemming',
                                  'indiener 2, id volgens stemming', 'indiener 2, partij', 'titel document volgens stemming') )
  
  let $description := export:xml-util-description( concat('Legislative period: ', $legislative-period) )
  
  (: Get member collection to match parties to submitters. :)
  let $member-collection := collection('/db/data/permanent/m/nl')
                                  
  let $items :=                                  
    for $vote in $amendment-votes
      let $root := root($vote)
      let $date := string($root//dc:date)
      let $house := string($root//pm:house/@pm:house)
      let $dossier-number := string-join(for $v in  $vote/pm:about/pm:information/pm:dossiernummer return string($v),';')
      let $sub-number := string-join(for $v in  $vote/pm:about/pm:information/pm:ondernummer return string($v),';')
      let $submitters-vote := $vote/pm:about/pm:information/pm:submitted-by/pm:actor/pm:person
      (:let $submitters-amendment := if ($vote/pm:about/@pm:doc-ref) then doc(concat('/db/data/permanent/d/nl/parldoc/',$vote/pm:about/@pm:doc-ref,'.xml'))//pm:block[@pm:type eq 'signed-by']//pm:tagged-entity else ():)
      order by $date
      return
        export:xml-row(
          (
          export:xml-item($root//pm:house/@pm:house),
          export:xml-item($root//pm:legislative-period),
          export:xml-item($root//pm:session-number),
          export:xml-item($date),
          export:xml-item($dossier-number),
          export:xml-item($sub-number),
          export:xml-item($vote/pm:about/@pm:voted-on),
          export:xml-item($vote/@pm:outcome, <options background="{if ($vote/@pm:outcome eq 'accepted') then '#afa' else '#faa'}"/>),
          export:xml-item($vote/@pm:vote-type),
          export:xml-item(if (not(matches($sub-number,'^[0-9]+$'))) then concat('https://zoek.officielebekendmakingen.nl/dossier/',$dossier-number) else concat('https://zoek.officielebekendmakingen.nl/kst-', $dossier-number,'-',$sub-number,'.html'), <options link="true"/>),
          export:xml-item(export:link-resolver($vote/pm:about/@pm:doc-ref,'html'), <options link="true"/>),
          export:xml-item(export:link-resolver($vote/@pm:id), <options link="true"/>),
          export:xml-item(export:link-resolver(root($vote)//dc:identifier, 'html', $vote/@pm:id), <options link="true"/>),
          export:xml-item($root//pm:link[@pm:linktype="html"]/@pm:source, <options link="true"/>),
          for $party-ref in $party-refs
            let $party-vote := $vote/pm:division/pm:actor[pm:organization/@pm:ref eq $party-ref]/@pm:vote
            return
              export:xml-item($party-vote, <options background="{if (count($party-vote) ne 1) then '#ccc' else if ($party-vote eq 'aye') then '#afa' else if ($party-vote eq 'no') then '#faa' else '#ccc'}"/>)
          ,
          export:xml-item($submitters-vote[1]/@pm:speaker),
          export:xml-item($submitters-vote[1]/@pm:member-ref),
          export:xml-item(pm:get-party-from-id-date-house($submitters-vote[1]/@pm:member-ref, $date, $house, $member-collection)),
          export:xml-item($submitters-vote[2]/@pm:speaker),
          export:xml-item($submitters-vote[2]/@pm:member-ref),
          export:xml-item(pm:get-party-from-id-date-house($submitters-vote[2]/@pm:member-ref, $date, $house, $member-collection)),
          export:xml-item($vote/pm:about/@pm:title)
          )
        )
        
  let $xml-output := export:xml-output( ($description, $column-names, $items) )  
  return $xml-output
};


let $col-proc := collection('/db/data/permanent/d/nl/proc/ob')

let $available-periods := export:data-util-legislative-periods($col-proc)

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <period accept="{string-join($available-periods,',')}"/>) )

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

let $xml-output := if ($request/@period) then pm:xml-votes($col-proc, string($request/@period)) else ()


let $links-to-overviews :=
    <div>
      { export:html-util-generate-parameter-links($request, 'view', ('table','csv')) }
      { export:html-util-generate-parameter-links($request, 'period', $available-periods) }
    </div>

let $output := if ($request/@view eq 'table') then ($links-to-overviews, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Votes')

return $output