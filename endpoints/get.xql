xquery version "3.0";

(:ddi namespaces:)
declare namespace g = "ddi:group:3_2";
declare namespace dc="ddi:dcelements:3_2";
declare namespace d="ddi:datacollection:3_2"; 
declare namespace dc2="http://purl.org/dc/elements/1.1/"; 
declare namespace s="ddi:studyunit:3_2"; 
declare namespace c="ddi:conceptualcomponent:3_2";
declare namespace r="ddi:reusable:3_2"; 
declare namespace a="ddi:archive:3_2"; 
declare namespace ddi="ddi:instance:3_2"; 
declare namespace l="ddi:logicalproduct:3_2";

let $config := doc('../config.xml')/config
let $collection :=  collection($config/base/text())

let $callNumber := request:get-parameter("callNumber", "")

return 
    if($callNumber != "") then
        $collection/.[range:field-starts-with('callNumber', $callNumber)]
    else 
        ()