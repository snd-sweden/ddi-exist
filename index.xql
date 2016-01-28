xquery version "3.0";
declare option exist:serialize "method=html media-type=text/html"; 

<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<title>DDI-eXist</title>
		<link rel="shortcut icon" type="image/png" href="icon.png"/>
		<!-- Bootstrap -->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" />
		<!-- Optional theme -->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css" />
		<!--[if lt IE 9]>
		<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
		<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		<![endif]-->
	</head>
	<body>
		<div class="container">
			<div class="page-header">
			    <div class="media">
			        <div class="media-left">
			            <img class="media-object" src="icon.png" />
			        </div>
			        <div class="media-body">
			            <h1>DDI-eXist endpoint</h1>
			            <p class="lead">Documentation about services avalible in DDI-eXist</p>
			        </div>
			    </div>
			</div>
			<div class="panel panel-primary">
				<div class="panel-heading">Search</div>
				<div class="panel-body">
				    
					<h4>Simple search</h4>
					<ul class="list-group">
						<li class="list-group-item"><a href="search">{request:get-url()}search</a> empty search (list all)</li>
						<li class="list-group-item"><a href="search?format=json">{request:get-url()}search?format=json</a> return json instead of xml</li>
						<li class="list-group-item"><a href="search?q=election">{request:get-url()}search?q=election</a> search studies, question and variables for &quot;election&quot;</li>
					</ul>
					
					<h4>Filter search</h4>
					<ul class="list-group">
						<li class="list-group-item"><a href="search?subject=history">{request:get-url()}search?subject=history</a> The documents must have the subject &quot;history&quot;</li>
					</ul>
				</div>
			</div>
			<div class="panel panel-primary">
				<div class="panel-heading">List values</div>
				<div class="panel-body">
					<ul class="list-group">
						<li class="list-group-item"><a href="list?type=subject">{request:get-url()}list?type=subject</a> list all subjects</li>
					</ul>
				</div>
			</div>
		</div>
		<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
		<!-- Include all compiled plugins (below), or include individual files as needed -->
		<script src="js/bootstrap.min.js"></script>        
	</body>
</html>

