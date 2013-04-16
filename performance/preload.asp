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

function loadStreams(){
    var con = Server.CreateObject("ADODB.Connection");
    con.ConnectionString = Application("connString");
    con.ConnectionTimeout = 60;
    try{
        con.Open();
        var rs=con.execute("SELECT STREAMNAME FROM STREAMREF order by streamname");
        while (! rs.EOF) {
            strNA.push(String(rs("STREAMNAME")));
            rs.MoveNext();
        }
        con.Close();
    }
    catch (e){
        Response.Write(e.message);
        Response.End();
    }
}

function loadRuns(){
    var con = Server.CreateObject("ADODB.Connection");
    con.ConnectionString = Application("connString");
    con.ConnectionTimeout = 60;
    try{
        con.Open();
        var rs=con.execute("SELECT max(runnumber) as mar, min(runnumber) as mir FROM jobperformance WHERE runnumber>2");
        if (! rs.EOF) {
            maxRun=parseInt(rs(0));
            minRun=parseInt(rs(1));
        }
        con.Close();
    }
    catch (e){
        Response.Write(e.message);
        Response.End();
    }
}

loadStreams();
loadRuns();
Response.Write(strNA+"|");
Response.Write(minRun+"|");
Response.Write(maxRun);

</script>