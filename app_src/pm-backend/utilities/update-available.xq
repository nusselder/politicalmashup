xquery version "1.0" encoding "UTF-8";
(:~
 :
 : @author Arjan Nusselder
 : @since  Oct 31 2012
 : @version 1.0
 :
 :
 : Retrieve a list of new files, and update the data with files that are either newer or not present.
 : The list of new files is retrieved from the global resolver resolver.politicalmashup.nl.
 : The actual files are downloaded from the source monitor.politicalmashup.nl through the rest interface (i.e. the original documents are retrieved, not the "resolved" versions).
 :)

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmd = "http://www.politicalmashup.nl/docinfo";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";

import module namespace localsettings="http://politicalmashup.nl/local/settings" at "xmldb:exist:///db/local/settings.xqm";

declare namespace system="http://exist-db.org/xquery/system";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";

(: If collection is not empty, then restrict the updates to those that match one of the given collections. :)
declare function local:restrict-collections($available-updates, $collection) {
  if ($collection) then
    let $collections := tokenize($collection, '\|')
    return $available-updates[item[4]/@string = $collections]
  else
    $available-updates
};

declare function local:process($local-collection, $local-filename, $remote-url) {
  let $doc := doc($remote-url)
  let $remote-identifier := $doc//dc:identifier
  let $result :=
    if (concat($remote-identifier,'.xml') eq $local-filename) then
      util:catch("java.lang.Exception",
        system:as-user($localsettings:user, $localsettings:pass, xmldb:store($local-collection, $local-filename, $doc)),
        'F')
    else 'NA'
  let $result := if ($result eq 'F') then 'store failed with java error'
            else if ($result eq 'NA') then 'remote document not available'
            else if (string($result) eq concat($local-collection,'/',$local-filename)) then 'success'
            else 'stored path not equal to requested path'
  return $result
};

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <since/>, <collection/>, <action default="list" accept="list,update"/>) )

let $available-updates := concat('http://backend.politicalmashup.nl/list-updates.xq?view=xml&amp;since=',$request/@since,'&amp;collection=',$request/@collection)
let $available-updates := doc($available-updates)//row
let $available-updates := local:restrict-collections($available-updates, $request/@collection)

let $desc := export:xml-util-description('s: source, l: local')
let $headers := export:xml-util-headers( ('s:identifier', 's:collection', 's:date', 'l:available', 'l:date', 'local equal-or-newer', 'action', 'result', 'local resolver') )

let $items :=
  for $row in $available-updates
  let $source-identifier := $row/item[2]/@string
  let $source-collection := $row/item[4]/@string
  let $source-date := string($row/item[1]/@string)
  let $local-collection := concat('/db/data/permanent/',$source-collection)
  let $local-filename := concat($source-identifier,'.xml')
  let $local-path := concat($local-collection,'/',$local-filename)
  let $local-doc := doc($local-path)
  let $local-available := if ($local-doc) then true() else false()
  let $local-date := if ($local-available) then string($local-doc//pmd:transformer[last()]/@pmd:datetime) else ()
  let $local-equal-or-newer := if ($local-available and $local-date ge $source-date) then true() else false()
  let $local-action := if ($local-equal-or-newer) then 'skip' else if ($local-available) then 'update' else 'add'
  let $monitor-url := concat('http://monitor.politicalmashup.nl/rest',$local-path)
  let $local-result := if ($request/@action eq 'list') then ''
                       else if ($local-equal-or-newer) then 'skipped'
                       else local:process($local-collection, $local-filename, $monitor-url)
  let $result-colour := if ($local-result eq '') then '#fff' else if ($local-result eq 'skipped') then '#ccc' else if ($local-result eq 'success') then '#afa' else '#faa'
  return
          export:xml-row(
            (
            export:xml-item($source-identifier),
            export:xml-item($source-collection),
            export:xml-item($source-date),
            export:xml-item($local-available),
            export:xml-item($local-date),
            export:xml-item($local-equal-or-newer),
            export:xml-item($local-action),
            export:xml-item($local-result, <options background="{$result-colour}"/>),
            export:xml-item(concat('../resolver/',$source-identifier,'.html'), <options link="true"/>)
            )
          )

(: Collect action stats. :)
let $action-stats := for $result in $items[self::row]/item[7]/@string return string($result)
let $action-stats := for $result in distinct-values($action-stats) return concat($result, ': ', count($action-stats[. eq $result]))
let $action-stats := export:xml-util-description(concat("Actions: ", string-join($action-stats,", ")))

(: Collect result stats. :)
let $result-stats := for $result in $items[self::row]/item[8]/@string return string($result)
let $result-stats := for $result in distinct-values($result-stats) return concat($result, ': ', count($result-stats[. eq $result]))
let $result-stats := export:xml-util-description(concat("Results: ", string-join($result-stats,", ")))
 
let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

let $xml-output := export:xml-output( ($desc, $action-stats, $result-stats, $headers, $items) )

let $output := if ($request/@view eq 'table') then (export:html-output($xml-output))
               else if ($request/@view eq 'csv') then export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-output
               else ()

let $output := export:output($request/@view, $output, 'Files updated')

return $output