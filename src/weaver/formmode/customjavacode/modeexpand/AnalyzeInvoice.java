package weaver.formmode.customjavacode.modeexpand;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import weaver.formmode.customjavacode.modeexpand.aliyunApiUtils.RecognitionInvoiceAliApi;
import weaver.formmode.customjavacode.modeexpand.baiduAiApiUtils.ErrorMsgUtils;
import weaver.formmode.customjavacode.modeexpand.baiduAiApiUtils.HttpUtil;
import com.baidu.aip.util.Base64Util;
import weaver.conn.RecordSet;
import weaver.file.AESCoder;
import weaver.formmode.customjavacode.AbstractModeExpandJavaCodeNew;
import weaver.formmode.customjavacode.modeexpand.baiduAiApiUtils.PushRobot;
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
public class AnalyzeInvoice extends AbstractModeExpandJavaCodeNew {
    private Log log = LogFactory.getLog(this.getClass().getName());
    static String Auth = null;

    @Override
    public Map<String, String> doModeExpand(Map<String, Object> param) {
        Map<String, String> result = new HashMap<>();
        RecordSet rs = new RecordSet();
        User user = (User) param.get("user");
        StringBuffer cffp = new StringBuffer();//记录已上传发票号码
        int billid = -1;//数据id
        try {
            RequestInfo requestInfo = (RequestInfo) param.get("RequestInfo");
            billid = Util.getIntValue(requestInfo.getRequestid());
            //查询发票录入数据
            String zzsfp = "";
            String ptfp = "";
            rs.executeQuery("SELECT zzsfp,ptfp FROM uf_fplr WHERE id = ?", new Object[]{billid});
            if (rs.next()) {
                zzsfp = rs.getString("zzsfp");
                ptfp = rs.getString("ptfp");
            }
            //主表字段
            List<String> fileids = new ArrayList<>();
            rs.executeQuery("SELECT fieldname  FROM workflow_billfield WHERE billid = '-678' AND viewtype = '0'");
            while (rs.next()) {
                fileids.add(rs.getString("fieldname"));
            }
            //明细表字段
            List<String> fileids_det = new ArrayList<>();
            rs.executeQuery("SELECT fieldname  FROM workflow_billfield WHERE billid = '-678' AND viewtype = '1'");
            while (rs.next()) {
                fileids_det.add(rs.getString("fieldname"));
            }

            //增值税发票，插入台账
            if (StringUtils.isNotBlank(zzsfp)) {
                String url = "https://aip.baidubce.com/rest/2.0/ocr/v1/vat_invoice";
                //遍历多个附件
                for (String zzs : zzsfp.split(",")) {
                    JSONObject jsonobj = recognitionInvoiceBaiduApi(url, zzs ,user);

                    rs.executeQuery("select 1 from uf_fptz where InvoiceNum = '"+jsonobj.get("InvoiceNum")+"'");
                    if (!rs.next()){
                        //将数据插入表中
                        addInvoiceData(fileids,jsonobj,zzs,user.getUID());

                        //获取解析后的数据_遍历明细字段 并插入明细表
                        addInvoiceDetailDataZZS(fileids_det,jsonobj,zzs);
                    }else{
                        if(cffp.length()>0){
                            cffp.append(",");
                        }
                        cffp.append(jsonobj.get("InvoiceNum"));
                    }

                }

            }

            //其他普通发票
            if (StringUtils.isNotBlank(ptfp)) {
                for (String pt : ptfp.split(",")) {
                    JSONObject jsonobj = recognitionInvoiceAliApi(pt,user);

                    rs.executeQuery("select 1 from uf_fptz where InvoiceNum = '"+jsonobj.get("InvoiceNum")+"'");
                    if (!rs.next()){
                        //将数据插入表中
                        addInvoiceData(fileids,jsonobj,pt,user.getUID());

                        //获取解析后的数据_遍历明细字段 并插入明细表
                        addInvoiceDetailDataPT(fileids_det,jsonobj,pt);
                    }else{
                        if(cffp.length()>0){
                            cffp.append(",");
                        }
                        cffp.append(jsonobj.get("InvoiceNum"));
                    }
                }
            }

            if(cffp.length() != 0){
                result.put("errmsg", "发票："+cffp.toString()+" 重复上传！");
                result.put("flag", "false");
            }
        }catch (Exception e){
//            e.printStackTrace();
            log.error(e.getMessage());
            ByteArrayOutputStream ba = new ByteArrayOutputStream();
            e.printStackTrace(new PrintStream(ba));
            log.error(ba.toString());

            result.put("errmsg", e.getMessage());
            result.put("flag", "false");
        }

        return result;
    }

    /**
     * 获取权限token
     */
    public static String getAuth() throws Exception{
        // 官网获取的 API Key 更新为你注册的
        String clientId = "g2WyZ2gxGfKddaRUyw6yTsIf";
        // 官网获取的 Secret Key 更新为你注册的
        String clientSecret = "MH227Fqih0nkDV2UiKpaQ9MBgnimwWTl";

        if(StringUtils.isBlank(Auth)){
            Auth = getAuth(clientId, clientSecret);
        }
        return getAuth(clientId, clientSecret);
    }

    /**
     * 获取API访问token
     * 该token有一定的有效期，需要自行管理，当失效时需重新获取.
     * @param ak - 百度云官网获取的 API Key
     * @param sk - 百度云官网获取的 Securet Key
     */
    public static String getAuth(String ak, String sk) throws Exception{
        // 获取token地址
        String authHost = "https://aip.baidubce.com/oauth/2.0/token?";
        String getAccessTokenUrl = authHost
                + "grant_type=client_credentials"
                + "&client_id=" + ak
                + "&client_secret=" + sk;
        URL realUrl = new URL(getAccessTokenUrl);
        // 打开和URL之间的连接
        HttpURLConnection connection = (HttpURLConnection) realUrl.openConnection();
        connection.setRequestMethod("GET");
        connection.connect();
        // 获取所有响应头字段
        Map<String, List<String>> map = connection.getHeaderFields();
//            // 遍历所有的响应头字段
//            for (String key : map.keySet()) {
//                System.err.println(key + "--->" + map.get(key));
//            }
        // 定义 BufferedReader输入流来读取URL的响应
        BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
        String result = "";
        String line;
        while ((line = in.readLine()) != null) {
            result += line;
        }
        JSONObject jsonObject = JSONObject.parseObject(result);
        String access_token = jsonObject.getString("access_token");
        return access_token;
    }


    /**
     * 调用百度文字识别，返回识别结果
     * @param url 接口URL
     * @param fileid 需要识别的附件ID
     * @return
     */
    public JSONObject recognitionInvoiceBaiduApi(String url,String fileid,User user) throws Exception{
        RecordSet rs = new RecordSet();
        //查询附件
        rs.executeQuery("SELECT imagefilename,filerealpath,iszip,isaesencrypt,aescode FROM imagefile WHERE imagefileid = (SELECT imagefileid from docimagefile WHERE docid = ?)"
                , new Object[]{fileid});
            if (rs.next()) {
                InputStream inputStream = null;
                //文件路径
                String filePath = Util.null2String(rs.getString("filerealpath"));
                //文件名
                String imagefilename = Util.null2String(rs.getString("imagefilename"));
                //是否压缩
                String iszip = Util.null2String(rs.getString("iszip"));
                //是否加密
                String isaesencrypt = Util.null2String(rs.getString("isaesencrypt"));
                //加密密码
                String aescode = Util.null2String(rs.getString("aescode"));

                ZipInputStream ziStream = null;
                File fpath = new File(filePath);
                //是否压缩
                if (iszip.equals("1")) {
                    ziStream = new ZipInputStream(new FileInputStream(fpath));
                    if (ziStream.getNextEntry() != null) {
                        inputStream = new BufferedInputStream(ziStream);
                    }
                } else {
                    inputStream = new BufferedInputStream(new FileInputStream(fpath));
                }
                //是否加密
                if (isaesencrypt.equals("1")) {
                    inputStream = AESCoder.decrypt((InputStream) inputStream, aescode);
                }
                byte[] imgData = IOUtils.toByteArray(inputStream);
                String imgParam = "";
                try {
                    String imgStr = Base64Util.encode(imgData);
                     imgParam = URLEncoder.encode(imgStr, "UTF-8");
                }catch (Exception e){
                    log.error(e.getMessage());
                    e.printStackTrace();
                }


                String filetype = "";
                String param = "";
                if (imagefilename.indexOf(".") > -1) {
                    filetype = imagefilename.substring(imagefilename.lastIndexOf(".") + 1);
                }
                if ("jpg".equalsIgnoreCase(filetype) || "jpeg".equalsIgnoreCase(filetype)
                        || "png".equalsIgnoreCase(filetype) || "bmp".equalsIgnoreCase(filetype)) {
                    param = "image=" + imgParam;
                }
                if("pdf".equalsIgnoreCase(filetype)){
                    param = "pdf_file=" + imgParam;
                }
                //文件不支持
                if(StringUtils.isBlank(param)){
                    return null;
                }
                String result = HttpUtil.post(url, getAuth(), param);
                JSONObject jsonObject = JSONObject.parseObject(result);
                if(jsonObject.containsKey("error_code")){
                    //将错误信息推送至钉钉机器人
                    PushRobot.pushRobot(user.getUsername()+"调用百度文字识别API失败",
                            ErrorMsgUtils.errorMsgUtils(jsonObject.getString("error_code"),jsonObject.getString("error_code")));
                    throw new RuntimeException(ErrorMsgUtils.errorMsgUtils(jsonObject.getString("error_code")
                    ,jsonObject.getString("error_code")));
                }else{
                    JSONObject words_result = jsonObject.getJSONObject("words_result");

                    //修改发票附件文件名
                    updateInvoiceFileName(fileid,words_result,imagefilename);
                    return words_result;
                }
            }
        return null;
    }

    /**
     * 调用阿里文字识别，返回识别结果
     * @param fileid 需要识别的附件ID
     * @return
     */
    public JSONObject recognitionInvoiceAliApi(String fileid,User user) throws Exception{
        RecordSet rs = new RecordSet();
        //查询附件
        rs.executeQuery("SELECT imagefilename,filerealpath,iszip,isaesencrypt,aescode FROM imagefile WHERE imagefileid = (SELECT imagefileid from docimagefile WHERE docid = ?)"
                , new Object[]{fileid});
        if (rs.next()) {
            InputStream inputStream = null;
            //文件路径
            String filePath = Util.null2String(rs.getString("filerealpath"));
            //文件名
            String imagefilename = Util.null2String(rs.getString("imagefilename"));
            //是否压缩
            String iszip = Util.null2String(rs.getString("iszip"));
            //是否加密
            String isaesencrypt = Util.null2String(rs.getString("isaesencrypt"));
            //加密密码
            String aescode = Util.null2String(rs.getString("aescode"));

            ZipInputStream ziStream = null;
            File fpath = new File(filePath);
            //是否压缩
            if (iszip.equals("1")) {
                ziStream = new ZipInputStream(new FileInputStream(fpath));
                if (ziStream.getNextEntry() != null) {
                    inputStream = new BufferedInputStream(ziStream);
                }
            } else {
                inputStream = new BufferedInputStream(new FileInputStream(fpath));
            }
            //是否加密
            if (isaesencrypt.equals("1")) {
                inputStream = AESCoder.decrypt((InputStream) inputStream, aescode);
            }

            String filetype = "";
            if (imagefilename.indexOf(".") > -1) {
                filetype = imagefilename.substring(imagefilename.lastIndexOf(".") + 1);
            }

            try {
                //调用阿里云接口
                JSONObject words_result = RecognitionInvoiceAliApi.analyze(inputStream,filetype);

                //修改发票附件文件名
                updateInvoiceFileName(fileid,words_result,imagefilename);

                return words_result;
            }catch (Exception e){
                PushRobot.pushRobot(user.getUsername()+" 调用阿里文字识别API失败",e.getMessage());
                throw new RuntimeException("普通发票识别失败请联系管理员");
            }
        }
        return null;
    }

    /**
     * 插入发票台账
     * @param fileids 发票主表字段
     * @param jsonobj 发票识别结果
     * @param fileld 发票附件ID
     */
    public void addInvoiceData(List<String> fileids,JSONObject jsonobj,String fileld,int uid){
        //查询表字段信息
        List<Map<String, String>> hlist = new ArrayList<>();
        Map<String,String> map = null;
        //获取解析后的数据_遍历主表字段
        for (String fileid : fileids) {
            if (jsonobj.containsKey(fileid)) {
                map = new HashMap<>();
                map.put("fileld", fileid);
                String val = jsonobj.getString(fileid);
                //税额字段转换为小数
                if("TotalTax".equals(fileid)){
                    try {
                        val = Double.parseDouble(val)+"";
                    }catch (NumberFormatException e){
                        val = "0";
                    }
                }
                map.put("value", val);
                hlist.add(map);
            }
        }

        RecordSet rs = new RecordSet();
        StringBuffer sb_fileld = new StringBuffer();
        StringBuffer sb_value = new StringBuffer();
        for(Map<String,String> data : hlist){
            if(sb_fileld.length() != 0){
                sb_fileld.append(",");
                sb_value.append(",");
            }
            sb_fileld.append(data.get("fileld"));
            sb_value.append("'");
            sb_value.append(data.get("value"));
            sb_value.append("'");
        }
        String cdata = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        String ctime = new SimpleDateFormat("HH:mm:ss").format(new Date());
        rs.executeUpdate("INSERT INTO uf_fptz ("+sb_fileld.toString()+",sbjg,fp,formmodeid,modedatacreater,modedatacreatedate,modedatacreatetime) " +
                        "VALUES ("+sb_value.toString()+",'"+jsonobj.toString()+"','"+fileld+"',301," +
                uid+",'"+ cdata +"','"+ctime+"')");
    }

    /**
     * 增值税发票解析并插入发票货物明细
     * @param filelds_det 字段集合
     * @param jsonobj 发票识别结果
     * @param fileld 附件ID
     */
    public void addInvoiceDetailDataZZS(List<String> filelds_det,JSONObject jsonobj,String fileld){
        //解析明细
        List<Map<String, String>> hlist_det = new ArrayList<>();
        Map<String,String> map = null;
        JSONObject jsontmp = new JSONObject();
        for (String fileid : filelds_det) {
            if (jsonobj.containsKey(fileid)) {
                JSONArray objarr = JSON.parseArray(jsonobj.getString(fileid));
                for(int i = 0; i < objarr.size(); i++){
                    map = new HashMap<>();
                    jsontmp = JSONObject.parseObject(String.valueOf(objarr.get(i)));
                    if(hlist_det.size() > i){
                        hlist_det.get(i).put(fileid, jsontmp.getString("word"));
                    }else{
                        map.put(fileid, jsontmp.getString("word"));
                        hlist_det.add(map);
                    }
                }
            }
        }
        //获取台账主表ID
        RecordSet rs = new RecordSet();
        rs.execute("select id from uf_fptz where CAST(fp AS VARCHAR) = '"+fileld+"' order by id desc");
        if (rs.next()){
            String mainid = rs.getString("id");
            StringBuilder sb = null;
            //将发票明细值按字段名称拼接
            for(Map<String,String> arr:hlist_det){
                sb = new StringBuilder();
                for(String fi : filelds_det){
                    if(sb.length() > 0){
                        sb.append(",");
                    }
                    sb.append("'");
                    if(arr.containsKey(fi)){
                        sb.append(arr.get(fi));
                    }
                    sb.append("'");
                }
                //插入明细
                rs.executeUpdate("INSERT INTO uf_fptz_dt1 ("+String.join(",", filelds_det)+",mainid) VALUES ("+sb.toString()+","+mainid+")");
            }
        }
    }

    /**
     * 普通发票解析并插入发票货物明细
     * @param filelds_det 明细字段集合
     * @param jsonobj 发票识别结果
     * @param fileld 附件ID
     */
    public void addInvoiceDetailDataPT(List<String> filelds_det,JSONObject jsonobj,String fileld){
        //获取台账主表ID
        RecordSet rs = new RecordSet();
        rs.execute("select id from uf_fptz where CAST(fp AS VARCHAR) = '"+fileld+"' order by id desc");
        if (rs.next()){
            String mainid = rs.getString("id");
            StringBuilder sb = null;
            //将发票明细值按字段名称拼接
            JSONArray jarr = jsonobj.getJSONArray("invoiceDetails");
            for(Object jo : jarr){
                JSONObject obj = (JSONObject) jo;
                sb = new StringBuilder();
                for(String fi : filelds_det){
                    if(sb.length() > 0){
                        sb.append(",");
                    }
                    sb.append("'");
                    if(obj.containsKey(fi)){
                        sb.append(obj.get(fi));
                    }
                    sb.append("'");
                }
                //插入明细
                rs.executeUpdate("INSERT INTO uf_fptz_dt1 ("+String.join(",", filelds_det)+",mainid) VALUES ("+sb.toString()+","+mainid+")");
            }
        }
    }

    /**
     * 更新发票附件名称 用发票编号+金额命名
     * @param fileid 发票附件ID
     * @param jsonobj 发票识别结果
     * @param filename 发票附件名
     */
    public void updateInvoiceFileName(String fileid,JSONObject jsonobj,String filename){
        String InvoiceNum = jsonobj.getString("InvoiceNum");
        String AmountInFiguers = jsonobj.getString("AmountInFiguers");
        String name = InvoiceNum+"_"+AmountInFiguers;
        String newName = name+filename.substring(filename.lastIndexOf("."));
        RecordSet rs = new RecordSet();
        rs.executeUpdate("update imagefile set imagefilename = '"+newName+"' where " +
                "imagefileid in (SELECT imagefileid from docimagefile WHERE docid = '"+fileid+"')");

        rs.executeUpdate("update docimagefile SET imagefilename = '"+newName+"' WHERE docid = '"+fileid+"'");

        rs.executeUpdate("update DocDetail SET docsubject = '"+name+"' WHERE id ='"+fileid+"'");
    }

}
