xquery version "3.0" encoding "UTF-8";
(:
Script to identify parties based on a name, and optionally a date.

Arjan Nusselder, June 20, 2012
Last update, October 22, 2012
:)

declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";


declare function  local:normalise-name($name as xs:string) as xs:string {
    replace(lower-case($name),'[^\p{Ll}0-9]','')
};  
  

declare function local:matching-date($history, $date) {
    (: Ignoring gran=6, if not completely given, than just match the year. :)
    $history[.//pm:formation/@pm:date le $date][empty(.//pm:abolition/@pm:date) or (.//pm:abolition/@pm:granularity eq '8' and .//pm:abolition/@pm:date ge $date) or (replace(.//pm:abolition/@pm:date,'([0-9]{4})-.*','$1-12-31') ge $date)]
    (:$history[.//pm:formation/@pm:date le $date][empty(.//pm:abolition/@pm:date) or .//pm:abolition/@pm:date ge $date]:)
};




let $request := export:request-parameters( (<q default=""/>, <col default=""/>, <date default=""/>, <view default="id" accept="id,csv,table,xml"/>) )

(: Normalise query. :)
let $xpath-query := local:normalise-name($request/@q)

(: Get initial set of candidates, based on simple name equivalence. :)
let $collection := collection(concat("/db/data/permanent/p/",$request/@col))


let $candidates :=
    if ($xpath-query ne '') then
        $collection//pm:party//pm:name[local:normalise-name(.) eq $xpath-query]/ancestor::pm:party
    else ()
    

(: When we have a set of candidates, see if additional options were given to reduce the candidate pool (this is usually the case). :)
let $candidates :=
    (: N.B. Note that the order is very important. If a party and date are both given, and you try party-only first, then ofcourse the date-party combination check will never be done. :)
    if ($request/@date ne '') then
        $candidates[local:matching-date(.//pm:history,$request/@date)]
    else $candidates


(: Define what exactly we return, full parties, multiple candidates, id's only, etc. :)
let $result-set :=
    for $party in $candidates
    return
        <party id="{$party/@pm:id}">
          <period from="{$party//pm:formation/@pm:date}" till="{$party//pm:abolition/@pm:date}"/>
          {$party/pm:name}
        </party>


let $options := export:options( (
                                  <q explanation="any string representing the party name"/>,
                                  <col explanation="collection, default is all countries (currently only 'nl' is available, being equivalent to all)"/>,
                                  <date explanation="proper date-string in iso-format (yyyy-mm-dd), castable as xs:date, e.g. '2006-05-24'"/>,
                                  <norm-q value="{$xpath-query}" explanation="normalised string as used for xpath query"/>
                                ),
                                $request)
                                

(: Construct export output. :)
let $column-names := export:xml-util-headers( ('party', 'link') )

let $description := export:xml-util-description('All possible parties for the given parameters.')

let $items :=
  for $party in $result-set
  return
    export:xml-row(
      (
      export:xml-item($party, <options copy="true" display="{$party//pm:name}"/>),
      export:xml-item(export:link-resolver($party/@id, 'html'), <options display="{$party/@id}" link="true"/>)
      )
    )

let $xml-output := export:xml-output( ($description, $column-names, $items) )
return export:output-util-common-id-script($xml-output, $options, $request, 'parties')
