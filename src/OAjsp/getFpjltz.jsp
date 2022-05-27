<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*" %>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     * 检查发票信息台账中是否含有此发票
     * 用于项目费用及报销流程
     * 0为是，1为否
     * 修改人：胡仲杰 2021-12-11
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    StringBuffer json = new StringBuffer();
    User user = HrmUserVarify.getUser(request, response);
    BaseBean log = new BaseBean();
    if (operation.equals("getFpbh")) {
        String tfpbh = Util.null2String(request.getParameter("tfpbh"));
        String lcid = Util.null2String(request.getParameter("lcid"));
        RecordSet rs = new RecordSet();
        String sf = "1"; //是否有这个发票编号登记了
        String lcbh = "";

        rs.writeLog("成功了=getFpbh" + lcid);
        json.append("{");
        String sql=" SELECT * from uf_fpjltz  where fpbh= '" + tfpbh + "' and lcid <> '" + lcid + "'";
        rs.executeSql(sql);
        rs.writeLog("执行的sql语句为："+sql);
        if (rs.next()) {
            sf = "0";
        }else{
            rs.executeQuery("SELECT 1 from uf_fptz where InvoiceNum = '"+tfpbh+"' AND zflc IS NOT NULL AND zflc <> '" + lcid + "'");
            if (rs.next()) {
                sf = "0";
            }
        }
        json.append("'sf':'").append(sf).append("'");
        json.append("}");
    }
    if(operation.equals("delFpjl")){
        String tfpbh = Util.null2String(request.getParameter("tfpbh"));
        String lcid = Util.null2String(request.getParameter("lcid"));
        RecordSet rs=new RecordSet();
        String sql="delete from uf_fpjltz where fpbh in ("+tfpbh+") and lcid='"+lcid+"'";
        rs.executeUpdate(sql);
        rs.writeLog("执行的sql语句为："+sql);
    }
    out.print(json);

%>