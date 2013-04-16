<script language="jscript" runat="server">

function connectToDB(){
        var con = Server.CreateObject("ADODB.Connection");
        con.ConnectionString = Application("WANconnString");
        con.ConnectionTimeout = 180;
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
    var na=Request("restartTask");
    
    var con = connectToDB();
	var query="update SSS_SUBJOBS set outputevents=0,outputsize=0, status=1, machinename='', cpueff=0, eventsprocessed=0 where taskid="+na;
	// Response.Write(query+"</br>");
	var rs=con.execute(query);

	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
