xquery version "1.0";

(:

Author: sgrijzenhout

This getVotes.xq xquery gives an interface to query for votes using a dossiernummer and ondernummer 

TODO: can't be used for wetsvoorstellen now, because ondernummer is required. Make the xquery more generic

:)

import module namespace request="http://exist-db.org/xquery/request";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace compression="http://exist-db.org/xquery/compression";
declare namespace system="http://exist-db.org/xquery/system";
declare namespace datetime="http://exist-db.org/xquery/datetime";
declare namespace dc="http://purl.org/dc/elements/1.1/";

(: a function to check whether a dossiernummer has a legitimate format :)
declare function pm:checkDossiernummer($dossiernummer) as xs:boolean {
    let $result := matches($dossiernummer,'^\d+[\-]?[XIV]*?$')
    return $result
};

(: a function to check if an ondernummer has a legitimate format :)
declare function pm:checkOndernummer($ondernummer) as xs:boolean {
    let $result := matches($ondernummer,'^\d+$')
    return $result
};

(: this function truly fetches the votes :)
declare function pm:getVotes($collection,$dossiernummer,$ondernummer) {
    (:for $i in $collection//pm:vote[./pm:about/pm:information[index-of(./pm:dossiernummer,$dossiernummer) ge 1 and index-of(./pm:ondernummer,$ondernummer) ge 1]]:)
    for $i in $collection//pm:vote[./pm:about/pm:information[pm:dossiernummer eq $dossiernummer and pm:ondernummer eq $ondernummer]]
    (:for $i in $collection//pm:vote[./pm:about/pm:information[index-of(./pm:dossiernummer,$dossiernummer)[1] ge 1 and index-of(./pm:ondernummer,$ondernummer)[1] ge 1]]:)
        return
          <result doc-ref="{$i/root()//dc:identifier}">
            {$i}
          </result>
};

declare function pm:get-votes-from-docref($collection,$dossiernummer,$ondernummer,$docref) {
    let $eligable-proceedings := $collection[.//pm:dossier/@pm:doc-ref eq $docref]
    let $votes := $eligable-proceedings//pm:vote
    (: Xpath [test] on $votes does not seem to work... TODO: figure out why :)
    for $i in $votes
        where $ondernummer eq string($i//pm:ondernummer) and $dossiernummer eq string($i//pm:dossiernummer)
        return
          <result doc-ref="{$i/root()//dc:identifier}">
            {$i}
          </result>
};

(: this function truly fetches the votes :)
declare function pm:errorMsgs($naam,$dossiernummer) {
    <error>{concat($naam,' "',$dossiernummer,'" does not adhere to the format specified in the regex.')}</error>
};

(: the collection of proceedings where the votes are present :)
let $collection := collection("/db/data/permanent/d/nl/proc/ob")
(: parameters for the dossiernummer and ondernummer :)
let $dossiernummer := request:get-parameter("dossiernummer", ())
let $ondernummer := request:get-parameter("ondernummer", ())
let $docref := request:get-parameter("docref", "")

(: results of the legitimate format checks :)
let $dossiernummerCheck := pm:checkDossiernummer($dossiernummer)
let $ondernummerCheck := pm:checkOndernummer($ondernummer)

return
<results> {
    if ($dossiernummerCheck and $ondernummerCheck and $docref ne '') then
        pm:get-votes-from-docref($collection,$dossiernummer,$ondernummer,$docref)
    (: check whether the dossiernummer and ondernummer have legitimate format. If so, search collection and return results :)
    else if ($dossiernummerCheck and $ondernummerCheck) then
        pm:getVotes($collection,$dossiernummer,$ondernummer)
    else 
        (: otherwise, generate error message saying which numbers are not legitimate :)
        (pm:errorMsgs('dossiernummer',$dossiernummer),pm:errorMsgs('ondernummer',$ondernummer))
} </results>