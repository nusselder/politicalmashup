xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq "") then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <redirect url="{concat(request:get-uri(), '/')}"/>
  </dispatch>
else if ($exist:resource eq "") then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="no"/>
    <forward url="/search/index.xq"/>
  </dispatch>
else
  <ignore xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
  </ignore>
