xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

import module namespace pmutil="http://politicalmashup.nl/modules/util";
import module namespace request="http://exist-db.org/xquery/request";

(:
N.B. because the resolver is a module, the $exist:path is everything in the url *after* the resolver part.
Example:
www.host.nl/resolver/nl.p.cda
and
resolver.host.nl/nl.p.cda
both have "/nl.p.cda" as $exist:path.
:)

(:Remove starting slash.:)
let $path := substring($exist:path, 2)

(: See if the $path contains a namespace. :)
let $parts := tokenize($path,'/')
let $namespace := if ($parts[2]) then $parts[1] else ''
let $path := if ($parts[2]) then $parts[2] else $path

(:
TODO: build proper accept parser, for explanation see for instance:
http://shiflett.org/blog/2011/may/the-accept-header
http://richard.cyganiak.de/blog/2008/03/what-is-your-rdf-browsers-accept-header/
:)
let $accept-header := request:get-header('Accept')

return

  (: Test headers :)
  (:if (true()) then <headers>{for $name in request:get-header-names() return <header name="{$name}" value="{request:get-header($name)}"/>}</headers> else:)
  
  (: If the original path contains static/, assume a static file was requested and just forward to the file. :)
  if (contains($exist:path, "static/")) then
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>

  (: refuse highlighting for bots :)
  else if (pmutil:is-a-bot(request:get-header("User-Agent"))
           and request:get-parameter("q", "") ne "") then
    pmutil:redirect-without("q")


  (:
  Simple example, very bad style, just checks if application/rdf+xml is in the header (no presedence checks)
  Also, there is no scenario for path.rdf (or path.html etc.) + header=rdf. It now only works for paths without type-indicator.
  :)
  else if (contains($accept-header,'application/rdf+xml')) then
      <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
      <forward url="resolver.xql">
        <add-parameter name="path" value="{$path}"/>
        <add-parameter name="namespace" value="{$namespace}"/>
        <add-parameter name="view" value="rdf"/>
      </forward>
    </dispatch>
  

  else if (ends-with($path, ".meta") or ends-with($exist:path, ".docinfo")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
      <forward url="resolver-meta-or-docinfo.xql">
        <add-parameter name="path" value="{$path}"/>
        <add-parameter name="namespace" value="{$namespace}"/>
      </forward>
    </dispatch>

  else if (ends-with($path, ".html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
      <forward url="resolver.xql">
        <add-parameter name="path" value="{substring($path,-4,string-length($path))}"/>
        <add-parameter name="namespace" value="{$namespace}"/>
        <add-parameter name="view" value="html"/>
      </forward>
    </dispatch>

  else if (ends-with($path, ".xml")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
      <forward url="resolver.xql">
        <add-parameter name="path" value="{substring($path,-3,string-length($path))}"/>
        <add-parameter name="namespace" value="{$namespace}"/>
        <add-parameter name="view" value="xml"/>
      </forward>
    </dispatch>

  else if (ends-with($path, ".rdf")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
      <forward url="resolver.xql">
        <add-parameter name="path" value="{substring($path,-3,string-length($path))}"/>
        <add-parameter name="namespace" value="{$namespace}"/>
        <add-parameter name="view" value="rdf"/>
      </forward>
    </dispatch>

  else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
      <forward url="resolver.xql">
        <add-parameter name="path" value="{$path}"/>
        <add-parameter name="namespace" value="{$namespace}"/>
      </forward>
    </dispatch>
