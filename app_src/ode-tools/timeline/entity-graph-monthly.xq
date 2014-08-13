xquery version "3.0" encoding "UTF-8";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmx = "http://www.politicalmashup.nl/extra";
declare namespace folia = "http://ilk.uvt.nl/FoLiA";
declare namespace local = "local";

import module namespace datetime="http://exist-db.org/xquery/datetime";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';
import module namespace export="http://politicalmashup.nl/modules/export";
import module namespace functx="http://www.functx.com";


declare function local:select-collection($request) {
  if ($request/@collection) then collection(concat($settings:data-root,'/',$request/@collection))
  else ()
};



declare function local:summarise-entity-names($entity-names as xs:string*) as xs:string {
  let $collapsed := for $en in $entity-names
                    let $name := xs:string($en)
                    group by $name
                    return <en n="{$name}" c="{count($en)}"/>
(:                    return concat($name,' (',count($en),')'):)
  let $strings := for $en in $collapsed order by xs:decimal($en/@c) descending return concat($en/@n,' (',$en/@c,')')
  return string-join($strings,', ')
};



declare function local:documents-per-month($collection, $request as element(request)) {

  let $wiki-link := local:fix-wikilink-input($request)
  
  let $document-links := $collection//dc:relation/pm:link[. eq $wiki-link]

  let $link-docs := for $dl in $document-links return root($dl)//meta

  let $dates := for $d in $link-docs//dc:date order by $d return $d
  
  let $distinct-dates := distinct-values($dates)
  
  let $first-date := $dates[1]
  let $last-date := $dates[last()]
  
  let $headers := (
    export:xml-util-description(concat('Entity graph for: ',$wiki-link)),
    export:xml-util-description(concat('From ',$first-date,' until ',$last-date)),
    export:xml-util-headers( ('date','#doc','#occ') )
    )
    
  (: Generate date/month list. :)
  let $first-year := xs:integer(substring($first-date,1,4))
  let $last-year := xs:integer(substring($last-date,1,4))
  let $date-months :=
    for $year in ($first-year to $last-year)
    return
      for $month in (1 to 12)
      let $m := if ($month le 9) then concat('0',xs:string($month)) else xs:string($month)
      return
        concat(xs:string($year),'-',$m)
  
  
  let $items :=
    for $dm in $date-months
    let $docs := $link-docs[substring(.//dc:date,1,7) eq $dm]
    let $occ := sum($docs//dc:relation/pm:link[. eq $wiki-link]/@pmx:entity-occurence)
    return
      export:xml-row(
        (
        export:xml-item($dm),
        export:xml-item(count($docs)),
        export:xml-item($occ)
        )
      )
  
  return export:xml-output( ($headers, $items) )
};




declare function local:documents-per-month-efficient($collection, $request as element(request)) {

  let $wiki-link := local:fix-wikilink-input($request)
  
  let $document-containers :=
    for $link in $collection//dc:relation/pm:link[. eq $wiki-link]
    let $date := xs:string(root($link)//dc:date)
    where $date ne '' (: ode Amsterdam data sometimes does not have a date, filter these.. :) 
    return
      <doc date="{$date}" date-month="{substring($date,1,7)}">
      {$link}
      </doc>

  let $docs :=
    for $doc in $document-containers
    let $date-month := $doc/@date-month
    group by $date-month
    return
      <doc date-month="{$date-month}" cnt-doc="{count($doc)}" cnt-occ="{sum($doc//pm:link/@pmx:entity-occurence)}"/>
  
  
  let $date-months := for $dm in $document-containers/@date-month order by $dm return $dm
  let $first-date := $date-months[1]
  let $last-date := $date-months[last()]
  
  (: Generate date/month list. :)
  let $date-months :=
    if ($first-date ne '' and $last-date ne '') then
    let $first-year := xs:integer(substring($first-date,1,4))
    let $last-year := xs:integer(substring($last-date,1,4))
    return
      for $year in ($first-year to $last-year)
      return
        for $month in (1 to 12)
        let $m := if ($month le 9) then concat('0',xs:string($month)) else xs:string($month)
        return
          concat(xs:string($year),'-',$m)
    else () 
  
  let $headers := (
    export:xml-util-description(concat('Entity graph for: ',$wiki-link)),
    export:xml-util-description(concat('From ',$first-date,' until ',$last-date)),
    export:xml-util-headers( ('date','#doc','#occ','entity search link') )
    )
  
  let $items :=
    for $dm in $date-months
    let $dm-doc := $docs[@date-month eq $dm]
    return
      export:xml-row(
        (
        export:xml-item($dm),
        export:xml-item(if ($dm-doc) then $dm-doc/@cnt-doc else 0),
        export:xml-item(if ($dm-doc) then $dm-doc/@cnt-occ else 0),
        export:xml-item(concat('entity-search.xq?entity=',$request/@entity,'&amp;collection=',$request/@collection,'&amp;month=',$dm), <options link="true"/>)
        )
      )
  
  return export:xml-output( ($headers, $items) )
};



declare function local:documents-per-year($collection, $request as element(request)) {

  let $wiki-link := local:fix-wikilink-input($request)
  
  let $document-links := $collection//dc:relation/pm:link[. eq $wiki-link]

  let $link-docs := for $dl in $document-links return root($dl)//meta

  let $dates := for $d in $link-docs//dc:date order by $d return $d
  
  let $distinct-dates := distinct-values($dates)
  
  let $first-date := $dates[1]
  let $last-date := $dates[last()]
  
  let $headers := (
    export:xml-util-description(concat('Entity graph for: ',$wiki-link)),
    export:xml-util-description(concat('From ',$first-date,' until ',$last-date)),
    export:xml-util-headers( ('date','#doc','#occ') )
    )
    
  (: Generate date/month list. :)
  let $first-year := xs:integer(substring($first-date,1,4))
  let $last-year := xs:integer(substring($last-date,1,4))
  let $date-months :=
    for $year in ($first-year to $last-year)
    return xs:string($year)
  
  
  let $items :=
    for $dm in $date-months
    let $docs := $link-docs[substring(.//dc:date,1,4) eq $dm]
    let $occ := sum($docs//dc:relation/pm:link[. eq $wiki-link]/@pmx:entity-occurence)
    return
      export:xml-row(
        (
        export:xml-item($dm),
        export:xml-item(count($docs)),
        export:xml-item($occ)
        )
      )
  
  return export:xml-output( ($headers, $items) )
};


declare function local:documents-per-day($collection, $request as element(request)) {

  let $wiki-link := local:fix-wikilink-input($request)
  
  let $document-links := $collection//dc:relation/pm:link[. eq $wiki-link]

  let $link-docs := for $dl in $document-links return root($dl)//meta

  let $dates := for $d in $link-docs//dc:date order by $d return $d
  
  let $distinct-dates := distinct-values($dates)
  
  (: Let's add the days before and after the actual dates, which will automatically get 0 docs/occ. :)
  let $distinct-dates :=
    for $d in $distinct-dates
    let $xsd := xs:date($d)
    let $day-before := $xsd - xs:dayTimeDuration("P1D")
    let $day-after := $xsd + xs:dayTimeDuration("P1D")
    return ($day-before,$xsd,$day-after)
    
  let $distinct-dates := distinct-values($distinct-dates)
  
  let $headers := (
    export:xml-util-description(concat('Entity graph for: ',$wiki-link)),
    export:xml-util-headers( ('date','#doc','#occ') )
    )
    
  
  let $items :=
    for $date in $distinct-dates
    let $docs := $link-docs[.//dc:date eq $date]
    let $occ := sum($docs//dc:relation/pm:link[. eq $wiki-link]/@pmx:entity-occurence)
    return
      export:xml-row(
        (
        export:xml-item($date),
        export:xml-item(count($docs)),
        export:xml-item($occ)
        )
      )
  
  return export:xml-output( ($headers, $items) )
};




(: Escape input entity query, because xml (and index!) contains escaped strings. :)
declare function local:fix-wikilink-input($request) {
  (: Cut off the escaped part after the wiki link, then unescape the entity (in case input is actually escaped already), and escape the string, then combine again. :)
  concat(
    substring-before($request/@entity,'/wiki/'), '/wiki/',
    replace(
      encode-for-uri(    
        util:unescape-uri(substring-after($request/@entity,'/wiki/'),'UTF-8')
      ), '%2F', '/'
    )
  )
};


declare function local:output-html($parts as element()*, $data, $request as element(request), $title as xs:string, $style as xs:string) as element() {
  <html>
    <head>
      {if ($title ne '') then <title>{$title}</title> else ()}
      {export:html-css()}
      {if ($style ne '') then <style>{$style}</style> else ()}
      {local:chart-header($data, $request)}
    </head>
    <body>
      {$parts}
    </body>
  </html>
};

declare function local:chart-line($xml-output) {
  for $line in $xml-output/*
  let $date-date := replace($line/item[1]/@string,'-',',')
  return
    if ($line[self::head]) then ()
    else concat("['",$line/item[1]/@string,"',",$line/item[2]/@string,",",$line/item[3]/@string,"],&#10;")
    (:else concat("[new Date(",$date-date,"),",$line/item[2]/@string,",",$line/item[3]/@string,"],&#10;"):)
};

declare function local:chart-container() {
  <div id="chart_div" style="width: 900px; height: 500px;"></div>
};

declare function local:chart-header($data as xs:string*, $request as element(request)) {
  let $start := 'google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ["Year-month", "#documents", "#occurences"],'
          
   let $end := concat(']);
        var options = {
          title: "Entity occurence: ',$request/@entity,'"
        };

        var chart = new google.visualization.LineChart(document.getElementById("chart_div"));
        
        // The select handler. Calls the getSelection() method
        function selectHandler() {
          var selectedItem = chart.getSelection()[0];
          if (selectedItem) {
            //var value = data.getValue(selectedItem.row, selectedItem.column);
            var search_url = entity_url("',$request/@entity,'","',$request/@collection,'",data.getValue(selectedItem.row, 0))
            window.location = search_url;
          }
        }

        google.visualization.events.addListener(chart, "select", selectHandler);
        
        chart.draw(data, options);
      }')

   return
    (<script type="text/javascript" src="https://www.google.com/jsapi"></script>,
    <script type="text/javascript" src="entity.js"></script>,
    <script type="text/javascript">
    {$start}
    {$data}
    {$end}
    </script>)
};


let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $count-queries := 'entities,documents'

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            (:<count accept="{$count-queries}"/>,:)
                                            <entity/>,
                                            <collection accept="{$accepted-collections}"/>) )

let $options := export:options( (
                                  (:<count explanation="choose example query" select="{$count-queries}"/>,:)
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>,
                                  <entity explanation="entity as wikilink to search for"/>,
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>,
                                  <entity-escaped value="{local:fix-wikilink-input($request)}" explanation="escaped wiki link used for querying"/>
                                ),
                                $request)


let $collection := local:select-collection($request)

(:let $xml-output := if ($request/@count eq 'entities') then local:entities($collection,$request)
                   else if ($request/@count eq 'documents') then local:documents($collection,$request)
                   else ():)
(:let $xml-output := local:documents-per-month($collection,$request):)
let $xml-output := local:documents-per-month-efficient($collection,$request)
(:let $xml-output := local:documents-per-year($collection,$request):)
(:let $xml-output := local:documents-per-day($collection,$request):)

let $introduction-html :=
    <div>
      <p>Below a timeline is shown for a previously detected (pre-computed) Wikipedia entity link.
         Data is shown per month, with both the number of documents, and total number of mentions within these documents.</p>
      <p>Clicking the chart on a specific point will link to a search for the actual documents.</p>
      {local:chart-container()}
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

(:  :let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output)) :)
let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form)
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $script-data := local:chart-line($xml-output)

(:let $output := export:output($request/@view, $output, 'ODE-II FoLiA Entity Search'):)
let $output := local:output-html($output, $script-data, $request, 'ODE-II FoLiA Entity Search', '')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output
