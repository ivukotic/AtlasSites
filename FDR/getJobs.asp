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

var testid    = Request("taskid");

    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="select to_char(created,'yy-mm-dd HH24:MI'), status, value, mbps, evps, pandaid from FDR_JOBS where testid="+testid;
	// Response.Write(query+"</br>");
	var rs=con.execute(query);
	while (! rs.EOF) {
		Response.Write(rs(0)+"\t"+rs(1)+"\t"+rs(2)+"\t"+rs(3)+"\t"+rs(4)+"\t"+rs(5)+"\n" );
	    rs.MoveNext();
	}
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
