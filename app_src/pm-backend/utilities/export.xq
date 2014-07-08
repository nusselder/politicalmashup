xquery version "1.0" encoding "UTF-8";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmd = "http://www.politicalmashup.nl/docinfo";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace util="http://exist-db.org/xquery/util";

import module namespace export="http://politicalmashup.nl/modules/export";

(:
TODO: WTF! using source= in the url forces eXist to output in text/plain. I suspect some kind of hardcoded thingy somewhere..

See e.g. http://exist-open.markmail.org/message/xepunn4mhb7eln6s?q=source+plain+text#query:source%20plain%20text+page:1+mid:xepunn4mhb7eln6s+state:results
:)



(: Copy of resolver/modules/resovler.xqm code that parses identifiers. :)
declare function local:document-type-from-path($path) {
  if (contains($path,".m.")) then 'm'
  else if (contains($path,".p.")) then 'p'
  else if (contains($path,".d.")) then 'd'
  else ''
};
declare function local:local-id-from-local-part($local-part) {

  (: Namescape special case. :)
  if (matches($local-part, "\.[sk]")) then
    string-join( (tokenize($local-part, "\.")[position() < 3]), ".")
    
  (: Since the local id can not contain a dot, everything before the first dot is the local id. :)
  else tokenize($local-part, "\.")[1]
};
declare function local:parse-identifier($path) {

  let $document-type := local:document-type-from-path($path)
  
  (: Split the path on the document-type, to get the collection-part and the id+section local-part. :)
  let $path-tokens := tokenize($path, concat("\.",$document-type,"\."))
  let $collection-part := $path-tokens[1]
  let $local-part := $path-tokens[2]
  
  let $local-id := local:local-id-from-local-part($local-part)

  (: The section within a document is everything after the local id. :)
  let $section-part := substring-after($path, $local-id)
  
  (: The part matching de dc:identifier element in our document/meta :)
  let $document-id := if ($section-part ne '') then substring-before($path, $section-part) else $path
  
  (: Construct the database paths, based on the identifier parts. :)
  let $collection-path := concat($document-type, "/", replace($collection-part, "\.", "/"))
  let $database-path := concat("/db/data/permanent/", $collection-path)
  let $resource-path := concat($database-path, "/", $document-id, ".xml")
  
  return
    <identifier>
      <path>{$path}</path>
      <document-type>{$document-type}</document-type>
      <collection-part>{$collection-part}</collection-part>
      <local-part>{$local-part}</local-part>
      <local-id>{$local-id}</local-id>
      <section-part>{$section-part}</section-part>
      <document-id>{$document-id}</document-id>
      <collection-path>{$collection-path}</collection-path>
      <database-path>{$database-path}</database-path>
      <resource-path>{$resource-path}</resource-path>
    </identifier>
};





declare function local:create-output() {
  let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <from type="xs:date"/>, <till type="xs:date"/>,
                                            <collection accept="{string-join(export:build-collection-tree(false()),',')}"/>,
                                            <collections accept="{string-join(export:build-collection-tree(false()),',')}" tokenize-split="\|" tokenize-join="|"/>,
                                            <house accept="commons,senate,other" tokenize-split="\|" tokenize-join="|"/>,
                                            <src/>,
                                            <output accept="xml,html,rdf,meta,docinfo" tokenize-split="\|" tokenize-join="|"/>,
                                            <rest accept="true,false" default="false"/>,
                                            <infofields default="legislative-period|date|house|id" accept="legislative-period,date,house,id,none" tokenize-split="\|" tokenize-join="|"/>) )

(: Create self-documenting set of options to describe the results found. :)
  let $options := export:options( (
    <collection explanation="collection to list"  select="{string-join(('---',export:build-collection-tree(true())),',')}"/>,
    <collections explanation="manually define multiple collections, seperated with '|' (overwrite collection above)"/>,
    <from explanation="xs:date from meeting date"/>,
    <till explanation="xs:date till meeting date"/>,
    <house explanation="body of legislature, single one or multiples seperated by '|', typically: 'commons', 'senate', 'commons|senate'"/>,
    <src explanation="html, pdf, xml, or any combination seperated by '|' (not all src may be defined)"/>,
    <output explanation="xml, html, rdf, meta, docinfo, rest, or any combination seperated by '|', or empty"/>,
    <rest explanation="true|false, give rest points to the raw stored xml; this is the fastest for data dumps"/>,
    <infofields explanation="legislative-period, date, house, id, or any combination seperated by '|', or 'none' for no fields"/>
                                ),
                                $request)

  let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

  let $xml-output := local:list-documents($request)

  let $example := <div>
    <p>Create lists of downloadable files as are available on our server.<br/>
    For example, list all downloadable xml files from the Dutch proceedings that describe meetings since 2012-10-01: <a href="?collection=d%2Fnl%2Fproc%2Fob&amp;collections=&amp;from=2012-10-01&amp;output=xml&amp;infofields=none">table</a> (or as <a href="?collection=d%2Fnl%2Fproc%2Fob&amp;from=2012-10-01&amp;output=xml&amp;infofields=none&amp;view=csv">csv</a>)<br/>
    Please note that requesting a list of many documents can take some time to generate.</p>
  </div>

  let $output := if ($request/@view eq 'table') then ($example, export:html-util-generate-parameter-links($request, 'view', ('table','csv')), export:html-util-generate-search-form($options, $request), export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

  let $output := export:output($request/@view, $output, 'Export: list available documents')

  return $output
};


declare function local:list-documents($request) {
  let $from-xsdate := if ($request/@from) then xs:date($request/@from) else ()
  let $till-xsdate := if ($request/@till) then xs:date($request/@till) else ()
  let $houses := tokenize($request/@house,'\|')
  let $sources := tokenize($request/@src,'\|')
  let $outputs := tokenize($request/@output,'\|')
  
  let $collection :=
    if ($request/@collections) then local:get-collection($request/@collections)
    else if ($request/@collection) then collection(concat('/db/data/permanent/',$request/@collection)) else ()
  let $collection := if ($request/@from) then $collection[.//dc:date ge $from-xsdate] else $collection
  let $collection := if ($request/@till) then $collection[.//dc:date le $till-xsdate] else $collection
  let $collection := if ($request/@house) then $collection[.//pm:house/@pm:house = $houses] else $collection
  
  let $sources-header := for $s in $sources return concat('src: ',$s)
  let $outputs-header := for $o in $outputs return concat('output: ',$o)
  let $rest-header := if ($request/@rest eq 'true') then 'rest' else ()
  let $info-fields := if ($request/@infofields eq 'none') then () else tokenize($request/@infofields,'\|')[. ne 'none'] 
  let $column-names := export:xml-util-headers( ($info-fields, $sources-header, $outputs-header, $rest-header) )
  
  let $rest-url := 'http://localhost:8080/exist/rest/db/data/permanent/'
  
  let $items :=
    for $document in $collection
    let $identifier := $document//dc:identifier
    let $date := $document//dc:date
    let $resolver-url := export:link-resolver($identifier)
    let $rest := if ($rest-header) then local:parse-identifier($identifier) else ()
    order by xs:date($document//dc:date) descending
    return
      export:xml-row(
        (
        for $field in $info-fields return local:optional-field-item($field, $document),
        for $source in $sources return export:xml-item($document//dc:source/pm:link[@pm:linktype eq $source]/@pm:source, <options link="true"/>),
        for $output in $outputs return export:xml-item(concat($resolver-url,'.',$output), <options link="true"/>),
        if ($rest) then export:xml-item(concat($rest-url,$rest/collection-path,'/',$rest/document-id,'.xml'), <options link="true"/>) else ()
        )
      )

  let $xml := export:xml-output( ($column-names, $items) )
  
  return $xml
};


declare function local:optional-field-item($field, $document) {
  if ($field eq 'legislative-period') then export:xml-item($document//pm:legislative-period)
  else if ($field eq 'date') then export:xml-item($document//dc:date)
  else if ($field eq 'house') then export:xml-item($document//pm:house/@pm:house)
  else if ($field eq 'id') then export:xml-item($document//dc:identifier)
  else ()
};


declare function local:get-collection($col-string) as node()* {
  let $sub-collections := tokenize(string($col-string),'\|')
  let $collections := for $sub-collection in $sub-collections return collection(concat('/db/data/permanent/',$sub-collection))
  return $collections
};

(: Run script to create output :)
local:create-output()
