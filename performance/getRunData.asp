<script language="jscript" runat="server">

var ti0 = Request("syst");

function connectToDB(){
	var con = Server.CreateObject("ADODB.Connection");
	if (ti0==1)
	    con.ConnectionString = Application("connString");
	else
    	con.ConnectionString = Application("connStringGRID");
	    
	con.ConnectionTimeout = 60;
	try{
		con.Open();
		return con;
	}
	catch (e){
		Response.Write(e.message);
		Response.End();
	}		
}

var usemu = Request("usemu");
var useid = Request("useid");
var minrun = Request("minrun");
var maxrun = Request("maxrun");
var reprostep = new String(Request("reprostep"));
var colname  = new String(Request("colname")); 

// Response.Write(usemu+'\n');
// Response.Write(useid+'\n');
	
sel='SELECT runnumber, cast('+colname+' as number) ';
if (usemu==1) sel+=', mu ';
if (useid==1 || usemu==1) 
	sel+=' FROM jobPerformance, runInfo WHERE jobPerformance.runNumber=runInfo.run and jobPerformance.jobProcessingStep=\''+reprostep+'\'';
else 
	sel += ' FROM jobPerformance WHERE jobPerformance.jobProcessingStep=\''+reprostep+'\'';

if (useid==1) sel+=' and runInfo.use=1 ';
	
if 	( !(isNaN(minrun)) ) sel += ' and runNumber >= '+ minrun;
if 	( !(isNaN(maxrun)) ) sel += ' and runNumber <= '+ maxrun;

// Response.Write(sel+'\n');

sel1="SELECT UNIQUE stream FROM "+(sel.split("FROM")[1]);
// Response.Write(sel1);

try{
    var con = connectToDB();
    		
    var iselcbs = [];
    var rs=con.execute(sel1);
	while (! rs.EOF) {
		iselcbs.push(new String(rs(0)));
	    rs.MoveNext();
	}

    // Response.Write(iselcbs);
	
	for (s in iselcbs){
		que= sel + " AND stream='"+iselcbs[s]+"' order by runnumber asc";
        // Response.Write(que + '\n');
		Response.Write('serie:\t' + iselcbs[s] + '\n');
	    rs=con.execute(que);
	    if (usemu==0){
    		while (! rs.EOF) {
    			Response.Write(rs(0) +"\t"+ rs(1) +"\n" );
    		    rs.MoveNext();
    		}
    	}else{
    	    while (! rs.EOF) {
    			Response.Write(rs(0) +"\t"+ rs(1) +"\t" + rs(2) +"\n" );
    		    rs.MoveNext();
    		}
    	}
	}
	con.Close();
	}
catch (e){
    Response.Write(e.message);
}

Response.End();

</script>
