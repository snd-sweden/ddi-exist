xquery version "3.0";
declare option exist:serialize "method=html media-type=text/html"; 

<html>
    <head>
        <title>DDI-eXist</title>
    </head>
    <body>
        <h2>Search</h2>
        <ul>
            <li><a href="search">search</a> empty search (list all)</li>
            <li><a href="search?format=json">search?format=json</a> return json instead of xml</li>
            <li><a href="search?q=election">search?q=election</a> search studies, question and variables for &quot;election&quot;</li>
        </ul>
        <h2>List</h2>
        <ul>
            <li><a href="list?type=subject">list?type=subject</a> list all subjects</li>
        </ul>        
        <h2>Validate</h2>
        
        
    </body>
</html>
