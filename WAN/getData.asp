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

var project = Request("project");
var toplotx = Request("toplotX");
var toploty = Request("toplotY");
var from    = Request("from");
var to      = Request("to");

var ossites = new String(Request("servsites"));
var servsites = [];
if (ossites.length) servsites = ossites.split(',');

var dssites = new String(Request("cliesites"));
var cliesites = [];
if (dssites.length) cliesites = dssites.split(',');


if (servsites.length && cliesites.length){
	try{
	    var con = connectToDB();

		var query="SELECT ";
		query += "TO_CHAR(" + toplotx +"), TO_CHAR(" + toploty + ") ";
		query += "FROM result, project, link ";
		query += "WHERE project.projectid=result.projectid AND result.linkid=link.linkid AND " ;
		query += "project.name='" + project + "' AND "; 
		query += "result.created>=to_date('"+ from + "','yyyy-mm-dd') AND ";
		query += "result.created<=to_date('"+ to +"','yyyy-mm-dd') ";
		
		for (s in servsites){
    		for (d in cliesites){
    			que= query + " AND link.client in (select site.siteid from site where site='"+cliesites[d]+"') AND link.server in (select site.siteid from site where site='"+servsites[s]+"')";
                // Response.Write(que + '\n');
    			Response.Write('link:\t' + servsites[s] + '->' + cliesites[d] + '\n');
    		    var rs=con.execute(que);
    			while (! rs.EOF) {
    				Response.Write(rs(0) +"\t"+ rs(1) +"\n" );
    			    rs.MoveNext();
    			}
    		}
		}
		con.Close();
	    Response.End();
		}
	catch (e){
	    Response.Write(e.message);
	    Response.End();
	}
}
else{
	Response.End();
}

</script>
