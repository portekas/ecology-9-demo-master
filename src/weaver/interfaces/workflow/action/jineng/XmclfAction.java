package weaver.interfaces.workflow.action.jineng;

import weaver.conn.RecordSet;
import weaver.conn.RecordSetTrans;
import weaver.general.Util;
import weaver.interfaces.workflow.action.Action;
import weaver.soa.workflow.request.RequestInfo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * 2021-12-13 刘港
 * 添加判断，只验证材料费、人工费、业务费 的报销金额是否大于剩余可付款金额
 */
public class XmclfAction implements Action {
    @Override
    public String execute(RequestInfo requestInfo) {
        //提交节点
        String[] xkzclkm = {"1","2","4"};////需要控制的科目 1材料费、2人工费、4业务费
        RecordSetTrans recordSetTrans = new RecordSetTrans();
        recordSetTrans.setAutoCommit(false);
        RequestTableInfoToMap requestTableInfoToMap = new RequestTableInfoToMap(requestInfo);
        Map<String, String> mainTable = requestTableInfoToMap.getMainTableMap();
        String xmbh1 = Util.null2String(mainTable.get("xmbh1"));
        String bxje = Util.null2String(mainTable.get("bxje"));
        String fykm = Util.null2String(mainTable.get("fykm"));
        Double bxje0 = Double.parseDouble(bxje);
        String kmkyys0 = Util.null2String(mainTable.get("kmkyys"));
        String clkm = Util.null2String(mainTable.get("fykm"));//需要控制的科目 材料费、人工费、业务费
        if (kmkyys0.isEmpty()) {
            requestInfo.getRequestManager().setMessagecontent("该项目未申请相关科目预算，流程无法提交");
            return FAILURE_AND_CONTINUE;
        } else {
            Double kmkyys = Double.parseDouble(kmkyys0);
            if (Arrays.asList(xkzclkm).contains(clkm) && bxje0 > kmkyys) {
                requestInfo.getRequestManager().setMessagecontent("报销金额不能大于科目可用预算");
                return FAILURE_AND_CONTINUE;
            } else {
                //获取项目台账明细表数据
                RecordSet selectXmbRS = new RecordSet();
                String selectXmbSQL = "select * from uf_xmb_dt1 a inner join uf_xmb b on a.mainid=b.id where b.xmbh='" + xmbh1 + "'";
                String mainid = null;

                if (selectXmbRS.execute(selectXmbSQL) && selectXmbRS.next()) {
                    mainid = Util.null2String(selectXmbRS.getString("mainid"));
                } else {
                    requestInfo.getRequestManager().setMessagecontent("未查找到项目台账数据");

                }

                //回写数据
                String updateXmbSQL = "update uf_xmb_dt1 set djje=isnull(djje,0)+?,sykfkje=isnull(sykfkje,0)-? where mainid=? and kmmc=?";
                try {
                    recordSetTrans.executeUpdate(updateXmbSQL, bxje, bxje, mainid, fykm);
                } catch (Exception e) {
                    recordSetTrans.rollback();
                    recordSetTrans.setAutoCommit(true);
                    requestInfo.getRequestManager().setMessagecontent("没有更新数据");
                    return FAILURE_AND_CONTINUE;
                }

            }
        }
        try {
            recordSetTrans.commit();
            recordSetTrans.setAutoCommit(true);

            return SUCCESS;
        } catch (Exception e) {
            recordSetTrans.rollback();
            recordSetTrans.setAutoCommit(true);
            requestInfo.getRequestManager().setMessagecontent("回写数据至项目台账失败");
            return FAILURE_AND_CONTINUE;
        }
    }
}
