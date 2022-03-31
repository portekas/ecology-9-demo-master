// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Xmsgfk2Action.java

package weaver.interfaces.workflow.action.jineng;

import java.io.PrintStream;
import java.util.*;
import weaver.conn.RecordSet;
import weaver.conn.RecordSetTrans;
import weaver.general.Util;
import weaver.interfaces.workflow.action.Action;
import weaver.interfaces.workflow.action.jineng.RequestTableInfoToMap;
import weaver.soa.workflow.request.RequestInfo;
import weaver.workflow.request.RequestManager;

// Referenced classes of package weaver.interfaces.workflow.action.jineng:
//            RequestTableInfoToMap

/**
 * 2021-12-13 刘港
 * 添加判断，只验证材料费、人工费、业务费 的报销金额是否大于剩余可付款金额
 */
public class Xmsgfk2Action2 implements Action
{

    public Xmsgfk2Action2()
    {
    }

    public String execute(RequestInfo requestInfo)
    {
        System.out.println("\u9879\u76EE\u65BD\u5DE5\u4ED8\u6B3E\u6D41\u7A0B2\u63D0\u4EA4\u5F00\u59CB\uFF1A");
        String[] xkzclkm = {"1","2","4"};////需要控制的科目 1材料费、2人工费、4业务费
        RecordSetTrans recordSetTrans = new RecordSetTrans();
        recordSetTrans.setAutoCommit(false);
        RequestTableInfoToMap requestTableInfoToMap = new RequestTableInfoToMap(requestInfo);
        Map <String, String>mainTable = requestTableInfoToMap.getMainTableMap();
        ArrayList <HashMap<String, String>>detailTables = requestTableInfoToMap.getDetailTableMaps(0);
        Iterator var6 = detailTables.iterator();
        do
        {
            if(!var6.hasNext())
                break;
            HashMap<String, String>  detailTable = (HashMap)var6.next();
            String mxid = Util.null2String((String)detailTable.get("mxid"));
            System.out.println((new StringBuilder()).append("mxid:").append(mxid).toString());
            String xmbhwb = Util.null2String((String)detailTable.get("xmbhwb"));
            System.out.println((new StringBuilder()).append("xmbhwb:").append(xmbhwb).toString());
            String sqje0 = Util.null2String((String)detailTable.get("sqje"));
            Double sqje = Double.valueOf(Double.parseDouble(sqje0));
            System.out.println((new StringBuilder()).append("sqje:").append(sqje).toString());
            String sykfkje0 = Util.null2String((String)detailTable.get("sykfkje"));
            System.out.println((new StringBuilder()).append("sykfkje0:").append(sykfkje0).toString());
            String kmmc0 = Util.null2String((String)detailTable.get("kmmc"));
            System.out.println((new StringBuilder()).append("kmmc0:").append(kmmc0).toString());
            String sfqyyskz0 = Util.null2String((String)detailTable.get("sfqyyskz"));
            System.out.println((new StringBuilder()).append("sfqyyskz0:").append(sfqyyskz0).toString());

            //是否启用预算控制 选否 直接提交
            if("1".equals(sykfkje0)){
                //直接提交不做控制
                return "1";
            }

//            if(sykfkje0.isEmpty() && !kmmc0.equals("15") && !sfqyyskz0.equals("1"))
            if(sykfkje0.isEmpty() && Arrays.asList(xkzclkm).contains(kmmc0)){
                requestInfo.getRequestManager().setMessagecontent("剩余可付款金额不能为空，流程无法提交");
                return "0";
            }
            try {
                Double sykfkje = Double.valueOf(Double.parseDouble(sykfkje0));

                System.out.println((new StringBuilder()).append("sykfkje:").append(sykfkje).toString());

                if(sqje.doubleValue() > sykfkje.doubleValue() && Arrays.asList(xkzclkm).contains(kmmc0))
//                if(sqje.doubleValue() > sykfkje.doubleValue() && !kmmc0.equals("15") && !sfqyyskz0.equals("1"))
                {
                    requestInfo.getRequestManager().setMessagecontent("申请金额不能大于剩余可付款金额,流程无法提交");
                    return "0";
                }
            }
            catch(Exception e)
            {
//                if(!kmmc0.equals("15") && !sfqyyskz0.equals("1")){
//                    requestInfo.getRequestManager().setMessagecontent("剩余可付款金额不能为空，流程无法提交");
                    //直接提交不做控制
                    return "1";
//                }else {
//                    System.out.println("因为科目名称为15，履约保证金"+kmmc0);
//                    System.out.println("该项目不需要启用预算控制"+sfqyyskz0);
//                }

            }
            if(mxid.isEmpty() && !kmmc0.equals("15") && !sfqyyskz0.equals("1"))
            {
                requestInfo.getRequestManager().setMessagecontent("\u660E\u7EC6id\u4E0D\u80FD\u4E3A\u7A7A\uFF0C\u6D41\u7A0B\u65E0\u6CD5\u63D0\u4EA4");
                return "0";
            }
            RecordSet selectXmbRS = new RecordSet();
            String selectXmbSQL = (new StringBuilder()).append("select * from uf_xmb_dt1 a inner join uf_xmb b on a.mainid=b.id where b.xmbh='").append(xmbhwb).append("'").toString();
            String mainid = null;
            if(selectXmbRS.execute(selectXmbSQL) && selectXmbRS.next() && !kmmc0.equals("15") && !sfqyyskz0.equals("1"))
            {
                mainid = Util.null2String(selectXmbRS.getString("mainid"));
                System.out.println((new StringBuilder()).append("mainid:").append(mainid).toString());
            } else
            {
                requestInfo.getRequestManager().setMessagecontent("\u672A\u67E5\u627E\u5230\u9879\u76EE\u53F0\u8D26\u6570\u636E");
            }
            String updateXmbSQL = "update uf_xmb_dt1 set djje=isnull(djje,0)+?,sykfkje=isnull(sykfkje,0)-? where mainid=? and mxid=?";
            System.out.println((new StringBuilder()).append("updateXmbSQL:").append(updateXmbSQL).toString());
            try
            {
                recordSetTrans.executeUpdate(updateXmbSQL, new Object[] {
                    sqje0, sqje0, mainid, mxid
                });
                System.out.println((new StringBuilder()).append("updateXmbSQL1:").append(updateXmbSQL).toString());
            }
            catch(Exception e)
            {
                recordSetTrans.rollback();
                recordSetTrans.setAutoCommit(true);
                requestInfo.getRequestManager().setMessagecontent("\u6CA1\u6709\u66F4\u65B0\u6570\u636E");
                return "0";
            }
        } while(true);
        try
        {
            recordSetTrans.commit();
            recordSetTrans.setAutoCommit(true);
            return "1";
        }
        catch(Exception e)
        {
            recordSetTrans.rollback();
        }
        recordSetTrans.setAutoCommit(true);
        requestInfo.getRequestManager().setMessagecontent("\u56DE\u5199\u6570\u636E\u81F3\u9879\u76EE\u53F0\u8D26\u5931\u8D25");
        return "0";
    }
}
