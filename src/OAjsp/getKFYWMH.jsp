<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     * 开发运维岗位平台页面
     * lg
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    String type = Util.null2String(request.getParameter("type"));
    RecordSet rs = new RecordSet();
    int dpg = 0;
    int dcl = 0;
    int jxz = 0;

    String ry = StringUtils.isBlank(type)?" AND fzr = " + user.getUID():"";
    String mhtitle = StringUtils.isBlank(type)?"OA开发运维岗位平台":"开发运维管理平台";
    rs.executeSql("SELECT COUNT(id) as numb FROM uf_gzrw WHERE wwczt = 0 " + ry);
    if(rs.next()){
        dpg=rs.getInt("numb");
    }
    rs.executeSql("SELECT COUNT(id) as numb FROM uf_gzrw WHERE wwczt = 1 " + ry);
    if(rs.next()){
        dcl=rs.getInt("numb");
    }
    rs.executeSql("SELECT COUNT(id) as numb FROM uf_gzrw WHERE wwczt = 2 " + ry);
    if(rs.next()){
        jxz=rs.getInt("numb");
    }

    request.setAttribute("mhtitle", mhtitle);
    request.setAttribute("type", type);
    request.setAttribute("dpg", dpg);
    request.setAttribute("dcl", dcl);
    request.setAttribute("jxz", jxz);
%>
<head>
    <script src="./cloudstore/resource/pc/ckeditor-4.6.2/adapters/jquery.js"></script>
    <style>
        .head-example-zzmh {
            width: 125px;
            height: 90px;
            border-radius: 10%;
            /* background: #eee; */
            display: inline-block;
            text-align: center;
            color: #fff;
            font-size: 14px;
            -webkit-user-select:none;
        }

        .ant-badge {
            margin-right:35px;
            margin-bottom: 10px;
        }
        .line-height-zzmh1{
            letter-spacing:1px;
            margin-top:20px;
        }
        .line-height-zzmh2{
            margin-top:10px;
            font-size: 21px;
        }

        .background1{
            background:rgb(243, 145, 16);
        }
        .background2{
            background:rgb(45, 183, 245);
        }
        .background3{
            background:rgb(125, 199, 86);
        }
        .background4{
            background:rgb(233, 97, 43);
        }

        .hmTop{
            text-align: center;
            padding-top: 20px;
        }
        .mhTitle{
            text-align: center;
            color: #404040;
            font-size: 38px;
            height:55px;
        }
        .hmBody{
            /*float: left;*/
            padding-top: 60px;
        }
    </style>

    <script>
        function dpg(){
            if("${type}" == "gl"){
                window.open("/spa/cube/index.html#/main/cube/search?customid=1579&wwczt=0");
            }else{
                window.open("/spa/cube/index.html#/main/cube/search?customid=1584&wwczt=0");
            }
        }
        function dcl(){
            if("${type}" == "gl"){
                window.open("/spa/cube/index.html#/main/cube/search?customid=1579&wwczt=1");
            }else {
                window.open("/spa/cube/index.html#/main/cube/search?customid=1584&wwczt=1");
            }
        }
        function jxz(){
            if("${type}" == "gl"){
                window.open("/spa/cube/index.html#/main/cube/search?customid=1579&wwczt=2");
            }else {
                window.open("/spa/cube/index.html#/main/cube/search?customid=1584&wwczt=2");
            }
        }

    </script>
</head>
<body onload="">
<div id="container">
    <div id="testdiv" class="hmTop">
        <div class="mhTitle">${mhtitle}</div>
        <div>
            <div class="hmBody" style="">
                <a>
                    <span class="head-example-zzmh background1 ant-badge" onclick="dpg()">
                        <div class="line-height-zzmh1">待评估</div>
                        <div class="line-height-zzmh2">${dpg}</div>
                    </span>
                </a>
                <a>
                    <span class="head-example-zzmh background2 ant-badge" onclick="dcl()">
                        <div class="line-height-zzmh1">待处理</div>
                        <div class="line-height-zzmh2">${dcl}</div>
                    </span>
                </a>
                <a>
                    <span class="head-example-zzmh background3 ant-badge" onclick="jxz()">
                        <div class="line-height-zzmh1">进行中</div>
                        <div class="line-height-zzmh2">${jxz}</div>
                    </span>
                </a>
            </div>

        </div>
    </div>
</div>
<script type="text/javascript" src="/cloudstore/resource/pc/polyfill/polyfill.min.js"></script>
<script type="text/javascript" src="/cloudstore/resource/pc/shim/shim.min.js"></script>
</body>