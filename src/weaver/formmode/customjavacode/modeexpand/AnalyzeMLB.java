package weaver.formmode.customjavacode.modeexpand;

import org.apache.commons.lang.StringUtils;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import weaver.conn.RecordSet;
import weaver.file.AESCoder;
import weaver.formmode.customjavacode.AbstractModeExpandJavaCodeNew;
import weaver.formmode.log.FormmodeLog;
import weaver.general.Util;
import weaver.hrm.User;
import weaver.soa.workflow.request.RequestInfo;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipInputStream;

/**
 * 创建 刘港 2022-3-1 解析毛利表附件，将数据插入明细1、明细2，计算出明细3并插入
 * 修改 刘港 2022-3-9 添加从excel中获取预算清单数据并插入预算清单台账中
 * 修改 刘港 2022-3-10 添加计算毛利三的毛利金额和毛利率
 */
public class AnalyzeMLB extends AbstractModeExpandJavaCodeNew {
    private Log log = LogFactory.getLog(AnalyzeMLB.class.getName());

    public Map<String, String> doModeExpand(Map<String, Object> param) {
        Map<String, String> result = new HashMap<String, String>();
        try {
            User user = (User) param.get("user");
            int billid = -1;//数据id
            int modeid = -1;//模块id
            String xmmc = "";//项目ID
            String xmbh = "";//项目编号
            String mlbfj = "";//毛利表附件ID
            String fpsl = "";//发票税率
            String xmlb = "";//项目类别 2 外协
            RequestInfo requestInfo = (RequestInfo) param.get("RequestInfo");
            if (requestInfo != null) {
                billid = Util.getIntValue(requestInfo.getRequestid());
                modeid = Util.getIntValue(requestInfo.getWorkflowid());

                if (billid > 0 && modeid > 0) {
                    RecordSet rs = new RecordSet();
                    rs.executeQuery("SELECT xmmc,xmbh,mlbfj,fpsl FROM uf_mlbtz WHERE id = ?", new Object[]{billid});
                    if (rs.next()) {
                        xmmc = Util.null2String(rs.getString("xmmc"));
                        xmbh = Util.null2String(rs.getString("xmbh"));
                        mlbfj = Util.null2String(rs.getString("mlbfj"));
                        fpsl = Util.null2String(rs.getString("fpsl"));

                        if(StringUtils.isNotBlank(fpsl)){
                            new Exception("发票税率不能为空");
                        }

                        rs.executeQuery("select xmlb from uf_xmb where id = ?",new Object[]{xmmc});
                        if(rs.next()){
                            xmlb = Util.null2String(rs.getString("xmlb"));
                        }
                    }

                    //无附件信息直接结束
                    if (StringUtils.isBlank(mlbfj)) {
                        return result;
                    }
                    //读取流文件并转换成excel
                    XSSFWorkbook hssfWorkbook = getMLBFile(mlbfj);
                    //解析流文件
                    List<Map<String, String>> mllist = fileAnalyze(hssfWorkbook);

                    //计算毛利三
                    calML3(mllist,fpsl,xmlb);

                    //保存毛利数据到明细中
                    addMLDetail(mllist,billid,xmmc);

                    //获取预算清单
                    List<Object[]> qdlist = fileAnalyzeYSQD(hssfWorkbook,xmmc,xmbh);

                    //保存预算清单数据
                    addYQDetail(qdlist,billid);
                }
            }
        } catch (Exception e) {
//            e.printStackTrace();

            ByteArrayOutputStream ba = new ByteArrayOutputStream();
            e.printStackTrace(new PrintStream(ba));
            log.error(ba.toString());

            result.put("errmsg", e.getMessage());
            result.put("flag", "false");
        }
        return result;
    }

    /**
     * 将附件转换成文件流
     * @param docid 附件ID
     * @return 文件流
     * @throws Exception
     */
    public XSSFWorkbook getMLBFile(String docid) throws Exception {
        InputStream inputStream = null;
        String filePath = "";//文件路径
        String iszip = "0";//是否压缩
        String isaesencrypt = "0";//是否加密
        String aescode = "";//加密密码

        RecordSet rs = new RecordSet();
        rs.executeQuery("SELECT filerealpath,iszip,isaesencrypt,aescode FROM imagefile WHERE imagefileid = (SELECT imagefileid from docimagefile WHERE docid = ?)"
                , new Object[]{docid});
        if (rs.next()) {
            filePath = Util.null2String(rs.getString("filerealpath"));
            iszip = Util.null2String(rs.getString("iszip"));
            isaesencrypt = Util.null2String(rs.getString("isaesencrypt"));
            aescode = Util.null2String(rs.getString("aescode"));

            //验证附件类型是否是excel
            if (filePath.indexOf(".") > -1) {
                int typelen = filePath.lastIndexOf(".");
                if (typelen >= 0) {
                    String filetype = filePath.substring(typelen + 1, filePath.length());
                    if ("xls".equalsIgnoreCase(filetype) || "xlsx".equalsIgnoreCase(filetype)) {
                        new Exception("附件类型不支持解析");
                    }
                }
            }

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

            XSSFWorkbook hssfWorkbook = new XSSFWorkbook(inputStream);
            return hssfWorkbook;
        }
        return null;
    }

    /**
     * 解析文件流的内容
     * @param hssfWorkbook excle
     * @return 文件内容集合
     */
    public List<Map<String,String>> fileAnalyze(XSSFWorkbook hssfWorkbook) throws Exception {
        List<Map<String,String>> mllist = new ArrayList<>();
        Map<String,String> map = new HashMap<>();
        Map<String,String> mlmap;
        //毛利一
        map.put("start0","3");//模板开始行
        map.put("end0","19");//模板结算行
        //毛利二
        map.put("start1","29");
        map.put("end1","38");

        //按照固定模板格式取值
        XSSFSheet sheetAt = hssfWorkbook.getSheetAt(0);
        for(int z = 0; z<2; z++){
            mlmap = new HashMap<>();
            mlmap.put("start",map.get("start"+z));
            mlmap.put("end",map.get("end"+z));
            for (int i = Integer.valueOf(map.get("start"+z)); i < Integer.valueOf(map.get("end"+z)); i++) {
                XSSFRow row = sheetAt.getRow(i);
                XSSFCell km = row.getCell(0);
                XSSFCell je = row.getCell(2);
                //设置字符串类型
                km.setCellType(CellType.STRING);
                je.setCellType(CellType.STRING);
                if(StringUtils.isBlank(km.getStringCellValue())){
                    continue;
                }
                mlmap.put("km"+i,km.getStringCellValue());
                mlmap.put("je"+i,je.getStringCellValue());
            }
            mllist.add(mlmap);
        }
        return mllist;
    }

    /**
     * 计算毛利三
     * @param mllist 明细集合
     */
    public void calML3(List<Map<String,String>> mllist,String fpsl,String xmlb) throws Exception{
        Map<String,String> mlmap = new HashMap<>();
        //1、设备材料费
        mlmap.put("km0",mllist.get(0).get("km5"));
        mlmap.put("je0",stringToDou(mllist.get(0).get("je5"))/1.13+"");
        //2、施工人工机械辅材费
        mlmap.put("km1",mllist.get(0).get("km7"));
        mlmap.put("je1",stringToDou(mllist.get(0).get("je7"))/1.13+"");
        //3、项目外包部分
        mlmap.put("km2",mllist.get(0).get("km8"));
        mlmap.put("je2",stringToDou(mllist.get(0).get("je8"))/1.13+"");
        //4、总包配合费(含临设、水电费、修补等）
        mlmap.put("km3",mllist.get(0).get("km9"));
        mlmap.put("je3",mllist.get(0).get("je9"));
        //5、代理服务费
        mlmap.put("km4",mllist.get(0).get("km10"));
        mlmap.put("je4",mllist.get(0).get("je10"));
        //6、公司综合费用（不取数）
        mlmap.put("km5",mllist.get(0).get("km11"));
        mlmap.put("je5","");
        //7、建造师费用
        mlmap.put("km6",mllist.get(0).get("km12"));
        mlmap.put("je6","");
        //2 外协
        if("2".equals(xmlb)){
            mlmap.put("je6",mllist.get(0).get("je12"));
        }
        //8、施工过程业务费
        mlmap.put("km7",mllist.get(0).get("km13"));
        mlmap.put("je7",mllist.get(0).get("je13"));
        //9、工程税金（不取数）
        mlmap.put("km8",mllist.get(0).get("km14"));
        mlmap.put("je8","");
        //（1）协助费
        mlmap.put("km9",mllist.get(1).get("km33"));
        mlmap.put("je9",mllist.get(1).get("je33"));
        //（2）投标业务费
        mlmap.put("km10",mllist.get(1).get("km34"));
        mlmap.put("je10",mllist.get(1).get("je34"));
        //（3）其他
        mlmap.put("km11",mllist.get(1).get("km35"));
        mlmap.put("je11",mllist.get(1).get("je35"));

        //收入金额 合同额/发票税率
        Double sr = stringToDou(mllist.get(0).get("je3"))/(stringToDou(fpsl)/100);
        //成本
        Double cb = stringToDou(mlmap.get("je0"))+stringToDou(mlmap.get("je1"))+stringToDou(mlmap.get("je2"))
                +stringToDou(mlmap.get("je3"))+stringToDou(mlmap.get("je4"))+stringToDou(mlmap.get("je6"))+stringToDou(mlmap.get("je7"))
                +stringToDou(mlmap.get("je9"))+stringToDou(mlmap.get("je10"))+stringToDou(mlmap.get("je11"));

        mlmap.put("km12","毛利金额");
        mlmap.put("je12",String.valueOf(sr - cb));
        mlmap.put("km13","毛利率");
        mlmap.put("je13",String.valueOf((sr - cb)/sr));

        //记录开始结算游标
        mlmap.put("start","0");
        mlmap.put("end","14");
        mllist.add(mlmap);
    }

    /**
     * 将数字字符串转换成double
     * @param st 数字字符串
     * @return
     */
    public double stringToDou(String st) throws Exception{
        if(StringUtils.isNotBlank(st)){
            return Double.parseDouble(st);
        }
        return 0;
    }

    /**
     * 保存毛利明细
     * @param mllist 明细集合
     */
    public void addMLDetail(List<Map<String,String>> mllist,int mainid,String xmid) throws Exception{
        RecordSet rs = new RecordSet();
        for(int i=0; i< mllist.size(); i++){
            Map<String,String> amap = mllist.get(i);
            rs.execute("delete uf_mlbtz_dt"+(i+1)+" where mainid = "+mainid);
            for (int j = Integer.valueOf(amap.get("start")); j < Integer.valueOf(amap.get("end")); j++) {
                if(!amap.containsKey("km"+j)){
                    continue;
                }
                rs.executeUpdate("INSERT INTO uf_mlbtz_dt"+(i+1)+" (mainid,km,je,px) VALUES (?,?,?,?)"
                        , new Object[]{mainid,amap.get("km"+j),stringForMat(amap.get("km"+j),amap.get("je"+j)),j-Integer.valueOf(amap.get("start"))});
            }
        }

        //更新项目表中的毛利值
        rs.executeUpdate("update uf_xmb set ml1 = ? , ml2 = ? , ml3 = ? where id = ?",
                new Object[]{mllist.get(0).get("je18"),mllist.get(1).get("je37"),mllist.get(2).get("je13"),xmid});
    }

    /**
     * 格式化金额
     * @param st 金额
     * @return
     */
    public String stringForMat(String km,String st) throws Exception{
        if(StringUtils.isNotBlank(st)) {
            if (km.indexOf("率") > -1) {
                return (String.format("%.2f", Double.valueOf(st) * 100)) + "%";
            }
            return String.format("%.2f", Double.valueOf(st));
        }
        return "0.00";
    }

    /**
     * 解析预算清单
     * @param hssfWorkbook 读取excel
     * @return 预算清单集合
     * @throws Exception
     */
    public List<Object[]> fileAnalyzeYSQD(XSSFWorkbook hssfWorkbook,String xmid,String xmbh) throws Exception {
        List<Object[]> mllist = new ArrayList<>();
        Object[] arr;

        //解析预算清单
        XSSFSheet sheetAt = hssfWorkbook.getSheetAt(1);
        String sheetname = sheetAt.getSheetName();
        //第二页签不是预算明细则不用解析
        if(sheetname.indexOf("预算") == -1){
            return mllist;
        }
        // 总行数
        int totoalRows = sheetAt.getLastRowNum();
        //遍历明细
        for(int i = 1; i < totoalRows; i++){
            arr = new Object[11];
            XSSFRow row = sheetAt.getRow(i);
            for(int j = 0; j< 8; j++){
                log.error("总行数："+totoalRows+"---"+i+"--"+j+"--");
                XSSFCell km = row.getCell(j);
                if(km == null){
                    continue;
                }
                km.setCellType(CellType.STRING);//设置字符串类型
                arr[j] = km.getStringCellValue();
            }
            arr[8] = xmid;
            arr[9] = xmbh;
            arr[10] = arr[5];//剩余数量取清单项数量
            mllist.add(arr);
        }
        return mllist;
    }

    /**
     * 保存预算清单明细
     * @param yslist 预算清单集合
     * @param mainid 主建模id
     */
    public void addYQDetail(List<Object[]> yslist,int mainid) throws Exception{
        RecordSet rs = new RecordSet();
        if(yslist != null && yslist.size() > 0){
            rs.execute("delete uf_gcysqd where mainid = "+mainid);
            for(int i=0; i< yslist.size(); i++){
                rs.executeUpdate("INSERT INTO uf_gcysqd (qdxmc,qdxsm,pp,ggxh,qdxdw,qdxsl,dj,zj,xmmc,gcxmbh,sysl,mainid,formmodeid,qdxfl,yysl,djsl)" +
                        " VALUES (?,?,?,?,?,?,?,?,?,?,?,"+mainid+",58,0,0,0)" ,yslist.get(i));
            }
        }
    }
}
