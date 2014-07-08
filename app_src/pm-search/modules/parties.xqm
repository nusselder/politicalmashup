module namespace parties="http://politicalmashup.nl/search/parties";

declare namespace pm="http://www.politicalmashup.nl";

declare variable $parties:mcoll := collection("/db/data/permanent/m/nl");
declare variable $parties:pcoll := collection("/db/data/permanent/p/nl");


declare function parties:all-parties()
{
  for $p in $parties:pcoll//pm:party
    (: Get the abbreviated name; DNPP usually has the best one :)
    let $abbrv := $p//pm:name[@pm:nametype eq "normalised"][1]
    let $name := string($p/pm:name)
    let $name := if ($abbrv) then
                   concat($name, " (", upper-case($abbrv), ")")
                 else
                   $name
    return <party id="{$p/@pm:id}">{$name}</party>
};


(: Returns all member-ids of party with id $party-id :)
declare function parties:members($party-id)
{
  $parties:mcoll//pm:member[.//pm:membership[@pm:party-ref eq $party-id]]/@pm:id
};
