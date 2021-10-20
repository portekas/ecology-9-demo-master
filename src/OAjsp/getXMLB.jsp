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
    rs.executeSql("SELECT id,xmbh,xmmc FROM uf_xmb WHERE gczt in ('0','1') and sgxmjl = "+user.getUID());
//    rs.executeSql("SELECT id,xmbh,xmmc FROM uf_xmb WHERE gczt in ('0','1') ");
    while(rs.next()){
        resMap = new HashMap<>();
        resMap.put("id",rs.getString("id"));
        resMap.put("xmbh",rs.getString("xmbh"));
        resMap.put("xmmc",rs.getString("xmmc"));
        resArr.add(resMap);
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
            height: 50px;
        }

        .tableBody td {
            padding-left: 5px;
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
        var par = window.parent;
        var info = par.ModeForm.getCardUrlInfo();
        var xmId = par.ModeForm.convertFieldNameToId("xmid");
        var jrgz = par.ModeForm.convertFieldNameToId("jrgz");
        var mrgz = par.ModeForm.convertFieldNameToId("mrgz");

        function LoadXM(id,num,name) {
            window.parent.LoadXM(id, num, name);
            // var xmidVal = par.ModeForm.getFieldValue(xmId);
            // var jrgzVal = par.ModeForm.getFieldValue(jrgz);
            // var mrgzVal = par.ModeForm.getFieldValue(mrgz);
            // if ((jrgzVal == "" && mrgzVal == "" ) || xmidVal == "") {
            //     getWDXMGZRZMX(id,num,name,"2");
            //
            // }else if(jrgzVal != "" || mrgzVal != ""){
            //     par.ModeForm.doCardSubmit('','0','',false,function(billid){
            //         par.ModeForm.showMessage("保存成功", 3, 1.5);
            //         getWDXMGZRZMX(id,num,name,"1");
            //     });
            // }

        }

        function getWDXMGZRZMX(id,num,name,type){
            $.ajax({
                url:"/OAjs/getLicense.jsp?operation=getWDXMGZRZMX&xmid="+id+"&_R="+ Math.random(),
                dataType:"json",
                async:false,
                success:function(data){
                    if(data.id != "" && data.id != null){
                        window.parent.location.href="/spa/cube/index.html#/main/cube/card?type=2&modeId="+info.modeId+"&formId="+info.formId+"&billid="+data.id+"&opentype=0&viewfrom=fromsearchlist";
                    }else{
                        if("1" == info.type){
                            if("1" == type){
                                window.parent.location.href="/spa/cube/index.html#/main/cube/card?type=1&modeId="+info.modeId+"&formId="+info.formId+"&xmid="+id+"&xmbh="+num+"&xmmc="+name;
                            }else{
                                window.parent.LoadXM(id, num, name);
                            }
                        }else{
                            window.parent.location.href="/spa/cube/index.html#/main/cube/card?type=1&modeId="+info.modeId+"&formId="+info.formId+"&xmid="+id+"&xmbh="+num+"&xmmc="+name;
                        }

                    }
                }
            })
        }


    </script>
</head>
<body onload="">
<table id="tableBody" class="tableBody">
    <c:forEach items="${resArr}" var="res">
        <tr><td onclick="LoadXM('${res.id}','${res.xmbh}','${res.xmmc}')"><a href="javascript:;">${res.xmmc}</a></td></tr>
    </c:forEach>
</table>
</body>