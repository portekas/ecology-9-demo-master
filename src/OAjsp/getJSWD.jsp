<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String jsmc = Util.null2String(request.getParameter("jsmc"));
    RecordSet rs = new RecordSet();
    List<Map<String,String>> resArr = new ArrayList<>();
    Map<String,String> resMap = new HashMap<>();
    rs.executeSql("SELECT wdmczw,wdmc FROM uf_jswdgl_dt1 where mainid = "+jsmc+" order by px");
    while(rs.next()){
        resMap = new HashMap<>();
        resMap.put("wdmc",rs.getString("wdmc"));
        resMap.put("wdmczw",rs.getString("wdmczw"));
        resArr.add(resMap);
    }
    request.setAttribute("resArr", resArr);
%>
<head>
    <style>
        .tableBody{
            width: 100%;
        }

        .tableBody tr{
            height: 30px;
        }

        .tableBody td {
            padding-left: 18px;
            border-bottom: 2px dashed rgb(233, 233, 233);
        }

        .tableBody tr td:hover {
            background: #e9f7ff;
        }

        .tableBody a{
            color: #7b7a7a;
            font-size: 13px;
            text-decoration:none;
        }
    </style>

    <script>

    </script>
</head>
<body onload="">
<table id="tableBody" class="tableBody">
    <tbody>
    <c:forEach items="${resArr}" var="res">
        <tr><td><a href="/spa/document/index.jsp?id=${res.wdmc}&router=1#/main/document/detail?" target="_blank">${res.wdmczw}</a></td></tr>
    </c:forEach>
    </tbody>

</table>
</body>