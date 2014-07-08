xquery version "3.0";

declare namespace exist ="http://exist.sourceforge.net/NS/exist";

declare variable $exist:path as xs:string+ external;

if ($exist:path eq '/') then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
    <forward url="index.xq"/>
  </dispatch>

else if ($exist:path eq '/evaluation/') then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
    <forward url="index.xq"/>
  </dispatch>


else if ($exist:path eq '/timeline/') then
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
    <forward url="index.xq"/>
  </dispatch>

else
  <ignore xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
  </ignore>