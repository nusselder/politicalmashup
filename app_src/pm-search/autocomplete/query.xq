(:
 : Autocompletion backend for person names
 : Authors: Anne Schuth <anne.schuth@uva.nl>
 :          Lars Buitinck <L.J.Buitinck@uva.nl>
 :)

declare namespace pm="http://www.politicalmashup.nl";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace functx="http://www.functx.com";

(: XXX should be using a JSON serialization here, but that seems to be buggy :)
declare option exist:serialize
  "method=text media-type=text/plain omit-xml-declaration=yes";


declare function local:search($terms, $scope)
{
  let $query := <query>
                  {
                    for $t in $terms[position() ne last()]
                      return <term occur="must">{$t}</term>
                  }
                  <wildcard>{concat($terms[last()], "*")}</wildcard>
                </query>
  return $scope//pm:member[ft:query(./pm:name, $query)]
};


(: Returns the most frequent party-name for a member :)
declare function local:party-from-member($member)
{
  (for $p in distinct-values($member//pm:membership/@pm:party-name)
     let $n := count($member//pm:membership[@pm:party-name eq $p])
     order by $n descending
     return $p)[1]
};


(: Returns some gov't that $member was in, if any :)
declare function local:government-from-member($member)
{
  $member//pm:membership/@pm:legislative-session[1]
};


(: TODO parameterize on country :)
let $scope := collection('/db/data/permanent/m')
let $query := request:get-parameter('term', "")

let $result := local:search(tokenize(functx:trim($query), "\s+"), $scope)

let $sortedhits :=
  for $hit in $result
    order by ft:score($hit) descending
    return $hit

let $str :=
  for $hit in subsequence($sortedhits, 0, 20)
    (: Assume that the first "alternative" first name is the short form;
     : it commonly is. :)
    let $first := string(if ($hit/pm:alternative-names/pm:name/pm:first) then
                           $hit/pm:alternative-names/pm:name/pm:first[1]
                         else if ($hit/pm:name/pm:first) then
                           $hit/pm:name/pm:first[1]
                         else
                           $hit/pm:name/pm:initials[1])

    let $last := functx:capitalize-first(($hit//pm:last)[1])

    let $extra := local:party-from-member($hit)
    let $extra := if ($extra) then
                    $extra
                  else
                    local:government-from-member($hit)

    let $label := normalize-space(concat($last, ", ", $first, " (", $extra, ")"))

    return concat('{"id": "', $hit/@pm:id,
                  '", "label": "', $label,
                  '", "score":', ft:score($hit), '}')

return concat("[", string-join($str, ",&#xA;") , "]")
