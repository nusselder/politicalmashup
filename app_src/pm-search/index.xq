(:
 : Search engine for PM hansard collections -- interface, Dutch
 :
 : Written by Lars Buitinck
 : Based on earlier work by Maarten Marx and Anne Schuth
 :)

xquery version "1.0";

(: local modules :)
import module namespace functx="http://www.functx.com";
import module namespace parties="http://politicalmashup.nl/search/parties" at "modules/parties.xqm";
import module namespace pmsearch="http://politicalmashup.nl/search/search" at "modules/search.xqm";
import module namespace pmutil="http://politicalmashup.nl/modules/util";
import module namespace export="http://politicalmashup.nl/modules/export";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace pmd = "http://www.politicalmashup.nl/docinfo";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";

import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";

(:declare option exist:serialize "method=xhtml media-type=text/html";:)

declare variable $max-pages-to-show := 20;

declare variable $dcoll := '/db/data/permanent/d/nl/proc';
declare variable $mcoll := collection('/db/data/permanent/m/nl');


declare function local:table-output($result, $query, $view as xs:string)
{
  let $serialization := export:set-serialization(if ($view eq 'table') then
                                                   'html'
                                                 else if ($view eq 'csv') then
                                                   'text'
                                                 else
                                                   'xml')

  let $xml-output := local:build-table($result, $query)

  let $header := <h1>Resultaten voor zoekopdracht: <code>{string($query)}</code></h1>

  let $output := if ($view eq 'table') then
                   ($header, export:html-output($xml-output))
                 else if ($view eq 'csv') then
                   export:csv-output($xml-output)
                 else if ($view eq 'xml') then
                   $xml-output
                 else
                   ()

  return export:output($view, $output, string($header))
};


(: returns HTML for search form and results :)
declare function local:build-page($results, $navigation, $page-summary, $form)
{
  let $title := "Zoeken in de Handelingen der Staten-Generaal"
  return
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nl" lang="nl">
    <head>
      <title>Political Mashup » {$title}</title>
      <link rel="stylesheet" href="search.css" type="text/css" />
      <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
            rel="stylesheet" type="text/css"/>
      <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"></script>
      <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
      <script src="autocomplete/autocomplete.js"></script>
    </head>
    <body>
      <a href="http://politicalmashup.nl">
        <img src="http://resolver.politicalmashup.nl/static/img/politicalmashup-small.png"
             alt="PoliticalMashup" style="float:right; border: 0" />
      </a>
      <h1>{$title}</h1>
      {$form}
      <hr/>
      {$navigation}
      {$page-summary}
      {$results}
      {$navigation}
    </body>
  </html>
};


(: make HTML display of results; returns sequence of <div>s :)
declare function local:show-results($results, $query, $start, $end)
{
  for $hit at $p in $results[position() = ($start + 1 to $end)]
    return local:make-snippet($hit, $p + $start, 0, 3, $query)
};

(: Find the last transformed documents. :)
declare function local:latest-document() {
  let $collection := collection('/db/data/permanent/d/nl/proc/ob')
  let $collection :=
    for $document in $collection
    let $date-transformed := $document//pmd:transformer[last()]/@pmd:datetime
    order by $date-transformed descending
    return $document
    
  let $latest-senate := ($collection[.//pm:house/@pm:house eq 'senate'])[last()]
  let $latest-commons := ($collection[.//pm:house/@pm:house eq 'commons'])[last()]
  
  return <span>Laatste TK vergadering datum {string($latest-commons//dc:date)}, verwerkt op {string($latest-commons//pmd:transformer[last()]/@pmd:datetime)}<br/>
               Laatste EK vergadering datum {string($latest-senate//dc:date)}, verwerkt op {string($latest-senate//pmd:transformer[last()]/@pmd:datetime)}.</span>
};


declare function local:search-form($query, $order)
{
  <form method="get" id="searchform">
    <table>
      <tr>
        <th align='left'>Laatste update (<a href="help.xq#update">?</a>)</th>
        <td>
          {local:latest-document()}
        </td>
      </tr>
      
      <tr>
        <th align='left'>Zoekopdracht (<a href="help.xq#queries">?</a>)</th>
        <td>
          <input name="q" type="text" size="40" value="{string($query/terms)}"/>
        </td>
      </tr>

      <tr>
        <th align="left">Spreker (<a href="help.xq#persons-parties">?</a>)</th>
        <td>
          <input id="speaker_name" size="40"/>
          <input name="speakers" id="speaker_id"
                 value="{string($query/speakers)}" />
        </td>
      </tr>
      <tr>
        <th align="left">Rol</th>
        <td>
        {
          local:radio("role", $query/speakers/@role,
                      (<opt value="">Alle</opt>,
                       <opt value="mp">Kamerlid</opt>,
                       <opt value="government">Kabinet</opt>,
                       <opt value="chair">Voorzitter</opt>,
                       <opt value="other">Overig</opt>))
        }
        </td>
      </tr>

      <tr>
        <th align="left">Partij (<a href="help.xq#persons-parties">?</a>)</th>
        <td>
          <select name="party" class="dropdown">
            <option value="">(Alle)</option>
            {
              for $p in parties:all-parties()
                return element option {
                  attribute value { $p/@id },
                  if ($p/@id eq $query/@party)
                    then attribute selected { "selected" }
                    else (),
                  $p/text()
                }
            }
          </select>
        </td>
      </tr>

      <tr>
        <th align="left">Leden van partij</th>
        <td>
          <select name="party-members" class="dropdown">
            <option value="">(Alle)</option>
            {
              for $p in parties:all-parties()
                return element option {
                  attribute value { $p/@id },
                  if ($p/@id eq $query/@party-members)
                    then attribute selected { "selected" }
                    else (),
                  $p/text()
                }
            }
          </select>
        </td>
      </tr>

      <tr>
        <th align="left">Kamer</th>
        <td>
        {
          local:radio("house", $query/@house,
                      (<opt value="">Beide</opt>,
                       <opt value="senate">Eerste</opt>,
                       <opt value="commons">Tweede</opt>))
        }
        </td>
      </tr>

      <tr>
        <th align="left">Datums (<a href="help.xq#date">?</a>)</th>
        <td>
          <input type="text" size="10" name="startdate"
                 value="{$query/date/@start}"/>Begindatum
          <input type="text" size="10" name="enddate"
                 value="{$query/date/@end}"/>Einddatum
        </td>
      </tr>

      <tr>
        <th align="left">Fijnmazigheid (<a href="help.xq#granularity">?</a>)</th>
        <td>
        {
          local:radio("granularity", $query/@granularity,
                      (<opt value="title">Titel van topic</opt>,
                       <opt value="topic">Topic</opt>,
                       <opt value="scene">Scène</opt>,
                       <opt value="">Speech</opt>))
        }
        </td>
      </tr>

      <tr>
        <th align="left">Volgorde (<a href="help.xq#sorting">?</a>)</th>
        <td>
        {
          local:radio("order", $order,
                      (<opt value="">Relevantie</opt>,
                       <opt value="chrono">Chronologisch</opt>,
                       <opt value="rchrono">Omgekeerd chron.</opt>,
                       <opt value="debatelength">Lengte debat</opt>))
        }
        </td>
      </tr>

      <tr>
        <th align="left">Uitvoer</th>
        <td>
        {
          local:radio("view", "html",
                      (<opt value="html">Regulier (HTML)</opt>,
                       <opt value="table">Tabel (HTML)</opt>,
                       <opt value="csv">Tabel (CSV)</opt>,
                       <opt value="xml">Tabel (XML)</opt>))
        }
        </td>
      </tr>

      <tr>
        <td>
          <input type="submit" id="searchbutton" value="Zoek"/>
          <small>(<a href="help.xq">hulp</a>)</small>
        </td>
      </tr>
    </table>
  </form>
};


(: Make a sequence of radio buttons for variable $name
 : with current value $value :)
declare function local:radio($name, $value, $options)
{
  for $opt in $options
    let $checked := ($opt/@value eq $value)
    return element input {
      attribute type { "radio" },
      attribute name { $name },
      attribute value { $opt/@value },
      if ($checked) then attribute checked { "checked" } else (),
      $opt/text()
    }
};


(: Get party for member $id at $date
 : XXX this should go in /modules/util.xqm
 :)
declare function local:party-at-date($id, $date)
{
  let $member := $mcoll//pm:member[@pm:id eq $id]
  let $period := $member//pm:membership/pm:period[pmutil:date-in-range($date,
                                                                       ./@pm:from,
                                                                       ./@pm:till)]
  return xs:string($period/../@pm:party-ref)
};


(: This should give a readable party name, but is just a hack for now. :)
declare function local:party-name($id)
{
  upper-case(functx:substring-after-match($id, "nl\.p\."))
};


(: build an HTML snippet (<div>) for $hit :)
declare function local:make-snippet($hit, $p, $start, $end, $query)
{
  let $date := xs:string($hit/root()//dc:date)
  return
  <div class="result">
    <span class="nr">{$p}.</span>

    <strong>{$date}</strong>

    <span class="title">
    {
      (: name and party of speaker, hyperlinked :)
      let $name-and-title := concat(xs:string($hit/@pm:function), " ",
                                    xs:string($hit/@pm:speaker))
      let $member-url := export:link-resolver($hit/@pm:member-ref, "html")

      let $party-id := local:party-at-date($hit/@pm:member-ref, $date)
      let $party-url := export:link-resolver($party-id, "html")
      let $party-name := local:party-name($party-id)

      return (<em><a href="{$member-url}">{$name-and-title}</a></em>,
              if ($party-name eq "")
                then ()
                else (" (", <a href="{$party-url}">{$party-name}</a>, ")")
             )
      }:

      {
        (: title of result topic, hyperlinked :)
        let $doc := $hit/root()//dc:identifier/text()
        let $html-url := export:link-resolver($doc, "html", string($hit/@pm:id),
                                              string($query/terms))
        let $tooltip := concat("Betoog van ", xs:string($hit/@pm:speaker),
                               " over dit onderwerp")

        let $title := $hit/ancestor-or-self::pm:topic/@pm:title
        let $title := functx:trim(xs:string($title))
        let $title := if ($title eq "")
                        then "(geen titel)"
                        else $title

        return <a title="{$tooltip}" href="{$html-url}">{$title}</a>
      }
    </span>

    {
      local:text-snippet($query, $hit, $start, $end)
    }

    <span class="block">
    {
      let $rawurl := export:link-resolver($hit/@pm:id)
      return <a href="{$rawurl}">
               <span class="url">{xs:string($hit/@pm:id)}</span>
             </a>
    }
    </span>
  </div>
};


declare function local:make-row($descr, $var)
{
  if (string($var) ne "") then
    <tr><td><strong>{$descr}</strong>:</td> <td>{string($var)}</td></tr>
  else
    ()
};


(: Query summary as a <table> :)
declare function local:query-summary($query)
{
  <table>
    { local:make-row("Termen", $query/terms) }
    {
      if (string($query/speakers) ne "") then
        <tr>
          <td><strong>Sprekercode</strong>:</td>,
          <td>
          {
            let $id := string($query/speakers)
            let $url := export:link-resolver($id, "html")
            return <a href="{$url}">{$id}</a>
          }
          </td>
        </tr>
      else
        ()
    }
    { local:make-row("Rol", $query/speakers/@role) }
    { local:make-row("Partijcode", $query/@party) }
    { local:make-row("Kamer", $query/@house) }
    { local:make-row("Begindatum", $query/date/@start) }
    { local:make-row("Einddatum", $query/date/@end) }
  </table>
};


declare function local:page-summary($query, $nresults, $start, $end, $perpage)
{
  let $how-many-on-this-page :=
    if ($nresults lt $perpage) then
      if ($nresults eq 0) then
        "ongeldige zoekopdracht of geen resultaten gevonden"
      else if ($nresults eq 1) then
        "één resultaat voor"
      else
        concat("alle ", $nresults, " resultaten voor")
    else
      concat("resultaat ", $start + 1, " tot ", min(($end, $nresults)),
             " van ", $nresults, " voor")

  return <div>
           <p>{$how-many-on-this-page}:</p>
           {local:query-summary($query)}
         </div>
};


(: functions to build a navigation bar :)
declare function local:make-nav-url($to)
{
  (: TODO replace this with a safer construct :)
  let $url-params-without-start := replace(request:get-query-string(),
                                           "&amp;start=\d+", "")
  return concat("?", $url-params-without-start, "&amp;start=", $to)
};


declare function local:make-nav-link($to, $text)
{
  <li><a href="{local:make-nav-url($to)}">{$text}</a></li>
};


declare function local:make-navigation($start, $end, $nresults, $perpage)
{
  let $number-of-pages := xs:integer(ceiling($nresults div $perpage))
  let $current-page := xs:integer(($start + $perpage) div $perpage)

  return
    if ($nresults lt $perpage) then ()
    else
      <div id="search-pagination">
        <ul>
          {local:make-nav-link(0, "eerste")}
          {
            if ($current-page = 1)
              then <li>vorige</li>
              else
                local:make-nav-link($perpage * ($current-page - 2), "vorige")
          }

          {
            let $padding := xs:integer(round($max-pages-to-show div 2))
            let $start-page :=
              if ($current-page le ($padding + 1))
                then 1
                else $current-page - $padding
            let $end-page :=
              if ($number-of-pages le ($current-page + $padding))
                then $number-of-pages
                else $current-page + $padding - 1
            for $page in ($start-page to $end-page)
              let $newstart := $perpage * ($page - 1)
              return
                if ($newstart eq $start)
                  then (<li>{$page}</li>)
                  else local:make-nav-link($newstart, $page)
          }

          {
            if ($start + $perpage ge $nresults)
              then <li>volgende</li>
              else local:make-nav-link($start + $perpage, "volgende")
          }

          {local:make-nav-link(($number-of-pages - 1) * $perpage, "laatste")}
        </ul>
      </div>
};


declare function local:text-snippet($query, $hit, $start, $end)
{
  if (string($query/@granularity) ne "title") then
    for $p in (kwic:expand($hit)//pm:p[exist:match])[position() ge $start
                                                 and position() le $end]
    let $url := export:link-resolver(root($hit)//dc:identifier, "html",
                                     $p/@pm:id, $query)
    return
      <span class="snippet">
      {
        kwic:get-summary($p, ($p//exist:match)[1],
                         <config width="70" link="{$url}"/>)
      }
      </span>
  else
    <span class="snippet">
    {
      substring(string(($hit/parent::pm:topic//pm:p)[1]), 1, 200)
    }...
    </span>
};


(: make HTML display of results; returns sequence of <div>s :)
declare function local:build-table($results, $query)
{
  let $column-names := export:xml-util-headers(('date','speaker','member-ref','party','topic-name','html context url', 'xml url', 'snippet'))

  let $items :=
    for $hit in $results
    return
      export:xml-row(
        (
          export:xml-item($hit/root()//dc:date),
          export:xml-item($hit/@pm:speaker),
          export:xml-item($hit/@pm:member-ref),
          export:xml-item($hit/@pm:party-ref),
          export:xml-item($hit/ancestor-or-self::pm:topic/@pm:title),
          export:xml-item(export:link-resolver(root($hit)//dc:identifier,
                                               'html', $hit/@pm:id, $query),
                          <options link="true" display="context link"/>),
          export:xml-item(export:link-resolver($hit/@pm:id),
                          <options link="true"/>),
          export:xml-item(local:text-snippet($query, $hit, 0, 3),
                          <options copy="true"/>)
          )
        )

  return export:xml-output( ($column-names, $items) )
};


(: construct search query :)
(: if speaker given, then reset house, party, role :)
let $speakers := request:get-parameter("speakers", "")
let $house := if ($speakers eq "") then
                request:get-parameter("house", "")
              else
                ""
let $party := if ($speakers eq "") then
                request:get-parameter("party", "")
              else
                ""
let $role := if ($speakers eq "") then
               request:get-parameter("role", "")
             else
               ""
let $party-members := if ($speakers eq "") then
                        request:get-parameter("party-members", "")
                      else
                        ""
let $query :=
  <query house='{$house}' party='{$party}'
         granularity='{request:get-parameter("granularity", "")}'
         party-members='{$party-members}'>
    <speakers negate='{request:get-parameter("negate-speakers", "")}'
              role='{$role}'>
      {request:get-parameter("speakers", "")}
    </speakers>
    <date start='{request:get-parameter("startdate", "")}'
          end='{request:get-parameter("enddate", "")}'/>
    <terms>{request:get-parameter("q", <noquery/>)}</terms>
  </query>

let $result := pmsearch:search($query, $dcoll)
let $order := request:get-parameter("order", "")
let $result := pmsearch:sort-hits($result, $order)

let $request := export:request-parameters((<view accept="csv,table,xml"/>))

return
  if ($request/@view) then
    local:table-output($result, $query, $request/@view)
  else
    (: paginated HTML results page :)
    let $default-perpage := 10
    let $default-start := 0

    let $perpage := xs:integer(request:get-parameter("perpage", $default-perpage))
    let $start := xs:integer(request:get-parameter("start", $default-start))

    let $nresults := count($result)
    let $end := if ($nresults lt $perpage) then
                  $nresults
                else
                  $start + $perpage

    let $serialization := export:set-serialization('html')
    let $form := local:search-form($query, $order)
    let $nav := local:make-navigation($start, $end, $nresults, $perpage)
    let $show-results := local:show-results($result, $query, $start, $end)
    let $summary := local:page-summary($query, $nresults, $start, $end, $perpage)

    return local:build-page($show-results, $nav, $summary, $form)