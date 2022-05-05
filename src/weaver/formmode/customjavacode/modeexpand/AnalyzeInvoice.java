package weaver.formmode.customjavacode.modeexpand;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import weaver.formmode.customjavacode.modeexpand.baiduAiAipUtils.HttpUtil;
import com.baidu.aip.util.Base64Util;
import weaver.conn.RecordSet;
import weaver.file.AESCoder;
import weaver.formmode.customjavacode.AbstractModeExpandJavaCodeNew;
import weaver.formmode.customjavacode.modeexpand.baiduAiAipUtils.PushRobot;
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
    private Log log = LogFactory.getLog(AnalyzeInvoice.class.getName());
    static String Auth = null;

    @Override
    public Map<String, String> doModeExpand(Map<String, Object> param) {
        Map<String, String> result = new HashMap<>();
        RecordSet rs = new RecordSet();
        User user = (User) param.get("user");
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
                    JSONObject jsonobj = recognitionInvoice(url, zzs);
                    //将数据插入表中
                    addInvoiceData(fileids,jsonobj,zzs,user.getUID());

                    //获取解析后的数据_遍历明细字段 并插入明细表
                    addInvoiceDetailData(fileids_det,jsonobj,zzs);
                }

            }

            //其他普通发票
            if (StringUtils.isNotBlank(ptfp)) {
                String url = "https://aip.baidubce.com/rest/2.0/ocr/v1/invoice";
                for (String pt : ptfp.split(",")) {
                    JSONObject jsonobj = recognitionInvoice(url, pt);

                    //将数据插入表中
                    addInvoiceData(fileids,jsonobj,pt,user.getUID());

                    //获取解析后的数据_遍历明细字段 并插入明细表
                    addInvoiceDetailData(fileids_det,jsonobj,pt);
                }
            }

        }catch (Exception e){
//            e.printStackTrace();

            ByteArrayOutputStream ba = new ByteArrayOutputStream();
            e.printStackTrace(new PrintStream(ba));
            log.error(ba.toString());

            result.put("errmsg", e.getMessage());
            result.put("flag", "false");
        }

        return result;
    }

    //获取增值税发票_主数据
    public List<String> getVatInvoice_h(){
        //获取配置
        RecordSet rs = new RecordSet();
        rs.execute("SELECT zd FROM uf_wzsbcspz_dt1 uwd WHERE uwd.mainid = '1'");
        List<String> hlist = new ArrayList<>();
        while (rs.next()){
            hlist.add(rs.getString("zd"));
        }
        return hlist;
    }

    //获取增值税发票_商品明细数据
    public List<String> getVatInvoice_s(){
        RecordSet rs = new RecordSet();
        rs.execute("SELECT zd FROM uf_wzsbcspz_dt2 uwd WHERE uwd.mainid = '1'");
        List<String> slist = new ArrayList<>();
        while (rs.next()){
            slist.add(rs.getString("zd"));
        }
        return slist;
    }

    /**
     * 获取权限token
     * @return 返回示例：
     * {
     * "access_token": "24.460da4889caad24cccdb1fea17221975.2592000.1491995545.282335-1234567",
     * "expires_in": 2592000
     * }
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
    public JSONObject recognitionInvoice(String url,String fileid) throws Exception{
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

                String imgStr = Base64Util.encode(imgData);
                String imgParam = URLEncoder.encode(imgStr, "UTF-8");

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
                    PushRobot.pushRobot("调用文字识别API失败",jsonObject.getString("error_msg"));
                    throw new RuntimeException("文字识别失败");
                }else{
                    JSONObject words_result = jsonObject.getJSONObject("words_result");
                    return words_result;
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
                map.put("value", jsonobj.getString(fileid));
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
        rs.executeUpdate("INSERT INTO uf_fptz ("+sb_fileld.toString()+",sbjg,fp,formmodeid,modedatacreater,modedatacreatedate) " +
                        "VALUES ("+sb_value.toString()+",'"+jsonobj.toString()+"','"+fileld+"',301," +
                uid+","+ new SimpleDateFormat("yyyy-MM-dd").format(new Date()) +")");
    }

    /**
     * 解析并插入发票货物明细
     * @param filelds_det 字段集合
     * @param jsonobj 发票识别结果
     * @param fileld 附件ID
     */
    public void addInvoiceDetailData(List<String> filelds_det,JSONObject jsonobj,String fileld){
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
        //插入明细
        RecordSet rs = new RecordSet();
        rs.execute("select id from uf_fptz where CAST(fp AS VARCHAR) = '"+fileld+"' order by id desc");
        if (rs.next()){
            String mainid = rs.getString("id");
            StringBuilder sb = null;
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
                rs.executeUpdate("INSERT INTO uf_fptz_dt1 ("+String.join(",", filelds_det)+",mainid) VALUES ("+sb.toString()+","+mainid+")");
            }
        }
    }

}
