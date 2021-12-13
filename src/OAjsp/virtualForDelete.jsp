<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     * 视图的批量删除
     * lg
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    String bid = Util.null2String(request.getParameter("bid"));
    RecordSet rs = new RecordSet();
    if(StringUtils.isBlank(bid)){
        return;
    }

    //我的专项工作批量删除
    if("v_zxgz".equals(operation)){
        rs.executeSql("delete uf_zxgzzb_dt1 where mainid in ("+bid+")");
        rs.executeSql("delete uf_zxgzzb where id in ("+bid+")");
    }





%>