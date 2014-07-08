xquery version "1.0" encoding "UTF-8";
(:~
 :
 : @author Arjan Nusselder
 : @since  March 9 2012
 : @version 1.2
 :
 : Last update: July 12, 2013
 :
 : This script is used by al dutch transformations to identify people. It is as such one of the most important scripts
 : and should always remain functioning. Do not break this script!!
 :
 : Given an input string with a name (currently possible: "lastname", "firstname lastname", "initials lastname"),
 : the name is mapped to a set of candidate members. These candidates are then filtered based on the other
 : arguments (party, house, date etc.) to uniquely identify a single person.
 : Results with one member (count="1") can be seen as a successful; results with zero or more than one member
 : can be seen as failed (e.g. non-found, or inconclusive).
 :
 : N.B. This script is not intended, not optimised, and not useful as a way to generate possible candidates
 : given a string. See for instance the autocomplete script functionality for these uses. 
 :)


import module namespace pmutil="http://politicalmashup.nl/modules/util";

import module namespace export="http://politicalmashup.nl/modules/export";


declare namespace pm="http://www.politicalmashup.nl";
declare namespace ft="http://exist-db.org/xquery/lucene";


(:~
 : Does a node match a specific date (based on contained pm:period element).
 : 
 : @param $node should typically be a pm:function of pm:membership element.
 : @param $date a string castable as xs:date.
 : @return true or false.
 :)
declare function local:matching-period($node, $date) {
    pmutil:date-in-range($date, $node/pm:period/@pm:from, $node/pm:period/@pm:till)
};


(:~
: TODO: maybe also make functions that calculates distance per period, and then orders (to rank people that have been inactive for a while)?
: TODO: however, note that ranking is done for sources other than proceedings, so specific activity might not be the best.
: TODO: alternatively, make the "rank" parameter not true/false but a set of choices..
:
 : Calculate the distance between a date and a member, via its set of house-membership and government-function periods.
 : Distance is calculated by comparing the given date to the earliest "from" and the last "till".
 : If the date lies in between them, the distance is zero. If the date lies before "from",
 : the negative distance in days is returned. If the date lies after the "till", the positive distance
 : in days is returned.
 :
 : N.B. Currently the granularity of the periods is ignored, which may lead to small deviations from "reality".
 : N.B. If "till" is "present" and a date in the future is given, the distance will default to zero (i.e. active).
 :      This can lead to wrong distances if there are erroneous "present" signifiers in the data.
 : 
 : @param $member a pm:member element.
 : @param $date a string castable as xs:date.
 : @return integer reflecting the distance: 0=active; <0=days before first activity; >0=days after last activity.
 :)
declare function local:period-rank($member, $date) {
  (: Get all relevant periods. Just on of many possible ways to define this. :)
  let $periods := $member//(pm:membership[local:matching-body(.,'commons|senate')] union pm:function[@pm:role eq 'government'])/pm:period  
  
  let $from := (for $f in $periods/@pm:from order by $f return $f)[1]
  let $till := (for $t in $periods/@pm:till order by $t return $t)[last()]
  
  let $distance :=
    if (pmutil:date-in-range($date, $from, $till)) then 0
    else if ($date lt $from) then ((xs:date($date) - xs:date($from)) div xs:dayTimeDuration('P1D')) div 365.242199
    (: if ($date ge $till) then 1:)
    else ((xs:date($date) - xs:date($till)) div xs:dayTimeDuration('P1D')) div 365.242199

  return round-half-to-even($distance,2)
};


(:~
 : Does a node match a specific house or one of multiple houses.
 : 
 : @param $node should typically be a pm:function of pm:membership element.
 : @param $house a string representing the body, or multiples separated by '|', e.g. 'commons', 'senate', 'commons|senate'.
 : @return true or false.
 :)
declare function local:matching-body($node, $house) {
    (:let $houses := tokenize($house, '\|')
    return $node[@pm:body = $houses]:)
    (: Above definition gives strange error that '\|' is "seven arguments" rather than one... :)
    if ($node[@pm:body = tokenize($house, '\|')]) then true() else false()
};


(:~
 : Normalise a name-string for xpath string equality testing.
 : lower-case and remove ' ' and '-'.
 : 
 : @param $name a string.
 : @return normalised string.
 :)
declare function local:normalise-name($name) {
    (:let $chars-removed := replace(lower-case($name),"[ \-]","")
    return $chars-removed:)
    (: The code below, for some reason, gives an error ("replace received 2 arguments"..), both of the two reformulations below seem to work properly. :)
    (:let $chars-removed := lower-case(replace($name,"[ \-]",""))
    return $chars-removed:)
    replace(lower-case($name),"[ \-]","")
};


(:~
 : Parse query string into a lucene query string (i.e. put quotes around it to treat is as one string).
 : 
 : @param $query a string.
 : @return lucene query string.
 :)
declare function local:lucene-query($query) {
    concat('"',$query,'"')
};


(:~
 : Select a set of member candidates according to lastname query matching.
 : 
 : @param $query as string that should match a last name.
 : @param $collection as collection of member documents.
 : @return element() with the used parameters and resulting collection of candidate-member-elements.
 :)
declare function local:select-candidates-by-lastname($query, $collection) {

    (: Create derived queries. :)
    let $lucene-query := local:lucene-query($query)
    let $xpath-query := local:normalise-name($query)
    
    (: Lucene is fast, but also returns partial matches. Use Lucene to get a small probable candidate set fast. :)
    (: For example "cohen" will match both "Cohen" and "Cohen Stuart" :)
    let $lucene-candidates := $collection//pm:member[.//pm:name[ft:query(pm:last,$lucene-query)]]
    
    (: We only want candidates that are exact matches. Use xpath string equality to remove partial matches. :)
    let $candidates := $lucene-candidates[.//pm:name[local:normalise-name(pm:last) eq $xpath-query]]
    
    let $result := local:create-candidates-result($lucene-query, $xpath-query, '', '', $candidates, 'lastname')
 
    return $result
};


(:~
 : Put a set of arguments describing the identification process and candidate persons in an xml element.
 : 
 : @param $lucene-query as string that lucene uses to find candidates last name (fast).
 : @param $xpath-query as string that stricter xpath matching used to filter lucene candidates (slow, but on little data).
 : @param $firstname as string of extracted firstname in the input string.
 : @param $initials as string of extracted initials in the input string.
 : @param $candidates as sequence of elements representing possible candidates.
 : @param $stage as string describing which path of input name analysis was followed to get at the current set of candidates.
 : @return element() <result> with the respective arguments in sub-elements.
 :)
declare function local:create-candidates-result($lucene-query, $xpath-query, $firstname, $initials, $candidates, $stage) {
    <result>
        <lucene-query>{string($lucene-query)}</lucene-query>
        <xpath-query>{string($xpath-query)}</xpath-query>
        <firstname>{string($firstname)}</firstname>
        <initials>{string($initials)}</initials>
        <candidates>{$candidates}</candidates>
        <stage>{string($stage)}</stage>
    </result>
};


(:~
 : Given a query, try to find suitable candidates, progressively parsing the query-string for possible firstnames/initials.
 : Each progression, if no candidates are found, the next progression is tried. First, assume just a lastname, then try
 : firstnames and initials. 
 : 
 : @param $query as string that should match a last name.
 : @param $collection as collection of member documents.
 : @return element() <result> as created with local:create-candidates-result().
 :)
declare function local:select-candidates-by-query($query, $collection) {
    (: First try to find candidates assuming the query string is only a last name. :)
    let $lastname-result := local:select-candidates-by-lastname($query, $collection)
    
    (: Prepare the failed result, with query-copies of default query. :)
    let $failed-result := local:create-candidates-result($lastname-result/lucene-query, $lastname-result/xpath-query, '', '', (), 'failed')
    
    (: Try to find candidates based on firstname, only if there were no results based on lastname. :)
    let $firstname-result :=
        if ($lastname-result/candidates/*) then ()
        else local:candidates-after-firstnames-level($query, $collection, 1)
        
    (: Try to find candidates assuming the first two words are firstnames. If more than two should are ever required, generalise this result and the above. :)
    let $firstnames-result :=
        if ($firstname-result/candidates/*) then ()
        else local:candidates-after-firstnames-level($query, $collection, 2)
        
    let $initials-result :=
        if ($firstnames-result/candidates/*) then ()
        else local:candidates-after-initials-level($query, $collection, 1)
        
    let $initials-result-two :=
        if ($initials-result/candidates/*) then ()
        else local:candidates-after-initials-level($query, $collection, 2)
        
    let $initials-result-three :=
        if ($initials-result-two/candidates/*) then ()
        else local:candidates-after-initials-level($query, $collection, 3)

    (: Check for empty, and if so, run the query that tries to match the first string to a firstname. :)
    let $candidate-search-result :=
        if ($lastname-result/candidates/*) then $lastname-result
        else if ($firstname-result/candidates/*) then $firstname-result
        else if ($firstnames-result/candidates/*) then $firstnames-result
        else if ($initials-result/candidates/*) then $initials-result
        else if ($initials-result-two/candidates/*) then $initials-result-two
        else if ($initials-result-three/candidates/*) then $initials-result-three
        else $failed-result
        
    return $candidate-search-result
};


(:~
 : Given a membership-id, find members that contain this id.
 : (No explicit checks on the data have been done, but membership-ids should be unique.)
 : 
 : @param $membershipid as string that should match a last name.
 : @param $collection as collection of member documents.
 : @return element() <result> as created with local:create-candidates-result().
 :)
declare function local:select-candidates-by-membership($membershipid, $collection) {
  (: We only want candidates that are exact matches. Use xpath string equality to remove partial matches. :)
  let $candidates := $collection//pm:member[.//pm:membership/@pm:membership-id eq $membershipid]
    
  let $result := local:create-candidates-result('', '', '', '', $candidates, 'membershipid')
 
  return $result
};


(:~
 : Try if the first $split-level tokens (tokenised on " ") are firstnames with the rest a lastname.
 : 
 : @param $query as string that should match a last name.
 : @param $collection as collection of member documents.
 : @param $split-level as an integer representing the number of tokens that should be considered firstnames.
 : @return element() <result> as created with local:create-candidates-result().
 :)
declare function local:candidates-after-firstnames-level($query, $collection, $split-level) {
    let $split := tokenize($query," ")
    let $query := string-join(subsequence($split, $split-level + 1)," ")
    let $firstname := local:normalise-name(string-join(subsequence($split, 1, $split-level)," "))
    let $result := local:select-candidates-by-lastname($query, $collection)
    let $candidates := $result/candidates/*[.//pm:name[local:normalise-name(pm:first) eq $firstname]]

    let $result := local:create-candidates-result($result/lucene-query, $result/xpath-query, $firstname, '', $candidates, concat('firstname-',$split-level))
 
    return $result
};


(:~
 : Try if the first $split-level tokens (tokenised on " ") are initials with the rest a lastname.
 : Given our Dutch member data set, initials should typically contain a ".", but this is not enforced or checked by this function.
 : 
 : @param $query as string that should match a last name.
 : @param $collection as collection of member documents.
 : @param $split-level as an integer representing the number of tokens that should be considered firstnames.
 : @return element() <result> as created with local:create-candidates-result().
 :)
declare function local:candidates-after-initials-level($query, $collection, $split-level) {
    let $split := tokenize($query," ")
    let $query := string-join(subsequence($split, $split-level + 1)," ")
    let $initials := local:normalise-name(string-join(subsequence($split, 1, $split-level)," "))
    let $result := local:select-candidates-by-lastname($query, $collection)
    let $candidates := $result/candidates/*[.//pm:name[local:normalise-name(pm:initials) eq $initials]]

    let $result := local:create-candidates-result($result/lucene-query, $result/xpath-query, '', $initials, $candidates, concat('initials-',$split-level))
 
    return $result
};


(: Example typing etc.
let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <search default="speech" accept="speech,p"/>, <start-date type="xs:date"/>, <end-date type="xs:date"/>,
                                            <query type="ft:query"/>, <collection default="nl-ob" accept="nl-ob,nl-sgd,nl,dk,se,no"/>, <limit default="20" type="xs:integer"/>) )
:)

let $request := export:request-parameters( (<q default="" type="ft:query"/>, <col default="nl"/>,
                                            <role default=""/>, <house default=""/>, <date default="" type="xs:date"/>,
                                            <partyid default=""/>, <membershipid default=""/>,
                                            <rank default="false" accept="true,false"/>,
                                            <view default="id" accept="id,csv,table,xml"/>) )

let $query := string($request/@q)
let $col := string($request/@col)
let $role := string($request/@role)
let $house := string($request/@house)
let $date := string($request/@date)
let $rank := string($request/@rank)
let $partyid := string($request/@partyid)
let $membershipid := string($request/@membershipid)




(: Open the collection. :)
let $collection := collection(concat("/db/data/permanent/m/",$col))

(: When we have a set of candidates, see if additional options were given to reduce the candidate pool (this is usually the case). :)
let $disambiguation-method :=
    if ($membershipid ne '') then "membershipid"
    else if ($role eq 'government' and $date ne '') then "government-date"        
    else if ($date ne '' and $partyid ne '' and $house ne '') then "date-partyid-house"
    else if ($date ne '' and $house ne '') then "date-house"
    else if ($house ne '') then "house"
    else if ($date ne '' and $rank eq 'true') then "date-rank"
    else if ($date ne '') then "date"
    else "none"


(: Create a set of candidates. :)
let $candidate-search-result := if ($disambiguation-method eq 'membershipid') then local:select-candidates-by-membership($membershipid, $collection)
                                else local:select-candidates-by-query($query, $collection)

(: Set the final set of candidates, to enter the ambiguation phase. :)
let $candidates := $candidate-search-result/candidates/*


let $members :=
    (: N.B. Note that the order is very important. If a party and date are both given, and you try party-only first, then ofcourse the date-party combination check will never be done. :)
    (: TODO: update comment below with new options..
    Currently implemented, two scenario's for identification while transforming:
    role=government & date
    (role=mp or role=chair?) & date & house & party (& gender)
    TODO (for older data), add:
    role=mp & date & house & gender
    Note, queries matching neither of these will return all members although the correct answer could be given, see: ?col=nl&q=cohen&house=senate&date=1996-04-05
    :)
    if ($disambiguation-method eq 'government-date') then
        $candidates[./pm:curriculum/pm:function[@pm:role eq 'government' and local:matching-period(.,$date)]]
    else if ($disambiguation-method eq 'date-partyid-house') then
        $candidates[./pm:memberships/pm:membership[local:matching-body(.,$house) and @pm:party-ref eq $partyid  and local:matching-period(.,$date)]]
    else if ($disambiguation-method eq 'date-house') then
        $candidates[./pm:memberships/pm:membership[local:matching-body(.,$house) and local:matching-period(.,$date)]]
    else if ($disambiguation-method eq 'house') then
        $candidates[./pm:memberships/pm:membership[local:matching-body(.,$house)]]
    else if ($disambiguation-method eq 'date') then
        $candidates[./pm:memberships/pm:membership[local:matching-period(.,$date)]]  (: TODO: fix, only use periods that match a house membership... :)
    (: 'date-rank' method implicitly falls back to all candidates, ranking is done below. :)
    else $candidates

(: Sometimes, a member of the 'commons' speaks in the 'senate', without his/her party mentioned, to exlain legislation etc. These are of course not found based on the house='senate' rule.
   So, create an exception rule where, if the disambiguation-method is 'date-house', the house='senate' and there are no members found, we try the disambiguation again with house='commons'.
   If this returns exactly one result, we can be pretty sure (sure enough) that it is correct. 
   N.B. the fact that someone is from the other house is mentioned in the presence-list, but this list might not be easily available in the actual document.
        Besides, if someone is in the senate, they should be indentified anyway, so the commons-exceptions does not kick in. :)
let $commons-in-senate-exception := if ($disambiguation-method eq 'date-house' and $house eq 'senate' and empty($members)) then true() else false()
let $members :=
    if ($commons-in-senate-exception) then
        (: TK in EK exception kicks in :)
        $candidates[./pm:memberships/pm:membership[local:matching-body(.,'commons') and local:matching-period(.,$date)]]
    else $members
(: Update disambiguation-method :)
let $disambiguation-method :=
    if ($commons-in-senate-exception and not(empty($members))) then concat($disambiguation-method,'+','commons-in-senate-exception')
    else $disambiguation-method


(: Get strings of arguments to add to the returned options. :)
let $lucene-query := string($candidate-search-result/lucene-query)
let $xpath-query := string($candidate-search-result/xpath-query)
let $firstname := string($candidate-search-result/firstname)


(: Create self-documenting set of options to describe the results found. :)
let $options := export:options( (
    <q explanation="any string representing the name"/>,
    <col explanation="collection (default 'nl', choose from nl, uk)"/>,
    <role explanation="choose from 'government', 'mp', 'chair'"/>,
    <house explanation="body of legislature, single one or multiples seperated by '|', typically: 'commons', 'senate', 'commons|senate'"/>,
    <date explanation="proper date-string in iso-format (yyyy-mm-dd), castable as xs:date, e.g. '2006-05-24'"/>,
    <partyid explanation="party identifier as used by PoliticalMashup, e.g. 'nl.p.vvd'"/>,
    <membershipid explanation="identifier for specific membership, used for uk"/>,
    <rank explanation="true|false, applicable when only supplying date; with date and false: filter; with date and true: rank" select="true,false"/>,
    <xpath-query value="{$xpath-query}" explanation="normalised string as used for final lastname equality check"/>,
    <lucene-query value="{$lucene-query}" explanation="string as used for lucene lastname selection"/>,
    <firstname value="{$firstname}" explanation="firstname(s) as parsed from input query, if used"/>,
    <initials value="{string($candidate-search-result/initials)}" explanation="initial(s) as parsed from input query, if used"/>,
    <candidate-generation-stage value="{string($candidate-search-result/stage)}" explanation="indication of the query parsing process"/>,
    <disambiguation-method value="{$disambiguation-method}" explanation="string representation of the disambiguation/strict-matching process used for filtering candidates; note that additional arguments can still give the value 'none' here, if they did not combine into a valid (is programmed) set; if 'none', none of the addtional arguments have been used"/>
                                ),
                                $request)
                                

(: Define what exactly we return, full members, multiple candidates, id's only, etc. :)
(: nl.m.02323 contains an error with memberships and dates, causing two memberships at the same date (2002-10-01). To prevent errors, <party-at-date> explicitly uses the first found reference. :)
let $result-set :=
    for $member in $members
    let $matching-membership := ($member/pm:memberships/pm:membership[local:matching-body(.,'commons|senate') and local:matching-period(.,$date)])[1]
    let $match-rank := if ($disambiguation-method eq 'date-rank') then <rank>{local:period-rank($member, $date)}</rank> else ()
    let $dutch-wiki-link := ($member//pm:link[@pm:description eq 'Wikipedia (NL)'])[1]
    return
        <member id="{$member/@pm:id}">
          {$member/pm:name}
          <party-at-date party-name="{$matching-membership/@pm:party-name}">{string($matching-membership/@pm:party-ref)}</party-at-date>
          {$dutch-wiki-link}
          {$match-rank}
        </member>


(: Construct export output. :)
let $column-names := export:xml-util-headers( ('member', 'link', if ($disambiguation-method eq 'date-rank') then 'rank' else ()) )

let $description := export:xml-util-description('All possible member candidates for the given parameters.')

let $items :=
  for $member in $result-set
  return
    export:xml-row(
      (
      export:xml-item($member, <options copy="true" display="{$member//pm:full}"/>),
      export:xml-item(export:link-resolver($member/@id, 'html'), <options display="{$member/@id}" link="true"/>),
      if ($disambiguation-method eq 'date-rank') then export:xml-item($member/rank) else ()
      )
    )

let $xml-output := export:xml-output( ($description, $column-names, $items) )

return export:output-util-common-id-script($xml-output, $options, $request, 'members')
