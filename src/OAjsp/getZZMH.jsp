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
     * 证照门户页面
     * lg
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String glgz = Util.null2String(request.getParameter("glgz"));
    RecordSet rs = new RecordSet();
    int ryday_10 = 0;
    int ryday_30 = 0;
    int rymonth_12 = 0;
    int ryoverdue = 0;
    int zzday_10 = 0;
    int zzday_30 = 0;
    int zzmonth_12 = 0;
    int zzoverdue = 0;

    String ry = " and t1.lb=1 ";
    String zz = " and t1.lb=0 ";
    String andSql1 = " AND yxlx = 1 AND requestID IS NULL AND t1.zt != '4'";
    andSql1 = StringUtils.isNotBlank(glgz)? " AND glgz="+ glgz + andSql1 : andSql1;
    String andSql2 = " AND datediff(day,getdate(),t1.dqrq) >= 0" + andSql1;
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 11" + andSql2 + ry);
    if(rs.next()){
        ryday_10=rs.getInt("numb");
    }
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 31" + andSql2 + ry);
    if(rs.next()){
        ryday_30=rs.getInt("numb");
    }
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(mm,getdate(),t1.dqrq) < 13" + andSql2 + ry);
    if(rs.next()){
        rymonth_12=rs.getInt("numb");
    }
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 0" + andSql1 + ry);
    if(rs.next()){
        ryoverdue=rs.getInt("numb");
    }

    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 11" + andSql2 + zz);
    if(rs.next()){
        zzday_10=rs.getInt("numb");
    }
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 31" + andSql2 + zz);
    if(rs.next()){
        zzday_30=rs.getInt("numb");
    }
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(mm,getdate(),t1.dqrq) < 13" + andSql2 + zz);
    if(rs.next()){
        zzmonth_12=rs.getInt("numb");
    }
    rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 0" + andSql1 + zz);
    if(rs.next()){
        zzoverdue=rs.getInt("numb");
    }

    request.setAttribute("glgz", glgz);
    request.setAttribute("ryday_10", ryday_10);
    request.setAttribute("ryday_30", ryday_30);
    request.setAttribute("rymonth_12", rymonth_12);
    request.setAttribute("ryoverdue", ryoverdue);
    request.setAttribute("zzday_10", zzday_10);
    request.setAttribute("zzday_30", zzday_30);
    request.setAttribute("zzmonth_12", zzmonth_12);
    request.setAttribute("zzoverdue", zzoverdue);

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
            /*text-align: center;*/
        }
        .hmTitle{
            text-align: center;
            color: #404040;
            font-size: 38px;
            height:55px;
        }
        .hmBody{
            float: left;
            margin-top: 12px;
        }
    </style>

    <script>
        function day10(lb,glgz){
            var glgz = glgz != ""? "&glgz="+glgz : "";
            window.open("/spa/cube/index.html#/main/cube/search?customid=1533&lb="+lb+glgz);
        }
        function day30(lb,glgz){
            var glgz = glgz != ""? "&glgz="+glgz : "";
            window.open("/spa/cube/index.html#/main/cube/search?customid=1534&lb="+lb+glgz);
        }
        function month_12(lb,glgz){
            var glgz = glgz != ""? "&glgz="+glgz : "";
            window.open("/spa/cube/index.html#/main/cube/search?customid=1535&lb="+lb+glgz);
        }
        function overdue(lb,glgz){
            var glgz = glgz != ""? "&glgz="+glgz : "";
            window.open("/spa/cube/index.html#/main/cube/search?customid=1536&lb="+lb+glgz);
        }

    </script>
</head>
<body onload="">
<div id="container">
    <div id="testdiv" class="hmTop">
        <div class="hmTitle">证照管理工作台</div>
        <div>
            <div class="hmBody" style="border-right: 2px dashed rgb(233, 233, 233);text-align: right;width: 50%">
                <span style="color: #7b7a7a;font-size: 18px;margin-right: 165px;">个人</span><br/>
                <a>
                    <span class="head-example-zzmh background1 ant-badge" onclick="day10('1','${glgz}')">
                        <div class="line-height-zzmh1">10天内到期</div>
                        <div class="line-height-zzmh2" id="day10">${ryday_10}</div>
                    </span>
                </a>
                <a>
                    <span class="head-example-zzmh background2 ant-badge" onclick="day30('1','${glgz}')">
                        <div class="line-height-zzmh1">30天内到期</div>
                        <div class="line-height-zzmh2" id="day30">${ryday_30}</div>
                    </span>
                </a><br/>
                <a>
                    <span class="head-example-zzmh background3 ant-badge" onclick="month_12('1','${glgz}')">
                        <div class="line-height-zzmh1">12月内到期</div>
                        <div class="line-height-zzmh2" id="month_12">${rymonth_12}</div>
                    </span>
                </a>
                <a>
                    <span class="head-example-zzmh background4 ant-badge" onclick="overdue('1','${glgz}')">
                        <div class="line-height-zzmh1">已超期</div>
                        <div class="line-height-zzmh2" id="overdue">${ryoverdue}</div>
                    </span>
                </a>
            </div>
            <div class="hmBody" style="width: 45%;margin-left: 35px;">
                <spen style="color: #7b7a7a;font-size: 18px;margin-left: 127px;">组织</spen><br/>
                <a>
                    <span class="head-example-zzmh background1 ant-badge" onclick="day10('0','${glgz}')">
                        <div class="line-height-zzmh1">10天内到期</div>
                        <div class="line-height-zzmh2" id="day10">${zzday_10}</div>
                    </span>
                </a>
                <a>
                    <span class="head-example-zzmh background2 ant-badge" onclick="day30('0','${glgz}')">
                        <div class="line-height-zzmh1">30天内到期</div>
                        <div class="line-height-zzmh2" id="day30">${zzday_30}</div>
                    </span>
                </a><br/>
                <a>
                    <span class="head-example-zzmh background3 ant-badge" onclick="month_12('0','${glgz}')">
                        <div class="line-height-zzmh1">12月内到期</div>
                        <div class="line-height-zzmh2" id="month_12">${zzmonth_12}</div>
                    </span>
                </a>
                <a>
                    <span class="head-example-zzmh background4 ant-badge" onclick="overdue('0','${glgz}')">
                        <div class="line-height-zzmh1">已超期</div>
                        <div class="line-height-zzmh2" id="overdue">${zzoverdue}</div>
                    </span>
                </a>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript" src="/cloudstore/resource/pc/polyfill/polyfill.min.js"></script>
<script type="text/javascript" src="/cloudstore/resource/pc/shim/shim.min.js"></script>
</body>