(:~
 : Highlighting code for HTML (and other) views.
 :
 : @author Lars Buitinck
 :)

xquery version "1.0" encoding "UTF-8";

module namespace highlight = "http://politicalmashup.nl/resolver/highlight";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace util="http://exist-db.org/xquery/util";


(:~
 : Add <exist:match> elements for query result highlighting.
 :
 : @param $element An element.
 : @param $query Query string.
 : @return $element with highlighting added to the appropriate elements.
 :)
declare function highlight:add($element as element(), $query as xs:string) as element()
{
  element {node-name($element)}
          {$element/@*,
           for $child in $element/node()
             return if ($child instance of element()) then (
                      if (local-name($child) = ("topic", "p", "speech", "scene")) then
                        local:kwic-expand($child, $query)
                      else
                        highlight:add($child, $query)
                    ) else
                      $child
          }
};


(: Apply kwic:expand to <pm:topic> element if it matches $query :)
declare function local:kwic-expand($topic as element(), $query as xs:string) as element()
{
  let $hit := util:catch('*',ft:query($topic, $query),())
  return if (count($hit) eq 0)
           then $topic
           else kwic:expand($hit)[1]
};
