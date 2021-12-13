<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     *
     * 通用JS,方便调用 获取数据库的值
     * taName 表名
     * field 列名
     * con 条件
     *
     * 刘港
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    User user=HrmUserVarify.getUser(request,response);
    String field = Util.null2String(request.getParameter("field"));
    String conditions = Util.null2String(request.getParameter("con"));
    //解决参数中可能含有全角的问题
    conditions = conditions.replaceAll("ｏｒ","or");
    conditions = conditions.replaceAll("ａｎｄ","and");
    conditions = conditions.replaceAll("ｉｎ","in");
    String tableName = Util.null2String(request.getParameter("taName"));
    List<JSONObject> resArr = new ArrayList<>();
    JSONObject json ;
    RecordSet rs = new RecordSet();
    if(!conditions.isEmpty()){
        conditions = " where "+conditions;
    }
    rs.executeSql("select "+field+" from "+tableName+conditions );
    String[] paras = field.split(",");
    while(rs.next()){
        json = new JSONObject();
        for(String para : paras){
            json.put(para,rs.getString(para));
        }
        resArr.add(json);
    }
    out.clear();
    out.print(resArr);
%>