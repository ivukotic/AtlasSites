<!DOCTYPE HTML>

<%@ language      = "javascript"%>

<html>

<head>
	
	<meta http-equiv = "Content-Type" content="text/html;charset=utf-8" />
	<title>ATLAS Skim Slim Service</title>
	<link rel   = "shortcut icon" href="../images/favicon.ico" />
	<link rel   = "stylesheet" href="css/ilija.css" type="text/css">
    <!-- <link rel   = "stylesheet" href="../css/redmond/jquery-ui-1.8.16.custom.css"> -->
    <link rel   = "stylesheet" href="http://code.jquery.com/ui/1.10.2/themes/redmond/jquery-ui.css">
    <link rel   = "stylesheet" href="../DataTables-1.9.4/media/css/demo_table.css">
    <!-- // <script src="../jquery/jquery-1.7.min.js"></script> -->
    <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
    <!-- // <script src="../jquery/jquery-ui-1.8.16.custom.min.js"></script> -->
    <script src="http://code.jquery.com/ui/1.10.2/jquery-ui.js"></script>
	<script type="text/javascript" language="javascript" src="../DataTables-1.9.4/media/js/jquery.dataTables.js"></script>

	

	
	
	<script type="text/javascript">
	
    var inevents=0;
    var outevents=0;
    var insize=0;
    var outsize=0; 
    var outbranches=0;
    
    var sTable, sTableDone;
    
    var intervalID;
    
    var pbar, progressLabel;
    
    function updateEventsSizes(){
        $("#p_inds").html(human(insize,3));
        $("#p_ouds").html(human(outsize,3));
        $("#p_inev").html(inevents);
        $("#p_ouev").html(outevents);
        $("#p_oubr").html(outbranches);
    }
    
    function human(bytes, precision){  
        var kilobyte = 1024;
        var megabyte = kilobyte * 1024;
        var gigabyte = megabyte * 1024;
        var terabyte = gigabyte * 1024;
   
        if ((bytes >= 0) && (bytes < kilobyte)) {
            return bytes + ' B';
 
        } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
            return (bytes / kilobyte).toFixed(precision) + ' KB';
 
        } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
            return (bytes / megabyte).toFixed(precision) + ' MB';
 
        } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
            return (bytes / gigabyte).toFixed(precision) + ' GB';
 
        } else if (bytes >= terabyte) {
            return (bytes / terabyte).toFixed(precision) + ' TB';
 
        } else {
            return bytes + ' B';
        }
    }
    
    function decodeStatus(status){
        sta=parseInt(status);
        if (sta==5) status='done';
        else if (sta==4) status='filtered';
        else if (sta==3) status='running';
        else if (sta==2) status='submitted';
        else if (sta==101) status='deleted';
        else status='created';
        return status;
    }
        
    /* Formating function for row details */
    function fnFormatDetails ( oTable, nTr ){
        var aData = oTable.fnGetData( nTr );
        var sOut = '<table id="detailsTable'+aData[1]+'" cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;font-size: 10px;">';
        sOut += '<thead> <tr ALIGN="right" ><th>TaskID</th> <th>Size</th><th>Events</th><th>Output file</th> <th>Size</th><th>Events</th><th>Status</th><th>CPU eff.</th><th>Machine</th><th>Duration</th><th>Last update</th></tr> </thead> ';
        sOut += '</table>';
        return sOut;
    }
    
    function getDetailesTable( oTable, nTr ){
        var aData = oTable.fnGetData( nTr );
        console.log("fetching details for jobID: "+aData[1]);
        $.post("getSubJobs.asp", {jobid: aData[1]}, function(msg){
                sOut='';
                if (msg.length){
                    msg = msg.trim().split(/\n/g);
                    jQuery.each(msg, function(i, line) {
                        line = line.split(/\t/);
                        sOut += '<tr ALIGN="right" ><td>'+line[0].slice(-50)+'</td><td>'+human(parseInt(line[1]),2)+'</td><td>'+line[2]+'</td><td>'+line[3].slice(-30)+'</td><td>'+human(parseInt(line[4]),2)+'</td><td>'+line[5]+'</td>';
                        sOut += '<td>'+decodeStatus(line[6])+'</td><td>'+line[7]+'</td><td>'+line[8]+'</td><td>'+line[9]+'</td><td>'+line[10]+'</td>';
                        if (line[6]=='2'||line[6]=='3'||line[6]=='4') sOut += '<td><img src="images/restart.png"></td>'
                        sOut +='</tr>';
                    });
                }
                $('#detailsTable'+aData[1]+' tr:last').after(sOut);
                // console.log("adding"+sOut);
        });
    }
    
    function fnClickAddJobRow(rid, cre, ds, ie, ep, oe, os, st) {
        sTable.fnAddData( [ '<img src="images/details_open.png">',rid, cre, '<a href="#">'+ds+'</a>', ie, ep, oe, human(os,2),decodeStatus(st),'<img src="images/trash2.png">'] );
    }
    
    function fnClickAddJobDoneRow(rid, cre, ds, ie, ep, oe, os, st) {
        sTableDone.fnAddData( [ '<img src="images/details_open.png">',rid, cre, '<a href="#">'+ds+'</a>', ie, ep, oe, human(os,2),decodeStatus(st)] );
    }
    
    function fnClickAddTreeRow(nam, ent, nbr, siz) {
	    $('#table_trees').dataTable().fnAddData( [ '<img src="images/details_open.png">',nam, ent, nbr, siz, '<input type="radio" name="rbgroup" value="' + nam + '" checked >', '<input type="checkbox" name="cbgroup" value="' + nam + '">'] );
    }
    
    function getStatusTable(){
               	
        $.post("getJobs.asp", {}, function(msg){
                if (msg.length){
                    msg = msg.trim().split(/\n/g);
                    jQuery.each(msg, function(i, line) {
                        line = line.split(/\t/);
                        fnClickAddJobRow(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7]);
                    });
                }
            });
          
    }
    
    function getStatusDoneTable(){
               	
        $.post("getDoneJobs.asp", {}, function(msg){
                if (msg.length){
                    msg = msg.trim().split(/\n/g);
                    jQuery.each(msg, function(i, line) {
                        line = line.split(/\t/);
                        fnClickAddJobDoneRow(line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7]);
                    });
                }
            });
          
    }
    
    function progress( val, max ) {
        pbar.progressbar( "option", "max", max);
        pbar.progressbar( "value", val);
    }
    
    function startPinging(md5){
        intervalID = setInterval(function(){
            
        $("#loading").show();
        $.ajax({
            type: 'POST',
            url: 'getDS.asp',
            // timeout:10000,
            data:md5,
            success: function(msg, textStatus, jqXHR) {
                // console.log( msg );
                msg = msg.split(/\n/g);
                line=msg.shift();
                line=line.split(":");
                if (line[0]=='size') insize=parseFloat(line[1]);
                else if (line[0]=='warning') {
                    clearInterval(intervalID);
                    pbar.hide();
                    alert("warning: "+line[1]); 
                    $("#loading").hide();
                    return;
                }
                else if (line[0]=='message'){
                     clearInterval(intervalID);
                     pbar.hide();
                     alert("\n "+line[1]+"");
                     $("#loading").hide();
                     return;
                 }
                else{
                    clearInterval(intervalID);
                    pbar.hide();
                    alert("unexpected response:\n >"+line[0]+"<");
                    $("#loading").hide();
                    return;
                }
                 
                console.log( "file size is "+line[1]+' bytes');
                line=msg.shift().trim();
                var nTrees=parseInt(line);
                console.log( "there are "+line+' trees in this file');
                $('#table_trees').dataTable().fnClearTable();
                var trees=[];
                for (i=0; i<nTrees;i++){
                    line=msg.shift().trim().split(":");
                    var t={name:line[0], entries:line[1], size:line[2], nbranches:line[3],branches:[]}
                    console.log( t.name + "  entries: " + t.entries+ "  size: " + t.size + "  nbranches: " + t.nbranches);
                    fnClickAddTreeRow(t.name, t.entries, t.nbranches, t.size);
                    trees.push(t);
                }
                    
                line=msg.shift().trim().split(":");
                progress(parseInt(line[1]),parseInt(line[0]));
                $("#basedon").html("Estimate based on <B>"+line[1]+"</B> from total of <B>"+line[0]+"</B> files.");
                if (line[0]==line[1] && line[0]>0) {
                    clearInterval(intervalID);
                    console.log("all done. finish pinging.");
                }
                // getting back the selected tree line
                line=msg.shift().trim();
                $("input[name=rbgroup][value=" + line + "]:radio").attr('checked',true);
                // getting back the copied trees line
                line=msg.shift().trim().split(":");
                for (l in line){
                    $("input[name=cbgroup][value="+line+"]:checkbox").attr('checked',true);
                }
                    
                // getting back line with estimated events and size
                line=msg.shift().trim().split(":");
                console.log("In events: "+line[0]+"\t Out events:"+line[1]+"\tsize: "+line[2]+"\tbranches: "+line[3])
                inevents=line[0];
                outevents=line[1];
                outsize=parseFloat(line[2]);
                outbranches=line[3];
                        
                updateEventsSizes();
                        
                line=msg.shift().trim();
                console.log(line);
                if (line!='OK') alert(line);
                $("#loading").hide();
            },
            error: function (msg, textStatus, errorThrown) {
                console.log( msg );
                if(textStatus==="timeout") {
                    alert("got timeout");
                }
                else{
                    console.log( errorThrown );
                    alert('POST failed.');
                }
                $("#loading").hide();
            }
        });
        
        }, 5000); // this is periodicity.   
    }
    
    function handleRequest(sReq){
         $("#loading").show();
         clearInterval(intervalID);
         pbar.show();
         pbar.progressbar( "option", "value", false );
         
         // datasets
         var DSs=new Array();
         var tt=$("#t_area").val();
         tt=tt.replace(/\n/g,",");
         tt=tt.replace(/ /g,",");
         tt=tt.split(","); 
         for (i in tt){
             var t=tt[i].trim();
             if (t.length<4 || t.indexOf(' ')!=-1 || t=="\n") continue;
             DSs.push(t);
         }
         $("#t_area").val(DSs.join("\n"));
         var ttj=DSs.join(",");
         console.log("datasets:"+ttj);
         
         // trees
         var mainTree=$("input[name=rbgroup]:radio:checked").val();
         var treesToCopy=[];
         $("input[name=cbgroup]:checkbox:checked").each(function() {
             treesToCopy.push(this.value);
         });
         treesToCopy=treesToCopy.join(",");
         console.log("mainTree:"+mainTree);
         console.log("treesToCopy:"+treesToCopy);
                
         // branches
         var BRs=new Array();
         tt=$("#t_branches").val();
         tt=tt.replace(/\n/g,",");
         tt=tt.replace(/ /g,",");
         tt=tt.split(","); 
         for (i in tt){
             var t=tt[i].trim();
             if (t.length==0 || t.indexOf(' ')!=-1 || t=="\n") continue;
             BRs.push(t);
         }
         $("#t_branches").val(BRs.join("\n"));
         var branchesToKeep=BRs.join(",");
         console.log("branchesToKeep:"+branchesToKeep);
                
         // cut
         var cutCode=$("#t_code").val();
         if (cutCode.length==140 && cutCode.substring(75,92)=="selectEvent=False" )
             cutCode=''
         console.log("cutCode:"+cutCode.substring(75,92));
                
         // outDSname
         var outDS='';
         outDS=$("#t_outDS").val();
         console.log("outDS:"+outDS);

         // deliverTo
         var deliverTo='';
         if (("#cDeliver").checked){
             deliverTo=$('#deliverTo').val();
         }
         console.log("deliverTo:"+deliverTo);
         
         $.ajax({
             type: 'POST',
             url: 'getDS.asp',
             // timeout:10000,
             data: 'inds='+ttj+'&mainTree='+mainTree+'&treesToCopy='+treesToCopy+'&branchesToKeep='+branchesToKeep+'&cutCode='+cutCode+"&sReq="+sReq+"&outDS="+outDS+"&deliverTo="+deliverTo,
             success: function(msg, textStatus, jqXHR) {
                 // console.log( msg );
                 msg = msg.split(/\n/g);
                 line=msg.shift();
                 line=line.split(":");
                 if (line[0]=='size') insize=parseFloat(line[1]);
                 else if (line[0]=='warning') {
                     alert(line[1]); 
                     $("#loading").hide();
                     return;
                 }
                 else if (line[0]=='md5'){
                     console.log('md5 assigned:'+line[1]);
                     startPinging(line[1]);
                     $("#loading").hide();
                     return;
                 }
                 else{
                     alert("unexpected response:\n >"+line[0]+"<");
                     $("#loading").hide();
                     return;
                 }
                 
//                  console.log( "file size is "+line[1]+' bytes');
//                  line=msg.shift().trim();
//                  var nTrees=parseInt(line);
//                  console.log( "there are "+line+' trees in this file');
//                  $('#table_trees').dataTable().fnClearTable();
//                  var trees=[];
//                  for (i=0; i<nTrees;i++){
//                      line=msg.shift().trim().split(":");
//                      var t={name:line[0], entries:line[1], size:line[2], nbranches:line[3],branches:[]}
//                      console.log( t.name + "  entries: " + t.entries+ "  size: " + t.size + "  nbranches: " + t.nbranches);
//                      fnClickAddTreeRow(t.name, t.entries, t.nbranches, t.size);
//                      // for (j=0;j<t.nbranches;j++){
//                          // line=msg.shift().trim().split(":");
//                          // t.branches.push[{name:line[0],size:line[1]}];
//                      // }
//                      trees.push(t);
//                  }
// 
//                  line=msg.shift().trim().split(":");
//                  $("#basedon").html("Estimate based on <B>"+line[1]+"</B> from total of <B>"+line[0]+"</B> files. To update the estimate press refresh button.");
//                  // getting back the selected tree line
//                  line=msg.shift().trim();
//                  $("input[name=rbgroup][value=" + line + "]:radio").attr('checked',true);
//                  // getting back the copied trees line
//                  line=msg.shift().trim().split(":");
//                  for (l in line){
//                      $("input[name=cbgroup][value="+line+"]:checkbox").attr('checked',true);
//                  }
// 
//                         
//                  // //listener for the details click no drill down into trees.
//                  // $('#table_trees tbody td img').live('click', function () {
//                  //         var nTr = this.parentNode.parentNode;
//                  //         if ( this.src.match('details_close') ){ 
//                  //             this.src = "images/details_open.png";
//                  //             oTable.fnClose( nTr );/* This row is already open - close it */
//                  //         }
//                  //         else{ 
//                  //             this.src = "images/details_close.png";
//                  //             oTable.fnOpen( nTr, fnFormatDetails(oTable, nTr), 'details' );/* Open this row */
//                  //         }
//                  // } );
//                  
//                  // getting back line with estimated events and size
//                  line=msg.shift().trim().split(":");
//                  console.log("In events: "+line[0]+"\t Out events:"+line[1]+"\tsize: "+line[2]+"\tbranches: "+line[3])
//                  inevents=line[0];
//                  outevents=line[1];
//                  outsize=parseFloat(line[2]);
//                  outbranches=line[3];
//                         
//                  updateEventsSizes();
//                         
//                  line=msg.shift().trim();
//                  console.log(line);
//                  if (line!='OK') alert(line);
//                  $("#loading").hide();
             },
             error: function (msg, textStatus, errorThrown) {
                 console.log( msg );
                 if(textStatus==="timeout") {
                     alert("got timeout");
                 }
                 else{
                     console.log( errorThrown );
                     alert('POST failed.');
                 }
                 $("#loading").hide();
             }
         });
    }
    
    $(function() {
        
        $( ".b_estimate" ).button().click(function( event ) {
                console.log('refresh demanded');

                $( ".b_estimate" ).button( "disable" );
                event.preventDefault();
                
                handleRequest(0);

                $( ".b_estimate" ).button( "enable" );                      
                
        });
        
        $( "#b_request" ).button().click(function( event ) {
                console.log('b_request clicked ');
                event.preventDefault();
                if ($("#t_outDS").val()==''){
                    alert("Please fill out output dataset name.");
                    return;
                }
                if (outsize==0 && outsize>50*1024*1024*1024 ){
                    alert("Output datasize is limited to (0-50GB). Please change your selection criteria.");
                    return;
                }
                $( "#dialog-confirm" ).dialog( "open" );
        });
        
        $( "#dialog-confirm" ).dialog({
            autoOpen: false, resizable: false, height:180, width:500, modal: true,
            buttons: {
                "Submit": function() { 
                    $( this ).dialog( "close" );
                    handleRequest(1);
                    // alert('Your SkimSlim request have been submitted. You may follow progress at "View Status" tab'); 
                },
                Cancel: function() { $( this ).dialog( "close" ); }
            }
        });

        $( "#dialog-confirm-delete" ).dialog({
            autoOpen: false, resizable: false, height:180, width:500, modal: true,
            buttons: {
                "Delete": function() { 
                    console.log ('deleting jobID:'+ $(this).data("id") );
                    $.post("deleteJob.asp", {deleteJob:$(this).data("id")}, function(msg){ if (msg.length) alert(msg); } );
                    $( this ).dialog( "close" );
                },
                Cancel: function() { $( this ).dialog( "close" ); }
            }
        });
        
        $( "#dialog-confirm-restart" ).dialog({
            autoOpen: false, resizable: false, height:180, width:500, modal: true,
            buttons: {
                "Restart": function() { 
                    console.log ('restarting taskID:'+ $(this).data("id") );
                    $.post("restartTask.asp", {restartTask:$(this).data("id")}, function(msg){ if (msg.length) alert(msg); } );
                    $( this ).dialog( "close" );
                },
                Cancel: function() { $( this ).dialog( "close" ); }
            }
        });
        
        $( "#dialog-jobinfo" ).dialog({
            autoOpen: false,
            height: 'auto',
            width: 'auto',
            modal: true,
        	open: function(event, ui){
                console.log ('showing info of jobID:'+ $(this).data("id") );
                $.post("getJobInfo.asp", {JobID:$(this).data("id")}, function(msg){
                    if (msg.length) {
                        msg = msg.split(/\t/g);
      				    document.getElementById('revINDS').value=msg[0];
                        $('#revMAIN').html('Tree to cut on: '+msg[1]);
                        $('#revTtoC').html('Trees to copy: '+msg[2]);
      				    document.getElementById('revBRAS').value=msg[3];
      				    document.getElementById('revCUTS').value=msg[4];
                        // alert(msg);
                    } 
                });
                // $(this).html("<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit.</p>");
                }
        });    
    });
    
         
    
     
	$(document).ready(
   
        
	    function() {		
            
            console.log('ready');
            
            $("#accordion").accordion({ event: "click hoverintent", fillSpace: true });
            $("#tabs").tabs({
                activate: function( event, ui ) {
                    if(ui.newPanel.index()==2){ // loading status tab
                        console.log("loading tab 2.");
                        $("#loading").show();
                        getStatusTable();
                        $("#loading").hide();
                    }
                    else{
                        sTable.fnClearTable();
                    }

                    if(ui.newPanel.index()==3){ // loading history tab
                        console.log("loading tab 3.");
                        $("#loading").show();
                        getStatusDoneTable();
                        $("#loading").hide();
                    }
                    else{
                        sTableDone.fnClearTable();
                    }
                }
            });
                        

            var oTable = $('#table_trees').dataTable({ "bFilter": false, "bInfo": false, "bPaginate": false,  "aoColumnDefs": [ {  "bSortable": false, "aTargets": [ 0 ] } ], "aaSorting": [[1, 'asc']] });


            sTable = $('#status').dataTable({ 
                "iDisplayLength": 25,
                "aoColumnDefs": [ { "bSortable": false, "aTargets": [ 0 ] } ], 
                "aaSorting": [[1, 'asc']],
                "aoColumns": [
                              { sWidth: '3%' },
                              { sWidth: '6%'  , "sClass": "right"},
                              {  },
                              { },
                              {  "sClass": "right" },
                              {  "sClass": "right"  },
                              {  "sClass": "right"  },
                              {  "sClass": "right"   },
                              { sWidth: '8%'  },
                              { sWidth: '3%' }
                              ]
        
            });

            sTableDone = $('#statusDone').dataTable({ 
                "iDisplayLength": 25,
                "aoColumnDefs": [ { "bSortable": false, "aTargets": [ 0 ] } ], 
                "aaSorting": [[1, 'asc']],
                "aoColumns": [
                              { sWidth: '3%' },
                              { sWidth: '6%'  , "sClass": "right"},
                              {  },
                              { },
                              {  "sClass": "right" },
                              {  "sClass": "right"  },
                              {  "sClass": "right"  },
                              {  "sClass": "right"   },
                              { sWidth: '8%'  }
                              ]
        
            });
            
            pbar = $( "#progressbar" ).progressbar({
                change: function() {
                    if (pbar.progressbar( "value" )==false){
                        progressLabel.text( "Looking up Datasets..." );
                    }
                    else
                    progressLabel.text( pbar.progressbar( "value" ) + " of "+ pbar.progressbar("option","max")+" files inspected." );
                },
                complete: function() {
                    progressLabel.text( "Complete!" );
                    pbar.hide();
                }
            });
           
            progressLabel = $( ".progress-label" );

            $("#cDeliver").click(function() {
                if (this.checked){
                    $("#loading").show();
                    console.log('deliver checked');
                    $("#deliverTo").prop('disabled', false);
                    
                    $.getJSON("getSE.asp",function(result){
                      $.each(result, function(i, field){
                        // console.log(field.ddmendpoints);
                        $.each(field.ddmendpoints, function(j, fiel){
                            // console.log(fiel);
                            $.each(fiel, function(k, fie){
                                if (fie.indexOf('TAPE')==-1){
                                    $('#deliverTo').append($("<option></option>") .attr("value",fie).text(fie)); 
                                    // console.log(fie);
                                }
                            });
                        });
                      });
                    });
                    $("#loading").hide();
                }else{
                    console.log('deliver unchecked');
                    $("#deliverTo").prop('disabled', true);
                };
            });

    	  	function handleFileSelect(evt) {
                  var files = evt.target.files;
    			  var reader = new FileReader();
    	  		  reader.onload = function(event) {
    	  		      var contents = event.target.result;
    				  document.getElementById('t_area').value+=contents;
    	  		      console.log("File contents: " + contents);
    	  		  };
    	  		  reader.onerror = function(event) {
    	  		      console.error("File could not be read! Code " + event.target.error.code);
    	  		  };
    	  		  reader.readAsText(evt.target.files[0]);
    	  	}

    	  	function handleBranchSelect(evt) {
    	  	      var files = evt.target.files;
    	  		  var reader = new FileReader();
    	  		  reader.onload = function(event) {
    	  		      var contents = event.target.result;
    				  document.getElementById('t_branches').value+=contents;
    	  		      console.log("branches from file: " + contents);
    	  		  };
    	  		  reader.onerror = function(event) {
    	  		      console.error("File could not be read! Code " + event.target.error.code);
    	  		  };
    	  		  reader.readAsText(evt.target.files[0]);
    	  	}
          
    	  	function handleCutSelect(evt) {
    	  	      var files = evt.target.files;
    	  		  var reader = new FileReader();
    	  		  reader.onload = function(event) {
    	  		      var contents = event.target.result;
    				  document.getElementById('t_code').value+=contents;
    	  		      console.log("cut code: " + contents);
    	  		  };
    	  		  reader.onerror = function(event) {
    	  		      console.error("File could not be read! Code " + event.target.error.code);
    	  		  };
    	  		  reader.readAsText(evt.target.files[0]);
    	  	  }

    	  	document.getElementById('files').addEventListener('change', handleFileSelect, false);
    	  	document.getElementById('f_branches').addEventListener('change', handleBranchSelect, false);
    		document.getElementById('f_code').addEventListener('change', handleCutSelect, false);
 
            //listener for the details click
            $(document).on('click', '#status tbody td img', function () {
            		var nTr = this.parentNode.parentNode;
                    if ( this.src.match('trash2') ){
                        // console.log("delete click");
                        $( "#dialog-confirm-delete" ).data("id", sTable.fnGetData(nTr)[1]).dialog( "open" );
                        return;
                    }
                    if ( this.src.match('restart') ){
                        // console.log("restart click");
                        $( "#dialog-confirm-restart" ).data("id", nTr.firstChild.innerHTML).dialog( "open" );
                        return;
                    }
            		if ( this.src.match('details_close') ) { 
                        // console.log("close click");
            			this.src = "images/details_open.png";
            			sTable.fnClose( nTr );/* This row is already open - close it */
            		}
            		else { 
                        // console.log("open click");
            			this.src = "images/details_close.png";
            			sTable.fnOpen( nTr, fnFormatDetails(sTable, nTr), 'details' );/* Open this row */
                        getDetailesTable(sTable, nTr);
            		}
            });
            
            $(document).on('click', '#statusDone tbody td img', function () {
            		var nTr = this.parentNode.parentNode;
            		if ( this.src.match('details_close') ) { 
                        // console.log("close click");
            			this.src = "images/details_open.png";
            			sTableDone.fnClose( nTr );/* This row is already open - close it */
            		}
            		else { 
                        // console.log("open click");
            			this.src = "images/details_close.png";
            			sTableDone.fnOpen( nTr, fnFormatDetails(sTableDone, nTr), 'details' );/* Open this row */
                        getDetailesTable(sTableDone, nTr);
            		}
            });
                
            $(document).on('click', '#status tbody td a', function () {
            		var nTr = this.parentNode.parentNode;
                    // console.log("jobinfo click");
                    $( "#dialog-jobinfo" ).data("id", sTable.fnGetData(nTr)[1]).dialog( "open" );
            });
            
            $(document).on('click', '#statusDone tbody td a', function () {
            		var nTr = this.parentNode.parentNode;
                    // console.log("jobinfo click");
                    $( "#dialog-jobinfo" ).data("id", sTableDone.fnGetData(nTr)[1]).dialog( "open" );
            });
 
       }
       
    );
	
    jQuery.ajax({
        url: "https://its.cern.ch/jira/s/en_US5flo3i-418945332/850/82/1.2.9/_/download/batch/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector-embededjs/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector-embededjs.js?collectorId=116f7c79",
        type: "get",
        cache: true,
        dataType: "script"
    });
	
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
            <a href="http://atlas.web.cern.ch/Atlas/Collaboration/">
                <img border="0" src="images/atlas_logo.jpg" alt="ATLAS main page"> 
            </a>
            <div id="maintitle">
                Skim Slim Service
            </div>
        </div>
    

    	<div id="tabs">
            <ul>
                <li><a href="#tabs-1">Create Request</a></li>
                <li><a href="#tabs-2">View Status</a></li>
                <li><a href="#tabs-3">Completed Requests</a></li>
                <li><a href="#tabs-4">About</a></li>
                <li><a href="#tabs-5">Examples</a></li>
            </ul>
        
            <div id="tabs-1" > <!-- style="overflow: auto; width: 100%" -->
                <table id="t_results" >
                  <tr>
                    <td><B>Input</B></td>
                    <td>events</td><td id="p_inev">0</td>
                    <td>size</td><td id="p_inds">0</td>
                    <td><B>Output</B></td>
                    <td>events</td><td id="p_ouev">0</td>
                    <td>branches</td><td id="p_oubr">0</td>
                    <td>size</td><td id="p_ouds">0</td>
                  </tr>
                </table> 
                <br>
                    <div id="accordion">
                        <h3><a href="#a">Input DataSets</a></h3>
                        <div id="inds">
                        	You may copy/paste your input data sets here. Separate them by newline or comma.  </br>		
    					    <textarea rows="8" cols="110" id="t_area">user.ilijav.HCtest.1</textarea>
    						<br><br>
    				    	or upload text file containing them: 
    						<input type="file" id="files" name="files[]" multiple /> 
                            <button class="b_estimate"  >Refresh</button><br>
                        </div>
                        <h3><a href="#a2">Trees</a></h3>
                        <div id="tree">
                            Please select the tree that you would like to SkimSlim.<div id="basedon"></div></br>
                            <p id="cbs_allTrees">
                              <table cellpadding="0" cellspacing="0" border="0" class="display" id="table_trees" width="100%"> <thead> <tr> <th></th> <th>Name</th> <th>Entries</th> <th>Branches</th> <th>% of tot. size</th> <th>select</th> <th>copy</th> </tr> </thead> <tbody></tbody></table>
                            </p>
                            <br>
                            <button class="b_estimate" >Refresh</button><br><br>
                        </div>
                        <h3><a href="#a3">Branches</a></h3>
                        <div id="branches">
                            Here you select all the branches of the tree you want to SkimSlim that you want to keep.
                            You may type them in here. You may use * as a wildcard. One entry per line.<br>
    					            <textarea rows="8" cols="110" id="t_branches">*</textarea><br>
                                </li>
                                <li><br>
                                    upload text file containing their list.
            						<input type="file" id="f_branches" name="f_branches"/>
                                    <button class="b_estimate" >Refresh</button><br><br>
                                </li>
                            </ul> 
                        </div>  
                        <h3><a href="#a4">Cut code</a></h3>
                        <div id="cutcode">
                            Here you give a python code that will be used to select events to be kept. You may type it here:
    			            <textarea rows="8" cols="110" id="t_code">def filter_fct(t):&#013;&#010;&nbsp;&nbsp;&nbsp;selectEvent=True&#013;&#010;&#013;&#010;&nbsp;&nbsp;&nbsp;# if t.eg_px[0] > 10000:&#013;&#010;&nbsp;&nbsp;&nbsp;#&nbsp;&nbsp;&nbsp;selectEvent=False&#013;&#010;&#013;&#010;&nbsp;&nbsp;&nbsp;return selectEvent
                            </textarea><br>
                            or upload the file containing it here:
    						<input type="file" id="f_code" name="f_code"/>
                            <button class="b_estimate" >Refresh</button><br><br> 
                        </div>
                        <h3><a href="#a1">Output DataSet</a></h3>
                        <div id="ods">
                            As SkimSlimService runs under ivukotic account, output dataset will be named whatever you input in the field bellow prefixed with "user.ivukotic.".<br>
                             <input type="text"  id="t_outDS" size="110"><br><br>
                             <input type="checkbox" id="cDeliver"  value="cbDeliver" />Deliver it to:  
                             <select id="deliverTo" disabled>  </select>
                             <button id="b_request"  >Submit request</button>
                        </div>
                    </div>
            </div>
        
            <div id="tabs-2">
                </br>  
                    <table cellpadding="0" cellspacing="0" border="0" class="display" id="status" width="100%"> 
                        <thead> 
                            <tr> 
                                <th></th> 
                                <th>ReqID</th>
                                <th>Created</th> 
                                <th>Dataset</th> 
                                <th>input ev.</th> 
                                <th>processed</th> 
                                <th>output ev.</th> 
                                <th>output size</th>
                                <th>status</th> 
                                <th></th> 
                            </tr> 
                        </thead> 
                        <tbody></tbody>
                    </table>
            </div>
            <div id="tabs-3">
            </br>  
                <table cellpadding="0" cellspacing="0" border="0" class="display" id="statusDone" width="100%"> 
                    <thead> 
                        <tr> 
                            <th></th> 
                            <th>ReqID</th>
                            <th>Created</th> 
                            <th>Dataset</th> 
                            <th>input ev.</th> 
                            <th>processed</th> 
                            <th>output ev.</th> 
                            <th>output size</th>
                            <th>status</th> 
                        </tr> 
                    </thead> 
                    <tbody></tbody>
                </table>
            </div>
            <div id="tabs-4">
                <p>SkimSlimService is provided for all of the ATLAS data that can be access using FAX. Currently there is no limit on size of output datasets or time to process it.  Service currently runs at University of Chicago at UC3 and UCT3, but will be expanded to use OSG resources.  </p>
                <p>In case of any problems please contact Ilija Vukotic at ivukotic@cern.ch. </p>
                <p>Process of skiming slimming is performed in three steps:
                    <ul><B>Inspect</B> - Upon entering/uploading file with the datasets to be skimmed/slimmed, dq2-ls is used to check size of the datasets, their availability in FAX. One of the files is opened in order to get file numbers and sizes of trees and branches.</ul>
                    <ul><B>Estimate</B> - In this step you select on which tree you want to perform skim/slim, and choose which other trees you want copied to the destination data files. You enter/upload a list of branches that you would like to see on the output. You may use * and ? as a pattern matching symbols. Finaly you should enter/upload a code that returns TRUE for events you want to keep. You may use all of the variables in the tree your are skimming/slimming in making that decission. </ul>
                    <ul><B>Send request</B> - If your cut code worked, and an estimated size of the output dataset is in the prescribed limits, you will have a possibility to submit a request to produce a full skimmed/slimmed datasets. Soon afterwards you will be able to follow progress of your skim/slim requests on a "View status" tab.
                </p>
    	    <p>A short PowerPoint presentation on SSS can be found <a href="SSS.pptx">here</a></p>
            </div>
            <div id="tabs-5">
                <p>The following example uses you one SMWZ D3PD file (760MB) of one dataset and selects 128 branches. Here are all parameters needed:</p>
                <ul>
                    <li>Input dataset: group.perf-jets.GRJETS.v01.TEST01.data12_8TeV.periodE.physics_JetTauEtmiss.PhysCont.AOD.t0pro13_v01.121116162501_StreamNTUP_GRJETS</li>
                    <li>Output dataset: SSS.test.SMWZ.0001</li>
                    <li>Trees: physics</li>
                    <li>Branches: runnr, eventnr, ....</li>
                </ul>
            </div>
        </div>
    
        <div id="progressbar" style="display: none;">
            <div class="progress-label"  style="float: left; margin-left: 45%; margin-top: 5px;font-weight: bold;text-shadow: 1px 1px 0 #fff;"></div>
        </div>
    </div>
	
    <div id="dialog-confirm" title="Submit request?">
        <p>
            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>
            This will submit SkimSlim request. Are you sure?
        </p>
    </div>
    
    <div id="dialog-confirm-delete" title="Delete request?">
        <p>
            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>
            This will delete the request. Are you sure?
        </p>
    </div>
    
    <div id="dialog-confirm-restart" title="Restart task?">
        <p>
            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>
            This will restart the task. Are you sure?
        </p>
    </div>

   
	<div id="loading"  style="display: none" >
		<br><br>Loading data. Please wait...<br><br>
			<img src="images/wait_animated.gif" alt="loading" />
	</div>

    <div id="dialog-jobinfo" title="Request details" style="display: none;">
        Input datasets
        <br>
        <textarea rows="4" cols="110" id="revINDS">
        </textarea>
        <br>
        <div id="revMAIN"></div><br>
        <div id="revTtoC"></div><br>
        Branch selection: <br>
        <textarea rows="4" cols="110" id="revBRAS">
        </textarea><br>
        Filter code:<br>
        <textarea rows="4" cols="110" id="revCUTS">
        </textarea>
    </div>
 

<!-- <div style="clear:both;margin:auto;text-align:center;width:100%"><font size=1>© 2012 Ilija Vukotic  All rights reserved.</font></div> -->
    
</body>

</html>
