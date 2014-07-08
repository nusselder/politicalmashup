(:
 : Serves up <id>.meta or <id>.docinfo
 : Lars Buitinck, June 1012
 :)

xquery version "1.0";

import module namespace functx="http://www.functx.com";
import module namespace pmutil="http://politicalmashup.nl/modules/util";

declare namespace pm="http://www.politicalmashup.nl";

declare option exist:serialize "method=xml omit-xml-declaration=no indent=yes";


(:
 : Add a pm:id to a <meta> element.
 : TODO: remove this when we have id's on such elements in the collection.
 : Addendum, now only adds pm:id when not already available (prevents double attribute declaration error)
 :)
declare function local:add-id($elem as element(), $id as xs:string)
{
  if ( $elem/@pm:id ) then $elem
  else functx:add-attributes($elem, xs:QName("pm:id"), $id)
};


(: $exist:path is of the form <pm-id>.{meta,docinfo} :)
let $full-path := request:get-parameter("path", "")
let $elem-type := functx:substring-after-last($full-path, ".")
let $path := functx:substring-before-last($full-path, ".")

return
  if ($path eq "") then
    <error>Specify an identifier.</error>

  else
    let $document := doc(pmutil:document-from-id($path))

    return
      if (empty($document)) then
        <error>Identifier {$path} not found.</error>
      else
        local:add-id($document/root/*[local-name() eq $elem-type], $full-path)
