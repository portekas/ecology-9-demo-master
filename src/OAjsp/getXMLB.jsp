<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="com.alibaba.fastjson.JSON" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>

<%
    /**
     * 项目经理施工日志，展示项目列表
     * lg
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    RecordSet rs = new RecordSet();
    List<Map<String,String>> resArr = new ArrayList<>();
    Map<String,String> resMap;
    JSONArray json = new JSONArray();
    JSONObject jo;
    String newDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
    rs.executeSql("SELECT DISTINCT ux.id,ux.xmbh,ux.xmmc, (SELECT COUNT(id) from uf_xmjlgzrz uxj where uxj.xmbh = ux.xmbh and rzrq = '"+newDate+"' and djr = '"+user.getUID() +"') AS isfill " +
            "FROM uf_xmb ux LEFT JOIN uf_xmzcy uz ON ux.xmbh = uz.xmbh " +
            "WHERE gczt in ('0','1') and (ux.sgxmjl = "+user.getUID() +" or uz.xm = "+user.getUID() +")");
    while(rs.next()){
        resMap = new HashMap<>();
        resMap.put("id",rs.getString("id"));
        resMap.put("xmbh",rs.getString("xmbh"));
        resMap.put("xmmc",rs.getString("xmmc"));
        resMap.put("isfill",rs.getString("isfill"));
        resArr.add(resMap);
        jo = new JSONObject();
        jo.put("id",rs.getString("id"));
        jo.put("xmmc",rs.getString("xmmc"));
        json.put(resArr.size()-1,jo);
    }
    request.setAttribute("resArr", resArr);
    request.setAttribute("sehArr", json);
%>
<head>
    <script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery.min.js"></script>
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
            /*color: #7b7a7a;*/
            font-size: 13px;
            text-decoration:none;
        }
        .inp{
            height: 30px;
            width: 205px;
            border: 1px solid #d9d9d9;
        }
        .acolor_0{
            color: #000;
        }
        .acolor_1{
            color: #7b7a7a;
        }
    </style>

    <script>
        var par = window.parent;
        var info = par.ModeForm.getCardUrlInfo();
        var xmId = par.ModeForm.convertFieldNameToId("xmid");
        var jrgz = par.ModeForm.convertFieldNameToId("jrgz");
        var mrgz = par.ModeForm.convertFieldNameToId("mrgz");

        function LoadXM(id,num,name) {
            // window.parent.LoadXM(id, num, name);

            var xmidVal = par.ModeForm.getFieldValue(xmId);
            var jrgzVal = par.ModeForm.getFieldValue(jrgz);
            var mrgzVal = par.ModeForm.getFieldValue(mrgz);
            //不保存
            if (jrgzVal == "" || mrgzVal == "" ) {
                getWDXMGZRZMX(id,num,name,"2");

            }else if(jrgzVal != "" && mrgzVal != ""){
                par.ModeForm.doCardSubmit('','0','',false,function(billid){
                    par.ModeForm.showMessage("保存成功", 3, 1.5);
                    getWDXMGZRZMX(id,num,name,"1");
                });
            }

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
                        //新建页面点开
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

        //回车后搜索
        var res=eval('(${sehArr})');
        document.onkeydown = function (e) {
            var theEvent = window.event || e;
            var code = theEvent.keyCode || theEvent.which || theEvent.charCode;
            var inp = $("#inp").val();
            if (code == 13) {
                for(i=0;i<res.length;i++){
                    if(res[i].xmmc.indexOf(inp) > -1){
                        $("#tr_"+res[i].id).show();
                    }else{
                        $("#tr_"+res[i].id).hide();
                    }
                }
            }
        }
    </script>
</head>
<body onload="">
<table id="tableBody" class="tableBody">
    <tr><td><input id="inp" class="inp" autocomplete="off" placeholder="输入后回车搜索" /></td></tr>
    <c:forEach items="${resArr}" var="res">
        <tr id="tr_${res.id}">
            <td onclick="LoadXM('${res.id}','${res.xmbh}','${res.xmmc}')">
                <a href="javascript:;" class="acolor_${res.isfill}"  >
                    ${res.xmmc}
                    <c:if test="${res.isfill == '1'}">
                        (已填写)
                    </c:if>
                </a>
            </td>
        </tr>
    </c:forEach>
</table>
</body>