<!--- 
 *
 * Copyright (c) 2016, Lucee Assosication Switzerland. All rights reserved.*
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 --->
<cfcomponent extends="org.lucee.cfml.test.LuceeTestCase">
  <cffunction name="runTest" access="public" output="true">
    <cfscript>
      var basepath = GetDirectoryFromPath(GetCurrentTemplatePath())&"/LDEV0933";
      var schemaurls = "";
      schemaurls=ListAppend(schemaurls, "http://schemas.xmlsoap.org/soap/envelope/", " ");
      schemaurls=ListAppend(schemaurls, "file://#basepath#/soap_envelope.xsd", " ");
      schemaurls=ListAppend(schemaurls, "http://jaxws.goochfriend.org/endpoint/", " ");
      schemaurls=ListAppend(schemaurls, "file://#basepath#/echo_response.xsd", " ");
      var ws = createobject("webservice","file://"&basepath&"/echo.wsdl");

      var srvobj = new LDEV0933.SimpleWSDLEchoServer(48120);
      srvobj.start();
    </cfscript>
    <cftry>
      Started Server <br/><br/><cfflush />

      <cfset var bean = new LDEV0933.Bean() />
      <cfset bean.setApplicationid("testAppID") />
      <cfset var obj = ws.echoRequest(EchoHeader=bean) />
      <cfoutput>Bean:<pre>#HTMLEditFormat(indentXML(obj))#</pre></cfoutput>
      <cfset var beanresponse = obj />
      <br/>

      <cfset var plain = structnew() />
      <cfset plain["applicationid"] = "TestAppID" />
      <cfset obj = ws.echoRequest(EchoHeader=plain) />
      <cfoutput>Map:<pre>#HTMLEditFormat(indentXML(obj))#</pre></cfoutput>
      <cfset var mapresponse = obj />

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

    <!---Assertions--->
    Bean:<br/>
    <Cfset var xml=xmlparse(beanresponse,"yes") />
    <cfset xml.XmlRoot.XmlAttributes['xsi:schemaLocation'] = schemaurls />

    Validate:<br/>
    <cfset valid=xmlvalidate(xml) />
    <cfdump var="#valid#" />
    <br/>
    <cfif not valid.status>
      <cfset fail("Bean provided to SOAP request did not pass validation when sent to service"&chr(10)&ArrayToList(valid.errors,chr(10))) />
    </cfif>
    <cfset assertTrue(valid.status) />

    Map:<br/>
    <Cfset var xml=xmlparse(mapresponse,"yes") />
    <cfset xml.XmlRoot.XmlAttributes['xsi:schemaLocation'] = schemaurls />

    Validate:<br/>
    <cfset valid=xmlvalidate(xml) />
    <cfdump var="#valid#" />
    <br/>
    <cfif not valid.status>
      <cfset fail("Struct provided to SOAP request did not pass validation when sent to service"&chr(10)&ArrayToList(valid.errors,chr(10))) />
    </cfif>
    <cfset assertTrue(valid.status) />
  </cffunction>





  <cffunction name="indentXml" output="false" returntype="string" access="private">
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

</cfcomponent>
