package weaver.formmode.customjavacode.modeexpand;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.baidu.aip.util.Base64Util;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import weaver.conn.RecordSet;
import weaver.file.AESCoder;
import weaver.formmode.customjavacode.AbstractModeExpandJavaCodeNew;
import weaver.formmode.customjavacode.modeexpand.baiduAiAipUtils.ErrorMsgUtils;
import weaver.formmode.customjavacode.modeexpand.baiduAiAipUtils.HttpUtil;
import weaver.formmode.customjavacode.modeexpand.baiduAiAipUtils.PushRobot;
import weaver.formmode.log.FormmodeLog;
import weaver.general.Util;
import weaver.hrm.User;
import weaver.soa.workflow.request.RequestInfo;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.zip.ZipInputStream;

/**
 * 创建 刘港 2022-5-5 发票台账解析发票
 */
public class VerDeleteInvoice extends AbstractModeExpandJavaCodeNew {

    @Override
    public Map<String, String> doModeExpand(Map<String, Object> param) {
        Map<String, String> result = new HashMap<>();
        RecordSet rs = new RecordSet();
        try {
            String billids = (String)param.get("billids");
            rs.executeQuery("select 1 from uf_fptz where zflc is not null and id in ("+billids+")");
            if(rs.next()){
                result.put("errmsg", " 删除发票中包含已发起流程的发票，禁止删除！ ");
                result.put("flag", "false");
            }

        }catch (Exception e){
            new FormmodeLog().error(e);
            result.put("errmsg", e.getMessage());
            result.put("flag", "false");
        }
        return result;

    }


}
