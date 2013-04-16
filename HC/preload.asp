<script language="jscript" runat="server">

strNA=[];
minRun=0;
maxRun=0;

function connectToDB(){
	var con = Server.CreateObject("ADODB.Connection");
    con.ConnectionString = Application("connString");
	con.ConnectionTimeout = 60;
	try{
		con.Open();
		return con;
	}
	catch (e){
		Response.Write(e.message);
		Response.End();
	}		
}

function HCload(){
    var con = Server.CreateObject("ADODB.Connection");
    con.ConnectionString = Application("HCconnString");
    con.ConnectionTimeout = 60;
    retStr='';
    try{
        con.Open();
        var rs=con.execute("SELECT NAME FROM project ORDER BY name");
        while (! rs.EOF) {
            retStr += String(rs('NAME')) + ',';
            rs.MoveNext();
        }
		retStr+='<|>';
		rs=con.execute("SELECT NAME FROM site ORDER BY site.name");
		while (! rs.EOF) {
            retStr += String(rs('NAME')) + ',';
            rs.MoveNext();
        }
        con.Close();
    }
    catch (e){
        Response.Write(e.message);
        Response.End();
    }
}

HCload();
Response.Write(retStr);

</script>