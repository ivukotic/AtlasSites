<script language="jscript" runat="server">

function SITESload(){
    var con = Server.CreateObject("ADODB.Connection");
    con.ConnectionString = Application("WANconnString");
    con.ConnectionTimeout = 60;
    ret='';
    try{
        con.Open();
        
        rs=con.execute("SELECT NAME FROM project ORDER BY name");
        while (! rs.EOF) {
            ret += String(rs('NAME')) + ',';
            rs.MoveNext();
        }
        ret+='\n';
        var rs=con.execute("SELECT site FROM site WHERE role='both' OR role='server' ORDER BY site");
        while (! rs.EOF) {
            ret += String(rs('site')) + ',';
            rs.MoveNext();
        }
        
        ret+='\n';
        var rs=con.execute("SELECT site FROM site WHERE role='both' OR role='client' ORDER BY site");
        while (! rs.EOF) {
            ret += String(rs('site')) + ',';
            rs.MoveNext();
        }        

        con.Close();
    }
    catch (e){
        Response.Write(e.message);
        Response.End();
    }
}

SITESload();
Response.Write(ret);

</script>