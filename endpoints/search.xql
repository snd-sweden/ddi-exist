xquery version "3.0";
import module namespace ddi-exist-utils ='https://github.com/snd-sweden/ddi-exist'       at '/db/apps/ddi-exist/modules/utils.xqm';
import module namespace ddi-exist       ='https://github.com/snd-sweden/ddi-exist/search' at '/db/apps/ddi-exist/modules/search.xqm';
import module namespace ddi-exist-filter ='https://github.com/snd-sweden/ddi-exist/filter' at '/db/apps/ddi-exist/modules/filter.xqm';

import module namespace request="http://exist-db.org/xquery/request";
import module namespace json="http://www.json.org";
import module namespace util="http://exist-db.org/xquery/util";

let $config := doc('../config.xml')/config

let $collection :=  collection($config/base/text())

let $collection := ddi-exist-filter:callNumberPrefixFilter($collection)
let $collection := ddi-exist-filter:subjectFilter($collection)
let $collection := ddi-exist-filter:keywordFilter($collection)
let $collection := ddi-exist-filter:kindOfDataFilter($collection)
let $collection := ddi-exist-filter:analysisUnitFilter($collection)
let $collection := ddi-exist-filter:timeMethodFilter($collection)
let $collection := ddi-exist-filter:typeOfSamplingProcedureFilter($collection)
let $collection := ddi-exist-filter:availabilityStatusFilter($collection)
let $collection := ddi-exist-filter:organizationFilter($collection)

let $collection := ddi-exist-filter:dataCollectionDateFilter($collection)

let $q  := request:get-parameter("q", '')
let $id := request:get-parameter("id", '')
let $series := xs:string(request:get-parameter("series", ()))

let $start    := xs:integer(request:get-parameter("start", "0"))
let $records  := xs:integer(request:get-parameter("records", $config/default-records/text()))
let $lang     := request:get-parameter("lang", '')
let $action   := request:get-parameter("action","status")
let $format   := request:get-parameter("format",$config/default-format/text())
let $callback := request:get-parameter("callback",())
let $type     := request:get-parameter("type","study,question,variable")

let $query-start-time := util:system-time()

(:set the correct header for the requested format:)
let $null := 
    if($format = 'xml') 
    then
        util:declare-option("exist:serialize", "method=xml media-type=text/xml")
    else if($format = 'json' and empty($callback))
        then
        util:declare-option("exist:serialize", "method=json media-type=application/json")
    else if($format = 'json')
        then
        util:declare-option("exist:serialize", fn:concat("method=json media-type=application/json jsonp=", $callback))
    else
        util:declare-option("exist:serialize", "method=xml media-type=text/xml")

(:get the status of the current document:)
let $status := if (contains($type, 'status')) then ddi-exist-utils:status($collection) else ()

let $studies   := if (contains($type, 'study')) then ddi-exist:searchStudy($q, $lang, $collection) else ()
let $questions := if (contains($type, 'question')) then ddi-exist:searchQuestion($q, $lang, $collection) else ()
let $variables := if (contains($type, 'variable')) then ddi-exist:searchVariable($q, $lang, $collection) else ()

(:limit the matches:)
let $studiesLimited   := if (contains($type, 'study'))    then <studies   hits="{count($studies)}">{  for $s in ddi-exist:limitMatches($studies, $start, $records)   return ddi-exist-utils:renderStudy($s)}</studies> else () 
let $questionsLimited := if (contains($type, 'question')) then <questions hits="{count($questions)}">{for $q in ddi-exist:limitMatches($questions, $start, $records) return ddi-exist-utils:renderQuestion($q)}</questions> else () 
let $variablesLimited := if (contains($type, 'variable')) then <variables hits="{count($variables)}">{for $v in ddi-exist:limitMatches($variables, $start, $records) return ddi-exist-utils:renderVariable($v)}</variables> else () 

(:facets:)
let $facets   := if (contains($type, 'facet'))    then ddi-exist:facets($q, $lang, $collection) else ()

(:time to run the query:)
let $time := (util:system-time() - $query-start-time) div xs:dayTimeDuration('PT1S')

return 
<result>
    {
        <time>{$time}</time>,
        <q>{$q}</q>,
        <start>{$start}</start>,
        <end>{($start + $records)}</end>,
        <lang>{$lang}</lang>,
        $status,
        $facets
    }
    {$studiesLimited}
    {$questionsLimited}   
    {$variablesLimited}   
    
</result>