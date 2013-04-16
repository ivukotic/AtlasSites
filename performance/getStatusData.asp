<script language="jscript" runat="server">

var ti0 = Request("syst");

var db='ATLAS_AMI_COLL_SIZES_01_LAL';
function connectToDB(){
	var con = Server.CreateObject("ADODB.Connection");
	if (ti0==1)
	    con.ConnectionString = Application("connString");
	else{
    	con.ConnectionString = Application("connStringGRID");
	    db='ATLAS_AMI_COLL_SIZES_01_LALG';
    }
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

try{
    var con = connectToDB();
    
    var sel="SELECT (extract( day from time-to_date('01-jan-1970 01','dd-mon-yyyy hh') )*24*60*60 + extract( hour from (time-to_date('01-jan-1970 01','dd-mon-yyyy hh')) )*60*60 + extract( minute from (time-to_date('01-jan-1970 01','dd-mon-yyyy hh')) )*60)*1000 t,";
    var sel3 = " FROM " + db + ".DBPERFORMANCE WHERE time>SYSDATE-5 AND ";
    

    // Response.Write(sel+", inserts " + sel3 +" eventtype='obj' ORDER BY time desc");
    
    var rs=con.execute(sel+" inserts " + sel3 +" eventtype='obj' ORDER BY time desc");
	Response.Write('serie:\tInserts to Obj\n');
    while (! rs.EOF) { Response.Write(rs(0) +"\t"+ rs(1) +"\n" ); rs.MoveNext(); }
    
    rs=con.execute(sel+" inserts " + sel3 +" eventtype='algo' ORDER BY time desc");
    Response.Write('serie:\tInserts to Algo\n');
    while (! rs.EOF) { Response.Write(rs(0) +"\t"+ rs(1) +"\n" ); rs.MoveNext(); }
        
    rs=con.execute(sel+" updates " + sel3 +" eventtype='obj' ORDER BY time desc");
    Response.Write('serie:\tUpdates to Obj\n');
    while (! rs.EOF) { Response.Write(rs(0) +"\t"+ rs(1) +"\n" ); rs.MoveNext(); }
        
    rs=con.execute(sel+" updates " + sel3 +" eventtype='algo' ORDER BY time desc");
    Response.Write('serie:\tUpdates to Algo\n');
    while (! rs.EOF) { Response.Write(rs(0) +"\t"+ rs(1) +"\n" ); rs.MoveNext(); }

	con.Close();
	}
catch (e){
    Response.Write(e.message);
}

Response.End();

</script>
