(: 
Author: Arjan Nusselder
Date : April 2012
Purpose: Show overviews of party seats distributions for easy validation.

(GET) Parameters
col = see collections.xqm (: old, just see within code :) only nl-members makes any sense
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace util="http://exist-db.org/xquery/util"; 
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace datetime="http://exist-db.org/xquery/datetime";
import module namespace sequences = "http://exist-db.org/xquery/sequences";

(:import module namespace collections="http://parliament.politicalmashup.nl/modules/collections" at "xmldb:exist:///db/modules/collections.xqm";:)
import module namespace pmutil="http://politicalmashup.nl/modules/util";


declare variable $col := (
                        let $input := request:get-parameter('col',"")  
                        return if (string-length($input)) then $input else ''  
                        );                        
                        
declare variable $house := (
                        let $input := request:get-parameter('house',"")  
                        return if (string-length($input)) then $input else ''  
                        );
                        
declare variable $partyref := (
                        let $input := request:get-parameter('partyref',"")  
                        return if (string-length($input)) then $input else ''  
                        );


(:~
 : Retrieve the list of memberships for a given house and party.
 : 
 : @param $collection collection of member documents/elements to search in
 : @param $house typically 'commons' or 'senate'
 : @param $party-ref valid party identifier
 : @return Sequence of <pm:membership> elements
 :)
declare function local:member-seats-for-party($collection, $house, $party-ref) {
  $collection//pm:membership[@pm:body eq $house and @pm:party-ref eq $party-ref]
};


(:~
 : Find the extent of the date-range for which the party has member-seats.
 : 
 : @param $member-seats sequence of <pm:membership> elements.
 : @return <result @start="" @end=""/>
 :)
declare function local:member-seats-date-range($member-seats) {
  let $start-dates := distinct-values($member-seats/pm:period/@pm:from)
  let $end-dates := distinct-values($member-seats/pm:period/@pm:till)
  let $start-date := (for $d in $start-dates order by $d return $d)[1]
  let $end-date := if (contains($end-dates,'present')) then 'present' else (for $d in $end-dates order by $d return $d)[last()]
  return
    <result start="{$start-date}" end="{$end-date}"/>
};


(:~
 : Create list of dates from start till end.
 : 
 : @param $start start at this date
 : @param $end stop at this date
 : @return list if iso-string-dates
 :)
declare function local:create-dates-range($start, $end) {
  let $end := if ($end eq 'present') then current-date() else $end
  let $iterations := days-from-duration(xs:date($end) - xs:date($start))
  return datetime:date-range(xs:date($start), xdt:dayTimeDuration('P1D'), $iterations)
};





(:~
 : Create difference list of seats changes.
 : 
 : @param $member-seats sequence of <pm:membership> elements.
 : @param $dates-range sequence of xs:date's
 : @return Sequence of <pm:membership> elements
 :)
declare function local:member-seats-diff-list($member-seats, $dates-range) {
  let $starts := $member-seats/pm:period/@pm:from
  let $ends := $member-seats/pm:period/@pm:till[not(. eq 'present')]
  let $cnt-sequence :=
    for $date at $pos in $dates-range
      (: Some joined the the house for the party if today is its first day, i.e. today is in starts. :)
      (: Some left the the house for the party if yesterday was its last day, i.e. yesterday is in starts. :)
      let $string-date := string($date)
      let $string-date-prev := string($dates-range[($pos - 1)])
      let $started := count($starts[. eq $string-date])
      let $ended := count($ends[. eq $string-date-prev])
      return $started - $ended
  return $cnt-sequence
};






declare function local:create-seats-setup($diffs, $dates) {
(: There is some discrepancy in the code, cause the last xs:date to be one less than the current date.. TODO: find and fix. -1day now used to create 'present' for final seats. :)
  let $final-date := if (xs:date($dates[last()]) eq current-date() - xdt:dayTimeDuration('P1D')) then 'present' else $dates[last()]
  let $seats-start :=
    for $i in (1 to count($diffs))
      return
        if ($diffs[$i] ne 0) then
          <seats seats="{sum($diffs[position() le $i])}" start-date="{$dates[$i]}"/>
        else ()
  let $seats-full :=
    for $s at $pos in $seats-start
      let $nextpos := $pos + 1
    
      let $end-date := if ($seats-start[$nextpos]) then xs:date($seats-start[$nextpos]/@start-date) - xdt:dayTimeDuration('P1D') else $final-date
    (: let $iterations := days-from-duration(xs:date($end) - xs:date($start))
  return datetime:date-range(xs:date($start), xdt:dayTimeDuration('P1D'), $iterations) :)
      return
        <seats seats="{$s/@seats}" start-date="{$s/@start-date}" end-date="{$end-date}"/>
  let $diff-rep := for $x at $pos in $diffs where $x ne 0 return concat(string($dates[$pos]), ": ", string($x))
  return (<diff>{string-join($diff-rep, ", ")}</diff>, $seats-full)
};


(: Copy of old collections function. :)
(:declare function collections:collection-from-colcode($colcode) {:)
declare function local:collection-from-colcode($colcode) {
  if ($colcode ='nl') then '/db/data/permanent/d/nl/proc' else
  if ($colcode ='nl-ob') then '/db/data/permanent/d/nl/proc/ob' else
  if ($colcode ='nl-sgd') then '/db/data/permanent/d/nl/proc/sgd' else
  if ($colcode ='be-vln') then '/db/data/permanent/d/be/proc/vln' else
  if ($colcode ='se') then '/db/data/permanent/d/se/proc' else
  if ($colcode ='dk') then '/db/data/permanent/d/dk/proc' else
  
  if ($colcode ='nl-party') then '/db/data/permanent/p/nl' else
  if ($colcode ='nl-member') then '/db/data/permanent/m/nl' else
  (: old :)
  if ($colcode ='no') then '/db/data/permanent/d/proceedings/no' else
  if ($colcode ='es') then '/db/data/permanent/d/proceedings/es' else
  if ($colcode ='uk') then '/db/data/permanent/d/proceedings/uk' else
  ''  
};



declare function local:results($col, $house, $partyref) {
  let $collection := collection(local:collection-from-colcode($col))
  let $member-seats := local:member-seats-for-party($collection, $house, $partyref)
  let $start-end-date := if ($member-seats) then local:member-seats-date-range($member-seats) else ()
  let $dates-range := if ($member-seats) then local:create-dates-range($start-end-date/@start, $start-end-date/@end) else ()
  let $diff-list := if ($member-seats) then local:member-seats-diff-list($member-seats, $dates-range) else ()
  let $result-set := if ($member-seats) then local:create-seats-setup($diff-list, $dates-range) else ()
  return $result-set
};


(: collections :)


let $options :=
  <options>
    <col type="get">{$col}</col>
    <house type="get">{$house}</house>
    <partyref type="get">{$partyref}</partyref>
  </options>

let $result-set := if ($col ne '' and $house ne '' and $partyref ne '') then local:results($col, $house, $partyref) else ()

return
  <result count="{count($result-set)}">
    {$options}
    <seats-for-party>
      {$result-set}
    </seats-for-party>
  </result>