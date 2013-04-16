<!DOCTYPE HTML>

<%@ language      = "javascript"%>

<html>

<head>
	
	<meta http-equiv = "Content-Type" content="text/html;charset=utf-8" />
	<title>ATLAS FAX Full Dress Rehearsal</title>
	<link rel   = "shortcut icon" href="../images/favicon.ico" />
	<link rel   = "stylesheet" href="css/ilija.css" type="text/css">
    <link rel   = "stylesheet" href="../DataTables-1.9.4/media/css/demo_table.css">
    <link rel   = "stylesheet" href="http://code.jquery.com/ui/1.10.0/themes/base/jquery-ui.css">
    <script src="http://code.jquery.com/jquery-1.9.0.js"></script>
	<script src="http://code.jquery.com/ui/1.10.0/jquery-ui.js"></script>
	<script type="text/javascript" language="javascript" src="../DataTables-1.9.4/media/js/jquery.dataTables.js"></script>
    <script src="/resources/demos/external/jquery.mousewheel.js"></script>
	

	
	
	<script type="text/javascript">
	
    
    function fnFormatDetails(oTable, nTr){
        var sOut = '<table id="detailsTable" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;"> <thead> <tr><th>Result arrived</th> <th>Comment</th> <th>Time [s]</th><th>Rate [MB/s]</th><th>Rate [ev/s]</th> <th>PandaID</th></tr> </thead> </table>';
        return sOut;
    }
    
    /* Formating function for row details */
    function  getDetailesTable( oTable, nTr ){
    	var aData = oTable.fnGetData( nTr );
        
        $.post("getJobs.asp", {taskid: aData[1]}, function(msg){
                sOut='';
                if (msg.length){
                    msg = msg.trim().split(/\n/g);
                    jQuery.each(msg, function(i, line) {
                        line = line.split(/\t/);
                        sOut += '<tr><td>'+line[0]+'</td><td>'+line[1]+'</td><td>'+line[2]+'</td><td>'+line[3]+'</td><td>'+line[4]+'</td><td><a href="http://panda.cern.ch/server/pandamon/query?job='+line[5]+'">'+line[5]+'</a></td></tr>';
                    });
                }
                $('#detailsTable tr:last').after(sOut);

                console.log("adding"+sOut);
        });
        
    }
    
    
    function getStatusTable(){

        $('#status').dataTable().fnClearTable();
        $.post("getTasks.asp", {}, function(msg){
                if (msg.length){
                    msg = msg.trim().split(/\n/g);
                    jQuery.each(msg, function(i, line) {
                        line = line.split(/\t/);
                    	$('#status').dataTable().fnAddData( [ '<img src="images/details_open.png">',line[0], line[1], line[2], line[3], line[4], line[5], line[6], line[7], line[8], line[9], line[10], line[11], line[12], line[13]] );
                    });
                }
        });
            
    }
    

    
    $(function() {
        
        
        $( "#b_submit" ).button().click(function( event ) {
                console.log('b_submit clicked ');
                $("#loading").show();
                event.preventDefault();

                var fi=$("#files").val();
                var jo=$("#jobs").val();
                var ti=$("#timeout").val();
                var na=$("#Name").val();
                var ty=$("#type").val();
                var se=$("#server").val();
                var cl=$("#client").val();
                console.log("name:"+na+"\ttype:"+ty+"\tserver:"+se+"\tclient:"+cl+"\tfiles:"+fi+"\tjobs:"+jo+"\ttimeout:"+ti);
                
                $.post("addTask.asp", {name: na,type:ty, server:se, client:cl,files:fi,jobs:jo,timeout:ti }, function(msg){
                        console.log("return: "+msg);
                });
                
                $("#loading").hide();
                getStatusTable();                
        });

        $( "#b_refresh" ).button().click(function( event ) {
                console.log('b_refresh clicked ');
                $("#loading").show();
                event.preventDefault();
                getStatusTable();
                $("#loading").hide();
                
        });

    });
    
         
    
     
	$(document).ready(
   
        
	    function() {		
            
             $("#loading").show();
            
             var oTable = $('#status').dataTable({
                 "iDisplayLength": 25,
                 "aoColumnDefs": [ { "bSortable": false, "aTargets": [ 0 ] } ],
                 "aaSorting": [[1, 'asc']] ,
                 "aoColumns": [
                             { sWidth: '3%' },
                             { sWidth: '4%' , "sClass": "right" },
                             { sWidth: '11%' },
                             { sWidth: '12%' },
                             { sWidth: '12%' },
                             { sWidth: '9%' },
                             { sWidth: '7%' },
                             { sWidth: '5%' , "sClass": "right" },
                             { sWidth: '6%' , "sClass": "right" },
                             { sWidth: '6%' , "sClass": "right" },
                             { sWidth: '6%' , "sClass": "right" },
                             { sWidth: '4%' , "sClass": "right" },
                             { sWidth: '5%' , "sClass": "right" },
                             { sWidth: '5%' , "sClass": "right" },
                             { sWidth: '5%' , "sClass": "right" } 
                             ]
             });
             getStatusTable();
                 
             $("#loading").hide();
             
             //listener for the details click
             $('#status tbody ').on('click',"tr td img", function(event) {
                 // console.log("need to open details.");
                  var nTr = this.parentNode.parentNode;
                  if ( this.src.match('details_close') ) { 
                      this.src = "images/details_open.png";
                      oTable.fnClose( nTr );/* This row is already open - close it */
                  }
                  else { 
                      this.src = "images/details_close.png";
                      oTable.fnOpen( nTr, fnFormatDetails(oTable, nTr), 'details' );/* Open this row */
                      getDetailesTable(oTable, nTr);
                  }
             } );

             
            console.log('ready');
            
 
       }
       
    );
	
	
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

<div class="maincolumn">
    
    <div class="mainheading">
        <a href="http://atlas.ch/">
            <img border="0" src="images/atlas_logo.jpg" alt="ATLAS main page"> 
        </a>
        <div id="maintitle">
            FAX - Full Dress Rehearsal
        </div>
    </div>
    
        
    <br>

    <table cellpadding="10" cellspacing="0" border="0" width="70%">  
        <tbody>
            <tr>
                <td>
                    To run and get here results of your own tests please contact Ilija Vukotic. ivukotic at standard cern adddress. 
                </td>
                <td>
                    <button id="b_refresh"  >Refresh</button>
                </td>
            </tr>
        </tbody>
    </table>

    
    <br>
    <hr>  
    <table cellpadding="0" cellspacing="0" border="0" class="display" id="status" width="100%"> 
        <thead> <tr> 
            <th></th> <th>TaskID</th> <th>name</th> <th>server</th> <th>client</th> <th>created</th>
            <th>type</th><th>files</th><th>time[s]</th><th>rate[MB/s]</th><th>rate[ev/s]</th><th>jobs</th> <th>finished</th><th>started</th><th>timeout</th>
        </tr> </thead> 
        <tbody></tbody>
    </table>
        
    
</div>
	
	<div id="loading"  style="display: none" >
		<br><br>Loading data. Please wait...<br><br>
			<img src="images/wait_animated.gif" alt="loading" />
	</div>

<!-- <div style="clear:both;margin:auto;text-align:center;width:100%"><font size=1>© 2012 Ilija Vukotic  All rights reserved.</font></div> -->
    
</body>

</html>
