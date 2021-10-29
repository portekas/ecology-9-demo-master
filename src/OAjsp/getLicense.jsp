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
    /*
    根据requestid获取对应流程的明细
    */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    String bid = Util.null2String(request.getParameter("bid"));
    String par1 = Util.null2String(request.getParameter("par1"));
    JSONObject json = new JSONObject();
    User user=HrmUserVarify.getUser(request,response);
    RecordSet rs = new RecordSet();
    if("getXYQZZTZ".equals(operation)){
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

    }else if("addZCPD".equals(operation)){
        rs.executeSql("SELECT COUNT(id) as num FROM uf_gdzcpdqd WHERE pdjhid = "+bid);
        if(rs.next()){
            int num = rs.getInt("num");
            if(num > 0){
                json.put("mess","请勿重复生成");
                json.put("type","2");
                out.clear();
                out.print(json);
                return;
            }
        }

        rs.executeSql("SELECT id,pdgs,pdbm,grrq,zclb,pdmc FROM uf_gdzcpdjh WHERE id = "+bid);
        String cond = "";
        if(rs.next()){
            String pdgs = rs.getString("pdgs");
            cond = "zcgzgs = " + pdgs;
            String pdbm = rs.getString("pdbm");
            cond = StringUtils.isNotBlank(pdbm)?(cond+" and zcgzbm="+pdbm):cond;
            String grrq = rs.getString("grrq");
            cond = StringUtils.isNotBlank(grrq)?(cond+" and DateDiff(yy,grrq,'"+grrq+"')=0"):cond;
            String zclb = rs.getString("zclb");
            String pdmc = rs.getString("pdmc");
            cond = StringUtils.isNoneBlank(zclb)?(cond+" and zclb in ("+zclb+")"):cond;
            String insqdsql = "insert into uf_gdzcpdqd(zcgzbm, zcgzgs, zp ,fj,cfdz,xgcglc,ipdz,zclb,zcbz,dw,sl,cgr,gysmc,sfbf,sfxmb,syr,xmbh,zcxgbm,zclbid,jkzt,aqsz,bgrj,czxt,qtrj,gdzcmc,gdzcbh,zclbwb,grrq,zt,cgje,zjnx,pp,xh,jyrq,bgr,bgrszbm,bz,xmmc,xmmclzy,zcbfrq,zcbfczr,zcbfczsm,sfypd,sygs,sffy,yzcid,pdjhid,formmodeid,ppxh,pdzt,ybgr,yzcsybm,yzczzgs) " +
                    "(select zcgzbm, zcgzgs, zp ,fj,cfdz,xgcglc,ipdz,zclb,zcbz,dw,sl,cgr,gysmc,sfbf,sfxmb,syr,xmbh,zcxgbm,zclbid,jkzt,aqsz,bgrj,czxt,qtrj,gdzcmc,gdzcbh,zclbwb,grrq,zt,cgje,zjnx,pp,xh,jyrq,bgr,bgrszbm,bz,xmmc,xmmclzy,zcbfrq,zcbfczr,zcbfczsm,sfypd,sygs,sffy,id,"+bid+",253,(ISNULL(pp,'')+'  '+ISNULL(xh,'')+'  '+ISNULL(CAST(zcbz AS NVARCHAR(300)),'')),0,bgr,zcgzbm,zcgzgs from uf_gdzcd where "+cond+")";
            rs.executeSql(insqdsql);
            String newDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
            String insbmsql = "INSERT INTO uf_bmzcpdd (pdjh, pddmc, pdrq, pdbm, pdsl, pdgs, pdry, formmodeid)" +
                    "  (SELECT "+bid+",'"+pdmc+"','"+newDate+"',zcgzbm,count(id),"+pdgs+","+user.getUID()+",251 FROM uf_gdzcpdqd where pdjhid = "+bid+" GROUP BY zcgzbm )";
            rs.executeSql(insbmsql);
            json.put("mess","操作成功");
            json.put("type","3");
            out.clear();
            out.print(json);
        }

    }else if("getbmzcpdd".equals(operation)){
        rs.executeSql("SELECT id FROM uf_bmzcpdd WHERE pdjh="+bid+" and pdbm="+par1);
        if(rs.next()){
            json.put("id",rs.getInt("id"));
        }
        out.clear();
        out.print(json);

    }else if("getgdzcd".equals(operation)){
        rs.executeSql("insert into uf_gdzcd(syqkbz,sybm,zcgzbm,zcgzgs,zp,fj,cfdz,xgcglc,ipdz,zclb,zcbz,dw,sl,cgr,gysmc,sfbf,sfxmb,syr,xmbh,zcxgbm,zclbid,jkzt,aqsz,bgrj,czxt,qtrj,gdzcmc,gdzcbh,zclbwb,grrq,zt,cgje,zjnx,pp,xh,jyrq,bgr,bgrszbm,bz,xmmc,xmmclzy" +
                ",zcbfrq,zcbfczr,zcbfczsm,sfypd,sygs,sffy)" +
                "(SELECT syqkbz,sybm,zcgzbm,zcgzgs,zp,fj,cfdz,xgcglc,ipdz,zclb,zcbz,dw,sl,cgr,gysmc,sfbf,sfxmb,syr,xmbh,zcxgbm,zclbid,jkzt,aqsz,bgrj,czxt,qtrj,gdzcmc,gdzcbh,zclbwb,grrq,zt,cgje,zjnx,pp,xh,jyrq,bgr,bgrszbm,bz,xmmc,xmmclzy" +
                ",zcbfrq,zcbfczr,zcbfczsm,sfypd,sygs,sffy FROM uf_gdzcd WHERE id="+bid+");" +
                "SELECT MAX(id) AS gid FROM uf_gdzcd");
        if(rs.next()){
            json.put("gid",rs.getInt("gid"));
        }
        out.clear();
        out.print(json);
    }





%>