xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq "/") then
    (: index page provides basic info :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="index.xql"/>
    </dispatch>

else if ($exist:path eq '/search') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="endpoints/search.xql"/>
    </dispatch>
    
else if ($exist:path eq '/list') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
        <forward url="endpoints/list.xql"/>
    </dispatch>

else if ($exist:path eq '/get') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="endpoints/get.xql"/>
    </dispatch>
    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
