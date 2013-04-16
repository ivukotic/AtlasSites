<script language="jscript" runat="server">

function connectToDB(){
        var con = Server.CreateObject("ADODB.Connection");
        con.ConnectionString = Application("HCconnString");
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
	// Response.Write("</br>connected</br>");
	var query="select site, queue from FDR_SERVERS";
	// Response.Write(query+"</br>");
	var rs=con.execute(query);
	while (! rs.EOF) {
		Response.Write(rs(0)+"\t"+rs(1)+"\n" );
	    rs.MoveNext();
	}
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
