
<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<%
If Len(Request.Form) > 0 Then
dim strResponse,destURL,strContent

destURL = "http://uc3-sub.uchicago.edu:8080"
'Construct the Post Data
strContent = strContent & Request.Form

'Construct the useragent and send
 On error resume next 
set http_obj=server.CreateObject("MSXML2.ServerXMLHTTP")
if err.number <> 0 then 
        Response.Write "MSXML2.ServerXMLHTTP is not installed." 
end if         
'                     resolve, connect, send, receive. 0 means infinite. milliseconds.
http_obj.setTimeouts 8000,8000,0,0
http_obj.Open "POST", destURL , false
http_obj.setRequestHeader "Content-type", "application/json" 
http_obj.send(strContent)

'Grab the response
strResponse = http_obj.ResponseText

set http_obj=nothing
'Response.Write "Form sent"
response.write( strResponse )

End If
%>
