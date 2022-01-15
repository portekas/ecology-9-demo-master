<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     * 创建 刘港 2022-1-12 用于会议交办事项台帐 填写事项跟进
     *
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String fmdid = Util.null2String(request.getParameter("fmdid"));
    RecordSet rs = new RecordSet();
    List<Map<String,String>> resArr = new ArrayList<>();
    Map<String,String> resMap = new HashMap<>();
    String sql = "SELECT selectvalue,selectname FROM workflow_SelectItem WHERE fieldid = '29657'";
    rs.executeSql(sql);
    rs.writeLog("输出sql:"+sql);
    while(rs.next()){
        rs.writeLog("结果"+rs.getString("selectname"));
        resMap = new HashMap<>();
        resMap.put("selectvalue",rs.getString("selectvalue"));
        resMap.put("selectname",rs.getString("selectname"));
        resArr.add(resMap);
    }
    request.setAttribute("resArr", resArr);
    request.setAttribute("fmdid", fmdid);
    request.setAttribute("newDate", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
%>

<head>
    <script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery.min.js"></script>
    <style>
        table {
            table-layout:fixed !important;
            width:90% !important;
            border-collapse:collapse;
            border:none;
            margin:0 auto;
            font-size: 62.5%;
        }
        td,th {
            width:1px;
            white-space:nowrap; /* 自适应宽度*/
            word-break:keep-all; /* 避免长单词截断，保持全部 */
            white-space:pre-line;
            word-break:break-all !important;
            word-wrap:break-word !important;
            vertical-align:middle !important;
            white-space: normal !important;
            height:auto;
            vertical-align:text-top;
            padding:6px 6px 6px 12px;
            display: table-cell;
        }
        td.alt {
            background: #fff;
            color: #797268;
            border: 1px solid #90badd;
        }

        td.spec {
            border: 1px solid #90badd;
            background: #e7f3fc ;
            font: bold 10px "Trebuchet MS", Verdana, Arial, Helvetica, sans-serif;
            width: 20%;
            text-align: center;
        }
        textarea{
            border: 1px solid #d9d9d9;
            min-height: 50px;
            width: 80%;
            font-size: 14px;
            font-family: 微软雅黑;
        }
        select{
            border: 1px solid #d9d9d9;
            min-height: 30px;
            width: 80%;
            font-size: 14px;
            font-family: 微软雅黑;
        }

    </style>

    <script type="text/javascript">
        /*
        * 请在下面编写JS代码
        */
        function closeDialog() {
            window.parent.ModeForm.closeCustomDialog();
        }

        function saveDialog() {
            var fmdid = "${fmdid}";
            var gjjl = $("#gjjl").val();
            var sxzt = $("#sxzt").val();
            $.ajax({
                url: "/OAjs/getLicense.jsp?operation=addHYJBSXGJ",
                // type: "post",
                async: false,
                data: "fmdid=" + fmdid+"&gjjl="+gjjl+"&sxzt="+sxzt,
                success: function doSuccess(msg) {
                    window.parent.ModeForm.closeCustomDialog();
                    window.parent.ModeList.reloadTable();
                }
            })
        }

    </script>
</head>
<body>
<table id="mytable" cellspacing="0">
    <tr>
        <td class="spec">跟进记录</td>
        <td class="alt"><textarea id="gjjl" name="gjjl"></textarea></td>
    </tr>
    <tr>
        <td class="spec">事项状态</td>
        <td class="alt">
            <select id="sxzt" name="sxzt">
                <c:forEach items="${resArr}" var="res">
                    <option value="${res.selectvalue}">${res.selectname}</option>
                </c:forEach>
            </select>
        </td>
    </tr>
    <tr>
        <td class="spec">跟进时间</td>
        <td class="alt">${newDate}</td>
    </tr>
</table>
</body>