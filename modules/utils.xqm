xquery version "1.0";
module namespace ddi-exist-utils="https://github.com/snd-sweden/ddi-exist";
declare namespace json="http://www.json.org";

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


import module namespace ddi-exist = 'https://github.com/snd-sweden/ddi-exist/search' at '/db/apps/ddi-exist/modules/search.xqm';

(:validate a document against its schema:)
declare function ddi-exist-utils:validate($document as xs:string, $version as xs:string) as node()*
{
    (: parse into node :) 
    let $parsed := util:parse($document)
    
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
};

declare function ddi-exist-utils:validate($document as xs:string) as node()*{
    ddi-exist-utils:validate($document, ())
};

(:get the status for the collection:)
declare function ddi-exist-utils:status($collection as node()*) as node()*{
    <status>
        <languages>
        {
            for $language in distinct-values($collection//@xml:lang)
                return <language>{$language}</language>
        }
        </languages>
        <DDIInstances>{count($collection/ddi:DDIInstance)}</DDIInstances>
        <studies>{count($collection//s:StudyUnit)}</studies>
        <questionschemes>{count($collection//d:QuestionScheme)}</questionschemes>
        <questions>{count($collection//d:QuestionText/..)}</questions>
        <variables>{count($collection//l:Variable)}</variables>
    </status>
};

declare function ddi-exist-utils:renderQuestion($question as node()) as node(){
    ddi-exist-utils:renderQuestion($question, fn:true())
};

(:~
 : Takes a question-item and its sub-questions 
 : and resolves references and render it
 :
 : @version 1.0
 : @param   $question the question item to be rendered
 : @return  xml fragment with the rendered question item
 :)
declare function ddi-exist-utils:renderQuestion($question as node(), $top as xs:boolean) as node(){
    <question>
        <id>{xs:string($question/r:ID)}</id>
        {
            if($question/r:UserID) then
                <userid>
                {
                    for $id in $question/r:UserID
                        (: return <id type="{$id/@typeOfUserID}">{xs:string($id)}</id> :)
                        return element {$id/@typeOfUserID} {xs:string($id)}
                }
                </userid>
            else ()
        }
        <name>{xs:string($question/d:QuestionItemName/r:String | $question/d:QuestionGridName/r:String)}</name>
        <questiontext>
        {
            for $q in $question/d:QuestionText/d:LiteralText/d:Text 
                return element {ddi-exist-utils:getLang($q)} {fn:string($q)}  
        }
        </questiontext>
        {
            if($question/d:SubQuestions) then
                <subquestions>
                {
                    let $subquestions := $question/d:SubQuestions/d:QuestionItem | $question/d:SubQuestions/d:MultipleQuestionItem
                    for $sub in $subquestions
                        return ddi-exist-utils:renderQuestion($sub, fn:false())
                }
                </subquestions>
            else ()
        }        
        {
        if($top)
            then
                let $study := $question/ancestor::s:StudyUnit
                return
                <study>
                        <uri>{fn:base-uri($question/ancestor::ddi:DDIInstance)}</uri>
                        <id>{xs:string(
                            if($study/r:UserID[@typeOfUserID='study_id'])
                                then
                                    $study/r:UserID[@typeOfUserID='study_id']
                                else
                                    $study/@id
                            )}   
                        </id>
                        <CallNumber>{$study//a:CallNumber/text()}</CallNumber>
                        <title>
                            {for $t in $study/r:Citation/r:Title/r:String
                                return
                                    element {$t/@xml:lang} {fn:string($t)}
                            }
                        </title>
                        <alsoIn>
                            {
                            let $question_id := $question/r:UserID[@typeOfUserID='question_id']/text()
                            let $question_text := $question//d:Text[@xml:lang="sv"]/text()
                            let $studies := collection('/db/ddi/data/ddi3_2/')//s:StudyUnit[.//d:Text = $question_text][.//a:CallNumber/text() != $study//a:CallNumber/text()]
                            for $s in $studies
                                order by $s/r:Citation/r:Title/r:String[@xml:lang="sv"] descending 
                                    return 
                                        let $qi := $s//d:QuestionItem[.//d:Text = $question_text]
                                        let $qs := $qi/ancestor::d:QuestionScheme
                                        let $fi := $s/r:OtherMaterial[.//r:ID = replace($qs/r:ID[0], 'qs_', '')]//r:ExternalURLReference/text()
                                        return
                                        <study>
                                            <name>{xs:string($qi/d:QuestionItemName/r:String[0] | $qi/d:QuestionGridName/r:String[0])}</name>
                                            <callNumber>{$s//a:CallNumber/text()}</callNumber>
                                            <title>{for $t in $s/r:Citation/r:Title/r:String
                                                        return
                                                            element {ddi-exist-utils:getLang($t)} {fn:string($t)}
                                                    }
                                            </title>
                                            <questionscheme json:array="true">
                                                <name>{
                                                        for $qss in $qs/d:QuestionSchemeName/r:String
                                                            return 
                                                                element {$qss/@xml:lang} {fn:string($qss)}
                                                    }
                                                </name>
                                                <file>{$fi}</file>
                                            </questionscheme>
                                        </study>
                            }
                            </alsoIn>
                </study>
            else
                ()
        }
        {
        if($top)
            then            
                <questionscheme>
                    <name>
                        {
                            for $qs in $question/preceding-sibling::d:QuestionSchemeName/r:String
                                return 
                                    element {$qs/@xml:lang} {fn:string($qs)}
                        }
                    </name>
                </questionscheme>
            else
                ()
            
        }
    </question>
};


declare function ddi-exist-utils:renderStudy($study as node()) as node()*{
    let $callNumber := xs:string($study/a:Archive/a:ArchiveSpecific/a:Collection/a:CallNumber)
    return
    <StudyUnit>
        <url>http://snd.gu.se/catalogue/study/{replace($callNumber, ' ', '')}</url>
        <xml-url>http://xml.snd.gu.se/ws/export/study.xql?output-format=ddi&amp;id={replace($callNumber, ' ', '%20')}</xml-url>
        <id>{xs:string(
            if($study/r:UserID[@typeOfUserID='study_id'])
                then
                    $study/r:UserID[@typeOfUserID='study_id']
                else
                    $study/@id
            )}
        </id>
        <CallNumber>{$callNumber}</CallNumber>                
        <title>
            {for $t in $study/r:Citation/r:Title/r:String
                return
                    element {$t/@xml:lang} {fn:string($t)}
            }
        </title>

        <abstract>
            {for $a in $study/r:Abstract/r:Content
                return
                    element {$a/@xml:lang} {fn:string($a)}
            }                    
        </abstract>

        <creator>
            {for $a in $study/r:Citation/r:CreatorReference
                return
                    $study//.[./r:ID = $a]
            }                    
        </creator>
    </StudyUnit>   

};

(:~
 : Takes a variable
 : and resolves references and render it
 :
 : @version 1.0
 : @param   $variable the variable to be rendered
 : @return  xml fragment with the rendered question item
 :)
declare function ddi-exist-utils:renderVariable($variable as node()) as node(){
    <variable>
        <id>{xs:string($variable/@id)}</id>
        {
            if($variable/r:UserID) then
                <userid>
                {
                    for $id in $variable/r:UserID
                        return element {$id/@typeOfUserID} {xs:string($id)}
                }
                </userid>
            else ()
        }        
        
        <name>
        {
            for $n in $variable/l:VariableName/r:String
                return element {ddi-exist-utils:getLang($n)} {fn:string($n)}        
        }
        </name>        
        <label>
        {
            for $l in $variable/r:Label/r:Content
                return element {ddi-exist-utils:getLang($l)} {fn:string($l)}        
        }
        </label>
        {ddi-exist-utils:renderResponseDomain($variable)}

        <study>
                <uri>http://xml.snd.gu.se/exist/rest{fn:base-uri($variable/ancestor::ddi:DDIInstance)}</uri>
                <id>{xs:string(
                    if($variable/ancestor::s:StudyUnit/r:UserID[@typeOfUserID='study_id'])
                        then
                            $variable/ancestor::s:StudyUnit/r:UserID[@typeOfUserID='study_id']
                        else
                            $variable/ancestor::s:StudyUnit/@id
                    )}   
                </id>
                <CallNumber>{xs:string($variable/ancestor::s:StudyUnit//a:CallNumber)}</CallNumber>
                <title>
                    {for $t in $variable/ancestor::s:StudyUnit/r:Citation/r:Title/r:String
                        return
                            element {$t/@xml:lang} {fn:string($t)}
                    }
                </title>
        </study>
    </variable>
};


declare function ddi-exist-utils:renderResponseDomain($item as node()) as node(){
    let $codeList := $item/ancestor::s:StudyUnit//l:CodeScheme[r:ID = xs:string($item//r:CodeListReference/r:ID)]
    let $categoryScheme := $item/ancestor::s:StudyUnit//.[r:ID = $codeList/r:CategorySchemeReference/r:ID]
    return
    <responsedomain>
        <codescheme>{$item/l:Representation/l:CodeRepresentation/r:CodeSchemeReference/r:ID}</codescheme>
        <codes>
            {
                for $category in $categoryScheme/l:Category
                    return 
                        <code>
                            <value>{xs:string($category/r:Version)}</value>
                            <label>
                                {for $t in $category/l:CategoryName/r:String
                                    return
                                        element {$t/@xml:lang} {fn:string($t)}
                                }
                            </label>
                        </code>
            }
        </codes>
    </responsedomain>
};

declare function ddi-exist-utils:findStudiesUsingQuestion($user_id as xs:string, $type as xs:string, $collection as node()*) as node()*{
        for $s in $collection//s:StudyUnit[.//r:UserID[@typeOfUserID=$type] = $user_id] 
        (:for $s in $collection//s:StudyUnit[.//r:UserID[@type=$type][ft:query(., <query><bool><term occur="must">{$user_id}</term></bool></query>)]] :)
            order by $s/ancestor-or-self::*/r:SeriesStatement, $s/r:Citation/r:Title[0]
            return
            <study>
                <uri>http://pelle.ssd.gu.se:8080/exist/rest{fn:base-uri($s/ancestor::ddi:DDIInstance)}</uri>
                <id>
                    {
                        if ($s/r:UserID[@typeOfUserID='study_id']) then
                            fn:string($s/r:UserID[@typeOfUserID='study_id'])   
                        else
                            fn:string($s/@id)  
                    }        
                </id>
                <title>
                    {for $t in $s/r:Citation/r:Title
                        return
                            element {ddi-exist-utils:getLang($t)} {fn:string($t)}
                    }
                </title>
                {
                    if ($s/ancestor-or-self::*/r:SeriesStatement) then
                        <series>
                            {
                                for $st in $s/ancestor-or-self::*/r:SeriesStatement/r:SeriesName
                                    return
                                        element {ddi-exist-utils:getLang($st)} {fn:string($st)}
                            }
                        </series>
                    else
                        ()
                }
            </study>
};

(:~
 : Find texts for autocomplete
 : @version 1.0
 : @param   $fragment
 : @param   $lang
 : @param   $type
 : @param   $collection
 : @return  autocomplete strings
 :)

declare function ddi-exist-utils:autocomplete($fragment as xs:string, $lang as xs:string, $type as xs:string, $collection as node()*) as xs:string*{
    if($type = 'title')
        then
            if(empty($lang))
                    then
                        distinct-values($collection//s:StudyUnit/r:Citation/r:Title[ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())  
                    else
                        distinct-values($collection//s:StudyUnit/r:Citation/r:Title[@xml:lang=$lang][ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())  
    else if($type = 'keyword')
        then
            if(empty($lang))
                    then
                        distinct-values($collection//s:StudyUnit//r:Keyword[ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())
                    else
                        distinct-values($collection//s:StudyUnit//r:Keyword[@xml:lang=$lang][ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())  
    else if($type = 'creator')
        then
            if(empty($lang))
                    then
                        distinct-values($collection//s:StudyUnit//r:Creator[ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())  
                    else
                        distinct-values($collection//s:StudyUnit//r:Creator[@xml:lang=$lang][ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())       
    else if($type = 'subject')
        then
            if(empty($lang))
                    then
                        distinct-values($collection//s:StudyUnit//r:Subject[ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())  
                    else
                        distinct-values($collection//s:StudyUnit//r:Subject[@xml:lang=$lang][ft:query(., <query><wildcard>{$fragment}*</wildcard></query>)]/text())                             
    else
        ()
};




(:~
 : Get the nearest xml:lang
 :  By Samuel Spencer <https://gist.github.com/3390504>
 : @version 1.0
 : @param   $node the node to get the xml:lang attribute from
 : @return  language code (default 'en')
 :)
declare function ddi-exist-utils:getLang($node as node()) as xs:string{
    let $lang := xs:string($node/ancestor-or-self::*[attribute::xml:lang][1]/@xml:lang)
    
    return if($lang != "") then
        $lang
    else
        "en"
};