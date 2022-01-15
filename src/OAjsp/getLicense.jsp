<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="rci" class="weaver.hrm.resource.ResourceComInfo" scope="page"/>

<%
    /**
     * 创建 刘港 各种简单处理数据方法合集
     * getXYQZZTZ ：证照门户统计到期数量（废弃）
     * getJSWD : 获取角色文档相关数据
     * getWDXMGZRZMX : 项目经理施工日志 获取项目经理今日填写的工作日志数据
     * getRDPUser ：获取报表用户名密码
     * addZCPD ：生成资产盘点
     * getbmzcpdd ：获取部门资产盘点单数据
     * getgdzcd ：固定资产 数据复制
     * getXMXQ ：项目经理工作日志 获取项目相关数据
     * addColdesc ：更新OA表单字段说明的字段描述列
     * getXMZTCQX ：项目模块，按当前用户的角色获取左侧按钮
     * getXMZJLS ： 项目模块，获取资金的收入、支出金额
     * 新增 刘港 2022-01-14 新增会议交办事项跟进记录提交方法
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    String bid = Util.null2String(request.getParameter("bid"));
    String par1 = Util.null2String(request.getParameter("par1"));
    JSONObject json = new JSONObject();
    List<Object> objArr = new ArrayList<>();
    User user=HrmUserVarify.getUser(request,response);
    RecordSet rs = new RecordSet();
    if("getXYQZZTZ".equals(operation)){
        /**
         * 证照门户统计到期数量（废弃）
         */
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
        /**
         * 获取角色文档相关数据
         */
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
        /**
         * 项目经理施工日志 获取项目经理今日填写的工作日志数据
         */
        String xmid = Util.null2String(request.getParameter("xmid"));
        String newDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        rs.executeSql("select id from uf_xmjlgzrz t1 where xmid = '"+xmid+"' and rzrq = '"+newDate+"' and djr = '"+user.getUID()+"'");
        while(rs.next()){
            json.put("id",rs.getString("id"));
        }
        out.print(json);

    }else if("getRDPUser".equals(operation)){
        /**
         * 获取报表用户名密码
         */
        rs.executeSql("SELECT id,bbzh,bbmm FROM uf_zhdybbqx WHERE ry like '%,"+user.getUID()+",%' or ry like '"+user.getUID()+",%' or ry like '%,"+user.getUID()+"'");
        if(rs.next()){
            json.put("username",rs.getString("bbzh"));
            json.put("password",rs.getString("bbmm"));
        }
        out.clear();
        out.print(json);

    }else if("addZCPD".equals(operation)){
        /**
         * 生成资产盘点
         */
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
        /**
         * 获取部门资产盘点单数据
         */
        rs.executeSql("SELECT id FROM uf_bmzcpdd WHERE pdjh="+bid+" and pdbm="+par1);
        if(rs.next()){
            json.put("id",rs.getInt("id"));
        }
        out.clear();
        out.print(json);

    }else if("getgdzcd".equals(operation)) {
        /**
         * 固定资产 数据复制
         */

        rs.executeSql("insert into uf_gdzcd(syqkbz,sybm,zcgzbm,zcgzgs,zp,fj,cfdz,xgcglc,ipdz,zclb,zcbz,dw,sl,cgr,gysmc,sfbf,sfxmb,syr,xmbh,zcxgbm,zclbid,jkzt,aqsz,bgrj,czxt,qtrj,gdzcmc,zclbwb,grrq" +
                ",zt,cgje,zjnx,pp,xh,jyrq,bgr,bgrszbm,bz,xmmc,xmmclzy,zcbfrq,zcbfczr,zcbfczsm,sfypd,sygs,sffy,formmodeid)" +
                "(SELECT syqkbz,sybm,zcgzbm,zcgzgs,zp,fj,cfdz,xgcglc,ipdz,zclb,zcbz,dw,sl,cgr,gysmc,sfbf,sfxmb,syr,xmbh,zcxgbm,zclbid,jkzt,aqsz,bgrj,czxt,qtrj,gdzcmc,zclbwb,grrq" +
                ",zt,cgje,zjnx,pp,xh,jyrq,bgr,bgrszbm,bz,xmmc,xmmclzy,zcbfrq,zcbfczr,zcbfczsm,sfypd,sygs,sffy,formmodeid FROM uf_gdzcd WHERE id=" + bid + ")");
        rs.executeSql("SELECT MAX(id) AS gid FROM uf_gdzcd where bgr = " + par1);
        if (rs.next()) {
            json.put("gid", rs.getInt("gid"));
        }
        out.clear();
        out.print(json);

    }else if("getXMXQ".equals(operation)) {
        /**
         *
         */

        //月计划
        rs.executeSql("SELECT yjh FROM formtable_main_272_dt1 WHERE xmbh = '" + bid + "' ORDER BY id DESC");
        if (rs.next()) {
            json.put("yjh", rs.getString("yjh"));
        }
        //周计划
        rs.executeSql("SELECT zjh FROM formtable_main_273_dt1 WHERE xmbh = '" + bid + "' ORDER BY id DESC");
        if (rs.next()) {
            json.put("zjh", rs.getString("zjh"));
        }
        //已完成产值
        rs.executeSql("select sum(sbje) as czje from uf_gcxmzchb where xmbh = '" + bid + "'");
        if (rs.next()) {
            json.put("czje", rs.getString("czje"));
        }
        //已完成收款
        rs.executeSql("select sum(hkje) as hkje from uf_xmbhkjl where xmbh = '" + bid + "'");
        if (rs.next()) {
            json.put("hkje", rs.getString("hkje"));
        }
        //回款金额
        rs.executeSql("SELECT htje FROM uf_xmb ux WHERE ux.xmbh = '" + bid + "'");
        if (rs.next()) {
            json.put("htje", rs.getString("htje"));
        }
        out.clear();
        out.print(json);

    }else if("addColdesc".equals(operation)) {
        /**
         * 更新OA表单字段说明的字段描述列
         */

        rs.executeSql("SELECT * FROM uf_OAcoldesc WHERE labelid = '" + bid + "'");
        if (rs.next()) {
            rs.executeSql("UPDATE uf_OAcoldesc SET labeldesc = '" + par1 + "' WHERE labelid = '" + bid + "'");
        } else {
            rs.executeSql("INSERT INTO uf_OAcoldesc (labelid,labeldesc,formmodeid) VALUES('" + bid + "','" + par1 + "','167')");
        }
        out.print(json);

    }else if("getXMZTCQX".equals(operation)) {
        /**
         * 项目模块，按当前用户的角色获取左侧按钮
         */

        //查询角色
        rs.executeSql("SELECT roleid FROM hrmrolemembers WHERE resourceid = '" + user.getUID() + "'");
        StringBuilder roleIds = new StringBuilder();
        while (rs.next()){
            String rid = rs.getString("roleid");
            if(!"".equals(roleIds.toString())){
                roleIds.append(",");
            }
            roleIds.append(rid);
        }
        //查询角色对应按钮
        rs.executeSql("SELECT an FROM uf_xmztcqxpz_dt1 uxd LEFT JOIN uf_xmztcqxpz ux ON  ux.id = uxd.mainid WHERE cast(ux.js as varchar(max)) in("+roleIds.toString()+")");
        StringBuilder ans = new StringBuilder();
        while (rs.next()){
            if(!"".equals(ans.toString())){
                ans.append(",");
            }
            ans.append(rs.getString("an"));
        }
        //查询按钮
        if(!"".equals(ans.toString())){
            rs.executeSql("select anmc,ffm from uf_xmztcanpz where id in ("+ ans.toString() +") order by px");
            while (rs.next()){
                json = new JSONObject();
                json.put("anmc",rs.getString("anmc"));
                json.put("ffm",rs.getString("ffm"));
                objArr.add(json);
            }
        }
        out.clear();
        out.print(objArr);


    }else if("getXMZJLS".equals(operation)) {
        /**
         * 项目模块，获取资金的收入、支出金额
         */

        BigDecimal bd1 = new BigDecimal(0);
        BigDecimal bd2 = new BigDecimal(0);
        BigDecimal bdt;
        //查询支出
        rs.executeSql("SELECT lx,sum(zcje) AS bxje FROM V_xmzjzc vx  WHERE xmbh = '"+bid+"' GROUP BY lx");
        while (rs.next()){
            json = new JSONObject();
            String je = rs.getString("bxje");
            json.put("fl","zcfl"+rs.getString("lx"));
            json.put("lx",rs.getString("lx"));
            json.put("szlx","1");
            json.put("jr",je);
            objArr.add(json);
            //统计支出
            bdt = new BigDecimal(je);
            bd1 = bd1.add(bdt);
        }

        //查询利息
        rs.executeSql("SELECT ISNULL(sum(lx),0) as lx FROM uf_zjcbmx WHERE xmbh = '"+bid+"'");
        json = new JSONObject();
        if(rs.next() && !"0.00".equals(rs.getString("lx"))){
            json.put("fl","zcfl17");
            json.put("jr",rs.getString("lx"));
            json.put("lx",17);
            json.put("szlx","1");
            objArr.add(json);
            //统计支出
            bdt = new BigDecimal(rs.getString("lx"));
            bd1 = bd1.add(bdt);
        }

        //查询保证金
        rs.executeSql("SELECT fkje,ISNULL(bzjhkje,0) AS hkje FROM uf_bzjtz WHERE xmbh = '"+bid+"'");
        json = new JSONObject();
        json.put("fl","zcfl18");
        if(rs.next()){
            //支出
            json.put("jr",rs.getString("fkje"));
            json.put("lx",18);
            json.put("szlx","3");
            objArr.add(json);
            //统计支出
            bdt = new BigDecimal(rs.getString("fkje"));
            bd1 = bd1.add(bdt);

            if(!"0.00".equals(rs.getString("hkje"))){
                //回款
                json = new JSONObject();
                json.put("fl","srfl2");
                json.put("jr",rs.getString("hkje"));
                json.put("lx","2");
                json.put("szlx","4");
                objArr.add(json);
                //统计收入
                bdt = new BigDecimal(rs.getString("hkje"));
                bd2 = bd2.add(bdt);
            }
        }

        //保存支出
        json = new JSONObject();
        json.put("fl","zzc");
        json.put("jr",bd1.doubleValue());
        objArr.add(json);

        rs.executeSql("SELECT lx,sum(srje) AS srje FROM V_xmzjsr WHERE xmbh = '"+bid+"' GROUP BY lx");
        while (rs.next()){
            json = new JSONObject();
            json.put("fl","srfl"+rs.getString("lx"));
            json.put("jr",rs.getString("srje"));
            json.put("lx",rs.getString("lx"));
            json.put("szlx","0");
            objArr.add(json);
            //统计收入
            bdt = new BigDecimal(rs.getString("srje"));
            bd2 = bd2.add(bdt);
        }

        //保存收入
        json = new JSONObject();
        json.put("fl","zsr");
        json.put("jr",bd2.doubleValue());
        objArr.add(json);
        //余额
        json = new JSONObject();
        json.put("fl","zye");
        json.put("jr",bd2.subtract(bd1).doubleValue());
        objArr.add(json);

        out.clear();
        out.print(objArr);

    }else if("addHYJBSXGJ".equals(operation)) {
        //添加会议交办事项跟进记录

        String fmdid = Util.null2String(request.getParameter("fmdid"));//事项ID
        String gjjl = Util.null2String(request.getParameter("gjjl"));//跟进内容
        String sxzt = Util.null2String(request.getParameter("sxzt"));//事项状态
        //登记人、所属部门、所属公司、跟进记录、事项状态、事项ID、跟进时间
        StringBuilder sb = new StringBuilder();
        sb.append(user.getUID());
        sb.append(",");
        sb.append(user.getUserDepartment());
        sb.append(",");
        sb.append(user.getUserSubCompany1());
        sb.append(",");
        sb.append("'");
        sb.append(gjjl);
        sb.append("'");
        sb.append(",");
        sb.append(sxzt);
        sb.append(",");
        sb.append(fmdid);
        sb.append(",");
        sb.append("'");
        sb.append(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        sb.append("'");

        rs.executeSql("INSERT INTO uf_hyjbsxgjjl (djr,szbm,szgs,gjjl,sxzt,sxid,gjsj,formmodeid) " +
                "VALUES(" + sb.toString() + ",278)");
        out.print(json);
    }

%>