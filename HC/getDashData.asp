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
var toploty = Request("toplotY");
var from    = Request("from");
var to      = Request("to");

var ssites = new String(Request("sites"));
var sites = [];
if (ssites.length) sites = ssites.split(',');

if (sites.length){
	try{
	    var con = connectToDB();

		var query="SELECT ";
		query += "TO_CHAR(to_number(result.created - to_date('01-JAN-1970','DD-MON-YYYY')) * 86400000), TO_CHAR(" + toploty + ") ";
		query += "FROM result, project, site, wn, panda ";
		query += "WHERE project.projectid=result.projectref AND result.siteref=site.siteid AND wn.resultid=result.resultid AND result.pandaid=panda.pandaid AND " ;
		query += "project.name='" + project + "' AND "; 
		query += "result.created>=to_date('"+ from + "','yyyy-mm-dd') AND ";
		query += "result.created<=to_date('"+ to +"','yyyy-mm-dd') ";
		query +=" AND result.filename like '%group.test.hc.NTUP_SMWZ.root' ";
		
		
		for (s in sites){
			que= query + " AND site.name='"+sites[s]+"'  order by created asc";
			// Response.Write(que + '\n');
			Response.Write('site:\t' + sites[s] + '\n');
		    var rs=con.execute(que);
			while (! rs.EOF) {
				Response.Write(rs(0) +"\t"+ rs(1) +"\n" );
			    rs.MoveNext();
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
