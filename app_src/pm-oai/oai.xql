(:
 : Makeshift implementation of an OAI-PMH endpoint.
 : Author: Lars Buitinck <L.J.Buitinck@uva.nl>
 : with input from Anne Schuth <anne.schuth@uva.nl>
 : Sets implemented by Breyten Ernsting <breyten@hetnieuwestemmen.nl>
 :)

xquery version "1.0";

import module namespace functx="http://www.functx.com";
import module namespace pmutil="http://politicalmashup.nl/modules/util";

import module namespace request="http://exist-db.org/xquery/request";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dcterms = "http://purl.org/dc/terms/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace pmd = "http://www.politicalmashup.nl/docinfo";


(: XXX should derive this from request:get-url() :)
declare variable $baseUrl := 'http://oai.politicalmashup.nl';


declare variable $EPOCH := xs:dateTime('1970-01-01T00:00:00');


(: Convert dateTime to UTC and format for OAI :)
declare function local:fmt-date-utc($d)
{
  let $utc := $d - fn:timezone-from-dateTime($d)
  return datetime:format-dateTime($utc, "yyyy-MM-dd'T'HH:mm:ss'Z'")
};


(: identify ourselves to harvester :)
(: we don't actually track deletions, but DANS wants "transient" here :)
declare function local:identify()
{
  (: we don't actually track deletions, but DANS wants "transient" for
   : deletedRecord :)
  <Identify>
    <repositoryName>PoliticalMashup -- handelingen</repositoryName>
    <baseURL>{$baseUrl}</baseURL>
    <protocolVersion>2.0</protocolVersion>
    <adminEmail>maartenmarx@uva.nl</adminEmail>
    <earliestDatestamp>{$EPOCH}Z</earliestDatestamp>
    <deletedRecord>transient</deletedRecord>
    <granularity>YYYY-MM-DDThh:mm:ssZ</granularity>

    <description>
      <oai-identifier xmlns="http://www.openarchives.org/OAI/2.0/oai-identifier"
                      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                      xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai-identifier http://www.openarchives.org/OAI/2.0/oai-identifier.xsd">
        <scheme>oai</scheme>
      </oai-identifier>
    </description>
  </Identify>
};


declare function local:make-set-spec($doc-path)
{
  let $parts := tokenize($doc-path, "/")
  return string-join(subsequence($parts, 5, 2), ":")
};


declare function local:make-header($ident, $doc, $set-spec)
{
  <header>
    <identifier>{$ident}</identifier>
    <datestamp>
    {
      local:fmt-date-utc(xs:dateTime(($doc//*:transformer/@*:datetime))[last()])
    }
    </datestamp>
    <setSpec>{$set-spec}</setSpec>
  </header>
};


(: make a <record> containing a DIDL item;
 : guts of both get-record and list-records
 :)
declare function local:make-record($ident, $docPath, $doc)
{
  let $didl := transform:transform($doc, doc("didl.xsl"), ())
  let $set-spec := local:make-set-spec($docPath)
  
  return
    <record>
    {
      local:make-header($ident, $doc, $set-spec)
    }

      <metadata>
      {
        $didl
      }
      </metadata>
    </record>
};


(: response to GetRecord verb :)
declare function local:get-record($ident)
{
  if ($ident eq "") then
    <error code="badArgument"/>
  else
    let $namespace-length := fn:string-length('oai:urn:nbn:nl:ui:35-')
    let $ident := substring($ident, $namespace-length + 1)
    let $doc-name := pmutil:document-from-id($ident)
    return if (empty($doc-name)) then
             <error code="idDoesNotExist"/>
           else
             util:catch("*",
                        <GetRecord>
                        {
                          local:make-record($ident, $doc-name, doc($doc-name))
                        }
                        </GetRecord>,
                        <error code="idDoesNotExist"/>)
};


declare function local:list-metadata-formats()
{
  <ListMetadataFormats>
    <metadataFormat>
      <metadataPrefix>didl</metadataPrefix>
      <schema>http://standards.iso.org/ittf/PubliclyAvailableStandards/MPEG-21_schema_files/did/didl.xsd</schema>
      <metadataNamespace>urn:mpeg:mpeg21:2002:02-DIDL-NS</metadataNamespace>
    </metadataFormat>
  </ListMetadataFormats>
};


(: Helper for get-descendant-resources :)
declare function local:get-descendant-collections($base, $col)
{
  for $subcol in xmldb:get-child-collections(concat($base, $col))
    return (concat($col, "/", $subcol),
            local:get-descendant-collections($base, concat($col, "/", $subcol)))
};

(: Recursive get-child-resources by Anne; returns a sequence of resource paths
 : (NOT basenames, like get-child-recources)
 :)
declare function local:get-descendant-resources($base)
{
  (
    for $xml in xmldb:get-child-resources($base)
      return concat($base, "/", $xml),
    for $subcol in local:get-descendant-collections($base, ())
      return for $xml in xmldb:get-child-resources(concat($base, $subcol))
               return concat($base, $subcol, "/", $xml)
  )
};


(: core of ListRecords response builder
 : lists records $start through ($start + num - 1)
 : ??? list records (($start-1)*$num) through ($start*$num) ??? 
 : within date range [$from, $until)
 :)
declare function local:list-records($from, $until, $start, $num, $prefix, $set-spec, $verb)
{
  if ($prefix != "didl") then
    <error code="cannotDisseminateFormat"/>
  else
    let $coll := "/db/data/permanent"
    let $setPath := if (not(empty($set-spec))) then
      concat('/', replace($set-spec, ':', '/'))
    else
      ""
    let $docs := local:get-descendant-resources(concat($coll, $setPath))
    
    (: Filter from/until. :)
    let $wanted :=
        for $path in $docs
          let $name := tokenize($path, "/")[last()]
          let $coll := substring-before($path, $name)
          let $ctime := xmldb:created($coll, $name)
          let $mtime := xmldb:last-modified($coll, $name)
          where ($ctime ge $from and $ctime lt $until)
            or ($mtime ge $from and $mtime lt $until)
          return $path
          
    let $current-wanted := subsequence($wanted, $start, $num)
    
    return if (empty($current-wanted)) then
      <error code="noRecordsMatch"/>
    else
    
    let $given :=
      let $headers-only := $verb eq "ListIdentifiers"
      let $data :=
        for $path in $current-wanted
          let $name := tokenize($path, "/")[last()]
          let $coll := substring-before($path, $name)
          let $docno := substring($name, 1, string-length($name) - string-length(".xml"))
          let $ident := concat('oai:urn:nbn:nl:ui:35-', $docno)
          return if ($headers-only) then
                   local:make-header($ident, doc($path), local:make-set-spec($path))
                 else
                   local:make-record($ident, $path, doc($path))
      let $resumption :=
        (: real programmers count from 0. :)
        (:if (($start - 1) + $num lt count($docs)) then:)
        if (($start - 1) + $num lt count($wanted)) then
          (: choose the easy way out for the expiration; now + 10 minutes :)
          <resumptionToken expirationDate="{local:fmt-date-utc(current-dateTime() + 10 * xs:dayTimeDuration('PT1M'))}"
                           completeListSize="{count($docs)}"
                           cursor="{$start}">
            {$start + $num}
          </resumptionToken>
        else
          ()

      return element
               {if ($headers-only) then "ListIdentifiers" else "ListRecords"}
               {($data, $resumption)}
               
      return $given
};


(: list the available sets :)
declare function local:list-sets()
{
  let $coll := "/db/data/permanent"
  
  return
  <ListSets>
  {
    for $subcol in local:get-descendant-collections($coll, ())
      let $setName := substring($subcol, 2, string-length($subcol) - 1)
      let $set-spec := replace($setName, '/', ':')
      return <set>
        <setName>{$setName}</setName>
        <setSpec>{$set-spec}</setSpec>
      </set>
  }
  </ListSets>
};


declare function local:parse-datetime($d as xs:string)
{
  (: exception handling, my kingdom for exception handling :)
  if (matches($d, "^\d+-\d+-\d+$")) then
    xs:dateTime(xs:date($d))
  else
    xs:dateTime($d)
};


(: main entry point: dispatch on verb, handle GET parameters :)
declare function local:dispatch()
{
  let $verb := request:get-parameter("verb", ())
  let $ident := request:get-parameter("identifier", ())
  let $from := request:get-parameter("from", ())
  let $until := request:get-parameter("until", ())
  let $resumptionToken := request:get-parameter("resumptionToken", ())
  let $metadataPrefix := request:get-parameter("metadataPrefix", ())
  let $set-spec := request:get-parameter("set", ())

  return
    <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
      <responseDate>{local:fmt-date-utc(current-dateTime())}</responseDate>
      <request verb="{$verb}">
        {if (not(empty($ident))) then attribute identifier {$ident} else ()}
        {if (not(empty($from))) then attribute from {$from} else ()}
        {if (not(empty($until))) then attribute until {$until} else ()}
        {if (not(empty($metadataPrefix))) then attribute metadataPrefix {$metadataPrefix} else ()}
        {if (not(empty($resumptionToken))) then attribute resumptionToken {$resumptionToken} else ()}
        {if (not(empty($set-spec))) then attribute set {$set-spec} else ()}
        {$baseUrl}
      </request>
    {
      if ($verb eq "Identify") then
        local:identify()
      else if ($verb eq "GetRecord") then
        local:get-record($ident)
      else if ($verb eq "ListIdentifiers" or $verb eq "ListRecords") then
        local:list-records(if (empty($from)) then $EPOCH else local:parse-datetime($from),
                           if (empty($until)) then current-dateTime() else xs:dateTime($until),
                           if (empty($resumptionToken)) then 1 else number($resumptionToken),
                           200,
                           $metadataPrefix,
                           $set-spec,
                           $verb)
      else if ($verb eq "ListMetadataFormats") then
        local:list-metadata-formats()
      else if ($verb eq "ListSets") then
        local:list-sets()
      else
        <error code="badVerb"/>
    }
    </OAI-PMH>
};


local:dispatch()
