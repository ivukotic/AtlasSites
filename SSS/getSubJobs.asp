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

var jobid    = Request("jobid");

try{
    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="select taskid, inputsize,  inputevents, outputfiles, outputsize, outputevents, status, cpueff, machinename, SUBSTR((cast(lastupdate as TIMESTAMP)-cast(started as TIMESTAMP)),10,10), to_char(lastupdate,'yy-mm-dd HH24:MI') from SSS_SUBJOBS where jobid="+jobid;
    // Response.Write(query+"</br>");
	var rs=con.execute(query);
    while (! rs.EOF) {
        Response.Write(rs(0)+"\t"+rs(1)+"\t"+rs(2)+"\t"+rs(3)+"\t"+rs(4)+"\t"+rs(5)+"\t"+rs(6)+"\t"+rs(7)+"\t"+rs(8)+"\t"+rs(9)+"\t"+rs(10)+"\n");
        rs.MoveNext();
    }
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
