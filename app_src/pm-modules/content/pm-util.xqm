(:
 : Common utility functions
 :)

module namespace pmutil = "http://politicalmashup.nl/modules/util";

import module namespace functx="http://www.functx.com";


(: Returns whether $date is in the range [$from, $to],
 : where $to may be "present"
 :)
declare function pmutil:date-in-range($date, $from, $till)
{
  $from le $date and ($till ge $date or $till eq "present")
};


(: get the document type from the identifier :)
declare function pmutil:doctype-from-id($id)
{
    if (contains($id,".m.")) then
      'm'
    else if (contains($id,".p.")) then
      'p'
    else if (contains($id,".d.")) then
      'd'
    else
      ''
};

(: get the local id, which identifies a document *within* a collection :)
declare function pmutil:get-local-id-from-id-parts($parts)
{
  let $local-part := $parts[2]

  return
    if (matches($local-part, "\.[sk]")) then
      string-join( (tokenize($local-part, "\.")[position() < 3]), ".")
    else
      tokenize($local-part, "\.")[1]
};

(: Return document path of identifier $id :)
declare function pmutil:document-from-id($id)
{
  let $type := pmutil:doctype-from-id($id)

  return
    if ($type eq "") then
      ()

    else
      let $id-parts := tokenize($id, concat("\.", $type, "\."))
      let $local-id := pmutil:get-local-id-from-id-parts($id-parts)
      let $element-path := substring-after($id, $local-id)
      let $basename := functx:substring-before-last($id, $element-path)

      let $coll-path := concat("/db/data/permanent/", $type, "/",
                               replace($id-parts[1], "\.", "/"))

      let $resource-path := concat($coll-path, "/", $basename, ".xml")

      return $resource-path
};

(: Heuristic to check whether $user-agent represents a bot.
 : Currently recognizes Baidu, Bing, Google, Yandex, wise-guys.nl and Python scripts.
 :)
declare function pmutil:is-a-bot($user-agent)
{
  matches($user-agent, "[Bb]aiduspider|([Bb]ing|[Gg]oogle|[Yy]andex)[Bb]ot|webcrawler|urllib")
};

(: send redirect to user agent, omitting parameter $omit
 : (to prevent bots from causing expensive highlighting) :)
declare function pmutil:redirect-without($omit as xs:string)
{
  let $url := concat(request:get-uri(), "?",
                     string-join(for $p in request:get-parameter-names()
                                   (: avoid undocumented(?) "path" parameter added by eXist :)
                                   let $val := request:get-parameter($p, "")
                                   where not($p = ("path", $omit))
                                   return concat(encode-for-uri($p), "=", encode-for-uri($val)),
                                 "&amp;"))
  return response:redirect-to(xs:anyURI($url))
};