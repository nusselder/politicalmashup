xquery version "1.0" encoding "UTF-8";
(:~
 :
 : @author Arjan Nusselder
 : @since  March July 24, 2012
 : @version 1.0
 :
 : Module containing functions to handle an incoming identifier plus arguments, and return a document.
 :
 : Identifiers must follow a specific structure, exemplified below. The identifier is provided by the
 : controller.xql as the $path parameter, and is the url-part after the resolver base url, without
 : any get-parameters or #hash parts.
 :
 :
 : Path/identifier for the bulk of our data (proceedings mostly):
 : nl.proc.sgd.d.192619270000382.2.14.4
 : ^^^^^^^^^^^ * =============== ++++++
 : |           | |               \----> document section(s), dot separated
 : |           | \--------------------> local id (document basename)
 : |           \----------------------> {d,m,p} respectively {document, member, party}
 : \----------------------------------> collection
 :
 : Identifiers are always unique within our entire data set..
 :
 : The document sections are currently only relevant for 'd' documents, and point
 : to a specific part (e.g. a paragraph or a topic) of the document. These sections
 : are automatically numbered and given during processing. As such, if .2.14.4 exists,
 : .2.14 will also exist as its parent element.
 :
 : The local id is a string that can not contain a dot but otherwise any sequence of
 : alphanumeric characters or dashes. It is unique within a specific collection
 :
 : The collection part must match exactly a collection hierarchy, within the permanent
 : data+document+path collection. For instance, nl.proc.sgd.d will be located in the
 : /db/data/permanent/d/nl/proc/sgd collection. nl.m.01234 (a member) is local-id 01234 in
 : the collection /db/data/permanent/m/nl
 : The identifier-collection + document-type + local-id together form the unique
 : identifier for a single xml document in the database. 
 :
 :
 : Path/identifier for the namescape project (note the additional corpus signifier).
 : nl.ns.d.9029017139.s.21
 : ^^^^^ * ========== # ++
 : |     | |          | \-------------> document section(s), dot separated
 : |     | |          \---------------> {"",s,k} respectively corpus {ebooks, sanders, karina}
 : |     | \--------------------------> local id (document basename, either ISBN10/13 if known, SHA1 sum otherwise)
 : |     \----------------------------> {d,m,p} respectively {document, member, party}
 : \----------------------------------> collection
 :)

module namespace resolver = "http://politicalmashup.nl/resolver/resolver";

import module namespace highlight="http://politicalmashup.nl/resolver/highlight" at "xmldb:exist:///db/apps/resolver/modules/highlight.xqm";
import module namespace views="http://politicalmashup.nl/resolver/views" at "xmldb:exist:///db/apps/resolver/modules/views.xqm";
import module namespace pmrdf="http://politicalmashup.nl/resolver/rdf" at "xmldb:exist:///db/apps/resolver/modules/rdf.xqm";

declare namespace response="http://exist-db.org/xquery/response";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace util="http://exist-db.org/xquery/util";


(:~
 : Determine the document type, represented as character [dmp], from an identifier path.
 : Currently there are three document types: m for member, p for party and d for document (proceedings etc.).
 : 
 : @param $path the input path/identifier.
 : @return {d,m,p,''}.
 :)
declare function local:document-type-from-path($path) {
  if (contains($path,".m.")) then 'm'
  else if (contains($path,".p.")) then 'p'
  else if (contains($path,".d.")) then 'd'
  else ''
};


(:~
 : Find the local id part, which provides the specific document within the collection.
 : Special case: handle the corpus signifier from the namescape project.
 : Currently there are three document types: m for member, p for party and d for document (proceedings etc.).
 : 
 : @param $local-part the local-id+section part of the input path/identifier, i.e. everything after the '.d.'.
 : @return {d,m,p,''}.
 :)
declare function local:local-id-from-local-part($local-part) {

  (: Namescape special case. :)
  if (matches($local-part, "\.[sk]")) then
    string-join( (tokenize($local-part, "\.")[position() < 3]), ".")
    
  (: Since the local id can not contain a dot, everything before the first dot is the local id. :)
  else tokenize($local-part, "\.")[1]
};


(:~
 : Parse a path identifier into all relevant parts and derived values such as the actual location of the resource.
 : Rather verbose return element, to assist debugging.
 : 
 : @param $path the input path/identifier.
 : @return element <identifier> with a sub-element for each part.
 :)
declare function resolver:parse-identifier($path) {

  let $document-type := local:document-type-from-path($path)
  
  (: Split the path on the document-type, to get the collection-part and the id+section local-part. :)
  let $path-tokens := tokenize($path, concat("\.",$document-type,"\."))
  let $collection-part := $path-tokens[1]
  let $local-part := $path-tokens[2]
  
  let $local-id := local:local-id-from-local-part($local-part)

  (: The section within a document is everything after the local id. :)
  let $section-part := substring-after($path, $local-id)
  
  (: The part matching de dc:identifier element in our document/meta :)
  let $document-id := if ($section-part ne '') then substring-before($path, $section-part) else $path
  
  (: Construct the database paths, based on the identifier parts. :)
  let $collection-path := concat($document-type, "/", replace($collection-part, "\.", "/"))
  let $database-path := concat("/db/data/permanent/", $collection-path)
  let $resource-path := concat($database-path, "/", $document-id, ".xml")
  
  return
    <identifier>
      <path>{$path}</path>
      <document-type>{$document-type}</document-type>
      <collection-part>{$collection-part}</collection-part>
      <local-part>{$local-part}</local-part>
      <local-id>{$local-id}</local-id>
      <section-part>{$section-part}</section-part>
      <document-id>{$document-id}</document-id>
      <collection-path>{$collection-path}</collection-path>
      <database-path>{$database-path}</database-path>
      <resource-path>{$resource-path}</resource-path>
    </identifier>
};



(:~
 : Define all possible error messages.
 : 
 : @param *
 : @return element <error> if there was an error, otherwise ''.
 :)
(: No input at all, or no document-type d,m,p found. :)
declare function local:check-input-error($identifier) {
  if ($identifier/path eq '') then <error status="400">Please specify an identifier.</error>
  else if ($identifier/document-type eq '') then <error status="400">No known document type found.</error>
  else ''
};
(: Document, or element within document, could not be found/opend. :)
declare function local:check-document-error($identifier, $document) {
  if (empty($document))
    then <error status="404">Identifier {string($identifier/path)} not found.</error>
    else ''
};
(: A stylesheet was requested, but could not be read. :)
declare function local:check-stylesheet-error($stylesheet, $transformer) {
  if ($stylesheet ne '' and empty($transformer))
    then <error>Stylesheet {$stylesheet} could not be found.</error>
  else ''
};
(: Transformation of the output went wrong somehow (caused java Exception). :)
declare function local:transform-error($view) {
  let $null := util:log('error', concat("Error in Resolver: ", $util:exception))
  return <error>Error transforming with {$view}.</error>
};


(:~
 : Transform a document with a transformer, and catch errors.
 : When upgrading to xquery 2.0, replace this java catch with an xquery try/catch.
 : 
 : @param $document as document-node or element-node input xml.
 : @param $transformer transformation xslt document.
 : @param $view parameter, for error message.
 : @param $query the query, passed to the transformer as parameter if available.
 : @param $namespace document namespace, e.g. [...resolver/]pm[/identifier].
 : @return transformed document/element if successful, otherwise an <error>.
 :)
declare function local:transform($document, $transformer, $view, $query, $namespace) {
  let $param := <parameters><param name="namespace" value="{$namespace}"/><param name="query" value="{$query}"/></parameters>
  return
    util:catch("java.lang.Exception",
      transform:transform($document, $transformer, $param),
      local:transform-error($view)
    )
};


(:~
 : Open/load the document specified by the identifier, and select the section
 : if requested.
 : 
 : @param $identifier <identifier> element as given by resolver:parse-identifier().
 : @return either a document, an element, or an empty sequence if the identifier did not exist.
 :)
declare function local:load-document($identifier) {
  let $document := doc($identifier/resource-path)
  let $document := if ($document and $identifier/section-part ne '')
                     then $document//*[@*:id eq string($identifier/path)]
                     else $document
  return $document                                                    
};


(:~
 : If $x is an element, return it as is.
 : If $x is a document, return its root element.
 :)
declare function local:as-element($x)
{
  if ($x instance of document-node()) then $x/* else $x
};


(:~
 : Nicely format an error message in HTML, and set the response status.
 : The response status can be set as $error/@status, and defaults to 500
 : (Internal Server Error).
 :
 : @return A full HTML page.
 :)
declare function local:format-error-html($error)
{
  let $message := string($error)
  return
    <html>
      <head><title>{$message}</title></head>
      <body>
        <h1>{$message}</h1>
      </body>
    </html>
};

(:~
 : Set the response status if an error occurred.
 : The response status can be set as $error/@status, and defaults to 500
 : (Internal Server Error).
 :
 : @param $error error element as created in error functions above.
 :)
declare function local:set-response-status-error($error)
{
  let $code := if ($error/@status) then xs:int($error/@status) else 500
  let $null := response:set-status-code($code)
  return $code
};


(:~
 : Run the entire process from parameters to output document.
 : Keeps track of errors in the process and only does work while no errors are detected.
 : If errors do happen, the first error occurence is returned instead of a document. 
 : 
 : @param $path the path parameter (identifier in url).
 : @param $view the view parameter to determine stylsheets.
 : @param $query the query parameter for highlighting in html output.
 : @param $namepsace the namespace of the document.
 : @return either the requested document, or an <error> element.
 :)
declare function resolver:process($path, $view, $query, $namespace) {

  let $identifier := resolver:parse-identifier($path)
  let $stylesheet := views:detect-stylesheet($view, $identifier/document-type, $identifier/collection-part)

  (: If a parseable identifier has been given, try to load the document. :)
  let $error := local:check-input-error($identifier)
  let $document := if ($error eq '') then local:load-document($identifier) else ()
  
  (: Check if the document was properly loaded, and load+check the transformation stylesheet if requested. :)
  let $error := if ($error eq '') then local:check-document-error($identifier, $document) else $error
  let $transformer := if ($error eq '' and $stylesheet ne '') then doc($stylesheet) else ()
  let $error := if ($error eq '') then local:check-stylesheet-error($identifier, $document) else $error
  
    (: Add highlighting. :)
  let $document := if ($query ne '' and $error eq '')
                     then highlight:add(local:as-element($document), $query)
                     else $document
  
  (: Transform document if required. :)
  let $document := if ($error eq '' and $stylesheet ne '')
                     then local:transform($document, $transformer, $view, $query, $namespace)
                     else $document
                     
  (: If the view is rdf, transform with the pmrdf module (for rdf, the $stylesheet is ''). :)
  let $document := if ($error eq '' and $view eq 'rdf')  
                     then pmrdf:transform($document)
                     else $document
                     

  (: $document is now either empty, the loaded document, the transformed document, or the transformation error. :)
  (: $error is now either '' if all went well or a transformation error occured,
     or an error message if either the document or the stylesheet was badly specified. :)


  (: Format error (html or xml) and set error status code, if errors occurred. :)
  let $error-document := if ($error ne '' and views:detect-serialisation($view) eq 'html') then local:format-error-html($error) else $error
  let $set-response-status := if ($error ne '') then local:set-response-status-error($error) else ''
  
  return if ($error eq '') then $document else $error-document
};
