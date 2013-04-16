<script language="jscript" runat="server">

function connectToDB(){
	var con = Server.CreateObject("ADODB.Connection");
	con.ConnectionString = Application("connString");
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

var ssites = new String(Request("sites"));
var scpus  = new String(Request("cpus")); 
var sroots = new String(Request("roots"));
var sstors = new String(Request("stors"));
var sifile = new String(Request("ifile"));
var sites = [];
var cpus  = [];
var roots = [];
var stors = [];
var ifile = [];

if (ssites.length) sites = ssites.split(',');
if (scpus.length)  cpus  = scpus.split(',');
if (sroots.length) roots = sroots.split(',');
if (sstors.length) stors = sstors.split(',');
if (sifile.length) ifile = sifile.split(',');


if (sites.length){
	try{
	    var con = connectToDB();

		var query="SELECT ";
		query += "TO_CHAR(" + toplotx +"), TO_CHAR(" + toploty + ") ";
		query += "FROM result, project, site, wn, root, panda ";
		if (cpus.length>0){ query += ",cpu "}
		if (roots.length>0){ query += ",rootversion "}
		if (stors.length>0){ query += ",storage "}
		query += "WHERE project.projectid=result.projectref AND result.siteref=site.siteid AND wn.resultid=result.resultid AND root.resultid=result.resultid AND result.pandaid=panda.pandaid AND " ;
		query += "project.name='" + project + "' AND "; 
		if (cpus.length>0) { query += "cpu.cpuid=wn.cpuid AND "};
		if (roots.length>0) { query += "rootversion.versionid=root.versionid AND "};
		if (stors.length>0) { query += "result.storageid=storage.storageref AND "};
		query += "result.created>=to_date('"+ from + "','yyyy-mm-dd') AND ";
		query += "result.created<=to_date('"+ to +"','yyyy-mm-dd') ";
		for (s in cpus){	
			query +=' AND cpu.cpuid!='+cpus[s]+' ';
		}
		
		for (s in roots){
			query +=' AND rootversion.versionid!='+roots[s]+' ';
		}
		
		for (s in stors){
			query +=' AND storage.storageid!='+stors[s]+' ';
		}
		
		for (s in ifile){
			query +=" AND result.filename NOT LIKE '%"+ifile[s]+"' ";
		}
		
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
