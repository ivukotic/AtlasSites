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
    var na=Request("JobID");
    
    var con = connectToDB();
    var query="select dbms_lob.substr( indatasets, 4000, 1 ),tree,treestokeep,dbms_lob.substr( cbranches, 4000, 1 ),dbms_lob.substr( ccut, 4000, 1 ) from SSS_JOBS where jobid="+na;
	// Response.Write(query+"</br>");
	var rs=con.execute(query);
    if (! rs.EOF) {
        Response.Write(rs(0)+"\t"+rs(1)+"\t"+rs(2)+"\t"+rs(3)+"\t"+rs(4)+"\n" );
    }
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>