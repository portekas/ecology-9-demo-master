package weaver.interfaces.workflow.action;

import org.apache.commons.lang3.StringUtils;
import weaver.conn.RecordSet;
import weaver.soa.workflow.request.RequestInfo;

/**
 * @author lg
 * @date 2021-10-11 15:47
 */
public class gzrwd implements Action {
    public gzrwd(){
    }

    @Override
    public String execute(RequestInfo requestInfo) {
        RecordSet rs = new RecordSet();
        String requestid = requestInfo.getRequestid();
        String sql = "select * from formtable_main_137  where  requestId ='" + requestid + "'";
        System.out.println("执行sql1为："+sql);
        rs.execute(sql);
        if (rs.next()) {
            int hlhjy = rs.getInt("hlhjy");
            String sql1 = "update formtable_main_393 set gzrwd = "+requestid+" where requestId = " + hlhjy;
            System.out.println("执行sql2为："+sql1);
            rs.execute(sql1);
        }
        return SUCCESS;
    }
}
