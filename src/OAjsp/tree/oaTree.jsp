<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>

<%
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    String bid = Util.null2String(request.getParameter("bid"));
    RecordSet rs = new RecordSet();
    List<Map<String,Object>> resArr = new ArrayList<>();
    Map<String,String> resMap = new HashMap<>();
    Map<String,Object> treeMap = new HashMap<>();
    rs.executeSql("SELECT sxmc,ljdz,gdcs,dtcs,fzcs,tjsql FROM uf_oatys WHERE id = "+bid);
    if(rs.next()){
        StringBuilder lj = new StringBuilder();
        String sxmc = rs.getString("sxmc");//树形名称
        String ljdz = rs.getString("ljdz");//连接地址
        String gdcs = rs.getString("gdcs");//固定参数
        String dtcs = rs.getString("dtcs");//动态参数
        lj.append(ljdz);
        if(StringUtils.isNotBlank(gdcs)){
            String[] par = gdcs.split(",");
            for(String p:par){
                String tem = Util.null2String(request.getParameter(p));
                resMap.put(p,tem);
                lj.append("&").append(p).append("=").append(tem);
            }
        }
        request.setAttribute("ljdz", lj.toString());
        request.setAttribute("sxmc", sxmc);
        request.setAttribute("dtcs", dtcs);

        //拼接统计sql
        String sql = rs.getString("tjsql");
        String fzcs = rs.getString("fzcs");
        if(StringUtils.isNotBlank(fzcs)){
            StringBuilder con = new StringBuilder();
            String[] tem = fzcs.split(",");
            for(int i = 0; i < tem.length; i++){
                if(i != 0){
                    con.append(" and ");
                }
                con.append(tem[i]).append(" = '").append(resMap.get(tem[i])).append("'");
            }
            sql = sql.replace("$tjcs$",con.toString());
        }
        rs.executeSql(sql);
        rs.writeLog("执行的sql为："+sql);
        int sum = 0;
        while (rs.next()){
            treeMap = new HashMap<>();
            treeMap.put("treeID",rs.getString("treeID"));
            treeMap.put("treeCount",rs.getInt("treeCount"));
            treeMap.put("treeName",rs.getString("treeName"));
            resArr.add(treeMap);
            sum += rs.getInt("treeCount");
        }
        request.setAttribute("sum", sum);
    }
    request.setAttribute("resArr", resArr);
%>
<head>
    <script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery-1.8.3.min.js?v=20180320"></script>
    <script type="text/javascript" src="tree.js"></script>
    <link rel="stylesheet" href="tree.css">
</head>
<body onload="">
<div>
    <div id="weleft" class="wea-left-right-layout-left ant-col-xs-8 ant-col-sm-7 ant-col-md-6 ant-col-lg-5" style="width: 250px;overflow: auto;">
        <div class="ant-row wea-new-top" style="border-bottom: 1px solid #e2e2e2">
            <div class="ant-col-14" style="padding-left: 20px; line-height: 50px;">
                <div class="wea-new-top-title wea-f14">
                    <span style="vertical-align: middle; margin-right: 10px;">
                    <span class="wea-new-top-title-breadcrumb" style="vertical-align: middle;user-select:none">${sxmc}</span>
                </div>
            </div>
        </div>
        <table id="tableBody" class="tableBody">
            <tr>
                <th>名称</th>
                <th>数量</th>
            </tr>
            <tr onclick="attifram('${ljdz}')">
                <td><span>全部</span></td>
                <td><span>${sum}</span></td>
            </tr>
            <c:forEach items="${resArr}" var="res">
                <tr onclick="attifram('${ljdz}&${dtcs}=${res.treeID}')">
                    <td><span>${res.treeName}</span></td>
                    <td><span>${res.treeCount}</span></td>
                </tr>
            </c:forEach>
        </table>
    </div>
    <!--右侧-->
    <div ecid="" class="wea-left-right-layout-right">
        <div id="rebut" class="wea-left-right-layout-btn wea-left-right-layout-btn-show" ></div>
        <div class="" style="display: block;height: 100%;">
            <iframe src="${ljdz}" id="lbifram" name="" frameborder="0" scrolling="auto" style="width:100%;height:100%;"></iframe>
        </div>
    </div>
</div>
</body>