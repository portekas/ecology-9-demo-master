package OAclass;

import com.engine.kq.log.KQLog;
import org.apache.commons.lang3.StringUtils;
import weaver.conn.RecordSet;
import weaver.interfaces.schedule.BaseCronJob;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 定时统计提醒数量
 * @author lg
 * @date 2021-10-25 08:47
 */
public class RemindStatistics extends BaseCronJob {
    private KQLog kqLog = new KQLog();

    public RemindStatistics(){

    }

    @Override
    public void execute() {
        this.kqLog.info("begin do RemindStatistics invoke ...");
        SimpleDateFormat sd = new SimpleDateFormat("yyyy-MM-dd");
        Object[] arr;
        RecordSet rec = new RecordSet();
        RecordSet rec2 = new RecordSet();
        rec.execute("select id,tjsql,txbt from uf_txxgb");
        while (rec.next()){
            int txsl = 0;
            String sql = rec.getString("tjsql");
            //解决参数中可能含有全角的问题
            sql = sql.replaceAll("ｏｒ","or");
            sql = sql.replaceAll("ａｎｄ","and");
            sql = sql.replaceAll("ｉｎ","in");
            sql = sql.replaceAll("ｓｅｌｅｃｔ","select");

            if(StringUtils.isNotBlank(sql)){
                rec2.execute(sql);
                if(rec2.next()){
                    txsl = rec2.getInt("txsl");
                }
            }
            String txbt = rec.getString("txbt");
            txbt = txbt.replace("$txsl$", String.valueOf(txsl));
            int id = rec.getInt("id");
            arr = new Object[3];
            arr[0] = sd.format(new Date());
            arr[1] = txsl;
            arr[2] = txbt;
            rec2.executeUpdate("update uf_txxgb set tjsj = ? , txsl = ? , txxsbt = ? where id = "+id,arr);
        }
        super.execute();
    }
}
