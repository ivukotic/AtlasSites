<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<%@ language      = "javascript"%>

<html>

<head>

	<meta http-equiv = "Content-Type" content="text/html;charset=utf-8" />
	<title>HammerCloud tests of ATLAS physics data IO </title>
	<link rel   = "shortcut icon" href="../images/favicon.ico" />
	<link rel   = "stylesheet" href="css/hc.css" type="text/css">
    <link rel   = "stylesheet" href="http://code.jquery.com/ui/1.10.0/themes/base/jquery-ui.css">
    <script src="http://code.jquery.com/jquery-1.9.0.js"></script>
    <script src="http://code.jquery.com/ui/1.10.0/jquery-ui.js"></script>
	<script src="../Highcharts-2.3.5/js/highcharts.js" type="text/javascript"></script>
	<script src="../Highcharts-2.3.5/js/modules/exporting.js" type="text/javascript"></script>
	<script  src="../Highcharts-2.3.5/js/themes/dark-blue.js" type="text/javascript"></script>
	
	<script>
	
	
	var ts=0;
	$(document).ready(function() {

        $.post("preload.asp", function(msg){
            var parts=msg.split(/\n/g); 
            var projects = parts[0].split(",");
            for (var s=0;s<projects.length-1;s++){
                $( "#project" ).append('<option value="'+projects[s]+'">'+projects[s]+'</option>');
            }
            var ssites = parts[1].split(",");
            for (var s=0;s<ssites.length-1;s++){
                $( "#servsites" ).append( '<input type="checkbox" class="servsite" value="'+ssites[s]+'" />'+ssites[s]+'<br />' );
            }
            var csites = parts[2].split(",");
            for (var s=0;s<csites.length-1;s++){
                $( "#cliesites" ).append( '<input type="checkbox" class="cliesite" value="'+csites[s]+'" />'+csites[s]+'<br />' );
            }
        } );


		var options = {
	        chart: { renderTo: 'graphspace', zoomType: 'xy', type: 'line' , height: 600, margin: [60, 30, 45, 70]},
	        title: { text: ''},
	        xAxis: { type: 'datetime',  tickWidth: 0, gridLineWidth: 1 , title:{text:''} }, 
	        yAxis: { title:{text:''} },
	      	legend: { align: 'left', verticalAlign: 'top', y: 10, floating: true, borderWidth: 0 },
			// tooltip: { formatter: function() { return '<b>'+ this.series.name +'</b><br/>'+ Highcharts.dateFormat('%e. %b', this.x) +': '+ this.y +' m';} },
            // credits: {text: 'by Ilija Vukotic', href: "http://www.vukotic.me"} 
	    };
		
		var avgoptions = {
	        chart: { renderTo: 'barspace', type: 'bar' , height: 600 },
	        title: { text: ''},
	        xAxis: { categories: [] }, 
	        yAxis: { min:0, align:'high', title: {text:''} },
			legend:{ enabled: false }, 
			plotOptions: { bar: {dataLabels: {enabled: true}} },
			// tooltip: { formatter: function() { return '<b>'+ this.series.name +'</b><br/>'+ Highcharts.dateFormat('%e. %b', this.x) +': '+ this.y +' m';} },
            // credits: {text: 'by Ilija Vukotic', href: "http://www.vukotic.me"},
			series: [{ name: "value", data:[] }] 
	    };
		
		var projoptions = {
	        chart: { renderTo: 'barspace', type: 'line', height: 300, margin: [60, 30, 45, 50]},
	        title: { text: ''},
	        xAxis: { title: {text:''}, startOnTick: true, endOnTick: true}, 
	        yAxis: { title: {text:''}, min:0 },
	      	legend: { align: 'left', verticalAlign: 'top', y: 10, floating: true, borderWidth: 0 },
            // credits: {text: 'by Ilija Vukotic', href: "http://www.vukotic.me"}
	    };
	    		
		// if (screen.width>1024) { $("#glavnacolumn").css("width","80%");$("BODY").css("font","90% arial,sans-serif");}

        $('#g2avg').click(function(){  ts=0; }); // show avg.
        $('#g2projx').click(function(){  ts=1; });
        $('#g2projy').click(function(){  ts=2; });
        
		$("#refresh").click(gData);
		$("#project").click(gData);
		$('#toPlotX, #toPlotY').change(gData);
		$("#vsTime").click( function(){ 
            console.log("vsTime is clicked.");
			if ($("#vsTime").is(':checked')) { 
                console.log("vsTime is checked.");
			    $('#toPlotX').attr('disabled', 'disabled'); 
			    $('#g2avg').attr('checked', true); 
			    $('#g2projx').attr('disabled', 'disabled'); 
			} else { 
			    $('#toPlotX').removeAttr('disabled');
			    $('#g2projx').removeAttr('disabled'); 
			} 
		});
		

		var dates = $( "#from, #to" ).datepicker({
			onClose: gData,
			dateFormat: 'yy-mm-dd',
			// defaultDate: "-1w",
			maxDate: '+1d',
			changeMonth: true,
			numberOfMonths: 1,
			onSelect: function( selectedDate ) {
				var option = this.id == "from" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" ),
					date = $.datepicker.parseDate(instance.settings.dateFormat || $.datepicker._defaults.dateFormat, selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
	    });
		
		$("#annocreated").datepicker({dateFormat: 'yy-mm-dd'});
		
		$( "#from").datepicker( "setDate" , '-1w' );
		$( "#to").datepicker( "setDate" , '+1d' );
		
				
		function gData(){
			options.title.text=$("#project option:selected").text();
			options.xAxis.title.text = $("#toPlotX option:selected").text(); 
			options.yAxis.title.text = $("#toPlotY option:selected").text();
			
			if (ts==0){
			    avgoptions.title.text= $("#toPlotY option:selected").text() +' for '+ $("#project option:selected").text();
			}
			else if (ts==1){
			    projoptions.title.text= $("#project option:selected").text();
                projoptions.xAxis.title.text= $("#toPlotX option:selected").text();
			} 
			else{
			    projoptions.title.text= $("#project option:selected").text();
			    projoptions.xAxis.title.text= $("#toPlotY option:selected").text();
			}
			
			if ($("#dLine").is(':checked')){options.chart.type='line';}else{options.chart.type='scatter';}
			var xax=$("#toPlotX").val();
			if ($("#vsTime").is(':checked')) {
				xax="to_number(result.created - to_date('01-JAN-1970','DD-MON-YYYY')) * 86400000";
				options.xAxis.title.text='Date & Time';
				options.xAxis.type='datetime';
			}else{
				options.xAxis.type='linear';
				delete options.xAxis.tickInterval;
			}
			
			var servSelSites=new Array(); $('.servsite').each( function (){ if (this.checked) {servSelSites.push($(this).val()); } }) ;
			var clieSelSites=new Array(); $('.cliesite').each( function (){ if (this.checked) {clieSelSites.push($(this).val()); } }) ;
            if (!servSelSites.length || !clieSelSites.length) return;
            
			$("#loading").show();
			$.post("getData.asp", {project: $("#project").val(), toplotX: xax, toplotY: $("#toPlotY").val(), from: $("#from").val(), to: $("#to").val(), servsites: servSelSites.join(), cliesites: clieSelSites.join()  }, 
				function(msg){ 
					if (! msg.length)  return;
                    
					var ser=-1;
                    var maxx=-9999;
                    var maxy=-9999;
                    var minx=999999999;
                    var miny=999999999;
					options.series = new Array();
    				var avers= new Array();
                    
					avgoptions.xAxis.categories = [];
					avgoptions.series[0].data = [];
					
					msg = msg.split(/\n/g);
					jQuery.each(msg, function(i, line) {
						line = line.split(/\t/);
						if (line[0]=='link:') {
							ser=ser+1;							
							options.series[ser]=new Object();
							options.series[ser].name = line[1];
							options.series[ser].data = new Array();
							
							avgoptions.xAxis.categories.push(options.series[ser].name);
                            avers.push([0,0]);
							
						}else{
							var x=parseFloat(line[0]);
							var y=parseFloat(line[1]);
							if (isNaN(x) || isNaN(y)){
								// $( "#glavnacolumn" ).append( "--"+line[0]+"--"+line[1]+ "--" + '</br>'   );
							}else{
								options.series[ser].data.push( [ x, y ] );
                                if (x<minx) minx=x; else if (x>maxx) maxx=x;
                                if (y<miny) miny=y; else if (y>maxy) maxy=y;
                    		    avers[ser][0]+=1; avers[ser][1]+=y;									
							}
						}
					});
					
					for( i in avers){
                        if (avers[i][0]==0) {
                            console.log("seria has 0 average");
						    avgoptions.series[0].data.push(0);	
                            continue;
                        }
                        var seriesAver = Math.round(avers[i][1]/avers[i][0]*100) /100;
                        console.log("average value: "+seriesAver)
						avgoptions.series[0].data.push(seriesAver);	
					}
					
					
					$("#loading").hide();
					chart = new Highcharts.Chart(options);
					
					if (ts==0) {
						barchart = new Highcharts.Chart(avgoptions);
					} else {
						projoptions.series = new Array();
					    for (w=0;w<options.series.length;w++){
					        projoptions.series[w]=new Object();
        					projoptions.series[w].name = options.series[w].name;
        					projoptions.series[w].data = new Array;
        					
    					    if(ts==1){
					            bw=(maxx-minx)/100;
        					    for (bin=0;bin<101;bin++) projoptions.series[w].data.push([minx+bin*bw,0]);
					            for(p=0;p<options.series[w].data.length;p++){
					                bin = Math.round( (options.series[w].data[p][0] - minx)/bw );
                                    projoptions.series[w].data[bin][1]++;
					            }
		
        					} else {
					            bw=(maxy-miny)/100;
        					    for (bin=0;bin<101;bin++) projoptions.series[w].data.push([miny+bin*bw,0]);
					            for(p=0;p<options.series[w].data.length;p++){
					                bin = Math.round( (options.series[w].data[p][1] - miny)/bw );
                                    projoptions.series[w].data[bin][1]++;
					            }
        					}
					    }
    					projchart = new Highcharts.Chart(projoptions);
					}
					
				}
			);
		};
		
		
		$( "#dialog" ).dialog({ autoOpen: false, show: "blind", width: 800, height: 640 });
        
        $( "#dialogANNO" ).dialog({ autoOpen: false, show: "blind", width: 800, height: 640 });
        
		$( "#opener" ).click(function() {
			$( "#dialog" ).dialog( "open" );
			return false;
		});
		$( "#bANNO" ).click(function() {
		    $("#loading").show();
		    var sSite='ANY';
		    $('.csite').each( function (){ if (this.checked) {sSite=$(this).val(); } }) ;
		    $("#annofrom").empty().append($("#from").val());
		    $("#annoto").empty().append($("#to").val());
		    $("#annosites").empty().append(sSite);
		    $("#annotable").empty().append("<tr><th>user</th><th>created</th><th>content</th></tr>");
			$.post("getAnno.asp", { from: $("#from").val(), to: $("#to").val(), site: sSite }, 
				function(msg){ 
                    msg=$.trim(msg);
                    msg = msg.split(/\n/g);
                    jQuery.each(msg, function(i, line) {
                        line=$.trim(line);
                        line = line.split(/\t/);
            		    $("#annotable").append("<tr><td>"+line[2]+"</td><td>"+line[0]+"</td><td>"+line[1]+"</td></tr>");
                    });
					
                    // $("tr:odd").css({backgroundColor: '#ccc'});
					$("#loading").hide();
					
				}
			);
			$( "#dialogANNO" ).dialog( "open" );
			return false;
		});
		
		$( "#bannonew" ).click(function() {
		    $("#loading").show();
		    var sSite='ANY';
		    $('.csite').each( function (){ if (this.checked) {sSite=$(this).val(); } }) ;
			$.post("putAnno.asp", { content: $("#annocontent").val(),  site: sSite, created:$("#annocreated").val() }, 
				function(msg){ 
                    if(msg) alert(msg);
					$("#loading").hide();
				}
			);
            $("#annocontent").empty();
			$( "#bANNO" ).click();
			return false;
		});
		
		           
	})
	</script>


	<script type="text/javascript">
	var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
	document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
	</script>
	<script type="text/javascript">
	var pageTracker = _gat._getTracker("UA-3194765-1");
	pageTracker._trackPageview();
	</script>
</head>

<body>


	<div id="leftcolumn" >
		
		<div id="login"> 
			<img id="opener" src="images/help_icon.gif" /> &nbsp;&nbsp;
			
			<%
			if (Request.ServerVariables("LOGON_USER") == "") {
			    Response.Write('<a href="../login/default.asp" id="loginLnk" >Login</a>');
		    }
			else {	
                 // Login name is retrieved like "CERN\username". We trim the login name without "cern\"
                var login = Request.ServerVariables("LOGON_USER")+'';
                login = login.substr(5);
                Response.Write(login);
            }
            
			%>
			<hr>
		</div>
		
		<label for="from">From</label></br>
		<input type="text" id="from" name="from"/></br>
		<label for="to">to</label></br>
		<input type="text" id="to" name="to"/>

		<p>
			<select id="project"></select>
        </p>

        <p>  
		x: <select id="toPlotX">
			<option value="ping">ping [ms]</option>
			<option value="copytime">direct copy [s]</option>
			<option value="readtime">read time</option>
			<option value="cputime">cpu time</option>
			<option value="round(cputime/nullif(readtime,0),3)">CPU eff.</option>
			<option value="reads">reads</option>
			<option value="filesize">filesize [kb]</option>
			<option value="pandaid">pandaID</option>
		</select></br>
		y: <select id="toPlotY">
    		<option value="ping">ping [ms]</option>
    		<option value="copytime">direct copy [s]</option>
    		<option value="readtime">read time</option>
			<option value="cputime">cpu time</option>
			<option value="round(cputime/nullif(readtime,0),3)">CPU eff.</option>
    		<option value="reads">reads</option>
    		<option value="filesize">filesize [kb]</option>
    		<option value="pandaid">pandaID</option>
		</select>
		</p>
	    <div style="float: left">
		    <input type="checkbox" id="vsTime" />vs Time<br />
		    <input type="checkbox" id="dLine" />line<br />
		</div>
		<div style="float: right">
                <input type="radio" name="g2" id="g2avg" checked /> avg.<br/>
                <input type="radio" name="g2" id="g2projx" /> proj. x<br/>
                <input type="radio" name="g2" id="g2projy" /> proj. y
		</div>
		<div style="clear:both">
    		<button id="refresh"  >Refresh</button><button id="bANNO"  >Annotations</button>
		</div>
		<h3>Server Sites</h3>
		<div id="servsites"></div>
		<h3>Client Sites</h3>
		<div id="cliesites"></div>
	</div>

	<div id="glavnacolumn">
		<div id="graphspace"></div><br />
		<div id="barspace"></div>
	</div>
	
	<div id="loading"  style="display: none" >
		<br><br>Loading data. Please wait...<br><br>
			<img src="images/wait_animated.gif" alt="loading" />
	</div>
	
	<div id="dialog" title="ATLAS WAN IO tests" style="text-align:left">	
        <h3>Idea</h3>
        Efficient WAN federation of resources would provide several important benefits:
        <ul>
            <li>Improve robustness - In case data are missing or corrupted at one site job would not fail but just access it directly from other site.</li>
            <li>Increase resources - If remote access would be almost as efficient as the local one, duplication of the data at different site would be avoided thus leaving more free space.</li>
            <li>Improved hardware utilization. Spare CPU capacity of one site could take over jobs whose input data are at other site</li>
            <li>Open the way for the big scale analysis services (SSS->SkimSlimService) </li>
        </ul>
        Where are several reasons for this test framework:
        <ul>
        	<li>WAN IO performance is changing all the time as function of packet routing, bandwidth, WN and SE load. </li>
        	<li>We want to easily test impact of any changes we will make on: ROOT file organization/setting, ROOT/Athena version used, way we use the files.</li>
        	<li>Need a way to compare different hardware, hardware and software site configurations. Optimize sites.</li>
        </ul>    
        Access is open not only to ATLAS community but also ROOT collaborations. We are also open for communication with sites.
        A short description of how stuff works underneath can be found <a href="https://twiki.cern.ch/twiki/bin/viewauth/Atlas/SiteIOperformance">here.</a>
        <h3>HC side of things</h3>
        There is a functional HammerCloud test set up which submits a test job to the most of large sites. 
        HummerCloud tries to always keep one test in the queue at ANALY queue of the sites. This usually means that sites run roughly 100 jobs per day. Tests are running continuously.
        HC just submits the job using Ganga and there is no special settings, so we are seeing the same performance as any normal grid analysis job. 
        Whatever a site does for normal analysis job it does the same thing for the test jobs.   
        <h3>Tests</h3>
        Each job submitted looks up from the database a list of "server" sites - sites that are available to provide the data. Each of server sites is tested in  different scenarios. Currently these are:
        <ul>
            <li><b>Ping - to establish if site is up at all and know its "distance" </li>
            <li><b>direct copy</b> test file is copied using relevant mechanism (now xrdcp) </li>
            <li><b>100% default cache</b> simple ROOT script reads sequentially 100% of events with TTreeCache set to default value of 30MB. </li>
        </ul> 
        
        <h3>Results</h3>
        Results are automatically uploaded to ORACLE database in CERN. The DB schema: <img src="images/DBschema.png" /> 
		While the most of variables stored are self-explanatory I will try to find time to describe exactly how each of them is obtained.
		For now it is important to explain content of the db table named "panda". HC test jobs collect pandaID. This ID is used by the cron job which runs every one hour to look up the pilot collected information from the panda monitor. From all of the panda monitor information we store: timing information (stage-in, stage-out, setup and exec times), job status, machine name, cmtconfig and atlas release. It is important to notice that the timing information is for all of the test. 
        <h3>Web site</h3>
		Even still in development, this web site can be used to look up the most important information. If you need an additional information that can be looked up from the db and is not available through the site let me know and I can give it to you directly. Please feel free to send me any comments, suggestions, feature requests.
    </div>
    
    <div id="dialogANNO" title="Annotations" style="text-align:left">
        <table>
        <tr><td>from:</td><td id="annofrom"></td></tr>
        <tr><td>to:</td><td id="annoto"></td></tr>
        <tr><td>site:</td><td id="annosites"></td></tr>
        </table>
        <hr>
        <table  class="styledTable"> 
         <tr><th>content</th><th>date</th></tr>
         <tr><td><input type="text" id="annocontent" style="width:97%" /></td><td><input type="text" id="annocreated" size="10"/></td><td><button id="bannonew"  >add</button></td></tr>
        </table>
         <hr>
         <table id="annotable"  class="styledTable">
         </table>
    </div>
    
</body>

</html>
