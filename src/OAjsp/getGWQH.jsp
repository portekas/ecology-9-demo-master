<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@ page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@ page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="weaver.hrm.resource.ResourceComInfo" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page isELIgnored="false"%>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     * 2022-06-28 新增 刘港 工具栏菜单-账号岗位切换页面
     */

    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    String msg = "";
    RecordSet rs = new RecordSet();
    rs.executeQuery("select ry,gw,bm,gs,sj from uf_gwrydygx where " +
            "ry = '"+user.getUID()+"' " +
            "and (gw != '"+user.getJobtitle()+"' or bm != '"+user.getUserDepartment()+"') " +
            "and (mrgw = '0' or datediff(day,getdate(),yxqz) >= 0)");
    if(rs.next()){
        String ry = rs.getString("ry");
        if(StringUtils.isNotBlank(ry)){
            String gw = rs.getString("gw");
            String bm = rs.getString("bm");
            String gs = rs.getString("gs");
            String sj = rs.getString("sj");
            //更新岗位、部门
            if(StringUtils.isNotBlank(gw) && StringUtils.isNotBlank(bm)) {
                rs.executeUpdate("update hrmresource set " +
                        "jobtitle = '"+gw+"' ," +
                        "departmentid = '"+bm+"'," +
                        "subcompanyid1 = '"+gs+"'," +
                        "managerid = '"+sj+"' " +
                        "where id ='"+ry+"'");

                //更新表缓存
                ResourceComInfo rc = new ResourceComInfo();
                rc.updateResourceInfoCache(ry);

                //更新对象缓存
                user.setJobtitle(gw);
                user.setUserDepartment(Integer.parseInt(bm));
                user.setUserSubCompany1(Integer.parseInt(gs));
                user.setManagerid(sj);
                request.getSession(true).setAttribute("weaver_user@bean",user);
                //查询最新岗位信息
                user=HrmUserVarify.getUser(request,response);
                rs.executeQuery("select jobtitlename from hrmjobtitles where id = "+user.getJobtitle());
                if(rs.next()){
                    msg = "岗位变更成功，当前岗位为："+rs.getString("jobtitlename");
                }
            }
        }
    }else{
        msg = "无其他岗位";
    }
    request.setAttribute("msg", msg);
%>


<html>
<head>
<script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery.min.js"></script>
<script>
    $(document).ready(function() {
        //移除右上角X
        window.parent.$(".ant-modal-close").remove()
        setTimeout(function (){
            //移除弹框
            window.parent.$(".e9header-toolbar-dialog").remove()
        },1500)
    })
</script>
</head>
<body onload="">
<div style="text-align: center">${msg}</div>
</body>
</html>
