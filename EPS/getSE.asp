<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<%
dim strResponse,destURL

destURL = "http://atlas-agis-api.cern.ch/request/service/query/get_se_services/?json&state=ACTIVE&flavour=SRM"

'Construct the useragent and send
 On error resume next 
set http_obj=server.CreateObject("MSXML2.ServerXMLHTTP")
if err.number <> 0 then 
        Response.Write "MSXML2.ServerXMLHTTP is not installed." 
end if         
'http_obj.setTimeouts 8000,8000,8000,300000
http_obj.Open "GET", destURL , false
http_obj.setRequestHeader "Content-type", "application/json" 
http_obj.send()

'Grab the response
strResponse = http_obj.ResponseText

set http_obj=nothing
'Response.Write "Form sent"
'Response.Write strResponse

response.write( strResponse )
%>
