xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";

import module namespace resolver="http://politicalmashup.nl/resolver/resolver" at "modules/resolver.xqm";
import module namespace views="http://politicalmashup.nl/resolver/views" at "modules/views.xqm";

import module namespace export="http://politicalmashup.nl/modules/export";

declare namespace exist="http://exist.sourceforge.net/NS/exist";

let $request := export:request-parameters( (<namespace default=""/>, <path default=""/>, <view default=""/>, <q default=""/>, <part/>) )
let $part := if ($request/@part) then concat('.',$request/@part) else ''
let $serialisation := export:set-serialization( views:detect-serialisation($request/@view) )   

return resolver:process(concat(string($request/@path),$part), string($request/@view), string($request/@q), string($request/@namespace)) 
