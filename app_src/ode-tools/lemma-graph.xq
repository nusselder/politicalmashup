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





declare function local:lemma-per-day($collection, $request as element(request)) {

(:
  let $terms := $collection//cloud[@w eq '0.100000'][@pos eq $request/@pos]//term[. eq $request/@lemma]
  
  let $items :=
    for $t in $terms
    let $date := root($t)//dc:date
    let $score := $t/@prob
    order by $date
    return
      export:xml-row(
        (
        export:xml-item($date),
        export:xml-item($score)
        )
      )
      :)
      
  let $clouds := $collection//cloud[@w eq '0.100000'][@pos eq $request/@pos]
  
  let $items :=
    for $c in $clouds
    let $date := root($c)//dc:date
    (:let $score := $c//term[. eq $request/@lemma]/@prob:)
    let $score := max($c//term[. eq $request/@lemma]/@prob)
    group by $date
    order by $date
    return
      export:xml-row(
        (
        export:xml-item($date),
        export:xml-item(if ($score) then $score else 0)
        )
      )
  
  let $headers := (
    export:xml-util-description(concat('Lemma graph for: ',$request/@lemma)),
    export:xml-util-headers( ('date','prob') )
    )
    
  return export:xml-output( ($headers, $items) )
};





declare function local:output-html($parts as element()*, $data, $title as xs:string, $style as xs:string) as element() {
  <html>
    <head>
      {if ($title ne '') then <title>{$title}</title> else ()}
      {export:html-css()}
      {if ($style ne '') then <style>{$style}</style> else ()}
      {local:chart-header($data)}
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
    (:else concat("['",$line/item[1]/@string,"',",$line/item[2]/@string,"],&#10;"):)
    (:else concat("[new Date(",$date-date,"),",$line/item[2]/@string,"],&#10;"):)
    else concat("[new Date('",$line/item[1]/@string,"'),",$line/item[2]/@string,"],&#10;")
};

declare function local:chart-container() {
  <div id="chart_div" style="width: 900px; height: 500px;"></div>
};

declare function local:chart-header($data as xs:string*) {
  let $start := 'google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ["Date", "max prob"],'
          
   let $end := ']);
        var options = {
          title: "Lemma max day probability",
          curveType: "function"
        };

        var chart = new google.visualization.LineChart(document.getElementById("chart_div"));
        chart.draw(data, options);
      }'

   return
    (<script type="text/javascript" src="https://www.google.com/jsapi"></script>,
    <script type="text/javascript">
    {$start}
    {$data}
    {$end}
    </script>)
};


let $accepted-collections := string-join(export:build-collection-tree(true()),',')

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>,
                                            (:<count accept="{$count-queries}"/>,:)
                                            <lemma/>,
                                            <pos default="all" accept="all,ADJ,N,WW"/>,
                                            <collection accept="{$accepted-collections}"/>) )

let $options := export:options( (
                                  (:<count explanation="choose example query" select="{$count-queries}"/>,:)
                                  <view explanation="view output as html table or plain text csv" select="csv,table"/>,
                                  <lemma explanation="lemma to search for"/>,
                                  <pos explanation="pos-tag" select="all,ADJ,N,WW"/>,
                                  <collection explanation="available leaf collections" select="{$accepted-collections}"/>
                                ),
                                $request)


let $collection := local:select-collection($request)

let $xml-output := local:lemma-per-day($collection,$request)

let $introduction-html :=
    <div>
      <p>Search for documents containing pre-computed entities.</p>
      {local:chart-container()}
    </div>
    
let $search-form := export:html-util-generate-search-form($options, $request)

let $output := if ($request/@view eq 'table') then ($introduction-html, $search-form, export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $script-data := local:chart-line($xml-output)

(:let $output := export:output($request/@view, $output, 'ODE-II FoLiA Entity Search'):)
let $output := local:output-html($output, $script-data, 'ODE-II FoLiA Entity Search', '')

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

return $output
