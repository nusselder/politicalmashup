xquery version "1.0" encoding "UTF-8";
(:~
 :
 : @author Arjan Nusselder
 : @since  Jun 1 2012
 : @version 1.0
 :
 :
 : Announce to this eXist instance that a file is available.
 : An available file is typically an newly transformed document that should also be updated in this eXist.
 :)


import module namespace request="http://exist-db.org/xquery/request";

import module namespace localsettings="http://politicalmashup.nl/local/settings" at "xmldb:exist:///db/local/settings.xqm";

declare namespace pm="http://www.politicalmashup.nl";
declare namespace dc = "http://purl.org/dc/elements/1.1/";

declare namespace system="http://exist-db.org/xquery/system";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";


declare variable $get-collection := (
                        let $input := request:get-parameter('collection',"")  
                        return if (string-length($input)) then $input else ''  
                        );

declare variable $get-identifier := (
                        let $input := request:get-parameter('identifier',"")  
                        return if (string-length($input)) then $input else ''  
                        );
                        
declare variable $get-url := (
                        let $input := request:get-parameter('url',"")  
                        return if (string-length($input)) then $input else ''  
                        );


(: Determine the full collection path, and whether it is available. :)
let $full-collection-path := if ($get-collection ne '') then concat('/db/data/',$get-collection) else ''
let $collection-available := if (xmldb:collection-available($full-collection-path)) then 'true' else 'false'


(: Try if the source document is available. :)
let $doc := if ($get-url ne '') then doc($get-url) else <false/>
let $doc := if ($doc) then $doc else <false/>
let $doc-available := if ($doc/name() ne 'false') then 'true' else 'false'


(: Find the identifier of the downloaded document, and compare to the given identifier. :)
let $doc-identifier := string($doc//dc:identifier)
let $identifiers-equal := if ($doc-identifier eq $get-identifier) then 'true' else 'false'


(: Save document. :)
let $stored-xml :=
  if ($collection-available eq 'true' and $doc-available eq 'true' and $identifiers-equal eq 'true') then
    util:catch("java.lang.Exception",
      system:as-user($localsettings:user, $localsettings:pass, xmldb:store($full-collection-path, concat($get-identifier,'.xml'), $doc)),
      'store failed')
  else 'not stored'


(: See if the stored file matches the supposed input file. :)
let $supposed-file := concat($full-collection-path,'/',$get-identifier,'.xml')
let $stored-filename-equal := if ($supposed-file eq $stored-xml) then 'true' else 'false'
let $stored-status := if ($stored-filename-equal eq 'true') then 'store success' else $stored-xml (: else the error message as created in `let $stored-xml :=`:)

let $status := if ($stored-status eq 'store success') then 'pass' else 'fail'


let $options :=
    <options>
      <collection type="collection">{$get-collection}</collection>
      <identifier type="get">{$get-identifier}</identifier>
      <url type="get">{$get-url}</url>
      <url-doc-identifier type="derived">{$doc-identifier}</url-doc-identifier>
    </options>
  
  
let $status :=
  <status status="{$status}">
    <collection-available status="{$collection-available}"/>
    <document-available status="{$doc-available}"/>
    <identifiers-equal status="{$identifiers-equal}"/>
    <stored-filename-equal status="{$stored-filename-equal}"/>
    <stored status="{$stored-status}"/>
  </status>
  
(: Always count="1", since we always return one <status> element. :)
return
<result count="1">
  {$options}
  {$status}
</result>