(: 
Author: Arjan Nusselder
Date : April 2012
Purpose: Show overviews of party seats distributions for easy validation.

(GET) Parameters
col = see collections.xqm
:)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace util="http://exist-db.org/xquery/util"; 
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace datetime="http://exist-db.org/xquery/datetime";

import module namespace pmutil="http://politicalmashup.nl/modules/util";


declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes 
    doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Strict//EN 
    doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd";


(:~
 : Retrieve the list of memberships for a given date.
 : 
 : @param $member-collection collection of member documents/elements to search in.
 : @param $date iso-date-string.
 : @return Sequence of <pm:membership> elements.
 :)
declare function local:member-seats-at-date($member-collection, $date, $house) {
  $member-collection//pm:membership[@pm:body eq $house and local:matching-date(., $date)]
};


(:~
 : Convert set of memberships to set of parties, with persons per party.
 : 
 : @param $memberships collection of membership elements.
 : @return Sequence of <membership> elements.
 :)
declare function local:memberships-per-party($memberships) {
  let $party-refs := distinct-values(for $m in $memberships return $m/@pm:party-ref)
  return
    <results membership-count="{count($memberships)}" party-count="{count($party-refs)}">
      {
      for $p in $party-refs
      let $party-memberships := $memberships[@pm:party-ref eq $p] 
      return
        <party party-ref="{$p}" count="{count($party-memberships)}">
          {
          for $pm in $party-memberships
          return
            <member id="{root($pm)//dc:identifier}" name="{(root($pm)//pm:name/pm:last)[1]}"/>
          }
        </party>
      }
    </results>
};


(:~
 : Create html snippet of party seats at the given date.
 : 
 : @param $sessions collection of <pm:session> elements
 : @return (<td/>,..)
 :)
declare function local:show-memberships-per-party-full($results, $date, $house) {
  <div>
    <h3>{$house} : {$date}</h3>
    <h4>Members: {string($results/@membership-count)} Parties: {string($results/@party-count)}</h4>
    {
    for $party in $results/party
    return
      <div>
        <h5>{string($party/@party-ref)}: {string($party/@count)}</h5>
        <p>
        {
        string-join(for $member in $party/member return $member/@name,", ")
        }
        </p>
      </div>
      }
  </div>    
};

declare function local:check-date-memberships($member-collection, $date, $house) {
  let $memberships := local:member-seats-at-date($member-collection, $date, $house)
  let $results := local:memberships-per-party($memberships)
  let $html := local:show-memberships-per-party-full($results, $date, $house)
  return $html
};


(:~
 : Retrieve the list of seats/session elements of parties, at the given date.
 : 
 : @param $collection collection of party documents/elements to search in.
 : @param $date iso-date-string.
 : @return Sequence of <session> elements.
 :)
declare function local:party-seats-sessions-at-date($collection, $date) {
  $collection//pm:seats/pm:session[local:matching-date(., $date)]
};

declare function local:party-seats-sessions-at-date-house($collection, $date, $house) {
  $collection//pm:seats/pm:session[@pm:house eq $house and local:matching-date(., $date)]
};

(:~
 : See if a session matches a date.
 : 
 : @param $session <pm:session> element.
 : @param $date iso-date-string.
 : @return true()/false()
 :)
declare function local:matching-date($session, $date) {
  (: Ignoring the possibility of granularity != 8, c.f. id-party check: :)
  (:$history[.//pm:formation/@pm:date le $date][empty(.//pm:abolition/@pm:date) or (.//pm:abolition/@pm:granularity eq '8' and .//pm:abolition/@pm:date ge $date) or (replace(.//pm:abolition/@pm:date,'([0-9]{4})-.*','$1-12-31') ge $date)]:)
  if (pmutil:date-in-range($date, $session/pm:period/@pm:from, $session/pm:period/@pm:till)) then true() else false()
};



(:~
 : Count if the total number of seats in a collection of sessions.
 : 
 : @param $sessions collection of <session> elements.
 : @return sum()
 :)
declare function local:count-seats($sessions) {
  sum( for $seats in $sessions/@pm:seats return number($seats) )
};


(:~
 : Return the list of parties+seats for the given date.
 : 
 : @param $sessions collection of <session> elements.
 : @return <results><result party="" seats="" /></results>
 :)
declare function local:date-details-from-sessions($sessions) {
  <results>
    {
    for $session in $sessions
    return
      <result party="{$session/ancestor::root/meta/dc:identifier}" seats="{$session/@pm:seats}"/>
    }
  </results>
};


(:~
 : See if a date has a correct set of seats.
 : 
 : @param $collection collection of party documents/elements to search in.
 : @param $date iso-date-string.
 : @return snippet for date
 :)
declare function local:check-date($collection, $date, $house) {
  let $sessions := local:party-seats-sessions-at-date-house($collection, string($date), $house)
  let $count := local:count-seats($sessions)
  return
  <table>
    <tr>
      <td>{string($date)}</td>
      <td>{$count}</td>
      { local:show-sessions($sessions) }
    </tr>
  </table>
  

};


(:~
 : Create html snippet of party seats at the given date.
 : 
 : @param $sessions collection of <pm:session> elements
 : @return (<td/>,..)
 :)
declare function local:show-sessions($sessions) {
  let $results := local:date-details-from-sessions($sessions)
  return
    for $result in $results/result
    let $party-id := string($result/@party)
    order by number($result/@seats) descending
    return
      <td><a href="http://resolver.politicalmashup.nl/{$party-id}?view=html">{$party-id}</a><br/>{string($result/@seats)}</td>
};


(:~
 : Create list of dates from start till end.
 : 
 : @param $start start at this date
 : @param $end stop at this date
 : @return list if iso-string-dates
 :)
declare function local:create-dates-range($start, $end) {
  let $iterations := days-from-duration(xs:date($end) - xs:date($start))
  return datetime:date-range(xs:date($start), xdt:dayTimeDuration('P1D'), $iterations)
};


(:~
 : Check for a date range, if all dates give a correct total number of seats.
 :
 : @param $collection collection of parties. 
 : @param $start start at this date.
 : @param $end stop at this date.
 : @return html snippet for each failed date check
 :)
declare function local:check-dates($collection, $start, $end, $house, $correct-count) {
  <table>
    {
  for $date in local:create-dates-range($start, $end)
    let $sessions := local:party-seats-sessions-at-date-house($collection, string($date), $house)
    let $count := local:count-seats($sessions)
    where $count ne $correct-count
    order by $date
  return
    <tr>
      <td>{string($date)}</td>
      <td>{$count}</td>
      { local:show-sessions($sessions) }
    </tr>
    }
  </table>
};


(: Copy from old collections:common-css() :)
declare function local:common-css() {
<style><![CDATA[
      body {margin: 20px 0 0 30px;}
      h1,h2,h3,h4,p,dl,li{font-family:sans-serif;color:#222;}
      h1{border-bottom:2px solid #aaa;}
      h2{margin-top:30px;border-bottom:2px solid #ccc;}
      h3{border-bottom:2px solid #eee;}
      dt,span.formaat{font-variant:small-caps;font-family:serif;}
      p{width:700px;}
      dd{width:500px;}
      a{color:#11f;}
      li a{text-decoration:none;}
      li a:hover{text-decoration:underline;}
      ul.menu li{margin-bottom:3px;}
      ul.menu li.top{margin-top:20px;}
      .small, .small * {font:12px monospace;}
      ul.small {list-style-type:none;}
      em{font-style:normal;font-weight:bold;}
      pre.statistics{width:300px;float:left;}
      span.def{font-variant:small-caps}
      span.ded{font-weight:bold;}
      span.display-option{border:2px solid #fff;padding:3px;background:#ccc;}
      button,input,select{border:1px solid #666;background:#fff;height:20px;}
      table{border:1px solid #888;font: 12px verdana;border-collapse:collapse;width:95%;}
      td,th{border:1px solid #aaa;padding:2px;}
      td p{padding:0;margin:0;width:auto;}
      ]]>
    </style>
};



(: collections :)

let $collection := collection('/db/data/permanent/p/nl')
let $member-collection := collection('/db/data/permanent/m/nl')
(:{ local:check-dates($collection, '1957-01-01', current-date()) }:) 
(:{local:check-date-memberships($member-collection, '2009-10-15', 'commons')}
{local:check-date-memberships($member-collection, '2005-10-26', 'commons')}:)
return

<html>
<head>
    {local:common-css()}
</head>
<body>
<h2>Check per date from members</h2>


<h2>1957 until now (before 1957, there were only 100 members).</h2>
<h2>Tweede Kamer</h2>
{ local:check-dates($collection, '2009-10-14', '2009-10-16', 'commons', 150) }
<h3>---</h3>
{ local:check-dates($collection, '2011-06-28', '2011-06-29', 'commons', 160) }
<h2>Eerste Kamer</h2>
{ local:check-dates($collection, '2009-10-14', '2009-10-15', 'senate', 150) }
<h2>Special dates</h2>
<p>{string-join(distinct-values(for $x in $member-collection//pm:membership[empty(@pm:party-ref)] return string($x/@pm:party-name))," :: ")}</p>
<p>lid Verdonk zou moeten bestaan:</p>
{ local:check-date($collection, '2009-10-15', 'commons') }
<p>Groep Wilders en Groep Nawijn zouder moeten bestaan:</p>
{ local:check-date($collection, '2005-10-26', 'commons') }
</body>
</html>