xquery version "1.0" encoding "UTF-8";
(:
Script to identify parties based on a name, and optionally a date.

Arjan Nusselder, June 20, 2012
Last update, October 22, 2012
:)

declare namespace pm = "http://www.politicalmashup.nl";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace export="http://politicalmashup.nl/modules/export";


(:
Get parliamentary documents according to dossier and sub numbers.
Note that no checks are done on how the numbers look. These checks have been removed because they showed to be too restrictive.
It is the responsibility of the calling function to make sure the numbers make sense (but we can assume that non-sensical numbers will not match any documents).
:)
declare function local:relevant-parliamentary-documents($dossiernummer, $ondernummer, $list) {
  (: Dutch version only. Make request parameter if this changes. :)
  let $collection := collection("/db/data/permanent/d/nl/parldoc")
  return
    (: No dossier number, no results. :)
    if ($dossiernummer eq '') then ()
    
    (: Given only a dossier number, list all documents in that dossier (implicitly creating a "dossier-type-document"). :)
    else if ($ondernummer eq '' and $list eq 'true') then
      $collection[.//pm:dossiernr eq $dossiernummer]
      
    (: Only display documents if list requested explicitly. :)
    else if ($ondernummer eq '') then ()
      
    (: Find specific documents. Typically one, but could be more, for instance with reprints or documents in multiple dossiers. :)
    else $collection[.//pm:dossiernr eq $dossiernummer][.//pm:ondernr eq $ondernummer]
};


(:
True if one identifier is a reprint of the other.
Reprints (in the current implementation) are always identified by a suffix to the original identifier.
E.g. "[id]" and "[id]-h1" of "[id]-n1".
:)
declare function local:is-reprint($original, $reprint) {
  (: Identity, not reprint. :)
  if ($original eq $reprint) then false()
  
  (: Reprint. :)
  else if (starts-with($reprint, $original)) then true()
  
  (: Nothing in common or inverse reprint, not reprint. :)
  else false()
};


(:
True if the identifier is reprinted in all of the other identifiers.
:)
declare function local:is-original($identifier, $identifiers) {
  every $id in $identifiers[. ne $identifier] satisfies local:is-reprint($identifier, $id)
};


(:
Rank documents in terms of applicability. Currently, only reprints are considered.

A set of documents consists of only reprints+original if:
- one and only one identifier is equal to the start of all other identifiers.
- all other identifiers are equal, except for the number in the suffix.
The most recent reprint is the latest in the lexicographical ordering of the suffixed identifiers.
:)
declare function local:rank-documents($documents) {
  let $identifiers := for $d in $documents return $d//dc:identifier
  let $original := $identifiers[local:is-original(., $identifiers)]
  let $others := $identifiers[starts-with(., $original)][. ne $original]
  let $latest := (for $id in $others order by $id return $id)[last()]
  return
    if (count($original) ne 1 or count($others)+1 ne count($identifiers)) then
      <documents>
      {
        for $id in $identifiers return <document id="{$id}"/>
      }
      </documents>
    else
      <documents reprints="true">
      {
        for $id in $identifiers return
          <document id="{$id}">
          {
          if ($id eq $original) then attribute {'original'} {'true'} else (),
          if ($id = $others) then attribute {'reprint'} {'true'} else (),
          if ($id eq $latest) then attribute {'latest'} {'true'} else ()
          }
          </document>
      }
      </documents>
};


let $request := export:request-parameters( (<dossiernummer default=""/>, <ondernummer/>, <list default="" accept="true"/>, <view default="id" accept="id,csv,table,xml"/>) )

let $documents := local:relevant-parliamentary-documents(string($request/@dossiernummer), string($request/@ondernummer), string($request/@list))

let $documents :=
  (: Zero or one documents, or no subnumber given, then result can be presented. :)
  if (count($documents) le 1 or empty($request/@ondernummer)) then <documents>{for $d in $documents return <document id="{$d//dc:identifier}"/>}</documents>
  
  (: If multiple documents, they might be reprints etc. Trye to determine the most relevant one (i.e. the latest reprint etc.) :)
  else local:rank-documents($documents)


(: Define what exactly we return, full parties, multiple candidates, id's only, etc. :)
let $result-set := $documents/document


(: Options, describing the input for the returned result. :)
let $options := export:options( (
                                  <dossiernummer explanation="required, dossier number of the document (without 'rijkswet' part)"/>,
                                  <ondernummer explanation="optional, local number within the dossier"/>,
                                  <list explanation="if 'true' then all documents within the dossier are shown"/>,
                                  <reprints value="{$documents/@reprints}" explanation="if 'true' then the documents are reprints with one unique latest version"/>
                                ),
                                $request)
                                

(: Construct export output. :)
let $column-names := export:xml-util-headers( ('document', 'link') )

let $description := export:xml-util-description('All possible documents for the given parameters.')

let $items :=
  for $document in $result-set
  return
    export:xml-row(
      (
      export:xml-item($document, <options copy="true" display="{$document/@id}"/>),
      export:xml-item(export:link-resolver($document/@id, 'html'), <options display="{$document/@id}" link="true"/>)
      )
    )

let $xml-output := export:xml-output( ($description, $column-names, $items) )

return export:output-util-common-id-script($xml-output, $options, $request, 'documents')
