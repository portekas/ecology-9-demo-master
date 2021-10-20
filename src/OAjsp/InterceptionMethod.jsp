<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /*
    拦截内部进行的操作
    */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    JSONObject json = new JSONObject();
    User user=HrmUserVarify.getUser(request,response);
    if(operation.equals("bindingDoc")){
        String docid = Util.null2String(request.getParameter("docid"));
        String customid = Util.null2String(request.getParameter("customid"));
        if(!docid.isEmpty() && !customid.isEmpty()){
            RecordSet rs = new RecordSet();
            String sql = "update uf_xxhmk set bzwdid = ? where mkid = ?";
            String[] arr = {docid,customid};
            rs.executeUpdate(sql,arr);
        }
    }

    out.print(json);

%>