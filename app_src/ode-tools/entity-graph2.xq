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
  (:let $date-date := replace($line/item[1]/@string,'-',','):)
  return
    if ($line[self::head]) then ()
    (:else concat("['",$line/item[1]/@string,"',",$line/item[2]/@string,",",$line/item[3]/@string,"],&#10;"):)
    (:else concat("[new Date(",$date-date,"),",$line/item[2]/@string,",",$line/item[3]/@string,"],&#10;"):)
    else concat("[new Date('",$line/item[1]/@string,"'),",$line/item[2]/@string,",",$line/item[3]/@string,"],&#10;")
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
          title: "Entity occurence"
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






declare function local:entity-per-day($collection, $request as element(request)) {

  let $wiki-link := local:fix-wikilink-input($request)

  let $items :=
    for $docs in $collection
    let $date := $docs//dc:date
    let $links := $docs//pm:link[. eq $wiki-link]
    let $nr-docs := count($links)
    let $nr-occ := sum($links/@pmx:entity-occurence)
    group by $date
    order by $date
    return
      export:xml-row(
        (
        export:xml-item($date),
        export:xml-item($nr-docs),
        export:xml-item($nr-occ)
        )
      )
  
  let $headers := (
    export:xml-util-description(concat('Entity graph for: ',$wiki-link)),
    export:xml-util-headers( ('date','#doc','#occ') )
    )

  return export:xml-output( ($headers, $items) )
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
(:let $xml-output := local:documents-per-month-efficient($collection,$request):)
(:let $xml-output := local:documents-per-year($collection,$request):)
(:let $xml-output := local:documents-per-day($collection,$request):)
let $xml-output := local:entity-per-day($collection,$request)

let $introduction-html :=
    <div>
      <p>Below a timeline is shown for a previously detected (pre-computed) Wikipedia entity link.
         Data is shown per month, with both the number of documents, and total number of mentions within these documents.</p>
      <p>Clicking the chart on a specific point will link to a search for the actual documents.</p>
      {local:chart-container()}
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

(:let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output)):)
let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form)
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $script-data := local:chart-line($xml-output)

(:let $output := export:output($request/@view, $output, 'ODE-II FoLiA Entity Search'):)
let $output := local:output-html($output, $script-data, $request, 'ODE-II FoLiA Entity Search', '')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output
