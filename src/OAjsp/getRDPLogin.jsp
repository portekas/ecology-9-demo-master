<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>

<%
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    RecordSet rs = new RecordSet();
    List<Map<String,String>> resArr = new ArrayList<>();
    Map<String,String> resMap;
    String gwid = Util.null2String(request.getParameter("gwid"));
    if(gwid != ""){
        rs.executeSql("SELECT bbmczw,bbid FROM uf_jswdgl_dt2 where mainid = " + gwid +" order by px");
        while(rs.next()){
            resMap = new HashMap<>();
            resMap.put("bbmczw",rs.getString("bbmczw"));
            resMap.put("bbid",rs.getString("bbid"));
            resArr.add(resMap);
        }
    }

    request.setAttribute("resArr", resArr);
%>

<head>
    <script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery-1.8.3.min.js?v=20180320"></script>
    <style>
        .tableBody{
            width: 100%;
        }

        .tableBody tr{
            height: 35px;
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

    <script type="text/javascript">
        function openbb(id){
            window.open("/RDP-SERVER/rdppage/main/"+id);
        }

    </script>
</head>
<body>

<div id="spbody" style="text-align: center;" ></div>
<table id="tableBody" class="tableBody">
    <c:forEach items="${resArr}" var="res">
        <tr><td onclick="openbb('${res.bbid}')"><a href="javascript:;">${res.bbmczw}</a></td></tr>
    </c:forEach>
</table>
</body>