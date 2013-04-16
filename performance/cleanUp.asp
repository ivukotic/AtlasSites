<script language="jscript" runat="server">

var ti0 = Request("syst");

var db='ATLAS_AMI_COLL_SIZES_01_LAL';
function connectToDB(){
	var con = Server.CreateObject("ADODB.Connection");
	if (ti0==1)
	    con.ConnectionString = Application("connString");
	else{
    	con.ConnectionString = Application("connStringGRID");
	    db='ATLAS_AMI_COLL_SIZES_01_LALG';
    }
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

try{
    var con = connectToDB();
    
    var rs=con.execute("begin "+db+".cleanup(); end;");
	Response.Write("CleanUp done.");
	con.Close();
	}
catch (e){
    Response.Write(e.message);
}

Response.End();

</script>
