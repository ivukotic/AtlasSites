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
var from    = Request("from");
var to      = Request("to");
var ssites   = new String(Request("sites"));
var sites = ssites.split(',');

if (sites.length>0){
	var andSites=" AND result.created>=to_date('"+ from + "','yyyy-mm-dd') AND result.created<=to_date('"+ to +"','yyyy-mm-dd') " ;
	andSites += "AND project.name='"+project+"' ";
	
	andSites += " AND ("
	for (s in sites){
		andSites += " site.name='"+sites[s]+"' OR ";
	}
	andSites=andSites.substring(0,andSites.length-3);
	andSites +=") ";

	try{
	    var con = connectToDB();
		// Response.Write("</br>connected</br>");
		
		var query="SELECT unique cpu.cpuid, cpu.name ||', '|| TO_CHAR(cores) || ' cores' || DECODE(ht,1, ' HT') FROM cpu, result, site, project, wn WHERE  project.projectid=result.projectref AND site.siteid=result.siteref AND wn.resultid=result.resultid AND wn.cpuid=cpu.cpuid" + andSites;
		// Response.Write(query+"</br>");
		var rs=con.execute(query);
		while (! rs.EOF) {
			Response.Write("cpu:\t"+ parseInt(rs(0)).toString() +"\t"+ rs(1)+"\n" );
		    rs.MoveNext();
		}
	
		query="SELECT UNIQUE rootversion.versionid, rootversion.svnversion , rootversion.name  FROM  result, site, project, root, rootversion WHERE  project.projectid=result.projectref AND site.siteid=result.siteref AND root.resultid=result.resultid AND root.versionid=rootversion.versionid" + andSites;
		// Response.Write(query+"</br>");
		rs=con.execute(query);
		while (! rs.EOF) {
			Response.Write("root:\t"+ parseInt(rs(0)).toString() +"\t"+rs(2)+" v:"+ parseInt(rs(1)).toString() + "\n" );
		    rs.MoveNext();
		}
		
		query="SELECT UNIQUE storage.storageid, storage.name, storage.serverversion, storage.clientversion FROM  result, site, project, storage WHERE  project.projectid=result.projectref AND site.siteid=result.siteref AND storage.storageid=result.storageref" + andSites;
		// Response.Write(query+"</br>");
		rs=con.execute(query);
		while (! rs.EOF) {
			Response.Write("stor:\t"+ parseInt(rs(0)).toString() +"\t"+rs(1)+" server - "+ rs(2) + " client - "+ rs(3) + "\n" );
		    rs.MoveNext();
		}
	
		query="SELECT UNIQUE SUBSTR(filename,INSTR(result.filename, '/',-1)+1) FROM result, site, project WHERE project.projectid=result.projectref AND site.siteid=result.siteref" + andSites;
		// Response.Write(query+"</br>");
		var rs=con.execute(query);
		while (! rs.EOF) {
			Response.Write("file:\t"+rs(0)+"\n" );
		    rs.MoveNext();
		}
	
		con.Close();
		}
	catch (e){
	    Response.Write(e.message);
	    Response.End();
	}
}

</script>
