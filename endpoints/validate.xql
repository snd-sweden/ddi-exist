xquery version "3.0";

declare namespace validation = "http://exist-db.org/xquery/validation";

import module namespace request="http://exist-db.org/xquery/request";

(: get file as base64 data from request object :)
let $upload := request:get-uploaded-file-data("upload")

let $document := request:get-parameter("document", ())

let $encoding := request:get-parameter("encoding", ("UTF-8"))

let $version := request:get-parameter("version", ("ddi3_1"))

(: if document param is empty, check for uploaded file :)
let $text := if(empty($document)) 
	then
		(: convert base64 to string :)
		util:binary-to-string($upload, $encoding)
	else		
        $document

(: parse into node :) 
let $parsed := util:parse($text)

let $schemaLocation := string($parsed/@xsi:schemaLocation)

let $version :=
    if($version = 'autodetect') then
        if(contains($schemaLocation, '2.1')) 
            then "ddi2_1"
        else if(contains($schemaLocation, '2.5')) 
            then "ddi2_5"               
        else if(contains($schemaLocation, '3.0')) 
            then "ddi3_0"        
        else if(contains($schemaLocation, '3.2')) 
            then "ddi3_2"                
        else
            "ddi3_1"
    else
        $version

return if(count($parsed) = 1) then
    (: validate :)
    if($version = "ddi3_2") 
	   then validation:jaxv-report($parsed , xs:anyURI('/db/ddi/xsd/3_2/instance.xsd'))
	else if($version = "ddi3_1") 
	   then validation:jaxv-report($parsed , xs:anyURI('/db/ddi/xsd/3_1/instance.xsd'))
	else if($version = "ddi3_0") 
       then validation:jaxv-report($parsed , xs:anyURI('/db/ddi/xsd/3_0/instance.xsd'))
    else if($version = "ddi2_1") 
       then validation:jaxv-report($parsed , xs:anyURI('/db/ddi/xsd/2_1/ddi_2_1.xsd'))
    else if($version = "ddi2_1") 
       then validation:jaxv-report($parsed , xs:anyURI('/db/ddi/xsd/2_5/codebook.xsd'))       
    else
       <error>the version {$version} is not supported</error>

else
    <error>the document must contain one node</error>