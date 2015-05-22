xquery version "3.0";
module namespace ddi-exist="https://github.com/snd-sweden/ddi-exist/search";

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


(:~
 : Makes a free-text search in StudyUnit elements and returns the matches
 :
 : @version 1.0
 : @param   $search the string that needs to be matched
 : @param   $lang  filter the search for one language, if empty all languages
 : @param   $collection the collection to search in
 :)
declare function ddi-exist:searchStudy($search as xs:string, $lang as xs:string, $collection as node()*) as node()*
{
    if($search = '') then
        $collection/ddi:DDIInstance/s:StudyUnit
    else    
        if($lang = '')
            then
                for $element in $collection//ddi:DDIInstance/s:StudyUnit[
                        ft:query(.//r:Title, $search)  | 
                        range:field-contains('title', $search)  |
                        ft:query(.//a:CallNumber, $search)  |
                        contains(.//a:CallNumber, $search)  |
                        ft:query(.//r:Subject, $search) |
                        ft:query(.//r:Keyword, $search) |
                        ft:query(.//s:Content, $search) |
                        ft:query(.//a:FirstGiven, $search) |
                        ft:query(.//a:LastFamily, $search) |
                        ft:query(.//r:Abstract, $search) |
                        ft:query(.//r:Purpose, $search) |
                        ft:query(.//a:OrganizationName/r:String, $search) |
                        ft:query(.//r:UserID, $search) |
                        ft:query(.//r:KindOfData, $search)
                    ]
                    order by ft:score($element) descending
                    
                    return $element
          else
                for $element in $collection//ddi:DDIInstance/s:StudyUnit[ft:query(.//., $search)]   
                    order by ft:score($element) descending
                    return $element

};


(:~
 : Free-text search in questions elements
 :
 : @version 1.0
 : @param   $search the string that needs to be matched
 : @param   $lang  filter the search for one language, if empty all languages
 : @param   $collection the collection to search in
 : @return  all top level questions containing the match
 :)
declare function ddi-exist:searchQuestion($search as xs:string, $lang as xs:string, $collection as node()*) as node()*
{
    let $result :=
        if($search = '')
        then
            $collection//d:QuestionItem | $collection//d:QuestionGrid
        else
            if($lang = '')
            	then
            	    let $questionTexts :=  distinct-values($collection//d:QuestionText//d:Text[ft:query(., $search)])
            	    
                    for $text in $questionTexts
                        return $collection//d:QuestionItem[.//d:Text eq $text][1] | $collection//d:QuestionGrid[.//d:Text eq $text][1]
            	else
                	for $q in $collection//(d:QuestionItem | d:QuestionGrid)[.//d:Text[@xml:lang = $lang][ft:query(., $search)]]
                	    group by $text := ($q//d:Text)[1]

                        return $q
    return
        $result
};


declare function ddi-exist:searchVariable($search as xs:string, $lang as xs:string, $collection as node()*) as node()*
{
    if($search = '')
    then
        $collection//l:Variable
    else
        if(empty($lang))
            then
        		$collection//l:Variable[ft:query(.//., $search)]
        	else
        		$collection//l:Variable[ft:query(.//., $search)]
};

(:~
 : Makes a free-text search in StudyUnit elements and returns the matches
 :
 : @version 1.0
 : @param   $id to find
 : @param   $collection the collection to search in
 :)
declare function ddi-exist:searchStudyById($id as xs:string, $collection as node()*) as node()*
{
    if($id = '') then
        $collection/ddi:DDIInstance/s:StudyUnit
    else    
        let $list :=
            $collection//ddi:DDIInstance/s:StudyUnit[.//r:UserID = $id] 
         for $element in $list
            order by ft:score($element) descending
            return $element
};

(:~
 : Find studies based on geography code or free text
 :
 : @version 1.0
 : @param   $id to find
 : @param   $type the geo code type to search for
 : @param   $collection the collection to search in
 :)
declare function ddi-exist:searchStudyByGeoId($id as xs:string, $type as xs:string, $collection as node()*) as node()*
{
    if($id = '') then
        $collection/ddi:DDIInstance/s:StudyUnit
    else if($type = '') then
        $collection//ddi:DDIInstance/s:StudyUnit[.//r:GeographyValue[r:GeographyCode/r:Value = $id]] |
        $collection//ddi:DDIInstance/s:StudyUnit[.//r:GeographyName = $id]
    else    
        let $list :=
            $collection//ddi:DDIInstance/s:StudyUnit[.//r:GeographyValue[r:GeographyCode/r:Value[@codeListID=$type] = $id]]
         for $element in $list
            order by ft:score($element) descending
            return $element
};

declare function ddi-exist:term-callback($term as xs:string, $data as xs:int+) as element() {
    <term freq="{$data[1]}" docs="{$data[2]}" n="{$data[3]}">{$term}</term> 
};

declare function ddi-exist:facets($search as xs:string, $lang as xs:string, $collection as node()*) as node(){
   let $hits := if(empty($search)) then
                    $collection
                else
                    $collection
    
    let $callback := util:function(xs:QName("ddi-exist:term-callback"), 2) 
    
    (: declare facets as XPath expressions, relative to the search hits :) 
    let $facets := 
      <facets>
        <facet label="subject">$hits//r:Subject[@xml:lang='sv']</facet>
        <facet label="keyword">$hits//r:Keyword[@xml:lang='sv']</facet>
        <facet label="kindofdata">$hits//s:KindOfData</facet> 
        <facet label="analysisunit">$hits//r:AnalysisUnit</facet>
        <facet label="organizationname">$hits//a:OrganizationName[ft:query(@xml:lang,$lang)]</facet>
      </facets> 
    
    return 
      <facets>
        <count>{count($hits)}</count>
        { 
        (: loop over facet XPaths, and evaluate them :)
        for $facet in $facets//facet 
            let $vals := util:eval($facet) 
            return <facet>{
              $facet/@label,
              subsequence(
                  for $t in util:index-keys($vals, '', $callback, 300)
                    order by xs:integer($t/@docs) descending
                        return $t
              , 0, 10)
            }</facet>
      }
      </facets>  
};






declare function ddi-exist:limitMatches($nodes as node()*, $start as xs:integer, $records as xs:integer) as node()*
{
    let $max := count($nodes)

    (: restrict the full set of matches to this subsequence :)
    return subsequence($nodes, $start, $records)    
};

declare function ddi-exist:getQuestions($questionId as xs:integer, $collection as node()*) as node()*
{
    $collection//.[r:UserID[@type='question_id'] = $id]/ancestor::d:MultipleQuestionItem  
};
