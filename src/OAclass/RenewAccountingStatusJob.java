package OAclass;

import com.engine.kq.log.KQLog;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.interfaces.schedule.BaseCronJob;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class RenewAccountingStatusJob extends BaseCronJob {
    private KQLog kqLog = new KQLog();

    public RenewAccountingStatusJob(){

    }

    @Override
    public void execute() {
        this.kqLog.info("begin do RenewAccountingStatusJob invoke ...");
        SimpleDateFormat sd = new SimpleDateFormat("yyyy-MM-dd");
        RecordSet xmbRec = new RecordSet();
        RecordSet xmbyhsRec = new RecordSet();
        RecordSet xmbUpdate = new RecordSet();
        String xmbsql = "select id,requestId,xmbh,xmmc,htrq,mbcb,formmodeid,modedatacreater,modedatacreatertype,htje," +
                "modedatacreatedate,modedatacreatetime,modedatamodifier,modedatamodifydatetime,MODEUUID,cbhsdfkzljzrq from uf_xmb " +
                "where datediff(day,cbhsdfkzljzrq,getdate()) > 0 and cbhszt = 1";
        xmbRec.execute(xmbsql);

        String xmbyhs = "insert into uf_xmbyhs " +
                "(requestId,xmbh,xmmc,htrq,mbcb,formmodeid,modedatacreater,modedatacreatertype,modedatacreatedate," +
                "modedatacreatetime,modedatamodifier,modedatamodifydatetime,MODEUUID,cjjezj,hsksrq) " +
                "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        String xmbUpdateSql = "update  uf_xmb set cbhszt = ? where id = ?";

        Object[] xmbArr;
        List<Object> xmbyhsList = new ArrayList<>();
        while(xmbRec.next()) {
            xmbArr = new String[2];
            String id = Util.null2String(xmbRec.getString("id"));
            String cbhsdfkzljzrq = Util.null2String(xmbRec.getString("cbhsdfkzljzrq"));
            this.kqLog.info("RenewAccountingStatusJob:id:" + id + ":cbhsdfkzljzrq:" + cbhsdfkzljzrq);
            xmbyhsList.add(Util.null2String(xmbRec.getString("requestId")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("xmbh")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("xmmc")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("htrq")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("mbcb")));
            xmbyhsList.add("206");
            xmbyhsList.add(Util.null2String(xmbRec.getString("modedatacreater")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("modedatacreatertype")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("modedatacreatedate")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("modedatacreatetime")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("modedatamodifier")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("modedatamodifydatetime")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("MODEUUID")));
            xmbyhsList.add(Util.null2String(xmbRec.getString("htje")));
            xmbyhsList.add(sd.format(new Date()));
            Object[] xmbyhsArr = xmbyhsList.toArray(new Object[xmbyhsList.size()]);
            xmbyhsRec.executeUpdate(xmbyhs,xmbyhsArr);

            xmbArr[0] = "2";
            xmbArr[1] = id;
            xmbUpdate.executeUpdate(xmbUpdateSql,xmbArr);
        }

        super.execute();
    }
}
