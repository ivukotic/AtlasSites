<script language="jscript" runat="server">

    var con = Server.CreateObject("ADODB.Connection");
    con.ConnectionString = Application("WANconnString");
    con.ConnectionTimeout = 60;
    try{
        con.Open();
        
        rs=con.execute("SELECT name, host, redirector FROM faxSites where redirector<2");
        while (! rs.EOF) {            
			Response.Write( String(rs('name')) + '\t' + String(rs('host')) + '\t' + String(rs('redirector')) +'\n') ;
            rs.MoveNext();
        }

        con.Close();
    }
    catch (e){
        Response.Write(e.message);
        Response.End();
    }

 Response.End();

</script>