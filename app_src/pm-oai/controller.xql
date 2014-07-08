xquery version "3.0";

declare variable $exist:path external;

if (starts-with($exist:path, "/doc/")) then
  <ignore xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
  </ignore>
  
else
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="no"/>
    <forward url="oai.xql"/>
  </dispatch>
