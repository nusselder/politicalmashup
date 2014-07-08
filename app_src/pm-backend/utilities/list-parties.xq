xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace pmd="http://www.politicalmashup.nl/docinfo";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace compression="http://exist-db.org/xquery/compression";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace datetime="http://exist-db.org/xquery/datetime";

(: $node should typically be a pm:function of pm:membership element :)
declare function local:matching-period($node,$date) {
    $node[./pm:period/@pm:from le $date and (./pm:period/@pm:till ge $date or ./pm:period/@pm:till eq 'present')]
};
                        
declare variable $col := (
                        let $input := request:get-parameter('col',"")  
                        return if (string-length($input)) then $input else ''  
                        );                        
                        
declare variable $date := (
                        let $input := request:get-parameter('date',"")  
                        return if (string-length($input)) then $input else ''  
                        );
                        
declare variable $house := (
                        let $input := request:get-parameter('house',"")  
                        return if (string-length($input)) then $input else ''  
                        );                        


(: Get initial set of candidates, based on simple name equivalence. :)
let $collection := collection(concat("/db/data/permanent/p/",$col))


let $parties :=
    if ($date ne '' and $house ne '') then
        $collection//pm:party[.//pm:seats/pm:session[@pm:house eq $house and local:matching-period(.,$date)]]
    else if ($date ne '') then
        $collection//pm:party[.//pm:seats/pm:session[local:matching-period(.,$date)]]
    else if ($house ne '') then
        $collection//pm:party[.//pm:seats/pm:session[@pm:house eq $house]]        
    else 
        $collection//pm:party


let $options :=
  <options>
    <col type="get">{$col}</col>
    <date type="get">{$date}</date>
    <house type="get">{$house}</house>
  </options>

(: Define what exactly we return, full parties, id's only, etc. :)
let $result-set :=
    for $party in $parties
    let $seats :=
      if ($date ne '' and $house ne '') then $party/pm:seats/pm:session[@pm:house eq $house and local:matching-period(.,$date)]
      else if ($date ne '') then $party/pm:seats/pm:session[local:matching-period(.,$date)]
      else if ($house ne '') then $party/pm:seats/pm:session[@pm:house eq $house]
      else ()
    return
        <party pm:id="{$party/@pm:id}" xmlns="http://www.politicalmashup.nl">
          <period pm:from="{$party//pm:formation/@pm:date}" pm:till="{$party//pm:abolition/@pm:date}"/>
          <seats>{$seats}</seats>
          {$party/pm:name}
        </party>


return
  <result count="{count($result-set)}">
    {$options}
    <parties xmlns="http://www.politicalmashup.nl" xmlns:pm="http://www.politicalmashup.nl">
      {$result-set}
    </parties>
  </result>