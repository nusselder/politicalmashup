xquery version "1.0" encoding "UTF-8";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmd = "http://www.politicalmashup.nl/docinfo";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";


declare function local:build-collection-tree($only-leafs as xs:boolean) as xs:string* {
  for $c in local:build-collection-tree('', $only-leafs) order by $c return $c
};
declare function local:build-collection-tree($current as xs:string, $only-leafs as xs:boolean) as xs:string* {
  for $c in xmldb:get-child-collections(concat('/db/data/permanent/',$current))
  let $current-child := if ($current ne '') then concat($current,'/',$c) else $c (: Prevent double '/' :)
  let $children := local:build-collection-tree($current-child, $only-leafs)
  return if (empty($children)) then $current-child else if ($only-leafs) then $children else ($children, $current-child)
};


declare function local:run() {
  let $request := export:request-parameters( (
    <view default="csv" accept="csv,table,xml"/>,
    <prefix/>,
    <project/>,
    <keyfile/>,
    <password/>,
    <since type="xs:dateTime"/>,
    <collection accept="{string-join(export:build-collection-tree(true()),',')}"/>) )
  
  let $options := export:options( (
    <prefix explanation="global handle prefix, without trailing '/', e.g. 11145 for ILPS"/>,
    <project explanation="project abbreviation within ILPS, e.g. 'pm' for PoliticalMashup, used for internal disambiguation"/>,
    <keyfile explanation="absolute reference to admin keyfile on disk"/>,
    <password explanation="passphrase with which the keyfile is encrypted; N.B. will be visible in plain text!"/>,
    <since explanation="xs:dateTime from when (transformed) on documents should be listed, cf. list-updates.xq"/>,
    <collection explanation="collection to list"  select="{string-join(('---',export:build-collection-tree(true())),',')}"/>,
    <view explanation="select csv to get a downloadable batch text file" select="csv,table"/>
    ), $request )
  
  let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )
  
  let $xml-output := if (empty($request/@prefix) or empty($request/@project) or empty($request/@collection))
    then if ($request/@view eq 'csv') then export:xml-output(export:xml-row(export:xml-item('#N.B. No items found. Add ?view=table to the url to see an interface.')), true()) else ()
    else local:items($request)
    
  
  let $explanation := <div><p>Create a batch processing file for Handle. The output is really only makes sense in plain text (csv) format.<br/>All arguments are in principle required, but you can leave out keyfile and password to see example output.</p></div>

  let $output := if ($request/@view eq 'table') then ($explanation,
                                                      export:html-util-generate-search-form($options, $request), export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

  let $output := if ($request/@view eq 'csv') then export:output('csv', $output)
                 else export:output($request/@view, $output, 'Handle batch file generator')

  return $output
};


declare function local:handle-value($index as xs:integer, $type as xs:string, $data as item()?) as xs:string {
  if ($data) then
    concat(string($index),' ',$type,' 86400 1110 UTF8 ',string($data))
  else
    concat(string($index),' ',$type,' 86400 1110 UTF8 -')
};



declare function local:handle-create($document, $prefix, $project) {
    let $identifier := $document//dc:identifier
    let $handle := concat($prefix,'/',$project,':',$identifier)
    return
      (
      (:'',
      concat('DELETE ',$handle),:)
      '',
      concat('CREATE ',$handle),
      concat('100 HS_ADMIN 86400 1110 ADMIN 200:111111111111:0.NA/',$prefix)
      )
};


(: Currently, view=rdf is not valid for parliamentary documents. :)
declare function local:handle-values($document) as xs:string* {
(: dc:source, dc:subject and dc:relation are not shown since they have no natural conversion of ./text(). :)
  let $identifier := $document//dc:identifier
  let $document-type := if ($document//dc:type eq 'Verbatim Proceedings') then 'proceeding' else 'other'
  let $get-api := if ($document-type eq 'proceeding') then 'Additional arguments for the document can be given with @arg1=value1&amp;arg2=value2. Valid arguments are part, view, q'
                                                      else 'Additional arguments for the document can be given with @arg1=value1&amp;arg2=value2. Valid argument is view.'
  return
    (
    local:handle-value(1, 'URL', export:link-resolver($identifier)),
    local:handle-value(10, 'DC_IDENTIFIER', $document//dc:identifier),
    local:handle-value(11, 'DC_FORMAT', $document//dc:format),
    local:handle-value(12, 'DC_TYPE', $document//dc:type),
    local:handle-value(13, 'DC_CONTRIBUTOR', $document//dc:contributor),
    local:handle-value(14, 'DC_COVERAGE', $document//dc:coverage),
    local:handle-value(15, 'DC_CREATOR', $document//dc:creator),
    local:handle-value(16, 'DC_LANGUAGE', $document//dc:language),
    local:handle-value(17, 'DC_PUBLISHER', $document//dc:publisher),
    local:handle-value(18, 'DC_RIGHTS', $document//dc:rights),
    local:handle-value(19, 'DC_DATE', $document//dc:date),
    local:handle-value(20, 'DC_TITLE', $document//dc:title),
    local:handle-value(21, 'DC_DESCRIPTION', $document//dc:description),
    local:handle-value(30, 'GET-API', $get-api),
    local:handle-value(31, 'GET-API-view', 'Presentation of the document in xml, html or rdf; default is xml. Valid are: view=xml view=html view=rdf'),
    if ($document-type eq 'proceeding') then local:handle-value(32, 'GET-API-part', 'Direct entry to structural parts of the document. Example: part=1.2') else (),
    if ($document-type eq 'proceeding') then local:handle-value(33, 'GET-API-q', 'Highlight a specific query, in lucene syntax, in the document. Example: q=storm*') else ()
    )
};


declare function local:items($request) {

  let $collection := if ($request/@collection) then collection(concat('/db/data/permanent/',$request/@collection)) else ()
  let $collection := if ($request/@prefix) then $collection else ()
  let $collection := if ($request/@since) then $collection[.//pmd:transformer/@pmd:datetime ge xs:dateTime($request/@since)]
                     else $collection
  
  let $prefix := string($request/@prefix)
  let $project := string($request/@project)
  
  (: Create items, note the item with many options: these will be picked up by the scrapy redo script. :)
  let $items :=
      for $document in $collection
      let $handle-create := local:handle-create($document, $prefix, $project)
      let $handle-values := local:handle-values($document)
      return
        for $line in ($handle-create, $handle-values)
        return
          export:xml-row(export:xml-item($line, <options disable-quote-escape="true"/>))

  
  let $items := (
    export:xml-row(export:xml-item(concat('AUTHENTICATE PUBKEY:300:0.NA/',$prefix))),
    export:xml-row(export:xml-item(concat($request/@keyfile,'|',$request/@password))),
    $items)
    
  (: Example:  

AUTHENTICATE PUBKEY:300:0.NA/11127
/<handle-dir>/svr_1/admpriv.bin|handle-test

DELETE 11127/pm.nl.p.cda

CREATE 11127/pm.nl.p.cda
100 HS_ADMIN 86400 1110 ADMIN 200:111111111111:0.NA/11127
1 URL 86400 1110 UTF8 http://resolver.politicalmashup.nl/nl.p.cda
11 DC_IDENTIFIER 86400 1110 UTF8 nl.p.cda
12 DC_TYPE 86400 1110 UTF8 Political Parties
13 DC_TITLE 86400 1110 UTF8 Christen-Democratisch Appel
14 DC_DESCRIPTION 86400 1110 UTF8 Party information for: Christen-Democratisch Appel
  :)
    
  let $xml := export:xml-output($items, true())
  
  return $xml
};



local:run()