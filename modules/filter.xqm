xquery version "3.0";
module namespace ddi-exist-filter="https://github.com/snd-sweden/ddi-exist/filter";

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

declare function ddi-exist-filter:apply-facet-filter($collection as node()*) as node()*{
    if(request:get-parameter('organizationname', ())) then
        $collection//ddi:DDIInstance[.//a:OrganizationName = request:get-parameter('organizationname', (''))]
    else
        $collection
    
};

declare function ddi-exist-filter:subjectFilter($collection as node()*) as node()*{
    let $subject := request:get-parameter("subject", "")
    
    return
    if($subject != "") then
        $collection/.[range:field-eq('subject', $subject)]
    else
        $collection
};

declare function ddi-exist-filter:kindOfDataFilter($collection as node()*) as node()*{
    let $kindOfData := request:get-parameter("kindOfData", "")
    
    return
    if($kindOfData != "") then
        $collection/.[range:field-eq('kindOfData', $kindOfData)]
    else
        $collection
};

declare function ddi-exist-filter:keywordFilter($collection as node()*) as node()*{
    let $keyword := request:get-parameter("keyword", "")
    
    return
    if($keyword != "") then
        $collection/.[range:field-eq('keyword', $keyword)]
    else
        $collection
};

declare function ddi-exist-filter:keywordFilter($collection as node()*) as node()*{
    let $keyword := request:get-parameter("keyword", "")
    
    return
    if($keyword != "") then
        $collection/.[range:field-eq('keyword', $keyword)]
    else
        $collection
};

declare function ddi-exist-filter:organizationFilter($collection as node()*) as node()*{
    let $organization := request:get-parameter("organization", "")
    
    return
    if($organization != "") then
        $collection/.[range:field-eq('organization', $organization)]
    else
        $collection
};

declare function ddi-exist-filter:analysisUnitFilter($collection as node()*) as node()*{
    let $analysisUnit := request:get-parameter("analysisUnit", "")
    
    return
    if($analysisUnit != "") then
        $collection/.[range:field-eq('analysisUnit', $analysisUnit)]
    else
        $collection
};

declare function ddi-exist-filter:timeMethodFilter($collection as node()*) as node()*{
    let $timeMethod := request:get-parameter("timeMethod", "")
    
    return
    if($timeMethod != "") then
        $collection/.[range:field-eq('timeMethod', $timeMethod)]
    else
        $collection
};

declare function ddi-exist-filter:typeOfSamplingProcedureFilter($collection as node()*) as node()*{
    let $typeOfSamplingProcedure := request:get-parameter("typeOfSamplingProcedure", "")
    
    return
    if($typeOfSamplingProcedure != "") then
        $collection/.[range:field-eq('typeOfSamplingProcedure', $typeOfSamplingProcedure)]
    else
        $collection
};



declare function ddi-exist-filter:availabilityStatusFilter($collection as node()*) as node()*{
    let $availabilityStatus := request:get-parameter("availabilityStatus", "")
    
    return
    if($availabilityStatus != "") then
        $collection/.[range:field-starts-with('availabilityStatus', $availabilityStatus)]
    else
        $collection
};

declare function ddi-exist-filter:callNumberPrefixFilter($collection as node()*) as node()*{
    let $callNumberPrefix := request:get-parameter("callNumberPrefix", "")
    
    return
    if($callNumberPrefix != "") then
        $collection/.[range:field-starts-with('callNumber', $callNumberPrefix)]
    else
        $collection
};