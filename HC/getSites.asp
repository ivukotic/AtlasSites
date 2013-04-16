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

var project = Request("project");
var from    = Request("from");
var to      = Request("to");
// Response.Write("project:"+project+"</br>");
// Response.Write("from:"+from+"</br>");
// Response.End();

try{
    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="select unique(site.name) from result, site, project where  project.projectid=result.projectref AND site.siteid=result.siteref and result.created>=to_date('"+ from + "','yyyy-mm-dd') AND result.created<=to_date('"+ to +"','yyyy-mm-dd') order by site.name ";
	// Response.Write(query+"</br>");
	var rs=con.execute(query);
	while (! rs.EOF) {
		Response.Write(rs(0)+"\t" );
	    rs.MoveNext();
	}
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
