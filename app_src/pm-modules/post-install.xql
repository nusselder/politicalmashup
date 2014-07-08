xquery version "1.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: Some strange verbose code copied from eXist, suggesting that getting the actual module path is "difficult". :)
declare variable $local:module-path := 
  let $rawPath := system:get-module-load-path()
  return
    if (starts-with($rawPath, "xmldb:exist://")) then
      if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then substring($rawPath, 36)
      else substring($rawPath, 15)
    else $rawPath;

(: Path locations. :)
declare variable $local:config-target := '/db/system/config/db/data/permanent';
declare variable $local:xconf-sources := concat($local:module-path,'/xconf/');

declare variable $local:prepare-collections :=
  xmldb:create-collection('/db/system/config/db','data'),
  xmldb:create-collection('/db/system/config/db/data','permanent');

  
declare variable $local:create-bare-data :=
  xmldb:create-collection('/db','data'),
  xmldb:create-collection('/db/data','permanent'),
  xmldb:create-collection('/db/data/permanent','d'),
  xmldb:create-collection('/db/data/permanent','m'),
  xmldb:create-collection('/db/data/permanent','p');

(: Store specific collection.xconf in the system config. :)
declare function local:store-xconf($data-collection as xs:string) {
  xmldb:create-collection($local:config-target, $data-collection),
  xmldb:store(
    concat($local:config-target,'/',$data-collection),                      (: Store at collection :)
    'collection.xconf',                                                     (: New filename :)
    doc(concat($local:xconf-sources,$data-collection,'-collection.xconf')), (: Source file (./xconf/X-collection.xconf) :)
    'application/xml')                                                      (: Store as xml. :)
};

(: Store the data collection.xconf files. :)
local:store-xconf('d'),
local:store-xconf('m'),
local:store-xconf('p')
