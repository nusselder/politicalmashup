xquery version "3.0" encoding "UTF-8";
(:~
 :
 : @author Arjan Nusselder
 : @since  August 27, 2012
 : @version 1.1
 :
 : Last update: September 6, 2012
 :
 : Contains a collection of functions to easily create deliverables, as csv or html-table output.
 :
 : Functions starting with 'html-' create xhtml output; functions starting with 'csv-' create csv output;
 : functions starting with 'xml-' create xml snippets, serve as input for csv/html functions, or can be output as is. 
 :)

module namespace export="http://politicalmashup.nl/modules/export";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

import module namespace settings="http://politicalmashup.nl/modules/settings" at '/db/apps/modules/settings.xqm';

declare namespace pm="http://www.politicalmashup.nl";

declare variable $export:newline := '&#10;';
declare variable $export:separator := ';';
declare variable $export:separator-replacement := ',';

(: Resolver base url either to global resolver eXist installation, or relative to local host. :)
declare variable $export:resolver-base-url := if ($settings:local-references) then $settings:local-resolver
                                              else 'http://resolver.politicalmashup.nl/';

declare variable $export:serialize-html      := "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes
                                              doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Strict//EN doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd";
(:declare variable $export:serialize-html      := "method=html5 media-type=text/html omit-xml-declaration=yes indent=yes";:)
declare variable $export:serialize-xml       := "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";
declare variable $export:serialize-plaintext := "method=text media-type=text/plain";



(:
 :
 : Request/Serialization/Other Utility functions.
 :
 :)


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:set-serialization($type as xs:string) as empty() {
  let $serialization := if ($type eq 'html') then $export:serialize-html
                        else if ($type eq 'text') then $export:serialize-plaintext
                        else if ($type eq 'xml') then $export:serialize-xml
                        else ()
  return
    if ($serialization) then util:declare-option("exist:serialize", $serialization)
    else ()
};



(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(:
<element default=? accept=? accept-separator=?/>
Looks for "element=" get parameter.
If @default is given, it will be the value if the element= was not in the request.
If value of element= is a member of @accept (list separated by @accept-separator) it remains that value, otherwise is will be set to "".
If no @accept-separator given, default is ",".
If no @accept given, the value remains what is returned by request:get-parameter.
If no @default is given, the result is: removed if the value is ""; the value if it is not "".

If accept is defined and you want to allow multiple values, also define @tokenize-split and @tokenize-join. Invalid values will be removed.
Examples:
  <view/> ::: ?view=html ::: <request view="html"/>
  <view/> ::: ?view= ::: <request/>
  <view default="html" accept="html,csv"/> ::: ?view=html ::: <request view="html"/>
  <view default="html" accept="html,csv"/> ::: ?view=wrong ::: <request view="html"/>
  <view default="" accept="html,csv"/> ::: ?view=wrong ::: <request view=""/>
  <view accept="html,csv"/> ::: ?view=wrong ::: <request/>
  <view default="missing" accept="html,csv"/> ::: ?view=wrong ::: <request view="missing"/>
:)
declare function export:request-parameters($parameters as element()*) as element() {
  <request>
    {
    for $parameter in $parameters
    let $name := $parameter/name()
    let $default := $parameter/@default
    let $accept-separator := if ($parameter/@accept-separator) then $parameter/@accept-separator else ','
    let $tokenize-split := if ($parameter/@tokenize-split) then string($parameter/@tokenize-split) else ()
    let $tokenize-join := if ($parameter/@tokenize-join) then string($parameter/@tokenize-join) else ''
    let $accept := tokenize($parameter/@accept, $accept-separator)
    let $value := request:get-parameter($name, $default)
    let $value := if ($parameter/@type) then export:request-check-type($value, string($parameter/@type), $default) else $value
    let $accepted-value := export:request-check-accepted($value, $accept, $tokenize-split, $tokenize-join, $default)
                           
    return
      if ($accepted-value or $default) then attribute {$name} {$accepted-value}
      else ()
    }
  </request> 
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
 declare function export:request-check-type($value as xs:string?, $type as xs:string, $default as item()?) as item()? {
  if ($type eq 'xs:integer' and $value castable as xs:integer) then $value
  else if ($type eq 'xs:double' and $value castable as xs:double) then $value
  else if ($type eq 'xs:date' and $value castable as xs:date) then $value
  else if ($type eq 'xs:dateTime' and $value castable as xs:dateTime) then $value
  else if ($type eq 'ft:query' and export:request-check-type-ft-query($value)) then $value
  else $default
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:request-check-type-ft-query($query as xs:string?) as xs:boolean {
  let $test := util:catch("*", ft:query(<empty/>, string($query)), <failed/>)
  return if ($test/name() eq 'failed') then false() else true()
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:request-check-accepted($value as xs:string?, $accept as xs:string*, $tokenize-split as xs:string?, $tokenize-join as xs:string?, $default as item()?) as item()? {

  (: If there is no accept condition, whatever was the value remains the same. :)
  if (empty($accept)) then $value
  
  (: If there is an accept condition, the value (or tokenized values) must (all) match one of the acceptable values. :)
  else
    let $values := if ($tokenize-split) then tokenize($value, $tokenize-split) else $value
    let $accepted-values := $values[. = $accept]
    
    return
      (: If there are accepted values, return these (joined by token). :)
      if (not(empty($accepted-values))) then string-join($accepted-values, $tokenize-join)
      
      (: Else, return the default value as defined during the request. :)
      else $default
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:request-update($request as element(request), $new-request as element(request)) as element() {
  <request>
  {
    let $new-names := for $n in $new-request/@* return string($n/name())
    let $parameters := (
                       $request/@*[not(name() = $new-names)],
                       $new-request/@*
                     )
     for $p in $parameters
     return
       attribute {$p/name()} {$p}
  }
  </request>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:request-to-get-string($request as element(request)) as xs:string {
  let $get-parameters := for $p in $request/@* return concat($p/name(),'=',$p)
  let $get := string-join($get-parameters,'&amp;')
  return concat('?',$get)
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:options($parameters as element()*, $request as element(request)?) as element() {
  <options>
  {
    for $parameter in $parameters
    let $name := $parameter/name()
    let $type := attribute {'type'} {if ($parameter/@value) then 'derived' else 'get'}
    let $explanation := if ($parameter/@explanation) then attribute {'explanation'} {$parameter/@explanation} else ()
    let $request-value := $request/@*[name() eq $name]
    let $value := if ($parameter/@value) then string($parameter/@value) else if ($request-value) then string($request-value) else ''
    return
      element {$name} {
        $type,
        $explanation,
        $parameter/@select,
        $value
        }
  }
  </options>
};



(:
 :
 : Link Utility functions.
 :
 :)

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:link-resolver($identifier as xs:string?) as xs:string {
  export:link($export:resolver-base-url, $identifier, (), (), ())
};
declare function export:link-resolver($identifier as xs:string?, $view as xs:string?) as xs:string {
  export:link($export:resolver-base-url, $identifier, $view, (), ())
};
declare function export:link-resolver($identifier as xs:string?, $view as xs:string?, $focus as xs:string?) as xs:string {
  export:link($export:resolver-base-url, $identifier, $view, $focus, ())
};
declare function export:link-resolver($identifier as xs:string?, $view as xs:string?, $focus as xs:string?, $query as xs:string?) as xs:string {
  export:link($export:resolver-base-url, $identifier, $view, $focus, $query)
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:link($resolver as xs:string?, $identifier as xs:string?) as xs:string {
  export:link($resolver, $identifier, (), (), ())
};
declare function export:link($resolver as xs:string?, $identifier as xs:string?, $view as xs:string?) as xs:string {
  export:link($resolver, $identifier, $view, (), ())
};
declare function export:link($resolver as xs:string?, $identifier as xs:string?, $view as xs:string?, $focus as xs:string?) as xs:string {
  export:link($resolver, $identifier, $view, $focus, ())
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:link($resolver as xs:string?, $identifier as xs:string?, $view as xs:string?, $focus as xs:string?, $query as xs:string?) as xs:string {
  if (not($resolver) or not($identifier)) then ''
  else
    let $view := if ($view) then
                     if (starts-with($view,'.')) then encode-for-uri($view)
                     else concat('?view=', encode-for-uri($view))
                 else ()
    let $focus := if ($focus) then concat('#', encode-for-uri($focus)) else ()
    let $query := if ($query) then concat('&amp;q=', encode-for-uri($query)) else ()
    return concat($resolver, encode-for-uri($identifier), $view, $query, $focus)
};






(:
 :
 : Data Utility functions.
 :
 :)
(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:data-util-legislative-periods($collection as item()*) as xs:string* {
  for $period in distinct-values($collection//pm:legislative-period) order by $period return $period
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:data-util-proceedings-collections() as element() {
  let $base-path := '/db/data/permanent/d/'
  return
    <proceedings-collections>
      <collection name="nl" collection-path="{concat($base-path,'nl/proc')}"/>
      <collection name="nl-ob" collection-path="{concat($base-path,'nl/proc/ob')}"/>
      <collection name="nl-sgd" collection-path="{concat($base-path,'nl/proc/sgd')}"/>
      <collection name="nl-draft" collection-path="{concat($base-path,'nl/draft')}"/>
      <collection name="dk" collection-path="{concat($base-path,'dk/proc')}"/>
      <collection name="se" collection-path="{concat($base-path,'se/proc')}"/>
      <collection name="no" collection-path="{concat($base-path,'no/proc')}"/>
      <collection name="be-vln" collection-path="{concat($base-path,'be/proc/vln')}"/>
      <collection name="uk" collection-path="{concat($base-path,'uk/proc')}"/>
    </proceedings-collections>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(:
List all available collections in the permanent data set. If only-leafs is true(), only end-points in the tree are returned.
:)
declare function export:build-collection-tree($only-leafs as xs:boolean) as xs:string* {
  for $c in local:build-collection-tree-recursive('', $only-leafs) order by $c return $c
};

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function local:build-collection-tree-recursive($current as xs:string, $only-leafs as xs:boolean) as xs:string* {
  for $c in xmldb:get-child-collections(concat($settings:data-root,'/',$current))
  let $current-child := if ($current ne '') then concat($current,'/',$c) else $c (: Prevent double '/' :)
  let $children := local:build-collection-tree-recursive($current-child, $only-leafs)
  return if (empty($children)) then $current-child else if ($only-leafs) then $children else ($children, $current-child)
};



(:
 :
 : Output functions.
 :
 :)

declare function export:output($type as xs:string, $parts as item()*) as item() {
  export:output($type, $parts, '')
};
(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:output($type as xs:string, $parts as item()*, $title as xs:string) as item() {
  if ($type eq 'xml') then export:output-xml($parts, $title)
  else if ($type eq 'csv') then export:output-csv($parts, $title)
  else if ($type eq 'table') then export:output-html($parts, $title)
  else if ($type eq 'id') then $parts
  (: Undefined $types will return (), conflicting with item(), thus causing an error. :)
  else ()
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:output-xml($parts as element()*, $title as xs:string) as element() {
  <xml>
    {if ($title ne '') then <title>{$title}</title> else ()}
    {$parts}
  </xml>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(:declare function export:output-html($parts as element()*, $title as xs:string) as element() {
  <html>
    <head>
      {if ($title ne '') then <title>{$title}</title> else ()}
      {export:html-css()}
    </head>
    <body>
      {$parts}
    </body>
  </html>
};:)


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:output-csv($parts as xs:string*, $title as xs:string) as xs:string {
  if ($title ne '') then
    concat('#Document title: ', $title, $export:newline, string-join($parts,""))
  else string-join($parts,"")
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:output-util-common-id-script($xml-output, $options, $request, $id-result-name) {

  let $output := if ($request/@view eq 'table') then (<div>{ export:html-util-generate-parameter-links($request, 'view', ('table','csv','xml','id')) }</div>,
                                                      export:html-util-generate-search-form($options, $request),
                                                      export:html-output($xml-output) )
                 else if ($request/@view eq 'csv') then export:csv-output($xml-output)
                 else if ($request/@view eq 'xml') then ($options, $xml-output)
                 else if ($request/@view eq 'id') then export:id-output($xml-output, $id-result-name, $options)
                 else ()
               
  let $output := export:output($request/@view, $output, concat($id-result-name,' id script'))

  let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )

  return $output
};




(:
 :
 : XML Create functions.
 :
 :)

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-item($content as item()*) as element() {
  export:xml-item($content, <options/>)
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-item($content as item()*, $options as element(options)) as element() {
  (: Overrule content string for copy with a display given. :)
  let $string-content := if ($options/@copy eq 'true' and $options/@display) then $options/@display else $content
  let $string := export:xml-clean-string($string-content)
  let $string := if ($options/@disable-quote-escape) then $string else export:xml-escape-quotes-with-quotes($string)
  
  let $content := if ($options/@copy eq 'true') then $content else ()
  return
  <item string="{$string}">
    {
    for $attr in $options/@*[name() != ('string')] (: attribute do not overwrite, so do not recopy (if xml-item is redo) the string :)
    return
      (:attribute {$attr/name()} {string($attr)}:)
      attribute {$attr/name()} {string($attr)}
    }
    {$content}
  </item>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-row($items as element(item)*) as element() {
  <row>
    {$items}
  </row>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-head($items as element(item)*) as element() {
  <head>
    {$items}
  </head>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-clean-string($content as item()*) as xs:string {
  (: TODO: string causes error when $content is more than one element. Is string-join the solution? :)
  let $content := string-join(for $c in $content return string($c),'!!!')
  
  (: Escape [text"text] to ["text""text"] (Google Fusion requirement) if " is present. :)
  (:let $content := if (contains($content,'"')) then (concat('"',replace($content,'"','""'),'"'))
                  else $content:)
  
  let $content := replace(replace(replace($content,
                  $export:newline,' '),
                  $export:separator,$export:separator-replacement),
                  '&#160;',' ')
   return $content
};

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-escape-quotes-with-quotes($content as xs:string) as xs:string {
  (: Escape [text"text] to ["text""text"] (Google Fusion requirement) if " is present. :)
  let $content := if (contains($content,'"')) then (concat('"',replace($content,'"','""'),'"'))
                  else $content
  
   return $content
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-update-item($item as element(item), $new-options as element(options)) as element() {
  if ($new-options) then
    let $new-attr-names := $new-options/@*/name()
    let $item-attrs := $item/@*[name() != $new-attr-names]
    return
    <item>
       {
       for $attr in $item-attrs return attribute {$attr/name()} {string($attr)},
       for $attr in $new-options/@* return attribute {$attr/name()} {string($attr)},
       $item/*
       }
    </item>
  else $item
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:xml-update-options($line, $column-count) as element() {
  if ($line/item/@description eq 'true') then
    element {$line/name()} {for $item in $line/item return export:xml-update-item($item, <options colspan="{$column-count}"/>)}
  else $line
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
 declare function export:xml-output($lines as element()*) as element() {
   export:xml-output($lines, false())
};

declare function export:xml-output($lines as element()*, $clean as xs:boolean) as element() { (: should be element(row|head) or element(row)|element(head) :)
  let $row-count := count($lines[self::row])
  let $column-count := count($lines[self::row][1]/item)
  let $statistics := export:xml-util-description(concat('Rows: ', $row-count, $export:separator-replacement, ' Columns: ', $column-count))
  let $clean-lines := if ($clean) then $lines else ($statistics, $lines)
  return
    <set rows="{$row-count}" columns="{$column-count}">
      {
        for $line in $clean-lines return export:xml-update-options($line, $column-count)
      }
    </set>
};




(:
 :
 : XML Utility functions.
 :
 :)

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
 (: Shortcut: create head with item for a list of strings. :)
declare function export:xml-util-headers($items as xs:string*) as element() {
  export:xml-head( for $item in $items return export:xml-item($item)  )
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
 (: Shortcut: create head with a description as a single line. :)
declare function export:xml-util-description($string as xs:string) as element() {
  export:xml-head( export:xml-item($string, <options description="true" background="#ddd"/>) )
};




(:
 :
 : CSV Create functions.
 :
 :)

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:csv-line($line as element()) as xs:string {
  let $content := string-join($line/item/@string, $export:separator)
  return
    if ($line[self::head]) then concat('#', $content)
    else $content
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:csv-lines($xml as element(set)?) as xs:string {
  let $lines := for $line in $xml/* return export:csv-line($line)
  return string-join($lines, $export:newline)
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:csv-output($xml as element(set)?) as xs:string {
  concat(export:csv-lines($xml), $export:newline)
};




(:
 :
 : ID Create functions.
 :
 :)

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:id-output($xml as element(set)?, $id-type as xs:string, $options as element(options)?, $id-position as xs:integer) as element() {
  <result count="{count($xml/row)}">
    {
      $options,
      element {$id-type} {$xml/row/item[position() eq $id-position]/*}
    }
  </result>
};
declare function export:id-output($xml as element(set)?, $id-type as xs:string, $options as element(options)?) as element() {
  export:id-output($xml, $id-type, $options, 1)
};




(:
 :
 : HTML Create functions.
 :
 :)

(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-table-cell($item as element(item), $type as xs:string) as element() {
  element {$type} {
    export:html-table-cell-attributes($item),
    export:html-table-cell-content($item)
    }
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(: Construct the actual content that will end up in the table cell. :)
declare function export:html-table-cell-content($item as element(item)) as item()* {
  (: String value of the item, i.e. the value that would end up in the csv output. :)
  let $string := string($item/@string)
  
  (: Display value of the item, equal to $string except when explicitly overridden (typically for links). :)
  let $display := if ($item/@display) then string($item/@display) else $string
  
  (: Content of the table cell, either just the string, a generated link, or a complete copy of the contents for fine-grained control. :)
  (:let $content := if ($item/@copy eq 'true') then $item/*
                  else if ($item/@link eq 'true') then <a href="{$string}">{$display}</a>
                  else $display:)
  let $content := if ($item/@link eq 'true') then <a href="{$string}">{$display}</a>
                  else if ($item/@copy eq 'true' and $item/@display) then $display (: Force display value over copy value, if display is given. :)
                  else if ($item/@copy eq 'true') then $item/*
                  else $display
                  
  return $content
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(: Parsing of attributes that have special meaning for html tables. :)
(: TODO: add complex parsing of style attributes.. :)
declare function export:html-table-cell-attributes($item as element(item)) as attribute()* {
  if ($item/@colspan) then attribute {'colspan'} {string($item/@colspan)} else (),
  if ($item/@background) then attribute {'style'} {concat('background:',string($item/@background))} else ()
};



(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(:declare function export:html-table-row($line as element()) as element() {
  let $cell-type := if ($line[self::head]) then 'th' else 'td'
  return
    <tr>
    {
      for $item in $line/item
      return
        export:html-table-cell($item, $cell-type)
    }
    </tr>
};
:)


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-output($xml as element(set)?) as element() {
  export:html-output($xml, ())
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-output($xml as element(set)?, $colgroup as element(colgroup)?) as element() {
  <table class="output">
    {
      $colgroup,
      for $line in $xml/* return export:html-table-row($line)
    }
  </table>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-css() as element() {
  <style>
    {util:binary-to-string(util:binary-doc('/db/apps/modules/static/export.css'))}
  </style>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-css-github() as element() {
  <style>
    {util:binary-to-string(util:binary-doc('/db/apps/modules/static/github.css'))}
  </style>
};


(:
 :
 : HTML Utility functions.
 :
 :)


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-util-generate-parameter-links($request as element(request), $parameter as xs:string, $values as xs:string*) as element() {
  let $current-value := string($request/@*[name() eq $parameter])
  return
    <div class="get-options">
      <p>{$parameter}: |{
        for $value in $values
        let $request-update := <request>{attribute {$parameter} {$value}}</request>
        let $new-request := export:request-update($request, $request-update)
        let $active := if ($value eq $current-value) then ' active' else '' 
        return
          <span class="option{$active}"><a href="{export:request-to-get-string($new-request)}">{$value}</a> |</span>
        }
      </p>
    </div>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
declare function export:html-util-generate-input-method($option as element()) as element() {
  let $name := $option/name()
  let $value := string($option)
  return
    if ($option/@select) then
      <select name="{$name}">
        {
        for $o in tokenize($option/@select,",") return
          <option value="{$o}">
            {if ($o eq $value) then attribute {"selected"} {"selected"} else ()}
            {$o}
          </option>
        }
      </select>
      
    else <input name="{$name}" type="text" value="{$value}"/>
};


(:~
 : --description--.
 : 
 : @param --parameters--.
 : @return --return value--.
 :)
(:declare function export:html-util-generate-search-form($options as element(options), $request as element(request)?) as element() {
  <div class="search-form">
  <form method="get" action="">
    <table>
    {
    for $option in $options/*
    let $name := $option/name()
    return
      <tr class="{$option/@type}">
        <td>{$name}</td>
        <td>{if ($option/@type eq 'get') then export:html-util-generate-input-method($option) else string($option)}</td>
        <td>{string($option/@explanation)}</td>
      </tr>
    }
      <tr><td></td><td><button type="submit">Search</button></td><td>Update search</td></tr>
    </table>
    {
    for $option in $request/@*
    let $name := $option/name()
    where empty($options/*[name() eq $name])
    return
       <input name="{$name}" type="hidden" value="{$option}"/>
    }
  </form>
  </div>
};:)

(: Changed functions for municipality search. Commented out above. :)

declare function export:html-table-row($line as element()) as element() {
  let $cell-type := if ($line[self::head]) then 'th' else 'td'
  let $content := if (count($line/item) eq 4) then
    <tr>
    <td>
      <div>
        <span class="muni-date">{export:html-table-cell-content($line/item[1])}</span> | {export:html-table-cell-content($line/item[2])}
      </div>
      <div class="muni-cloud">
        {string-join($line/item[3]/term," . ")}
      </div>
      <div class="muni-snippet">
        {export:html-table-cell-content($line/item[4])}
      </div>
    </td>
    </tr>
    
  else
    <tr>
    {
      for $item in $line/item
      return
        export:html-table-cell($item, $cell-type)
    }
    </tr>
    
  return $content
};

declare function export:output-html($parts as element()*, $title as xs:string) as element() {
  <html>
    <head>
      {if ($title ne '') then <title>{$title}</title> else ()}
      {export:html-css()}
      <style>
      <![CDATA[
      span.muni-date{display:inline-block;width:5.8em;color:#1e0fbe;font-family:sans-serif;}
      table.output td{padding:25px 5px 5px;}
      table.output a{color:#006621;font-family:sans-serif;}
      table.output td div{margin:0 0 2px 0;font-size:120%;}
      table.output{border:0;}
      table.output td{border:0;border-bottom:1px solid #ddd;}
      table.output th{border:0;background:none !important;font-weight:normal;font-family:sans-serif;color:#666;}
      div.muni-cloud{color:#622;font-family:sans-serif;}
      div.muni-snippet{padding-top:10px;color:#111;}
      div.muni-snippet p{font-family:sans-serif;}
      div.muni-snippet span.hi{background:#eee;font-weight:bold;}
      div.introduction div{width:49%;float:left;}
      div.introduction p{font-family:sans-serif;color:#666;width:auto;font-size:12px;}
      div.introduction div.querybox{float:none;clear:both;width:100%;border-top:1px solid #888;padding-top:2em;}
      div.introduction div.querybox input{width:60%;font-size:16px;padding:5px 5px 5px 10px;height:30px;}
      div.introduction div.querybox button{font-size:16px;padding:5px;height:42px;width:100px;}
      div.search-form td{border:none;font-family:sans-serif;color:#666;}
      div.search-form input, div.search-form select{border:none;border-bottom:1px solid #aaa;color:#666}
      div.search-form table{border-bottom:none;border-right:none;border-top:none;}
      span.intr-datum{color:#1e0fbe;padding:0 0.3em;}
      span.intr-link{color:#006621;text-decoration:underline;padding:0 0.3em;}
      span.intr-term{color:#622;padding:0 0.3em;}
      span.intr-fragment{color:#000;background:#eee;font-weight:bold;padding:0 0.3em;}
      ]]>
      </style>
    </head>
    <body>
      {$parts}
    </body>
  </html>
};

declare function export:html-util-generate-search-form($options as element(options), $request as element(request)?) as element() {
  <div class="search-form">
    <table>
    {
    for $option in $options/*
    let $name := $option/name()
    return
      <tr class="{$option/@type}">
        <!--<td>{$name}</td>-->
        <td>{if ($option/@type eq 'get') then export:html-util-generate-input-method($option) else string($option)}</td>
        <td>{string($option/@explanation)}</td>
      </tr>
    }
    </table>
  </div>
};