xquery version "3.0";
import module namespace ddi-exist-filter ='https://github.com/snd-sweden/ddi-exist/filter' at '/db/apps/ddi-exist/modules/filter.xqm';

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

import module namespace request="http://exist-db.org/xquery/request";
import module namespace json="http://www.json.org";
import module namespace util="http://exist-db.org/xquery/util";

declare option exist:serialize "method=json media-type=text/javascript";

let $config := doc('../config.xml')/config
let $collection :=  collection($config/base/text())

let $collection := ddi-exist-filter:callNumberPrefixFilter($collection)
let $collection := ddi-exist-filter:subjectFilter($collection)
let $collection := ddi-exist-filter:keywordFilter($collection)
let $collection := ddi-exist-filter:kindOfDataFilter($collection)
let $collection := ddi-exist-filter:availabilityStatusFilter($collection)
let $collection := ddi-exist-filter:organizationFilter($collection)


let $type := request:get-parameter("type","")
let $lang := request:get-parameter("lang", $config/default-lang/text())

let $list :=
    switch ($type) 
      case "study" 
        return
            $collection//a:CallNumber/text()
      case "kindOfData"
            return
            distinct-values($collection//r:KindOfData/text())
      case "subject"
            return
            distinct-values($collection//r:Subject[@xml:lang=$lang]/text())
      case "keyword"
            return
            distinct-values($collection//r:Keyword[@xml:lang=$lang]/text()) 
      case "organization"
            return
            distinct-values($collection//a:OrganizationName/r:String[@xml:lang=$lang]/text())             
      case "analysisUnit"
            return
            distinct-values($collection//r:AnalysisUnit/text())                 
      case "availabilityStatus"
            return
            distinct-values($collection//a:AvailabilityStatus/r:Content[@xml:lang=$lang]/text())              
            
      default 
        return ()
            
return
    <list>{
            for $item in $list
                order by $item
                return <json:value>{$item}</json:value>

    }</list>