xquery version "3.0";

import module namespace request   = "http://exist-db.org/xquery/request";
import module namespace transform = "http://exist-db.org/xquery/transform";
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace xslfo="http://exist-db.org/xquery/xslfo";

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

let $config     := doc("../config.xml")/config
let $collection := collection($config/base/text())

let $ddi-xslt-base := concat("xmldb:exist://", $config/ddi-xslt-path/text())

let $callNumber := request:get-parameter("callNumber", "")
let $doi        := request:get-parameter("doi", "")
let $file       := request:get-uploaded-file-data("file")
let $filename   := request:get-uploaded-file-name("file")
let $encoding   := request:get-parameter("encoding", ("UTF-8"))
let $input-format    := request:get-parameter("input-format", ("ddi_3_2"))
let $output-format   := request:get-parameter("output-format", ("dcterms"))

let $document :=
    if($doi != "") then
        $collection//ddi:DDIInstance[s:StudyUnit/r:Citation/r:InternationalIdentifier/r:IdentifierContent = $doi]
    else if($callNumber != "") then
        $collection/.[range:field-eq("callNumber", $callNumber)]
    else if($filename) then
        util:parse(util:binary-to-string($file, $encoding))        
    else 
        ()

let $params := <parameters></parameters>

let $output := 
    if($output-format = "dcterms") then
        let $header := response:set-header("Content-Disposition", concat('inline; filename="', $filename, '.dcterms.xml"'))
        return transform:transform($document, xs:anyURI(concat($ddi-xslt-base, "ddi-dcterms/ddi3_2/ddi_3_2-dcterms.xsl")), $params)
    else if($output-format = "marc-xml") then
        let $header := response:set-header("Content-Disposition", concat('inline; filename="', $filename, '.marc.xml"'))
        return transform:transform($document, xs:anyURI("xmldb:exist:///db/ddi/xsl/ddixslt/ddi-marcxml/ddi3_2/ddi_3_2-marcxml.xsl"), $params)
    else if($output-format = "ddi-1.2.2") then
        let $header := response:set-header("Content-Disposition", concat('inline; filename="', $filename, '.ddi-1.2.2.xml"'))
        return transform:transform($document, xs:anyURI("xmldb:exist:///db/ddi/xsl/ddixslt/ddi-1.2.2/ddi3_2/ddi3_2_to_ddi1_2_2.xsl"), $params)        
    else
        $document

return $output