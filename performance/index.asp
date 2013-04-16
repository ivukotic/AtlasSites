<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<%@ language="javascript"%>

<html>

<head>
	
	
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>ATLAS Computing Performance Browser</title>


<!-- FOR DROPDOWN MENU -->
<link rel="stylesheet" type="text/css" href="dd/dd.css" />
<script src="dd/stuHover.js" type="text/javascript"></script>

<!-- jQuery -->
<!--<link rel    = "stylesheet" href="../css/redmond/jquery-ui-1.8.16.custom.css">-->
<link rel    = "stylesheet" href="../css/le-frog/jquery-ui-1.8.17.custom.css">
<script src  = "../jquery/jquery-1.7.min.js"></script>
<script src  = "../jquery/jquery-ui-1.8.16.custom.min.js"></script>
<script src  = "../js/highcharts.js" type="text/javascript"></script>
<script src  = "../js/modules/exporting.js" type="text/javascript"></script>
<!-- <script  src = "../js/themes/dark-blue.js" type="text/javascript"></script> -->

<!-- This Site js and css -->
<link rel    = "shortcut icon" href="../images/favicon.ico" />
<link rel    = "stylesheet" type="text/css" href="css/performance.css" />


<script type = "text/javascript">
        var _gaq   = _gaq || [];
        _gaq.push(['_setAccount', 'UA-3194765-1']);
        _gaq.push(['_trackPageview']);
        (function() {
                var ga   = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                ga.src   = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                var s    = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
</script>

<script>
	        	
	var menu1value;
	var menu2value;
	var menu3value;
	var aspFunc;
    var view='graphmenu';
	var usemu=0;
    var useid=0;

	
	var options = {
        chart: { renderTo: 'graphspace', type: 'scatter' , height: 600 , zoomtype: 'x'},
        title: { text: 'c'},
        // xAxis: { type: 'datetime', tickInterval: 1 * 24 * 3600 * 1000, tickWidth: 0, gridLineWidth: 1  },
        xAxis: { type: 'linear' },
        yAxis: {  },
      	legend: { align: 'left', verticalAlign: 'top', y: 7, floating: true, borderWidth: 0 },
		// tooltip: { formatter: function() { return '<b>'+ this.series.name +'</b><br/>'+ Highcharts.dateFormat('%e. %b', this.x) +': '+ this.y +' m';} },
        // credits: {text: 'by Ilija Vukotic', href: "http://www.vukotic.me"} 
    };

    function setMenu(aF,m1,m2,m3){
		aspFunc=aF;
		menu1value=m1;
		menu2value=m2;
		menu3value=m3;

		refresh();
	}

	function refresh(){
		$("#loading").show();
        if ($('#vsmuid').is(':checked')) usemu=1; else usemu=0; 
        if ($('#useid').is(':checked')) useid=1; else useid=0;  
        minrun = $('#minrunid').val();
        maxrun = $('#maxrunid').val();
		if (aspFunc==0) run(menu1value,menu2value,menu3value);
		if (aspFunc==1) obj(menu1value,menu2value);
		if (aspFunc==2) alg(menu1value,menu2value);
		if (aspFunc==4) showStatus();
		if (aspFunc==5) cleanUp();
	}
    	
	
	function drawTable(){
	    $('#graphspace').hide(); 
	    $('#accordion').empty().show();
	    $('#accordion').accordion( "destroy" );
	    for (var i=0; i<ALLData.length;i++){
            $('#accordion').append('<h3><a href="#">'+ALLData[i].name+'</a></h3><div id="div-'+ALLData[i].name+'"></div>')
            $('#div-'+ALLData[i].name).append("<table id='tab-" + ALLData[i].name + "' width='100%' border='0' ></table>")
            $('#tab-'+ALLData[i].name).append("<tr><th>"+ options.xAxis.title.text +"</th><th>"+ options.title.text +"</th></tr>");
            for (var j=0;j<ALLData[i].data.length;j++){
                $('#tab-'+ALLData[i].name).append("<tr><td>"+ ALLData[i].data[j][0] +"</td><td>"+ ALLData[i].data[j][1] +"</td></tr>");
            }
        }
        $('#accordion').accordion({ collapsible: true, fillSpace: true });// event: "mouseover",
	}
	
	function makeCSV(){
	    $.post("getRunData.asp", { tit:options.title.text, tity:options.yAxis.title.text, data: ALLData, usemu:usemu}
            // ,function(msg){
                 // parseData(msg); 
                // }
		);
        // var elemIF = document.createElement("iframe");
        //         elemIF.src = 'getRunData.asp';
        //         elemIF.style.display = "none";
        //         document.body.appendChild(elemIF)
	}
	
	function toggleSeries(){
	    
	    options.series=new Array();
        
        $('.cbs').each( function (){ 
            if (this.checked) {
                for (var i=0; i<ALLData.length;i++){
                    if ($(this).val()==ALLData[i].name) options.series.push(ALLData[i]); 
                }
            }
        }) ;
        
        if (view=='graphmenu'){
    	    $('#accordion').hide('slow');
	        $('#graphspace').show('slow');
            chart = new Highcharts.Chart(options);
        }
	}
	
	function parseData(msg){
	    if (msg.length){
			var ser=-1;
			ALLData = new Array();
			msg = msg.split(/\n/g);
			$( "#chboxes" ).empty();
			jQuery.each(msg, function(i, line) {
				line = line.split(/\t/);
				if (line[0]=='serie:') {
					ser=ser+1;							
					ALLData[ser]=new Object();
					ALLData[ser].name = line[1];
					ALLData[ser].data = new Array;
					if (view=='graphmenu')	$( "#chboxes" ).append( '<input type="checkbox"  checked="yes" class="cbs"  value="'+line[1]+'" />'+line[1]+'<br />' );

				}else{
					var x=parseFloat(line[0+2*usemu]);
					var y=parseFloat(line[1]);
					if (isNaN(x) || isNaN(y)){
						// $( "#glavnacolumn" ).append( "--"+line[0]+"--"+line[1]+ "--" + '</br>'   );
					}else{
						ALLData[ser].data.push( [ x, y ] );
					}
				}
			});

		}
		$("#loading").hide();
		options.series=ALLData;
		
		if (view=='graphmenu'){
    	    $('#accordion').hide('slow');
    	    $('#graphspace').show('slow');
            chart = new Highcharts.Chart(options);
            }
	    else if (view=='csvmenu'){
	        makeCSV();
	        }
	    else
	        drawTable();
		
		options.xAxis=new Object();
		options.xAxis.type='linear';
		options.chart.type='scatter';
		
        $('.cbs').click(toggleSeries);

	}
	
	function run(reprostep, colname, yT){
		options.title.text = colname + '  ' + reprostep;
		options.yAxis.title = new Object(); options.yAxis.title.text = yT;
		options.xAxis.title = new Object();
		if (usemu)  options.xAxis.title.text = "<mu>"; else options.xAxis.title.text = "run number";	 
		
	    $.post("getRunData.asp", { syst:t0, usemu:usemu, useid:useid, minrun:minrun, maxrun:maxrun, reprostep: reprostep, colname: colname }, 
			function(msg){ parseData(msg); }
		);   
	}
	
	function obj(format,stream){
	    
	    options.title.text = format + '  ' + stream;
		options.yAxis.title = new Object(); options.yAxis.title.text = "size [kB/event]";
		options.xAxis.title = new Object();
		if (usemu)  options.xAxis.title.text = "<mu>"; else options.xAxis.title.text = "run number";

	    $.post("getObjData.asp", { syst:t0, usemu:usemu, useid:useid, minrun:minrun, maxrun:maxrun, format: format, stream: stream }, 
			function(msg){ parseData(msg); }
		);
				
	}
	
	function alg(procstep,stream){

		options.title.text = procstep + '  ' + stream;
		options.yAxis.title = new Object(); options.yAxis.title.text = "time [ms/event]";
		options.xAxis.title = new Object();
		if (usemu)  options.xAxis.title.text = "<mu>"; else options.xAxis.title.text = "run number";

	    $.post("getAlgData.asp", { syst:t0, usemu:usemu, useid:useid, minrun:minrun, maxrun:maxrun, procstep: procstep, stream: stream }, 
			function(msg){ parseData(msg); }
		);

	}	
	
	function showStatus(){
	    options.title.text = "Database status";
		options.yAxis.title = new Object(); 
		options.yAxis.title.text = "rows per 2 minutes";
		options.xAxis.title = new Object();
		options.xAxis.type='datetime';
		options.xAxis.tickInterval=1 * 6 * 3600 * 1000;
		options.chart.type='line';
		$.post("getStatusData.asp", { syst:t0 }, 
			function(msg){ parseData(msg); }
		);
		
	}
	
	function cleanUp(){
	    $.post("cleanUp.asp", { syst:t0 }, 
			function(msg){ if (msg.lenght>0) alert(msg); }
		);
	}
	
    var t0=1;
    $(document).ready(function() {
        $.post("preload.asp", function(msg){ 
            msg = msg.split("|");
            streams=msg[0].split(",");
            for (var s=0;s<streams.length;s++){
                $( "#ESD" ).append('<li><a href="javascript:setMenu(1, \'ESD\', \''+ streams[s] +'\' );">'+ streams[s] +'</a></li>');
                $( "#AOD" ).append('<li><a href="javascript:setMenu(1, \'AOD\', \''+ streams[s] +'\' );">'+ streams[s] +'</a></li>');
                $( "#DPD" ).append('<li><a href="javascript:setMenu(1, \'DPD\', \''+ streams[s] +'\' );">'+ streams[s] +'</a></li>');
                
                $( "#RAWtoESD" ).append('<li><a href="javascript:setMenu(2, \'RAWtoESD\', \''+ streams[s] +'\' );">'+ streams[s] +'</a></li>');
                $( "#ESDtoAOD" ).append('<li><a href="javascript:setMenu(2, \'ESDtoAOD\', \''+ streams[s] +'\' );">'+ streams[s] +'</a></li>');
                $( "#ESDtoDPD" ).append('<li><a href="javascript:setMenu(2, \'ESDtoDPD\', \''+ streams[s] +'\' );">'+ streams[s] +'</a></li>');
            }
            $("#minrunid").val(parseInt(msg[1]));
    		$("#maxrunid").val(parseInt(msg[2]));
        } );

        $('#group2idT0').trigger('click');
        $('#group2idT0').click(function(){ $('#prodSysmenu').hide('slow'); $('#t0menu').show('slow'); t0=1; });
        $('#group2idGRID').click(function(){ $('#t0menu').hide('slow'); $('#prodSysmenu').show('slow'); t0=0; });
        $('#bRefresh').click(refresh);
        $('#vm1,#vm2,#vm3').click(function(){
            view=$(this).attr('value');
            $('#vm1,#vm2,#vm3').removeClass("emph"); //try underline
            $(this).addClass("emph");
        });
        
        var dates = $( "#from, #to" ).datepicker({
            // onClose: gSites,
			dateFormat: 'yy-mm-dd',
			// defaultDate: "-1w",
			changeMonth: true,
			numberOfMonths: 1,
			onSelect: function( selectedDate ) {
				var option = this.id == "from" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" ),
					date = $.datepicker.parseDate(instance.settings.dateFormat || $.datepicker._defaults.dateFormat, selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
	    });
        

    });
</script>

</head>

<body>
	
	<!-- <div class="zaglavlje">Simple Performance browser</div> -->

	<span class="preload1"></span>
	<span class="preload2"></span>

	<ul id="nav">
		<li class="top"><a href="index.asp" class="top_link"><span>Home</span></a></li>
		
		<li class="top"><a href="#nogo2" id="Job" class="top_link"><span class="down">Job performance</span></a>
			<ul class="sub">
				<li><a href="#nogo3" class="fly">RAWtoESD</a>
						<ul>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'EVTLOOP_CPU', 'time [ms]' )">CPU event loop</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'EVTLOOP_WALL', 'time [ms]' )">Wall event loop</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'OVERHEAD_CPU', 'time [ms]' )">CPU overhead</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'OVERHEAD_WALL', 'time [ms]' )">Wall overhead</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'JOBCFG_WALL', 'time [ms]' )">Job cfg overhead</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'VMEM_PEAK', 'memory [kB]' )">peak VMEM</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'VMEM_MEAN', 'memory [kB]'  )">mean VMEM</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'RSS_MEAN', 'memory [kB]'  )">mean RSS</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'LEAK_51_VMEM', 'memory [kB]'  )">VMEM leak -50 ev.</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'LEAK_51_MALLOC', 'memory [kB]'  )">malloc leak -50 ev.</a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'LEAK_11_50_MALLOC', 'memory [kB]'  )">malloc leak 11-50 ev. </a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'events', 'events'  )">events </a></li>
							<li><a href="javascript:setMenu(0,'RAWtoESD', 'Tasks', 'tasks'  )">tasks </a></li>
						</ul>
				</li>
				<li><a href="#nogo3" class="fly">ESDtoAOD</a>
						<ul>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'EVTLOOP_CPU', 'time [ms]' )">CPU event loop</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'EVTLOOP_WALL', 'time [ms]' )">Wall event loop</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'OVERHEAD_CPU', 'time [ms]' )">CPU overhead</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'OVERHEAD_WALL', 'time [ms]' )">Wall overhead</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'JOBCFG_WALL', 'time [ms]' )">Job cfg overhead</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'VMEM_PEAK', 'memory [kB]' )">peak VMEM</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'VMEM_MEAN', 'memory [kB]'  )">mean VMEM</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'RSS_MEAN', 'memory [kB]'  )">mean RSS</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'LEAK_51_VMEM', 'memory [kB]'  )">VMEM leak -50 ev.</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'LEAK_51_MALLOC', 'memory [kB]'  )">malloc leak -50 ev.</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'LEAK_11_50_MALLOC', 'memory [kB]'  )">malloc leak 11-50 ev. </a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'events', 'events'  )">events </a></li>
							<li><a href="javascript:setMenu(0,'ESDtoAOD', 'Tasks', 'tasks'  )">tasks </a></li>
						</ul>
				</li>
				<li><a href="#nogo3" class="fly">ESDtoDPD</a>
						<ul>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'EVTLOOP_CPU', 'time [ms]' )">CPU event loop</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'EVTLOOP_WALL', 'time [ms]' )">Wall event loop</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'OVERHEAD_CPU', 'time [ms]' )">CPU overhead</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'OVERHEAD_WALL', 'time [ms]' )">Wall overhead</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'JOBCFG_WALL', 'time [ms]' )">Job cfg overhead</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'VMEM_PEAK', 'memory [kB]' )">peak VMEM</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'VMEM_MEAN', 'memory [kB]'  )">mean VMEM</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'RSS_MEAN', 'memory [kB]'  )">mean RSS</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'LEAK_51_VMEM', 'memory [kB]'  )">VMEM leak -50 ev.</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'LEAK_51_MALLOC', 'memory [kB]'  )">malloc leak -50 ev.</a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'LEAK_11_50_MALLOC', 'memory [kB]'  )">malloc leak 11-50 ev. </a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'events', 'events'  )">events </a></li>
							<li><a href="javascript:setMenu(0,'ESDtoDPD', 'Tasks', 'tasks'  )">tasks </a></li>
						</ul>
				</li>
			</ul>
		</li>
		<li class="top"><a href="#nogo22" id="Object_Sizes" class="top_link"><span class="down">Object Sizes</span></a>
			<ul class="sub">
				<li><a href="#nogo23" class="fly">ESD</a>
					<ul id='ESD'></ul>	
				</li>
				<li><a href="#nogo24" class="fly">AOD</a>
					<ul id='AOD'></ul>	
				</li>
				<li><a href="#nogo25" class="fly">DPD</a>
					<ul id='DPD'></ul>	
				</li>
			</ul>
		</li>
		<li class="top"><a href="#nogo27" id="Algorithm_performances" class="top_link"><span class="down">Algorithm performances</span></a>
			<ul class="sub">
				<li><a href="#nogo23" class="fly">RAWtoESD</a>
					<ul id='RAWtoESD'></ul>	
				</li>
				<li><a href="#nogo24" class="fly">ESDtoAOD</a>
					<ul id='ESDtoAOD'>
					</ul>	
				</li>
				<li><a href="#nogo25" class="fly">ESDtoDPD</a>
					<ul id='ESDtoDPD'></ul>	
				</li>
			</ul>
		</li>
		<li class="top"><a href="#" id="View" class="top_link"><span class="down">View</span></a>
			<ul class="sub">
				<li ><a href="#" id="vm1" value="graphmenu">Graph        </a></li>
				<li ><a href="#" id="vm2" value="tablemenu">Table        </a></li>
            <!--    <li ><a href="#" id="vm3" value="csvmenu"  >Export to CSV</a></li> -->
			</ul>
		</li>
		<li class="top"><a href="#nogo22" id="Expert" class="top_link"><span class="down">Expert</span></a>
			<ul class="sub">
				<li><a href="javascript:setMenu(4)">DB Status</a></li>
				<li><a href="javascript:setMenu(5)">Clean Up</a></li>
				<li><a href="javascript:addCut()">Add Cut</a></li>
				<li><a href="javascript:addVariable()">Add Variable</a></li>
			</ul>
		</li>
		<li class="top"><a href="https://twiki.cern.ch/twiki/bin/view/Main/PerformanceReporting" id="moreinfo" class="top_link"><span>More Info</span></a></li>
	</ul>
	
	<div id="leftcolumn">
		<form action="index.asp" method="post" id="queryFormID">
		<p>
			<input type="radio" name="group2" id="group2idT0"  checked /> Tier-0<br/>
			<input type="radio" name="group2" id="group2idGRID" /> prodSys
		</p>
		<hr>
		<p>
			<input type="button" id="bRefresh" value="refresh">
		</p>
		<hr>
		<div id="t0menu">
    		<p>
    			Run range:<br />
    			min:&nbsp;  <input type="text" name="minrun" id="minrunid" maxlength="7" size="7"  /><br />
    			max:        <input type="text" name="maxrun" id="maxrunid" maxlength="7" size="7"  /><br />
    		</p>
    		<p>
    			<input type="checkbox" name="use" id="useid" />good runs only<br />
    			<input type="checkbox" name="RfP" id="RfPid" />physics ready
    		</p>	
    			<hr>
    		<p>
    			<input type="checkbox" id="vsmuid"  value="mu"   />vs <&mu;><br />
              <!--  <input type="checkbox" id="linesid" value="lines" /> lines<br /> -->
    		</p>
    		<hr>

		</div>
		
		<div id="prodSysmenu"  style="display: none" >
    		<label for="from">From</label></br>
    		<input type="text" id="from" name="from"/></br>
    		<label for="to">to</label></br>
    		<input type="text" id="to" name="to"/>
		</div>
		<div id="chboxes"></div>
		</form>
	</div>
	

	
	<div id="glavnacolumn" >
        <div id="graphspace"></div> 
        <div id='accordion'></div>
	</div>
	
	<div id="loading"  style="display: none" >
		<br><br>Loading data. Please wait...<br><br>
			<img src="images/wait_animated.gif" alt="loading" />
	</div>	
	
    
</body>

</html>	
	