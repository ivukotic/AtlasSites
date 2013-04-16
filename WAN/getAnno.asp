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


var site    = Request("site");
var from    = Request("from");
var to      = Request("to");

try{
    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="select to_char(created,'yyyy/mm/dd'), content, users.username from annotation, users";
	if (site!='ANY') query+=", site";
    query += " where users.userid=annotation.userid and annotation.created>=to_date('"+ from + "','yyyy-mm-dd') AND annotation.created<=to_date('"+ to +"','yyyy-mm-dd') ";
    if (site!='ANY') query+="AND site.siteid=annotation.siteid AND site.name='"+site+"' ";
	query+=" order by created desc ";
    // Response.Write(query+"</br>");
	var rs=con.execute(query);
	while (! rs.EOF) {
		Response.Write(rs(0)+"\t"+rs(1)+"\t"+rs(2)+"\n" );
	    rs.MoveNext();
	}
	
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
