<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<%@ language      = "javascript"%>

<html>

<head>

	<meta http-equiv = "Content-Type" content="text/html;charset=utf-8" />
	<title>HammerCloud tests of ATLAS physics data IO - Dashboard</title>
	<link rel   = "shortcut icon" href="../images/favicon.ico" />
	<link rel   = "stylesheet" href="css/hc.css" type="text/css">
	<link rel   = "stylesheet" href="../css/redmond/jquery-ui-1.8.16.custom.css">
	<script src="../jquery/jquery-1.7.min.js"></script>
	<script src="../jquery/jquery-ui-1.8.16.custom.min.js"></script>
	<script src="../js/highcharts.js" type="text/javascript"></script>
	<script src="../js/modules/exporting.js" type="text/javascript"></script>
	<script  src="../js/themes/dark-blue.js" type="text/javascript"></script>
	
	<%
		if ( (Request.QueryString("project")+'') != 'undefined') { 
			var project = Request.QueryString("project");
			var sites   = Request.QueryString("sites");
			var plot    = Request.QueryString("toplotY");
			Response.Write("<script language=javascript> var project='"+project+"'; var sites='"+sites+"'; var plot='"+plot+"'; var show=0; </script>");
		}else{
			Response.Write("<script language=javascript> var project='';var sites=''; var plot=''; var show=1;</script>");
		}
	%>
	
	<script>
	
	
	$(document).ready(function() {

		if (show==0) {
			$("#leftcolumn").hide();
			gData();
		}
		else{
			$.post("preload.asp", function(msg){
				var parts=msg.split("<|>");
	            var allprojects = parts[0].split(",");
	            for (var s=0;s<allprojects.length-1;s++)
	                $( "#project" ).append('<option value="'+allprojects[s]+'">'+allprojects[s]+'</option>');
            
				var allsites = parts[1].split(",");
	            for (var s=0;s<allsites.length-1;s++)
	                $( "#sites" ).append( '<input type="checkbox" class="csite" value="'+allsites[s]+'" />'+allsites[s]+'<br />' );
            
	        } );
		}
      

		var options = {
	        chart: { renderTo: 'graphspace', zoomType: 'xy', type: 'scatter' , height: 600, margin: [60, 30, 45, 70]},
	        title: { text: ''},
	        xAxis: { type: 'datetime',  tickWidth: 0, gridLineWidth: 1 , title:{text:'Date & Time'} }, 
	        yAxis: { title:{text:''} },
	      	legend: { align: 'left', verticalAlign: 'top', y: 10, floating: true, borderWidth: 0 },
            // credits: {text: 'by Ilija Vukotic', href: "http://www.vukotic.me"} 
	    };
		
		var avgoptions = {
	        chart: { renderTo: 'barspace', type: 'bar' , height: 300 },
	        title: { text: ''},
	        xAxis: { categories: [] }, 
	        yAxis: { min:0, align:'high', title: {text:''} },
			legend:{ enabled: false }, 
			plotOptions: { bar: {dataLabels: {enabled: true}} },
            // credits: {text: 'by Ilija Vukotic', href: "http://www.vukotic.me"},
			series: [{ name: "value", data:[] }] 
	    };
		
	    		
		$("#refresh").click(gData);
		$('#toPlotY').change(gData);
	
		var dates = $( "#from, #to" ).datepicker({
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
		
		$( "#from").datepicker( "setDate" , '-1w' );
		$( "#to").datepicker( "setDate" , '+1d' );
		

				
		function gData(){
			$("#loading").show();
			
			var gProject  ;
			var gtoplotY  ;
			var gselSites ;
			var gfrom     ;
			var gto       ;

			
			if (show==0){
				gProject=project;
				gselSites=sites;
				var fd=new Date();
				var td=new Date();
				td.setTime(fd.getTime()+24*3600000);
				fd.setTime(fd.getTime()-7*24*3600000);
				gfrom=fd.getFullYear()+'-'+(fd.getMonth()+1)+'-'+fd.getDate();
				gto=td.getFullYear()+'-'+(td.getMonth()+1)+'-'+td.getDate();
				gtoplotY=plot;
				// document.write('<H3>test : '+gProject+'</H3>');
				// document.write('<H3>sites: '+gselSites+'</H3>');
				// document.write('<H3>plot : '+gtoplotY+'</H3>');
				// document.write('<H3>from : '+gfrom+'</H3>');
				// document.write('<H3>to   : '+gto+'</H3>');
				show=-1;
			}else{
				options.title.text=$("#project option:selected").text();
				options.yAxis.title.text = $("#toPlotY option:selected").text();
			    avgoptions.title.text= $("#toPlotY option:selected").text() +' for '+ $("#project option:selected").text();

				var selSites=new Array(); $('.csite').each( function (){ if (this.checked) {selSites.push($(this).val()); } }) ;

				gProject  = $("#project").val();
				gtoplotY  = $("#toPlotY").val();
				gselSites = selSites.join();
				gfrom=$("#from").val();
				gto=$("#to").val();
				var lin="http://ivukotic.web.cern.ch/ivukotic/HC/dashboard.asp"
				lin += "?project="+gProject + "&sites="+gselSites + "&toplotY="+gtoplotY;
				$("#bookID").attr("href", encodeURI(lin));
			}
			
			$.get("getDashData.asp", {project: gProject, toplotY: gtoplotY, from: gfrom, to: gto, sites: gselSites  }, 
				function(msg){ 
					var avers= new Array();
                    var maxx=-9999;
                    var maxy=-9999;
                    var minx=999999999;
                    var miny=999999999;
					if (msg.length){
						var ser=-1;
						options.series = new Array();
						
						avgoptions.xAxis.categories = [];
						avgoptions.series[0].data = [];
						
						msg = msg.split(/\n/g);
						jQuery.each(msg, function(i, line) {
							line = line.split(/\t/);
							if (line[0]=='site:') {
								ser=ser+1;							
								options.series[ser]=new Object();
								options.series[ser].name = line[1];
								options.series[ser].data = new Array;
								
								avgoptions.xAxis.categories.push(line[1]);
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
								avgoptions.series[0].data.push( Math.round(avers[i][1]/avers[i][0]*100) /100 );	
						}
						
					}
					chart = new Highcharts.Chart(options);
					barchart = new Highcharts.Chart(avgoptions);
				}
				
			);
					$("#loading").hide();
		};
		
		           
	})
	</script>



</head>

<body>


	<div id="leftcolumn" >
		<a href="http://ivukotic.web.cern.ch/ivukotic/HC/dashboard.asp" id="bookID" >Bookmark link</a>
		
		</br>	
		<label for="from">From</label></br>
		<input type="text" id="from" name="from"/></br>
		<label for="to">to</label></br>
		<input type="text" id="to" name="to"/>

		<p><select id="project"></select></p>

        <p>  
		<select id="toPlotY">
			<option value="cputime">CPU time [s]</option>
			<option value="walltime">WALL time [s]</option>
			<option value="round(cputime/nullif(walltime,0),3)">CPU eff.</option>
			<option value="usedswap">Used swap [kb]</option>
			<option value="load">load</option>
			<option value="networkin">Network IN [blocks]</option>
			<option value="networkout">Network OUT [blocks]</option>
			<option value="result.pandaid">pandaID</option>
			<option value="stagein">stagein [s]</option>
			<option value="stageout">stageout [s]</option>
			<option value="exec">exec [s]</option>
			<option value="setup">setup [s]</option>
			<option value="setup+exec+stageout+stagein">total time[s]</option>
		</select>
		</p>
		
		<div style="clear:both">
    		<button id="refresh"  >Refresh</button>
		</div>

		<h3>Sites</h3>
		<div id="sites"></div>

	</div>

	<div id="glavnacolumn">
		<div id="graphspace"></div></br>
		<div id="barspace"></div>
	</div>
	
	<div id="loading"  style="display: none" >
		<br><br>Loading data. Please wait...<br><br>
			<img src="images/wait_animated.gif" alt="loading" />
	</div>
	
</body>

</html>
