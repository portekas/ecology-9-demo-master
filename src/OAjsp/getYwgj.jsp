<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*" %>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /*
    根据requestid获取对应流程的明细
    */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    StringBuffer json = new StringBuffer();
    User user = HrmUserVarify.getUser(request, response);
    int gjr=user.getUID();
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

    String gjrq = df.format(new Date());//进度日期
    BaseBean log = new BaseBean();
    String needWorkTypes = "4,6,8";    //需要过滤 节假日和周末 的 类型
    if (operation.equals("getYwgj")) {
        String xmbh = Util.null2String(request.getParameter("xmbh"));
        String xmmc = Util.null2String(request.getParameter("xmmc"));
        String gjnr = Util.null2String(request.getParameter("gjnr"));
        String formId = Util.null2String(request.getParameter("formId"));

        RecordSet rs = new RecordSet();
        String sf = "1"; //是否有这个工程名称
        rs.writeLog("成功了=1111111111111111");
        json.append("{");
        String sql=" insert into uf_hkywgj (xmbh,xmmc,gjnr,gjr,gjrq,formmodeid) values('" + xmbh + "','"+xmmc+"','"+gjnr+"','" +
                gjr+"','"+gjrq+"','"+formId+"')";
        rs.executeSql(sql);
        rs.writeLog("sql语句是："+sql);

//        if (rs.next()) {
//            sf = "0";
//        }
        json.append("'sf':'").append(xmbh).append("'");
        json.append("}");
    }
    out.print(json);
%>