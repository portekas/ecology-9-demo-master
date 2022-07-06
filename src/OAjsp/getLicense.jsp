<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.lang.*"%>
<%@page import="weaver.general.*,weaver.interfaces.*,weaver.conn.*,weaver.interfaces.workflow.browser.*" %>
<%@page import="weaver.hrm.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="weaver.interfaces.datasource.DataSource" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Connection" %>
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
     * 修改 刘港 2022-02-16 修改 getXMZTCQX 添加 项目直通车按钮权限 查询当前用户在当前项目中的岗位，添加查询当前用户角色、当前用户岗位对应按钮
     * 新增 刘港 2022-03-14 新增 getZTCZA 获取直通车质安抽查、质安处罚、采购、人工费、结算单（人工费）统计数据
     * 修改 刘港 2022-03-16 修改 getZTCZA 添加劳务费用结算评审流程统计，工程-结算单(人工费)流程统计
     * 新增 刘港 2022-3-31 新增 getYSCLQDFH 添加预算清单材料复核功能，调用存储过程XDOA_gcysqdsysljd
     * 新增 刘港 2022-04-08 新增 getSyncYYLedger CRM供应商页面按钮调用 同步用友供应商帐套，调用存储过程sp_insertbase
     * 新增 刘港 2022-04-19 新增 getHTGLCGDD 合同关联采购订单，用于采购合同智能关联订单查询，手动选择关联订单操作
     * 新增 刘港 2022-04-19 新增 getHTGLCGDDPL 合同关联采购订单，用于采购合同智能关联订单查询，勾选自动关联订单操作
     * 新增 刘港 2022-05-12 新增 getFPFQFKLC 发票台账发起付款流程时 匹配是否存在供应商和客商
     * 新增 刘港 2022-05-19 新增 addGYSKS 新增供应商和客商
     */
    response.setHeader("cache-control", "no-cache");
    response.setHeader("pragma", "no-cache");
    response.setHeader("expires", "Mon 1 Jan 1990 00:00:00 GMT");
    String operation = Util.null2String(request.getParameter("operation"));
    String bid = Util.null2String(request.getParameter("bid"));
    String par1 = Util.null2String(request.getParameter("par1"));
    String par2 = Util.null2String(request.getParameter("par2"));
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
         * 项目模块，按当前用户的角色、项目组成员岗位获取左侧按钮
         */

        //查询当前用户在当前项目中的岗位
        String gw = "null";
        rs.executeSql("SELECT gw FROM uf_xmzcy WHERE xm = '" + user.getUID() + "' AND xmbh = '"+bid+"'");
        if (rs.next()){
            gw = rs.getString("gw");
        }

        //查询当前用户所有的角色
        rs.executeSql("SELECT roleid FROM hrmrolemembers WHERE resourceid = '" + user.getUID() + "'");
        StringBuilder roleIds = new StringBuilder();
        while (rs.next()){
            String rid = rs.getString("roleid");
            roleIds.append(" OR ");
            roleIds.append("',' + CONVERT(VARCHAR(MAX), jsqx) + ',' LIKE '%,");
            roleIds.append(rid);
            roleIds.append(",%' ESCAPE '/'");
        }

        //查询角色或项目成员岗位对应按钮
        rs.executeSql("SELECT an FROM uf_xmztcqxpz WHERE ',' + CONVERT(VARCHAR(MAX), xmcygwqx) + ',' LIKE '%,"+ gw +",%' ESCAPE '/' " +
                "OR ',' + CONVERT(VARCHAR(MAX), bmqx) + ',' LIKE '%,"+user.getUserDepartment()+",%' ESCAPE '/'" +
                "OR ',' + CONVERT(VARCHAR(MAX), ryqx) + ',' LIKE '%,"+user.getUID()+",%' ESCAPE '/'" +
                "OR sfgk = '0'" +
                roleIds.toString());
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
        //添加交办事项跟进记录

        String fmdid = Util.null2String(request.getParameter("fmdid"));//事项ID
        String gjjl = Util.null2String(request.getParameter("gjjl"));//跟进内容
        String sxzt = Util.null2String(request.getParameter("sxzt"));//事项状态
        String gjlx = Util.null2String(request.getParameter("gjlx"));//跟进类型
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
        sb.append(",");
        sb.append(gjlx);

        rs.executeSql("INSERT INTO uf_hyjbsxgjjl (djr,szbm,szgs,gjjl,sxzt,sxid,gjsj,gjlx,formmodeid) " +
                "VALUES(" + sb.toString() + ",278)");
        out.print(json);

    }else if("getZTCZA".equals(operation)) {
        //获取直通车质安抽查、质安处罚、采购、人工费、结算单（人工费）统计数据
        //抽查
        rs.executeQuery("SELECT COUNT(id) AS zs, SUM(CASE jcjg WHEN 1 THEN 1 ELSE 0 END) AS xzg, SUM(CASE fhjg WHEN 0 THEN 1 ELSE 0 END) AS wc," +
                "  SUM(CASE fhjg WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 0 END) AS wwc FROM formtable_main_129 where xmbh1 = ?",new Object[]{bid});
        if (rs.next()){
            json.put("cczs",rs.getString("zs"));
            json.put("ccxzg",rs.getString("xzg"));
            json.put("ccwc",rs.getString("wc"));
            json.put("ccwwc",rs.getString("wwc"));
        }
        //处罚
        rs.executeQuery("SELECT SUM(a.rs) AS rs,SUM(a.je) AS je,SUM(a.rs2) AS rs2,SUM(a.je2) AS je2 FROM (" +
                "  SELECT  (SELECT COUNT(fmd1.xm) FROM formtable_main_76_dt1 fmd1 WHERE fmd1.mainid = fm.id ) AS rs," +
                "  ISNULL((SELECT SUM(fmd1.cfje) FROM formtable_main_76_dt1 fmd1 WHERE fmd1.mainid = fm.id ),0) AS je," +
                "  (SELECT COUNT(fmd2.sgd) FROM formtable_main_76_dt2 fmd2 WHERE fmd2.mainid = fm.id ) AS rs2," +
                "  ISNULL((SELECT SUM(fmd2.cfje) FROM formtable_main_76_dt2 fmd2 WHERE fmd2.mainid = fm.id ),0) AS je2" +
                "  FROM formtable_main_76 fm WHERE fm.clwc = 0 AND fm.xmbh = '"+bid+"' )a");
        if(rs.next()){
            int rs1 = StringUtils.isNoneBlank(rs.getString("rs"))?rs.getInt("rs"):0;
            int rs2 = StringUtils.isNoneBlank(rs.getString("rs2"))?rs.getInt("rs2"):0;
            Double je1 = StringUtils.isNoneBlank(rs.getString("je"))?rs.getDouble("je"):0;
            Double je2 = StringUtils.isNoneBlank(rs.getString("je2"))?rs.getDouble("je2"):0;
            json.put("cfrc",rs1+rs2);
            json.put("cfje",je1+je2);
        }

        //采购
        rs.executeQuery("SELECT COUNT(id) AS fs,SUM(htjey) AS je FROM V_ht_cght WHERE (htlx != '3' OR htlx IS NULL) AND xmbh = '"+bid+"' ");
        json.put("cghts",0);
        json.put("cgzje",0);
        if(rs.next()){
            json.put("cghts",rs.getInt("fs"));
            json.put("cgzje",StringUtils.isNoneBlank(rs.getString("je"))?rs.getDouble("je"):0);
        }

        //人工费
        rs.executeQuery("SELECT COUNT(id) AS zs,SUM(htjey) AS je FROM V_ht_cght WHERE htlx = 3 AND xmbh = '"+bid+"'");
        json.put("rgfght",0);
        json.put("rgfje",0);
        if(rs.next()){
            json.put("rgfght",rs.getInt("zs"));
            json.put("rgfje",StringUtils.isNoneBlank(rs.getString("je"))?rs.getDouble("je"):0);
        }

        //结算单（人工费）
        rs.executeQuery("SELECT COUNT(id) AS zs FROM formtable_main_515 WHERE xmbh = '"+bid+"'");
        json.put("zsdsl",0);
        if(rs.next()){
            json.put("zsdsl",rs.getInt("zs"));
        }

        //劳务费用结算评审流程数量统计
        rs.executeQuery("SELECT COUNT(*) AS sl,SUM(sdjey) AS je FROM formtable_main_80  WHERE xmbh = '"+bid+"'");
        if(rs.next()){
            json.put("lwfylcsl",rs.getString("sl"));
            json.put("lwfysdje",StringUtils.isNoneBlank(rs.getString("je"))?rs.getDouble("je"):0);
        }

        //工程-结算单(人工费)数量统计
        rs.executeQuery("SELECT COUNT(*) AS sl,SUM(sdje) AS je FROM formtable_main_515 WHERE xmbh = '"+bid+"'");
        if(rs.next()){
            json.put("gcjslcsl",rs.getInt("sl"));
            json.put("gcjssdje",StringUtils.isNoneBlank(rs.getString("je"))?rs.getDouble("je"):0);
        }
        out.print(json);

    }else if("getYSCLQDFH".equals(operation)) {
        //预算清单复核
        rs.executeQuery("EXEC XDOA_gcysqdsysljd");
        out.print(json);

    }else if("getSyncYYLedger".equals(operation)) {
        //同步用友供应商帐套
        String[] ids = bid.split(",");
        String exgys = "";
        for(String id : ids){
            rs.executeQuery("SELECT gysmc,gysbh,glgs FROM uf_crmgys where id = " + id);
            if (rs.next()) {
                String gysbh = rs.getString("gysbh");
                String gysmc = rs.getString("gysmc");
                String glgs = rs.getString("glgs");
                rs.executeQuery("SELECT 1 FROM uf_OAU8DY WHERE oadm = '" + gysbh + "'");
                if (!rs.next()) {
                    DataSource ds = (DataSource) StaticObj.getServiceByFullname(("datasource.U8_GC"), DataSource.class);
                    Connection conn = ds.getConnection();
                    PreparedStatement psm = conn.prepareStatement("EXEC sp_insertbase ?,?,?,?");
                    psm.setString(1, gysbh);
                    psm.setString(2, gysmc);
                    psm.setString(3, glgs);
                    psm.setString(4, "供应商");
                    psm.execute();
                    try {
                        psm.close();
                        conn.close();
                    } catch (SQLException s) {
                        s.printStackTrace();
                    }
                }else{
                    if(StringUtils.isNotBlank(exgys)){
                        exgys += ",";
                    }
                    exgys += gysmc;
                }
            }
        }
        if(StringUtils.isNotBlank(exgys)){
            json.put("msg","对应表中已存在 "+exgys+" 供应商");
        }
        out.print(json);

    }else if("getRKDZT".equals(operation)){
        //获取入库单账套金额
        String ztje100 = "0";
        String ztje110 = "0";
        String ztje114 = "0";
        rs.execute("select SUM(iprice) as je from V_u8cgrkdmx100 WHERE crmgys = '"+bid+"'");
        if(rs.next()){
            ztje100 = StringUtils.isNoneBlank(rs.getString("je"))?rs.getString("je"):"0";
        }
        rs.execute("select SUM(iprice) as je from V_u8cgrkdmx110 WHERE crmgys = '"+bid+"'");
        if(rs.next()){
            ztje110 = StringUtils.isNoneBlank(rs.getString("je"))?rs.getString("je"):"0";
        }
        rs.execute("select SUM(iprice) as je from V_u8cgrkdmx114 WHERE crmgys = '"+bid+"'");
        if(rs.next()){
            ztje114 = StringUtils.isNoneBlank(rs.getString("je"))?rs.getString("je"):"0";
        }
        json.put("ztje100",ztje100);
        json.put("ztje110",ztje110);
        json.put("ztje114",ztje114);
        out.print(json);

    }else if("getHTGLCGDD".equals(operation)){
        //合同管理采购订单
        //合同ID或订单ID为空直接返回
        if(StringUtils.isBlank(par1) || StringUtils.isBlank(bid)){
            return;
        }

        String[] ddids = par1.split(",");
        for(String ddid : ddids){
            rs.executeUpdate("INSERT INTO uf_cghtglcgdd (htmc,ddbh,szzt) VALUES (?,?,?)"
                    ,new Object[]{bid,ddid,par2});
        }

        rs.executeUpdate("update uf_htylb set ddbh = ? where id = ?",new Object[]{par1,bid});
        out.print(json);

    }else if("getHTGLCGDDPL".equals(operation)) {
        //合同管理采购订单-批量操作
        RecordSet rs2 = new RecordSet();
        //合同ID为空直接返回
        if (StringUtils.isBlank(bid)) {
            return;
        }
        for (String id : bid.split(",")) {
            rs.execute("select ddbh from " + par1 + " where id = " + id);
            if (rs.next()) {
                String ddbh = rs.getString("ddbh");
                for (String ddid : ddbh.split(",")) {
                    rs2.executeUpdate("INSERT INTO uf_cghtglcgdd (htmc,ddbh,szzt) VALUES (?,?,?)"
                            , new Object[]{id, ddid, par2});
                }
                rs2.executeUpdate("update uf_htylb set ddbh = ? where id = ?", new Object[]{ddbh, id});
            }
        }

        out.print(json);

    }else if("getFPFQFKLC".equals(operation)){
        /**
         * 发票台账发起付款流程时 匹配是否存在供应商和客商
         * bid：发票台账ID；
         * par1：发起流程类型：xmfk 项目付款 bmfk：部门付款
         */
        StringBuilder fp = new StringBuilder();
        String xsf = "";//销售方
        String nsrsbh = "";//税号
        String dzdh = "";//地址及电话
        String dz = "";
        String dh = "";
        String khhzh = "";//开户行及账号
        String khh = "";
        String zh = "";
        String gysksbh = "";
        rs.executeQuery("select gysksbh,SellerName,SellerRegisterNum,SellerAddress,SellerBank from uf_fptz where id in ("+bid+")");
        if (rs.next()){
            xsf = rs.getString("SellerName");
            nsrsbh = rs.getString("SellerRegisterNum");
            dzdh = rs.getString("SellerAddress");
            khhzh = rs.getString("SellerBank");
            gysksbh = rs.getString("gysksbh");
        }
        if(StringUtils.isNotBlank(nsrsbh)){
            //拆分开户行及账号
            char[] xsfch = khhzh.toCharArray();
            for(int i = xsfch.length-1; i>=0; i--){
                if(xsfch[i] < '0' ||  xsfch[i] > '9'){
                    khh = khhzh.substring(0,i+1);
                    zh = khhzh.substring(i+1);
                    break;
                }
            }
            //拆分地址及电话
            char[] dzdhch = dzdh.toCharArray();
            for(int i = dzdhch.length-1; i>=0; i--){
                if((dzdhch[i] < '0' ||  dzdhch[i] > '9') && dzdhch[i] != '-') {
                    dz = dzdh.substring(0,i+1);
                    dh = dzdh.substring(i+1);
                    break;
                }
            }

            if("xmfk".equals(par1)){
                //项目付款取供应商
                rs.executeQuery("select id,gysbh,gysmc from uf_crmgys where sh = '"+nsrsbh+"' or gysmc = '"+xsf+"'");
                if(rs.next()){
                    //供应商存在
                    String gysbh = rs.getString("gysbh");
                    json.put("gysbh",gysbh);
                    json.put("gysmc",rs.getString("gysmc"));
                    rs.executeQuery("SELECT 1 FROM uf_crmgys_dt1 WHERE khx = '"+khh+"' and mainid = "+rs.getString("id"));
                    if(rs.next()){
                        json.put("khh",khh);
                    }
                    if(StringUtils.isNotBlank(gysksbh)){
                        //绑定发票供应商
                        rs.executeUpdate("update uf_fptz set gysksbh = '"+gysbh+"' where id in ("+bid+")");
                    }
                }else{
                    //没有匹配到供应商则返回识别供应商名称做人工匹配
                    json.put("gysmc",xsf);
                }
            }else if("bmfk".equals(par1)){
                //部门付款取客商
                rs.executeQuery("select id,khbh,khmc from uf_crmkhb where sh = '"+nsrsbh+"' or khmc = '"+xsf+"'");
                if(rs.next()){
                    //客户存在
                    String khbh = rs.getString("khbh");
                    json.put("khbh",khbh);
                    json.put("khmc",rs.getString("khmc"));
                    rs.executeQuery("SELECT 1 FROM uf_crmkhb_dt1 WHERE khx = '"+khh+"' and mainid = "+rs.getString("id"));
                    if(rs.next()){
                        json.put("khh",khh);
                    }
                    //绑定发票客商
                    rs.executeUpdate("update uf_fptz set gysksbh = '"+khbh+"' where id in ("+bid+")");
                }else{
                    //没有匹配到供应商则返回识别供应商名称做人工匹配
                    json.put("khmc",xsf);
                }
            }
        }
        out.print(json);

    }else if("addGYSKS".equals(operation)){
        //供应商不存在的情况 添加供应商
        StringBuilder fp = new StringBuilder();
        String xsf = "";//销售方
        String nsrsbh = "";//税号
        String dzdh = "";//地址及电话
        String dz = "";
        String dh = "";
        String khhzh = "";//开户行及账号
        String khh = "";
        String zh = "";
        rs.executeQuery("select SellerName,SellerRegisterNum,SellerAddress,SellerBank from uf_fptz where id in ("+bid+")");
        if (rs.next()){
            xsf = rs.getString("SellerName");
            nsrsbh = rs.getString("SellerRegisterNum");
            dzdh = rs.getString("SellerAddress");
            khhzh = rs.getString("SellerBank");
        }

        if(StringUtils.isNotBlank(nsrsbh)) {
            //拆分开户行及账号
            char[] xsfch = khhzh.toCharArray();
            for (int i = xsfch.length - 1; i >= 0; i--) {
                if (xsfch[i] < '0' || xsfch[i] > '9') {
                    khh = khhzh.substring(0, i + 1);
                    zh = khhzh.substring(i + 1);
                    break;
                }
            }
            //拆分地址及电话
            char[] dzdhch = dzdh.toCharArray();
            for (int i = dzdhch.length - 1; i >= 0; i--) {
                if ((dzdhch[i] < '0' || dzdhch[i] > '9') && dzdhch[i] != '-') {
                    dz = dzdh.substring(0, i + 1);
                    dh = dzdh.substring(i + 1);
                    break;
                }
            }

            if ("xmfk".equals(par1)) {
                //供应商不存在则新增
                String newCode = "";
                rs.executeQuery("SELECT currentCode,currentnumber FROM modecode WHERE id = '15'");
                if (rs.next()) {
                    String currentnumber = rs.getString("currentnumber");

                    String newTime = new SimpleDateFormat("yyyyMMdd").format(new Date());
                    String code = "CGZ" + newTime;

                    String newNumber = String.format("%04d", Integer.valueOf(currentnumber) + 1);
                    newCode = code + newNumber;
                    rs.executeUpdate("update modecode set  currentnumber = ? WHERE id = '15'",
                            new Object[]{newNumber});
                }

                //数据插入供应商表
                rs.executeUpdate("INSERT INTO  uf_crmgys (khlb,gysmc,sh,khdz,dh,khx,zh,formmodeid,modedatacreater,modedatacreatedate,modedatacreatetime,gysbh,djr,djrq) " +
                        "VALUES(0,'" + xsf + "','" + nsrsbh + "','" + dz + "','" + dh + "','" + khh + "','" + zh + "',93," + user.getUID()
                        + ",'" + new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + "'"
                        + ",'" + new SimpleDateFormat("HH:mm:ss").format(new Date()) + "'"
                        + ",'" + newCode + "'"
                        + "," + user.getUID()
                        + ",'" + new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + "')");
                json.put("gysbh", newCode);
                json.put("gysmc", xsf);

            } else if ("bmfk".equals(par1)) {
                //客户不存在则新增
                String newCode = "";
                rs.executeQuery("SELECT currentCode,currentnumber FROM modecode WHERE id = '14'");
                if (rs.next()) {
                    String currentnumber = rs.getString("currentnumber");
                    String newTime = new SimpleDateFormat("yyyyMMdd").format(new Date());
                    String code = "CKZ" + newTime;

                    //当天更新过编号，编号+1
                    String newNumber = String.format("%04d", Integer.valueOf(currentnumber) + 1);
                    newCode = code + newNumber;
                    rs.executeUpdate("update modecode set currentnumber = ? WHERE id = '14'",
                            new Object[]{newNumber});
                }

                //数据插入客户表
                rs.executeUpdate("INSERT INTO  uf_crmkhb (khlb,khmc,sh,khdz,dh,khx,zh,formmodeid,modedatacreater,modedatacreatedate,modedatacreatetime,khbh,djr,djrq) " +
                        "VALUES(0,'" + xsf + "','" + nsrsbh + "','" + dz + "','" + dh + "','" + khh + "','" + zh + "',72," + user.getUID()
                        + ",'" + new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + "'"
                        + ",'" + new SimpleDateFormat("HH:mm:ss").format(new Date()) + "'"
                        + ",'" + newCode + "'"
                        + "," + user.getUID()
                        + ",'" + new SimpleDateFormat("yyyy-MM-dd").format(new Date()) + "')");
                json.put("khbh", newCode);
                json.put("khmc", xsf);
            }
        }
        out.print(json);

    }else if("bindGYSKS".equals(operation)) {
        //供应商、客商台账绑定发票
        if ("xmfk".equals(par1)) {
            rs.executeSql("update uf_fptz set SellerName = uc.gysmc FROM  uf_crmgys uc WHERE uc.id = '" + par2 + "' AND uf_fptz.id IN (" + bid + ")");

        } else if ("bmfk".equals(par1)) {
            rs.executeSql("update uf_fptz set SellerName = khmc FROM  uf_crmkhb uc WHERE uc.id = '" + par2 + "' AND uf_fptz.id IN (" + bid + ")");
        }
        out.print(json);

    }else if("getwjyyzllx".equals(operation)) {
        rs.executeQuery("select 1 from uf_yysqgzzlflpz where zllx = " + par1 + " AND ((',' + CONVERT(VARCHAR(MAX), dygw) + ',' LIKE '%," + par2 + ",%' ESCAPE '/') or dygw is null) ");
        if (rs.next()) {
            json.put("ishave", "true");
        }
        out.print(json);

    }

%>