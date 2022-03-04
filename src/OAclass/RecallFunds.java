package OAclass;


import org.apache.commons.lang.StringUtils;
import weaver.conn.RecordSet;
import weaver.interfaces.workflow.action.Action;
import weaver.soa.workflow.request.RequestInfo;

/**
 * 创建 刘港 2022-03-04 收付款流程撤回后重新提交，查询已转台账数据，将余额还原
 */
public class RecallFunds implements Action {

    @Override
    public String execute(RequestInfo reqInfo) {
        RecordSet yer = new RecordSet();
        RecordSet rs = new RecordSet();
        rs.executeQuery("select id,yxmc,sr,zc FROM uf_cnzjtz WHERE lcid = ?",new Object[]{reqInfo.getRequestid()});
        while (rs.next()){
            String id = rs.getString("id");
            String yxmc = rs.getString("yxmc");
            String sr = rs.getString("sr");
            String zc = rs.getString("zc");
            if(StringUtils.isBlank(yxmc)){
                continue;
            }
            //收入不为空
            if(StringUtils.isNotBlank(sr)){
                yer.executeQuery("UPDATE uf_yhzhtz SET dqye = dqye - ? WHERE id = ?",new Object[]{sr,yxmc});
            }
            //支出不为空
            if(StringUtils.isNotBlank(zc)){
                yer.executeQuery("UPDATE uf_yhzhtz SET dqye = dqye + ? WHERE id = ?",new Object[]{zc,yxmc});
            }
            //删除这条明细
            yer.executeQuery("delete uf_cnzjtz where id = ?",new Object[]{id});
        }

        return SUCCESS;
    }
}
