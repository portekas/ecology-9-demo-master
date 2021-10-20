<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /*
    根据requestid获取对应流程的明细
    */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    StringBuffer json=new StringBuffer();
    User user=HrmUserVarify.getUser(request,response);
    BaseBean log = new BaseBean();
    String needWorkTypes="4,6,8";	//需要过滤 节假日和周末 的 类型
    if(operation.equals("getWork")){
        String workid = Util.null2String(request.getParameter("id"));
//        String lcid = Util.null2String(request.getParameter("lcid"));
        RecordSet rs = new RecordSet();
        String wname="";
        String wdoc="";
        String helpid="";

        rs.writeLog("成功了=1111111111111111pfjl");
        json.append("{");

        rs.executeSql(" SELECT * FROM workflow_base where id='"+workid+"'");

        if(rs.next()){
            wname=rs.getString("workflowname");
            wdoc=rs.getString("workflowdesc");
            helpid=rs.getString("helpdocid");
        }


        json.append("'wname':'").append(wname + "").append("',");  //名称
        json.append("'wdoc':'").append(wdoc + "").append("',");  //文档
        json.append("'helpid':'").append(helpid + "").append("'");  //id
        json.append("}");
    }
    if(operation.equals("getMode")){
        String mkid = Util.null2String(request.getParameter("mkid"));
        String mklb = Util.null2String(request.getParameter("mklb"));
        RecordSet rs = new RecordSet();
//        String wname="";
//        String wdoc="";
        String id="";
        String mkmc="";

        rs.writeLog("成功了=1111111111111111pfjl");
        json.append("{");

        rs.executeSql(" SELECT * FROM uf_xxhmk where mkid='"+mkid+"' and mklb='"+mklb+"'");

        if(rs.next()){
//            wname=rs.getString("workflowname");
//            wdoc=rs.getString("workflowdesc");
            id=rs.getString("bzwdid");
            mkmc=rs.getString("mkmc");

        }


//        json.append("'wname':'").append(wname + "").append("',");  //内部领料金额
        json.append("'mkmc':'").append(mkmc + "").append("',");  //预算变更次数
        json.append("'id':'").append(id + "").append("'");  //id
        json.append("}");
    }
    out.print(json);

%>