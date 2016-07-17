<cfscript>
  basepath = GetDirectoryFromPath(GetCurrentTemplatePath());
  schemaurls = "";
  schemaurls=ListAppend(schemaurls, "http://schemas.xmlsoap.org/soap/envelope/", " ");
  schemaurls=ListAppend(schemaurls, "file://#basepath#/soap_envelope.xsd", " ");
  schemaurls=ListAppend(schemaurls, "http://jaxws.goochfriend.org/endpoint/", " ");
  schemaurls=ListAppend(schemaurls, "file://#basepath#/echo_response.xsd", " ");
  ws = createobject("webservice","file://"&basepath&"/echo.wsdl");

  srvobj = new SimpleWSDLEchoServer(48120);
  srvobj.start();
</cfscript>
<cftry>
  Started Server <br/><br/><cfflush />

  <cfset bean = new Bean() />
  <cfset bean.setApplicationid("testAppID") />
  <cfset obj = ws.echoRequest(EchoHeader=bean) />
  <cfoutput>Bean:<pre>#HTMLEditFormat(indentXML(obj))#</pre></cfoutput>
  <cfset beanresponse = obj />
  <br/>

  <cfset plain["applicationid"] = "TestAppID" />
  <cfset obj = ws.echoRequest(EchoHeader=plain) />
  <cfoutput>Map:<pre>#HTMLEditFormat(indentXML(obj))#</pre></cfoutput>
  <cfset mapresponse = obj />

  Stopping server<br/>
  <cfset srvobj.stop() />
  Joining
  <cfset srvobj.join() />
  Done
  <cfcatch type="Any">
    <cfset srvobj.stop() />
    <cfset srvobj.join() />
    <cfrethrow />
  </cfcatch>
</cftry>


Assertions:<br/>
Bean:<br/>
<cfset obj = beanresponse />
Parse bean: <Cfset xml=xmlparse(obj,"yes") />
<cfset xml.XmlRoot.XmlAttributes['xsi:schemaLocation'] = schemaurls />

Validate:<br/>
<cfset valid=xmlvalidate(xml) />
<cfif valid.status>Passed<br/><cfelse>
  <cfdump var="#valid#" />
</cfif>
<br/>

Map:<br/>
<cfset obj = mapresponse />
Parse bean: <Cfset xml=xmlparse(obj,"yes") />
<cfset xml.XmlRoot.XmlAttributes['xsi:schemaLocation'] = schemaurls />

Validate:<br/>
<cfset valid=xmlvalidate(xml) />
<cfif valid.status>Passed<br/><cfelse>
  <cfdump var="#valid#" />
</cfif>
<br/>


<cfabort />





<cffunction name="indentXml" output="false" returntype="string">
  <cfargument name="xml" type="string" required="true" />
  <cfargument name="indent" type="string" default="  "
    hint="The string to use for indenting (default is two spaces)." />
  <cfset var lines = "" />
  <cfset var depth = "" />
  <cfset var line = "" />
  <cfset var isCDATAStart = "" />
  <cfset var isCDATAEnd = "" />
  <cfset var isEndTag = "" />
  <cfset var isSelfClose = "" />
  <cfset xml = trim(REReplace(xml, "(^|>)\s*(<|$)", "\1#chr(10)#\2", "all")) />
  <cfset lines = listToArray(xml, chr(10)) />
  <cfset depth = 0 />
  <cfloop from="1" to="#arrayLen(lines)#" index="i">
    <cfset line = trim(lines[i]) />
    <cfset isCDATAStart = left(line, 9) EQ "<![CDATA[" />
    <cfset isCDATAEnd = right(line, 3) EQ "]]>" />
    <cfif NOT isCDATAStart AND NOT isCDATAEnd AND left(line, 1) EQ "<" AND right(line, 1) EQ ">">
      <cfset isEndTag = left(line, 2) EQ "</" />
      <cfset isSelfClose = right(line, 2) EQ "/>" OR REFindNoCase("<([a-z0-9_-]*).*</\1>", line) />
      <cfif isEndTag>
        <!--- use max for safety against multi-line open tags --->
        <cfset depth = max(0, depth - 1) />
      </cfif>
      <cfset lines[i] = repeatString(indent, depth) & line />
      <cfif NOT isEndTag AND NOT isSelfClose>
        <cfset depth = depth + 1 />
      </cfif>
    <cfelseif isCDATAStart>
      <!---
      we don't indent CDATA ends, because that would change the
      content of the CDATA, which isn't desirable
      --->
      <cfset lines[i] = repeatString(indent, depth) & line />
    </cfif>
  </cfloop>
  <cfreturn arrayToList(lines, chr(10)) />
</cffunction>

