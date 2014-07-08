xquery version "1.0";

declare namespace exist ="http://exist.sourceforge.net/NS/exist";

declare variable $exist:path as xs:string+ external;

if (contains($exist:path, "/js/") or contains($exist:path, "/images/") or contains($exist:path, "/css/")) then
  <ignore xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
  </ignore>

else if (ends-with($exist:path, ".xq")) then
  <ignore xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
  </ignore>
  
else
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
    <forward url="overview.xq"/>
  </dispatch>