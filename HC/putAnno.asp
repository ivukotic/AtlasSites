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

if (Request.ServerVariables("LOGON_USER") == "") {
    Response.Write('You must login in order to add annotation');
    Response.End();
}
    
var login = Request.ServerVariables("LOGON_USER")+'';
login = login.substr(5);
Response.Write(login);

//  // Declare variables
// DIM connAD, rsADUserInfo
// DIM strUserEmail
// DIM strBase, strFilter,strAttributes, strScope, strFullCommand

// //Create connection to LDAP
// set connAD = Server.CreateObject("ADODB.Connection")
// connAD.Provider = "ADsDSOObject"
// connAD.Open
// 
// // Select 
// strBase = "<LDAP://DC=cern,DC=ch>"
// strFilter = "(sAMAccountName=" & login & ")" 
// strAttributes = "mail"
// strScope = "subtree" 
// strFullCommand = strBase & ";" & strFilter & ";" & strAttributes & ";" & strScope  'Search command
// set rsADUserInfo = Server.CreateObject("ADODB.Recordset")    ' Object to collect results
// set  rsADUserInfo = connAD.Execute(strFullCommand)   ' Execution of query
// 
// strUserEmail = rsADUserInfo("mail")   ' Retrieve the e-mail field from the results
// 
// set connAD = Nothing
// 
// Response.Write("<b>User</b>: " & login)
// Response.Write("<br><b>E-mail</b>: " & strUserEmail)


var site    = Request("site");
var content = Request("content");
var created = Request("created")+"";

try{
    var con = connectToDB();
	// Response.Write("</br>connected</br>");
	var query="";
	if (created.length>8)
    	query="addanno('"+ login +"','"+ content +"','"+ site +"','"+ created + "')";
	else
    	query="addanno('"+ login +"','"+ content +"','"+ site + "')";
    // Response.Write(query);
	var rs=con.execute(query);
	con.Close();
	}
catch (e){
    Response.Write(e.message);
    Response.End();
}

</script>
