xquery version "1.0" encoding "UTF-8";
(:   
Analyses for proceedings data.
Arjan Nusselder, June 6, 2013
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";


declare function local:active-members-items($proceedings, $request) {

  let $do-count := if ($request/@count eq 'true') then true() else false()
  let $members := if ($do-count) then collection('/db/data/permanent/m/nl') else ()
  
  let $description := export:xml-util-description('Active speakers in given proceedings selection.')
  
  let $headers := export:xml-util-headers(('member-id', if ($do-count) then ('fullname','speeches','view resolver','analyse interruptions','download paragraphs','list scenes') else ()))
  
  let $item-data := distinct-values($proceedings//pm:speech/@pm:member-ref)
  
  let $items :=
    for $member-ref in $item-data
      
      return
        export:xml-row(
          (
          export:xml-item($member-ref),
          if ($do-count) then (
                               export:xml-item($members[.//dc:identifier eq $member-ref]//pm:member/pm:name/pm:full),
                               export:xml-item(count($proceedings//pm:speech[@pm:member-ref eq $member-ref])),
                               export:xml-item(export:link-resolver($member-ref,'html'),<options link="true"/>),
                               export:xml-item(concat('?memberid=',$member-ref,'&amp;period=',$request/@period,'&amp;periods=',$request/@periods,'&amp;house=',$request/@house,'&amp;action=member-interruptions'),<options link="true"/>),
                               export:xml-item(concat('?memberid=',$member-ref,'&amp;period=',$request/@period,'&amp;periods=',$request/@periods,'&amp;house=',$request/@house,'&amp;action=member-paragraphs'),<options link="true"/>),
                               export:xml-item(concat('?memberid=',$member-ref,'&amp;period=',$request/@period,'&amp;periods=',$request/@periods,'&amp;house=',$request/@house,'&amp;action=member-scenes'),<options link="true"/>)
                              )
          else ()
          )
        )
        
  return export:xml-output( ($description, $headers, $items) )
};



declare function local:member-paragraphs-items($proceedings, $request) {

  let $member-ref := string($request/@memberid)
  let $do-count := if ($request/@count eq 'true') then true() else false()
  
  let $description := export:xml-util-description( concat($member-ref,' : ',collection('/db/data/permanent/m/nl/')[.//dc:identifier eq $member-ref]//pm:member/pm:name/pm:full) )
  
  let $headers := export:xml-util-headers( (if ($do-count) then 'token count' else (), 'paragraph') )

  let $item-data := $proceedings//pm:speech[@pm:member-ref eq $member-ref]/pm:p
  
  let $items :=
    for $paragraph in $item-data
    return
      export:xml-row(
        (
          if ($do-count) then export:xml-item(count(tokenize($paragraph,'\s+'))) else (),
          export:xml-item($paragraph)
        )
      )

  return export:xml-output( ($description, $headers, $items) )      
};



declare function local:member-scenes-items($proceedings, $request) {

  let $member-ref := string($request/@memberid)
  let $do-count := if ($request/@count eq 'true') then true() else false()
  
  let $description := export:xml-util-description( concat($member-ref,' : ',collection('/db/data/permanent/m/nl/')[.//dc:identifier eq $member-ref]//pm:member/pm:name/pm:full) )
  
  let $headers := export:xml-util-headers( ('scene', if ($do-count) then ('speeches', 'own speeches') else ()) )

  let $item-data := $proceedings//pm:scene[@pm:member-ref eq $member-ref]
      
  let $items :=
    for $scene in $item-data
    return
      export:xml-row(
        (
          export:xml-item(export:link-resolver($scene/@pm:id,'html'),<options link="true"/>),
          if ($do-count) then (
            export:xml-item(count($scene/pm:speech)),
            export:xml-item(count($scene/pm:speech[@pm:member-ref eq $member-ref]))
            ) else ()
        )
      )

  return export:xml-output( ($description, $headers, $items) )
};



declare function local:member-interruptions-items($proceedings, $request) {

  (:let $member-ref := string($request/@memberid):)
  let $member-refs := tokenize($request/@memberid, '\|')
  let $do-count := if ($request/@count eq 'true') then true() else false()

  let $description := export:xml-util-description('Number of interruptions.')
  
  (:let $headers := export:xml-util-headers(('member-id', if ($do-count) then 'speeches' else ())):)
  let $headers := export:xml-util-headers(('member-id', 'name', 'party', 'legislative-period',
                                           'interruptions-total', 'interruptions-unique', 'interruptions-unique-persons', 'interrupted-total', 'interrupted-unique', 'interrupted-unique-persons', 'interrupted-scenes',
                                           'scenes',
                                           if ($do-count) then ('speeches', 'paragraphs', 'tokens', 'topics-with-scene', 'topics-with-speech') else (),
                                           'link'
                                           ))

  let $periods := local:determine-input-periods($request)
  
  let $items :=
    for $member-ref in $member-refs
    return
      for $period in $periods
        let $period-proceedings := $proceedings[.//pm:legislative-period eq $period]
        return local:member-interruptions-member-period-items($period-proceedings, $member-ref, $do-count, $period)

  return export:xml-output( ($description, $headers, $items) )
};



declare function local:member-interruptions-member-period-items($proceedings, $member-ref, $do-count, $period) {
  let $name := $proceedings//pm:speech[@pm:member-ref eq $member-ref]
  let $party := ($name/@pm:party)[1]
  let $name := ($name/@pm:speaker)[1]

  let $scenes-with-self-as-interruptor := $proceedings//pm:scene[@pm:member-ref ne $member-ref and pm:speech[@pm:member-ref eq $member-ref and not(@pm:role eq 'chair')]]
  
  (: Sequence of all speeches (pm:speech) by others. Count gives total. :)
  let $interruptions-total := $scenes-with-self-as-interruptor/pm:speech[@pm:member-ref eq $member-ref][@pm:role ne 'chair']

  (: Scenes wherein member-ref interrupted. Also equals unique interruptions. :)
  let $interruptions-unique := count($scenes-with-self-as-interruptor)
  
  (: Unique persons which member-ref interrupted. :)
  let $interruptions-unique-persons := count(distinct-values($scenes-with-self-as-interruptor/@pm:member-ref))
  
  (: Make a total count. :)
  let $interruptions-total := count($interruptions-total)


  let $scenes-from-self := $proceedings//pm:scene[@pm:member-ref eq $member-ref]
  
  (: Sequence of all non-chair speeches (pm:speech) by others. Count gives total. :)
  let $interrupted-total := $scenes-from-self/pm:speech[@pm:member-ref ne $member-ref][@pm:role ne 'chair']
  
  (: Sequence of all non-chair speeches (pm:speech) by others. Count gives total. :)
  let $interrupted-scenes := count($scenes-from-self[pm:speech[@pm:member-ref ne $member-ref][@pm:role ne 'chair']])
  
  (: Unique person by whom member-ref was interrupted. :)
  let $interrupted-unique-persons := count(distinct-values($interrupted-total/@pm:member-ref))
  
  (: Make total a count. :)
  let $interrupted-total := count($interrupted-total)
  
  (: Sequence of unique interuptors (@pm:member-ref) per scene. Sum gives total. :)
  let $interrupted-unique := sum(
                               for $scene in $scenes-from-self
                               return count(distinct-values($scene/pm:speech[@pm:member-ref ne $member-ref][@pm:role ne 'chair']/@pm:member-ref))
                               )  
  
  
  (: Additionally count speeches, paragraphs and tokens, if requested. :)
  let $speeches := if ($do-count) then $proceedings//pm:speech[@pm:member-ref eq $member-ref] else ()
  let $paragraphs := $speeches/pm:p
  let $tokens := sum( for $p in $paragraphs return count(tokenize($p,'\s+')) )
  
  let $item-data := distinct-values($proceedings//pm:speech/@pm:member-ref)
  
  let $items :=
    export:xml-row(
      (
        export:xml-item($member-ref),
        export:xml-item($name),
        export:xml-item($party),
        export:xml-item($period),
        
        export:xml-item($interruptions-total),
        export:xml-item($interruptions-unique),
        export:xml-item($interruptions-unique-persons),
        
        export:xml-item($interrupted-total),
        export:xml-item($interrupted-unique),
        export:xml-item($interrupted-unique-persons),
        export:xml-item($interrupted-scenes),
        
        export:xml-item(count($scenes-from-self)),
        
        if ($do-count) then (export:xml-item(count($speeches)),
                             export:xml-item(count($paragraphs)),
                             export:xml-item($tokens),
                             export:xml-item(count($proceedings//pm:topic[pm:scene[@pm:role ne 'chair' and @pm:member-ref eq $member-ref]])),
                             export:xml-item(count($proceedings//pm:topic[.//pm:speech[@pm:role ne 'chair' and @pm:member-ref eq $member-ref]]))
                            )
        else (),
        
        export:xml-item(export:link-resolver($member-ref,'html'),<options link="true"/>)
      )
    )
    
  return $items
};

declare function local:determine-input-periods($request) {
  if (empty($request/@periods) and empty($request/@period)) then ()
  else if ($request/@periods) then tokenize($request/@periods, '\|')
  else (string($request/@period))
};


declare function local:restrict-proceedings($proceedings, $request) {

  let $periods := local:determine-input-periods($request)

  let $proceedings :=
    if (empty($request/@action) or empty($periods)) then ()
  
    else if ($request/@action = ('member-paragraphs','member-interruptions','member-scenes') and empty($request/@memberid)) then ()
    
    else
      (: Multiple period possible, use '='. :)
      $proceedings[.//pm:legislative-period = $periods]
    
  let $proceedings :=
    if (contains($request/@house,'|')) then
      $proceedings
    else
      $proceedings[.//pm:house/@pm:house eq string($request/@house)]
      
  return $proceedings
};
    



let $proceedings := collection('/db/data/permanent/d/nl/proc/ob')

let $available-periods := string-join(export:data-util-legislative-periods($proceedings),',')

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            <action accept="active-members,member-paragraphs,member-interruptions,member-scenes"/>,
                                            <memberid tokenize-split="\|" tokenize-join="|"/>,
                                            <period accept="{$available-periods}"/>,
                                            <periods accept="{$available-periods}" tokenize-split="\|" tokenize-join="|"/>,
                                            <count default="false" accept="true,false"/>,
                                            <house default="commons|senate" accept="commons,senate" tokenize-split="\|" tokenize-join="|"/>) )


let $proceedings := local:restrict-proceedings($proceedings, $request)

let $options := export:options( (
                                  <action explanation="select an analysis" select="active-members,member-paragraphs,member-interruptions,member-scenes"/>,
                                  <memberid explanation="member-id of the person whose paragraph are selected, or multiple separated with '|' (only for interruptions)"/>,
                                  <period explanation="legislative period" select="{$available-periods}"/>,
                                  <periods explanation=".. or override single period with mutilple, as '2012-2013|2011-2012' (can take some time..)"/>,
                                  <count explanation="count some additional things" select="true,false"/>,
                                  <house explanation="commons, senate or both commons|senate" select="commons,senate,commons|senate"/>
                                ),
                                $request)

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

let $xml-output :=
  if ($request/@action eq 'active-members') then local:active-members-items($proceedings, $request)
  
  else if ($request/@action eq 'member-paragraphs') then local:member-paragraphs-items($proceedings, $request)
  
  else if ($request/@action eq 'member-interruptions') then local:member-interruptions-items($proceedings, $request)
  
  else if ($request/@action eq 'member-scenes') then local:member-scenes-items($proceedings, $request)
    
  else ()


let $search-form := export:html-util-generate-search-form($options, $request)

let $links-to-overviews :=
    <div>
      { export:html-util-generate-parameter-links($request, 'view', ('table','csv')) }
    </div>

let $output := if ($request/@view eq 'table') then ($links-to-overviews, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Member speech activity analysis')

return $output