xquery version "1.0";

import module namespace pmutil="http://politicalmashup.nl/modules/util";
import module namespace request="http://exist-db.org/xquery/request";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace pmd="http://www.politicalmashup.nl/docinfo";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace compression="http://exist-db.org/xquery/compression";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace datetime="http://exist-db.org/xquery/datetime";


declare function local:matching-period($node, $date) {
    pmutil:date-in-range($date, $node/pm:period/@pm:from, $node/pm:period/@pm:till)
};

declare function local:matching-body($node, $house) {
    let $houses := tokenize($house, '\|')
    return $node[@pm:body = $houses]
};


declare variable $col := (
                        let $input := request:get-parameter('col',"")  
                        return if (string-length($input)) then $input else ''  
                        );                        
                        
declare variable $role := (
                        let $input := request:get-parameter('role',"")  
                        return if (string-length($input)) then $input else ''  
                        );                        

declare variable $house := (
                        let $input := request:get-parameter('house',"")  
                        return if (string-length($input)) then $input else ''  
                        );

declare variable $date := (
                        let $input := request:get-parameter('date',"")  
                        return if (string-length($input)) then $input else ''  
                        );
                        
declare variable $partyid := (
                        let $input := request:get-parameter('partyid',"")  
                        return if (string-length($input)) then $input else ''  
                        );

declare variable $memberid := (
                        let $input := request:get-parameter('memberid',"")  
                        return if (string-length($input)) then $input else ''  
                        );                        


(: Get initial set of candidates, based on simple name equivalence. :)
let $collection := collection(concat("/db/data/permanent/m/",$col))

let $candidates := 
    $collection//pm:member

let $disambiguation-method :=
    if ($memberid ne '') then "memberid"
    else if ($role eq 'government' and $date ne '') then "government-date"        
    else if ($date ne '' and $partyid ne '' and $house ne '') then "date-partyid-house"
    else if ($date ne '' and $house ne '') then "date-house"
    else "none"
    
let $members :=
    (: N.B. Note that the order is very important. If a party and date are both given, and you try party-only first, then ofcourse the date-party combination check will never be done. :)
    (:
    Currently implemented, two scenario's for identification while transforming:
    role=government & date
    (role=mp or role=chair?) & date & house & party (& gender)
    TODO (for older data), add:
    role=mp & date & house & gender
    Note, queries matching neither of these will return all members although the correct answer could be given, see: ?col=nl&q=cohen&house=senate&date=1996-04-05
    :)
    if ($disambiguation-method eq 'memberid') then
        $collection[.//dc:identifier eq $memberid]//pm:member
    else if ($disambiguation-method eq 'government-date') then
        $candidates[./pm:curriculum/pm:function[@pm:role eq 'government' and local:matching-period(.,$date)]]
    else if ($disambiguation-method eq 'date-partyid-house') then
        $candidates[./pm:memberships/pm:membership[@pm:body eq $house and @pm:party-ref eq $partyid  and local:matching-period(.,$date)]]
    else if ($disambiguation-method eq 'date-house') then
        $candidates[./pm:memberships/pm:membership[@pm:body eq $house and local:matching-period(.,$date)]]
    else $candidates


let $options :=
  <options>
    <col type="get">{$col}</col>
    <role type="get">{$role}</role>
    <house type="get">{$house}</house>
    <date type="get">{$date}</date>
    <partyid type="get">{$partyid}</partyid>
    <disambiguation-method type="derived">{$disambiguation-method}</disambiguation-method>
  </options>


(: Define what exactly we return, full members, multiple candidates, id's only, etc. :)
let $result-set :=
    for $member in $members
    return
        <member id="{$member/@pm:id}">
          {$member/pm:name}
          <party-at-date>{string(($member/pm:memberships/pm:membership[local:matching-body(.,'commons|senate') and local:matching-period(.,$date)]/@pm:party-ref)[1])}</party-at-date>
        </member>


return
  <result count="{count($result-set)}">
    {$options}
    <members>
    {$result-set}
    </members>
  </result>