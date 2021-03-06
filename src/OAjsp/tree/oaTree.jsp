<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>

<%
    /**
     * OA通用树，数据在OA后端配置中设置，引用后在查询的左侧展示
     * 创建 2021-11-23 刘港
     * 修改 2021-12-20 刘港 调整通用树滚动条样式，调整统计数据小于2条时默认隐藏树
     * 修改 2021-12-21 刘港 添加当前人员ID、人员部门ID替换
     * 修改 2022-02-22 刘港 添加隐藏数值功能
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    String bid = Util.null2String(request.getParameter("bid"));
    List<Map<String,Object>> resArr = new ArrayList<>();
    Map<String,String> resMap = new HashMap<>();
    Map<String,Object> treeMap = new HashMap<>();
    RecordSet rs = new RecordSet();
    rs.executeSql("SELECT sxmc,ljdz,gdcs,dtcs,fzcs,tjsql,ryxxcs,dytjbzd,sfxssz FROM uf_oatys WHERE id = "+bid);
    if(rs.next()){
        StringBuilder lj = new StringBuilder();
        String sxmc = rs.getString("sxmc");//树形名称
        String ljdz = rs.getString("ljdz");//连接地址
        String gdcs = rs.getString("gdcs");//固定参数
        String dtcs = rs.getString("dtcs");//动态参数
        String sfxssz = rs.getString("sfxssz");//是否显示数值
        lj.append(ljdz);
        if(StringUtils.isNotBlank(gdcs)){
            for(String p:gdcs.split(",")){
                String tem = Util.null2String(request.getParameter(p));
                resMap.put(p,tem);
                lj.append("&").append(p).append("=").append(tem);
            }
        }
        request.setAttribute("ljdz", lj.toString());
        request.setAttribute("sxmc", sxmc);
        request.setAttribute("dtcs", dtcs);
        request.setAttribute("sfxssz", sfxssz);

        //查询人员表信息拼接统计sql
        String ryxxcs = rs.getString("ryxxcs");
        String dytjbzd = rs.getString("dytjbzd");
        StringBuilder con = new StringBuilder();
        if(StringUtils.isNotBlank(ryxxcs)){
            RecordSet rs1 = new RecordSet();
            String s = "select id," + ryxxcs + " from hrmresource where id=" + user.getUID();
            rs1.executeSql(s);
            if(rs1.next()){
                String[] ry = ryxxcs.split(",");
                String[] tj = dytjbzd.split(",");
                for(int i = 0; i< ry.length; i++){
                    if(con.length() != 0){
                        con.append(" AND ");
                    }
                    con.append(tj[i]).append(" = '").append(rs1.getString(ry[i])).append("'");
                }
            }
        }

        //拼接统计sql
        String sql = rs.getString("tjsql");
        String fzcs = rs.getString("fzcs");
        sql = sql.replaceAll(Matcher.quoteReplacement("$")+"UserId"+Matcher.quoteReplacement("$"),String.valueOf(user.getUID()));
        sql = sql.replaceAll(Matcher.quoteReplacement("$")+"DepartmentId"+Matcher.quoteReplacement("$"),String.valueOf(user.getUserDepartment()));
        if(StringUtils.isNotBlank(fzcs)){
            for(String cs:gdcs.split(",")){
                fzcs = fzcs.replace("$"+cs+"$",resMap.get(cs));
            }
            con.append(fzcs);
        }

        //替换sql的全角

        if(con.length() > 0){
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
    <script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="tree.js"></script>
    <link rel="stylesheet" href="tree.css">
</head>
<body onload="">
<div>
    <c:choose>
        <c:when test="${resArr.size() > 1 }">
            <div id="weleft" class="wea-left-right-layout-left ant-col-xs-8 ant-col-sm-7 ant-col-md-6 ant-col-lg-5 weleft">
        </c:when>
        <c:otherwise>
            <div id="weleft" class="wea-left-right-layout-left ant-col-xs-0 ant-col-sm-0 ant-col-md-0 ant-col-lg-0">
        </c:otherwise>
    </c:choose>
        <div class="ant-row wea-new-top" style="border-bottom: 1px solid #e2e2e2">
            <div class="ant-col-14" style="padding-left: 20px; line-height: 50px;">
                <div class="wea-new-top-title wea-f14">
                    <span style="vertical-align: middle; margin-right: 10px;">
                    <span class="wea-new-top-title-breadcrumb" style="vertical-align: middle;user-select:none">${sxmc}</span>
                </div>
            </div>
        </div>
        <table class="tableBody">
            <tr>
                <th>名称</th>
                <c:if test="${sfxssz != 1}">
                    <th>数量</th>
                </c:if>
            </tr>
        </table>
        <div class="table2">
        <table id="tableBody" class="tableBody ">
            <colgroup>
                <COL style="width: 180px">
                <COL >
            </colgroup>
            <tr onclick="attifram('${ljdz}')">
                <td><span>&emsp;&emsp;全部</span></td>
                <c:if test="${sfxssz != 1}">
                    <td class="tealCen"><span>${sum}</span></td>
                </c:if>
            </tr>
            <c:forEach items="${resArr}" var="res">
                <tr onclick="attifram('${ljdz}&${dtcs}=${res.treeID}')">
                    <td><span>&emsp;&emsp;${res.treeName}</span></td>
                    <c:if test="${sfxssz != 1}">
                        <td class="tealCen"><span>${res.treeCount}</span></td>
                    </c:if>
                </tr>
            </c:forEach>
        </table>
        </div>
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