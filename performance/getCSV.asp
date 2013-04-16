<script language="jscript" runat="server">

var fn = Request("tit");
var yt = Request("tity");
var data = Request("data");
var usemu = Request("usemu");

Response.Clear();
Response.Buffer = true;
Response.Contenttype="application/csv";

fn=String(fn).replace("  ","-");
Response.AddHeader("Content-Disposition", "attachment;filename="+fn+".csv");

if (usemu) Response.Write("stream,<mu>,"+String(yt)+'\n'); else Response.Write("stream,runnumber,"+String(yt)+'\n');

for (var i=0; i<data.length;i++){
    for (var j=0;j<ALLData[i].data.length;j++){
        Response.Write(ALLData[i].name+","+ALLData[i].data[j][0] +","+ALLData[i].data[j][1]+"\n");
    }
}

Response.End();

</script>
