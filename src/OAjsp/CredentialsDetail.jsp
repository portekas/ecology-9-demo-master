<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*" %>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.json.JSONObject" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
	/**
    * 需延续证照跟进
    * lg
    */
	response.setHeader("cache-control", "no-cache");
	response.setHeader("pragma", "no-cache");
	response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
	String operation = Util.null2String(request.getParameter("operation"));
	JSONObject json = new JSONObject();
	User user = HrmUserVarify.getUser(request, response);
	int gjr=user.getUID();
	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

	if (operation.equals("saveDetail")) {
		String mainid = Util.null2String(request.getParameter("mainid"));
		String zzbh = Util.null2String(request.getParameter("zzbh"));
		String zzmc = Util.null2String(request.getParameter("zzmc"));
		String ygxm = Util.null2String(request.getParameter("ygxm"));
		String gjnr = Util.null2String(request.getParameter("gjnr"));

		List<Object> detailList = new ArrayList<>();
		RecordSet rs = new RecordSet();
		String sql=" insert into uf_zzylb_dt1 (mainid,zzbh,zzmc,ygxm,gjnr,gjr,gjsj) values(?,?,?,?,?,?,?)";
		detailList.add(mainid);
		detailList.add(zzbh);
		detailList.add(zzmc);
		detailList.add(ygxm);
		detailList.add(gjnr);
		detailList.add(gjr);
		detailList.add(df.format(new Date()));
		Object[] detailArr = detailList.toArray(new Object[detailList.size()]);
		rs.executeUpdate(sql,detailArr);

		json.put("mainid",mainid);
		json.put("zzbh",zzbh);
		json.put("zzmc",zzmc);
		json.put("ygxm",ygxm);
		json.put("gjnr",gjnr);
		json.put("gjr",gjr);
		json.put("sql",sql);
	}
	out.print(json);
%>