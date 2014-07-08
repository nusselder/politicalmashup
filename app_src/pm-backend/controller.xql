xquery version "3.0";

declare variable $exist:path external;

if ($exist:path eq "/") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="index.xql"/>
    </dispatch>
    
else if (ends-with($exist:path,'.xq')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat('utilities/',tokenize($exist:path,'/')[last()])}"/>
    </dispatch>
    
else
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>
