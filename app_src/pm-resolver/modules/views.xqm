xquery version "1.0" encoding "UTF-8";
(:~
 :
 : @author Arjan Nusselder
 : @since  March July 24, 2012
 : @version 1.0
 :
 : Last update: July 24, 2012
 :
 : Module containing functions to translate input parameters to actual views and stylesheets. 
 :)

module namespace views = "http://politicalmashup.nl/resolver/views";


(: Define all the available formatting stylesheets. :)
declare variable $views:sheet-empty := '';
declare variable $views:sheet-base := '//db/apps/resolver/view/';
declare variable $views:sheet-html-d-proceedings := concat($views:sheet-base, 'default-d-html.xsl');
declare variable $views:sheet-html-d-parldoc := concat($views:sheet-base, 'default-d-paper-html.xsl');
declare variable $views:sheet-html-p := concat($views:sheet-base, 'default-p-html.xsl');
declare variable $views:sheet-html-m := concat($views:sheet-base, 'default-m-html.xsl');
declare variable $views:sheet-validate-m := concat($views:sheet-base, 'validate-m-html.xsl');
declare variable $views:sheet-xml-m := concat($views:sheet-base, 'default-m-xml.xsl');
declare variable $views:sheet-html-d-generic-document := concat($views:sheet-base, 'default-d-generic-document.xsl');
declare variable $views:sheet-html-proc-with-entities := concat($views:sheet-base, 'proc-with-entities.xsl');
 
(:~
 : Based on the view parameter, see if the output requires (x)html or xml serialization (e.g. which resolver-...xql to call).
 : In the future, more output types might be added (think JSON, csv, etc.).
 : 
 : @param $view a string representing the type of view.
 : @return either 'html' or 'xml'.
 :)
declare function views:detect-serialisation($view) {

  (: Default, i.e. no view given, is xml. :)
  if ($view eq '') then 'xml'

  else if ($view eq 'html') then 'html'

   (: Use of html-paper should become deprecated, but is handled for backwards compatibility. :)
  else if ($view eq 'html-paper') then 'html'

  else if ($view eq 'xml') then 'xml'
  
  else if ($view eq 'rdf') then 'xml'
  
  (: The special validation view for documents should be presented in html. :)
  else if ($view eq 'validate') then 'html'
  
  (: Entity/summary view. :)
  else if ($view eq 'entities') then 'html'

  (: If no type can be determined (view="something unknown"), default to xml. :)
  else 'xml'
};


(:~
 : Based on the view parameter, the document type and if necessary the collection, give an actual stylesheet.
 : If no matching stylesheet is found, an empty string is returned, signifying that no transformation should be done.
 : In the future, additional derived document types might be added (e.g. dossiers/collections).
 : 
 : @param $view a string representing the type of view.
 : @param $document-type on of 'd', 'm' or 'p' (the available document types).
 : @return the absolute path to a XSLT translation sheet, or empty string to signify that no transformation should be done.
 :)
declare function views:detect-stylesheet($view, $document-type, $collection) {

  (: Member (person) documents. :)
  if ($document-type eq 'm') then
  
    (: Member - Standard html view. :)
    if ($view eq 'html') then $views:sheet-html-m
    
    (: Member - Special validation view. :)
    else if ($view eq 'validate') then $views:sheet-validate-m
    
    (: Member - stripped xml view, removing copyrighted data from our full data. :)
    else $views:sheet-xml-m
    
    
  (: Party documents. :)
  else if ($document-type eq 'p') then
  
    (: Party - Standard html view. :)
    if ($view eq 'html') then $views:sheet-html-p 

    (: Party information in xml format can be returned without any further processing. :)
    else $views:sheet-empty

    
  (: "Document" documents, e.g. proceedings, books etc. :)
  else if ($document-type eq 'd') then
    
    (: Document - html view depends on the actual collection. :)
    if ($view eq 'html') then
    
      (: Parliamentary documents. :)
      if (contains($collection, 'parldoc')) then $views:sheet-html-d-parldoc
      
      (: Proceedings. :)
      else if (contains($collection, 'proc')) then $views:sheet-html-d-proceedings
      
      (: Proceedings in draft version. :)
      else if (contains($collection, 'draft')) then $views:sheet-html-d-proceedings
      
      (: Else maybe a generic document? :)
      else $views:sheet-html-d-generic-document
      (:else $views:sheet-empty:)
    
    (: Deprecated view-name for html parliamentary documents, checked for backwards compatibility. :)
    else if ($view eq 'html-paper') then $views:sheet-html-d-parldoc
    
    (: New view with entities/clouds from meta. :)
    else if ($view eq 'entities') then
      
      (: Proceedings. :)
      if (contains($collection, 'proc')) then $views:sheet-html-proc-with-entities
      
      (: Generic document. :)
      else $views:sheet-html-d-generic-document
    
    
    (: Documents in xml view can be shown without transformation. :)
    else $views:sheet-empty


  (: Unkown document types will not be processed further. :)
  else $views:sheet-empty
};
