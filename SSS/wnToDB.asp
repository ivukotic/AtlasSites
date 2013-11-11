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

try{
    
    var con = connectToDB();
    
    // get variables always needed
    var method=Request("Method");
    var TaskID=Request("Task");
    var query;
    
    if (method=="SSS_START_TASK"){
        Response.Write(method+"</br>");
        var machineName=Request("Machine");
        query="ATLAS_WANHCTEST.SSS_START_TASK("+TaskID+",'"+machineName+"')"
    }
    
    if (method=="SSS_FINISH_TASK"){
        Response.Write(method+"</br>");
        var CPUeff=Request("CPUeff");
        query="ATLAS_WANHCTEST.SSS_FINISH_TASK("+TaskID+",4,"+CPUeff+")"
    }
    
    if (method=="SSS_FINISH_FILE"){
        Response.Write(method+"</br>");
        var ePassed=Request("EventsPassed");
        var eProcessed=Request("EventsProcessed");
        query="update ATLAS_WANHCTEST.SSS_SUBJOBS set outputevents="+ePassed+", eventsprocessed=eventsprocessed+"+eProcessed+" where taskid=" + TaskID;
    }
    
    if (method=="SSS_FINALE"){
        Response.Write(method+"</br>");
        var outputSize=Request("OutputSize");
        query="update ATLAS_WANHCTEST.SSS_SUBJOBS set status=5, outputsize="+outputSize+" where taskid="+TaskID;
    }
    
    Response.Write(query+"</br>");
    
    con.execute(query);
    con.Close();  
	
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
