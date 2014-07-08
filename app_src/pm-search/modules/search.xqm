(:
 : Search engine for PM hansard collections -- language independent core
 :
 : Written by Lars Buitinck
 : Based on earlier work by Maarten Marx and Anne Schuth
 :
 : See index.xq for an example of use, esp. the construction of a <query>
 : object.
 :)

xquery version "1.0";

module namespace pmsearch = "http://politicalmashup.nl/search/search";

(: local modules :)
import module namespace functx="http://www.functx.com";
import module namespace parties="http://politicalmashup.nl/search/parties" at "parties.xqm";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";

import module namespace util="http://exist-db.org/xquery/util";

declare option exist:serialize "method=xhtml media-type=text/html";


declare function pmsearch:search($query, $coll-name)
{
  if ($query/terms/noquery) then
    ()
  else
    local:real-search($query, $coll-name)
};


(: Returns all non-whitespace segments in string $s
 : (like Python's str.split with no arguments) :)
declare function local:split($s)
{
  for $x in tokenize($s, "\s+")
    where $x ne ""
    return $x
};


(: Main entry point: do search, return a sequence of hits :)
declare function local:real-search($query, $coll-name)
{
  let $coll := collection($coll-name)
  let $coll := local:restrict-dates($coll, $query/date/@start, $query/date/@end)

  let $scope := if ($query/@granularity eq "topic"
                 or $query/@granularity eq "title") then
                  $coll//pm:topic
                else if ($query/@granularity eq "scene") then
                  (: Account for older data without scenes
                   : XXX why doesn't $coll[not(.//pm:scene)]//pm:speech work? :)
                  $coll//pm:scene union $coll//pm:speech[not(ancestor::pm:scene)]
                else
                  $coll//pm:speech

  let $scope := local:restrict-speakers($scope, local:split($query/speakers))

  (: XXX workaround: government members currently don't have parties :)
  let $scope := if ($query/speakers/@role eq "government") then
                  $scope
                else
                  local:restrict-party($scope, $query/@party)

  let $scope := local:restrict-party-by-members($scope, $query/@party-members)

  let $house := $query/@house
  let $scope := if ($house ne "") then
                  $scope[root()//pm:house/@pm:house eq $house]
                else
                  $scope

  let $qterms := functx:trim($query/terms)
  let $scope := if ($qterms eq "") then
                  (: don't do any search :)
                  $scope
                else
                  (: XXX this should catch only
                   : org.apache.lucene.queryParser.ParseException,
                   : but putting that here instead of "*" doesn't do the trick
                   :)
                  util:catch("*",
                             ft:query(if ($query/@granularity eq "title")
                                        then $scope/@pm:title
                                        else $scope,
                                      $qterms),
                             ())

  (: assume @role is either "" or one of the permitted values for @pm:role :)
  let $role := $query/speakers/@role
  let $scope := if ($role eq "")
                  then $scope
                  else $scope[@pm:role eq $role]

  (:return local:restrict-dates($scope, $query/date/@start, $query/date/@end):)
  return $scope
};


(: Expand "partial" date like "1993-01" to full date.
 : The argument $inclusive determines whether a whole year/month is meant.
 : Might return an invalid date such as February 31,
 : but good enough for sorting.
 :)
declare function local:complete-date($d, $inclusive)
{
  (: The following line prevents mysterious class cast exceptions. :)
  let $d := functx:trim(xs:string($d))

  let $last-month := if ($inclusive) then "-12" else "-01"
  let $d := if (matches($d, "^\d\d\d\d$"))
              then concat($d, $last-month)
              else $d

  let $last-day := if ($inclusive) then "-31" else "-01"
  return if (matches($d, "^\d\d\d\d-\d\d$"))
           then concat($d, $last-day)
           else $d
};


(:
 : Restrict $scope to the dates given.
 : $scope should be a collection.
 :)
declare function local:restrict-dates($scope, $start-date, $end-date)
{
  (: date restrictions are expensive; when only one is needed,
   : then only apply that one :)
  let $scope :=
    if ($start-date eq "") then
      $scope
    else
      let $start-date := local:complete-date($start-date, 0)
      return $scope[.//dc:date ge xs:date($start-date)]

  let $scope :=
    if ($end-date eq "") then
      $scope
    else
      let $end-date := local:complete-date($end-date, 1)
      return $scope[.//dc:date le xs:date($end-date)]

  return $scope
};


declare function local:restrict-party($scope, $party)
{
  if ($party eq "") then
    $scope
  else
    $scope[@pm:party-ref eq $party]
};


declare function local:restrict-party-by-members($scope, $party)
{
  if ($party eq "") then
    $scope
  else
    let $members := parties:members($party)
    return local:restrict-speakers($scope, $members)
};


declare function local:restrict-speakers($scope, $speaker-ids)
{
  let $scope := if (empty($speaker-ids))
                  then $scope
                  else $scope[@pm:member-ref = $speaker-ids]

  return $scope
};


(: Sort hits by $order
 : "chrono" -> chronologically
 : "rchrono" -> reverse chronologically
 : "debatelength" -> by # speeches in containing debate
 : else -> by Lucene scoring formula
 :)
declare function pmsearch:sort-hits($hits, $order)
{
  if ($order = "chrono") then
    for $hit in $hits
      order by local:hit-date($hit) ascending
      return $hit
  else if ($order = "rchrono") then
    for $hit in $hits
      order by local:hit-date($hit) descending
      return $hit
  else if ($order = "debatelength") then
    for $hit in $hits
      order by local:debate-length($hit) descending
      return $hit
  else
    for $hit in $hits
      order by ft:score($hit) descending
      return $hit
};


(: Approximate length of the debate that a hit belongs to :)
declare function local:debate-length($hit)
{
  count($hit/ancestor-or-self::pm:topic//pm:speech)
};


declare function local:hit-date($hit)
{
  $hit/root()//dc:date/text()
};
