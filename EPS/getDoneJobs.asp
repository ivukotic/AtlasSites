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

    var con = connectToDB();
	var query="select jobid, to_char(created,'yy-mm-dd HH24:MI'), substr(outdataset,-least(30, length(outdataset) ) ), inputevents, eventsprocessed, outputevents, currentoutputsize, status from SSS_JOBS where status>4";
	// Response.Write(query+"</br>");
	var rs=con.execute(query);
	while (! rs.EOF) {
		Response.Write(rs(0)+"\t"+rs(1)+"\t"+rs(2)+"\t"+rs(3)+"\t"+rs(4)+"\t"+rs(5)+"\t"+rs(6)+"\t"+rs(7)+"\n" );
	    rs.MoveNext();
	}
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
