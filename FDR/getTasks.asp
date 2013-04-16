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
    var con1 = connectToDB();
    var query1="FDR_UPDATE";
    con1.execute(query1);
    con1.Close();

    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="select testid, name,server,client, to_char(created,'yy-mm-dd HH24:MI'), testtype, files, value, mbps, evps, jobs,finished,started,timeout from FDR_TESTS";
	// Response.Write(query+"</br>");
	var rs=con.execute(query);
	while (! rs.EOF) {
		Response.Write(rs(0)+"\t"+rs(1)+"\t"+rs(2)+"\t"+rs(3)+"\t"+rs(4)+"\t"+rs(5)+"\t"+rs(6)+"\t"+rs(7)+"\t"+rs(8)+"\t"+rs(9)+"\t"+rs(10)+"\t"+rs(11)+"\t"+rs(12)+"\t"+rs(13)+"\n" );
	    rs.MoveNext();
	}
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
