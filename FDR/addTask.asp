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

    var na=Request("name");
    var ty=Request("type");
    var se=Request("server");
    var cl=Request("client");
    var fi=Request("files");
    var jo=Request("jobs");
    var ti=Request("timeout");

    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="insert into fdr_tests (name, server, client, files, testtype, jobs, timeout) values ('"+na+"','"+se+"','"+cl+"',"+fi+",'"+ty+"' ,"+jo+","+ti+")";
	// Response.Write(query+"</br>");
	var rs=con.execute(query);

	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
