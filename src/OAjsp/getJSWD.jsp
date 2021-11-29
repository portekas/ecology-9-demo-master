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
    /**
     * 角色文档页面
     * lg
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String id = Util.null2String(request.getParameter("id"));
    RecordSet rs = new RecordSet();
    List<Map<String,String>> resArr = new ArrayList<>();
    Map<String,String> resMap = new HashMap<>();
    rs.executeSql("SELECT wdmczw,wdmc FROM uf_jswdgl_dt1 where mainid = "+id+" order by px");
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
        .btnCol {
            border-radius: 7px;
            color: #fff;
            background-color: #2db7f5;
            border-color: #2db7f5;
            padding: 7px 15px;
            line-height: 1.5;
            border: 1px solid transparent;
            cursor:pointer;
        }
        .butSpen{
            display: inline-block;
            line-height: 28px;
            vertical-align: middle;
            margin-left: 20px;
        }
    </style>

    <script>
        function openwtlb(){
            window.open("/spa/cube/index.html#/main/cube/search?customid=1531");
        }
        function openwtxj(){
            window.open("/spa/cube/index.html#/main/cube/card?type=1&modeId=224&formId=-505");
        }
    </script>
</head>
<body onload="">
<div style="min-height: 245px">
<table id="tableBody" class="tableBody">
    <c:forEach items="${resArr}" var="res">
        <tr><td><a href="/spa/document/index.jsp?id=${res.wdmc}&router=1#/main/document/detail?" target="_blank">${res.wdmczw}</a></td></tr>
    </c:forEach>
</table>
</div>

    <div style="float: left;width: 50%;text-align: center;">
        <span class="butSpen">
            <button type="button" class="btnCol" onclick="openwtlb()">
                <span>常见问题查询</span>
            </button>
        </span>
    </div>
    <div style="float: left;text-align: center;">
        <span class="butSpen">
            <button type="button" class="btnCol" onclick="openwtxj()">
                <span>常见问题发布</span>
            </button>
        </span>
    </div>

</body>