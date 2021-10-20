<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /*
    根据requestid获取对应流程的明细
    */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    JSONObject json = new JSONObject();
    User user=HrmUserVarify.getUser(request,response);
    RecordSet rs = new RecordSet();
    if("v".equals(operation)){
        int day_10 = 0;
        int day_30 = 0;
        int month_12 = 0;
        int overdue = 0;

        String andSql1 = " AND yxlx = 1 AND requestID IS NULL AND t1.zt != '4'";
        String andSql2 = " AND datediff(day,getdate(),t1.dqrq) >= 0" + andSql1;
        rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 11" + andSql2);
        if(rs.next()){
            day_10=rs.getInt("numb");
        }
        rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 31" + andSql2);
        if(rs.next()){
            day_30=rs.getInt("numb");
        }
        rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(mm,getdate(),t1.dqrq) < 13" + andSql2);
        if(rs.next()){
            month_12=rs.getInt("numb");
        }
        rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 0" + andSql1);
        if(rs.next()){
            overdue=rs.getInt("numb");
        }

        json.put("day_10",day_10);
        json.put("day_30",day_30);
        json.put("month_12",month_12);
        json.put("overdue",overdue);

        out.print(json);
    }else if("getJSWD".equals(operation)){
        List<Map<String,String>> resArr = new ArrayList<>();
        Map<String,String> resMap;
        rs.executeSql("select count(id) as numb from uf_zzylb t1 where datediff(day,getdate(),t1.dqrq) < 11" );
        while(rs.next()){
            resMap = new HashMap<>();
            resMap.put("id",rs.getString("wd"));
            resArr.add(resMap);
        }

        out.print(resArr);
    }else if("getWDXMGZRZMX".equals(operation)){
        String xmid = Util.null2String(request.getParameter("xmid"));
        String newDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        rs.executeSql("select id from uf_xmjlgzrz t1 where xmid = '"+xmid+"' and rzrq = '"+newDate+"' and djr = '"+user.getUID()+"'");
        while(rs.next()){
            json.put("id",rs.getString("id"));
        }
        out.print(json);
    }else if("getRDPUser".equals(operation)){
        rs.executeSql("SELECT id,bbzh,bbmm FROM uf_zhdybbqx WHERE ry like '%,"+user.getUID()+",%' or ry like '"+user.getUID()+",%' or ry like '%,"+user.getUID()+"'");
        if(rs.next()){
            json.put("username",rs.getString("bbzh"));
            json.put("password",rs.getString("bbmm"));
        }
        out.clear();
        out.print(json);
    }





%>