package weaver.formmode.customjavacode.modeexpand;

import weaver.conn.RecordSet;
import weaver.formmode.customjavacode.AbstractModeExpandJavaCodeNew;
import weaver.formmode.log.FormmodeLog;

import java.util.*;

/**
 * 创建 刘港 2022-5-24 发票台账删除时校验是否已发起流程，已发起流程禁止删除
 */
public class VerDeleteInvoice extends AbstractModeExpandJavaCodeNew {

    @Override
    public Map<String, String> doModeExpand(Map<String, Object> param) {
        Map<String, String> result = new HashMap<>();
        RecordSet rs = new RecordSet();
        try {
            String billids = (String)param.get("billids");
            rs.executeQuery("select zflc from uf_fptz where zflc is not null and id in ("+billids+")");
            if(rs.next()){
                rs.executeQuery("select 1 from workflow_requestbase where requestid = '"+rs.getString("zflc")+"'");
                if(rs.next()){
                    result.put("errmsg", " 删除发票中包含已发起流程的发票，禁止删除！ ");
                    result.put("flag", "false");
                }
            }

        }catch (Exception e){
            new FormmodeLog().error(e);
            result.put("errmsg", e.getMessage());
            result.put("flag", "false");
        }
        return result;

    }


}
