package com.api.OAapi;

import com.alibaba.fastjson.JSONObject;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import weaver.conn.RecordSet;
import weaver.formmode.customjavacode.modeexpand.AnalyzeMLB;
import weaver.general.Util;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 创建 刘港 2022-04-13 批量导入毛利表
 */
@Path("/AnalyzeMLBListApi")
public class AnalyzeMLBListApi {

    @GET
    @Path("/getAnalyzeMLB")
    @Produces(MediaType.APPLICATION_JSON)
    public JSONObject getAnalyzeMLB(){
        Log log = LogFactory.getLog(AnalyzeMLBListApi.class.getName());

        JSONObject json = new JSONObject();
        try {

            File fpath = new File("D:\\WEAVER\\项目毛利批量导入.xlsx");
            InputStream inputStream = new BufferedInputStream(new FileInputStream(fpath));
            Workbook xss = new XSSFWorkbook(inputStream);
            //解析流文件
            List<List<Map<String, String>>> mllist = fileAnalyze(xss);

            json.put("mllistsize",mllist.size());

            json.put("va1",mllist.get(0).get(0).get("je5"));
            json.put("va2",mllist.get(1).get(0).get("je5"));
            json.put("va3",mllist.get(2).get(0).get("je5"));

            RecordSet rs = new RecordSet();
            String id = "";
            String xmbh = "";
            String xmlb = "";
            for(List<Map<String,String>> li : mllist){
                xmbh = li.get(0).get("je1");
                rs.executeQuery("select id,xmbh,xmlb from uf_xmb where xmbh = ?",new Object[]{xmbh});
                if(rs.next()){
                    id = Util.null2String(rs.getString("id"));
                    xmbh = Util.null2String(rs.getString("xmbh"));
                    xmlb = Util.null2String(rs.getString("xmlb"));

                    //删除原毛利一信息
                    rs.executeUpdate("delete uf_mlbtz_dt1 where mainid = (select id from uf_mlbtz where xmbh = '"+xmbh+"')");

                    //删除原毛利一信息
                    rs.executeUpdate("delete uf_mlbtz_dt2 where mainid = (select id from uf_mlbtz where xmbh = '"+xmbh+"')");
                    //删除原毛利一信息
                    rs.executeUpdate("delete uf_mlbtz_dt3 where mainid = (select id from uf_mlbtz where xmbh = '"+xmbh+"')");

                    //删除原毛利主表信息
                    rs.executeUpdate("delete uf_mlbtz where xmbh = '"+xmbh+"'");

                    //保存毛利主表信息
                    rs.executeUpdate("INSERT INTO uf_mlbtz (formmodeid,xmmc,xmbh,fpsl) VALUES (285,?,?,?)",
                            new Object[]{id,xmbh,li.get(0).get("je2")});

                    //计算毛利三
                    calML3(li,xmlb);

                    //保存毛利数据
                    addMLDetail(li,id,xmbh,json);
                }
            }

        }catch (Exception e){

            ByteArrayOutputStream ba = new ByteArrayOutputStream();
            e.printStackTrace(new PrintStream(ba));
            log.error(ba.toString());
        }

        return json;
    }

    /**
     * 解析文件流的内容
     * @param hssfWorkbook excle
     * @return 文件内容集合
     */
    public List<List<Map<String,String>>> fileAnalyze(Workbook hssfWorkbook){

        Log log = LogFactory.getLog(AnalyzeMLBListApi.class.getName());

        List<List<Map<String,String>>> llmArr = new ArrayList<>();
        try {

            List<Map<String,String>> mllist = new ArrayList<>();
            Map<String,String> map = new HashMap<>();
            Map<String,String> mlmap;
            //毛利一
            map.put("start0","3");//模板开始列 包含
            map.put("end0","17");//模板结算列 不包含
            //毛利二
            map.put("start1","17");
            map.put("end1","26");

            //按照固定模板格式取值
            Sheet sheetAt = hssfWorkbook.getSheetAt(0);
            //总行数
            int totoalRows = sheetAt.getLastRowNum();
            //没数据不读
            if(totoalRows < 3){
                return null;
            }

            //存列名
            String[] lmarr = new String[27];
            for(int z = 0; z<2; z++) {
                //遍历列，存列名
                for (int i = Integer.valueOf(map.get("start" + z)); i < Integer.valueOf(map.get("end" + z)); i++) {
                    Cell mc = sheetAt.getRow(1).getCell(i);
                    lmarr[i] = mc.toString();
                }
            }

            //从第三行开始取，前两行是列名
            for(int jj = 2; jj < totoalRows; jj++){
                mlmap = new HashMap<>();
                mllist = new ArrayList<>();

                Row row = sheetAt.getRow(jj);
                //取二三列分别为编号和税率
                Cell val_1 = row.getCell(1);
                //遍历到没有项目编号结束，防止读到空行
                if(StringUtils.isBlank(val_1.toString())){
                    break;
                }
                //项目编号
                val_1.setCellType(CellType.STRING);
                mlmap.put("je1",val_1.getStringCellValue());

                //税率
                Cell val_2 = row.getCell(2);
                val_2.setCellType(CellType.STRING);
                mlmap.put("je2",val_2.getStringCellValue());

                mlmap.put("start",map.get("start0"));
                mlmap.put("end",map.get("end0"));
                //第四列开始为毛利一数据
                for (int i = Integer.valueOf(map.get("start0")); i < Integer.valueOf(map.get("end0")); i++) {
                    mlmap.put("km"+i,lmarr[i]);
                    Cell val = row.getCell(i);
                    if (val != null) {
                        val.setCellType(CellType.STRING);
                        if (StringUtils.isBlank(val.getStringCellValue())) {
                            mlmap.put("je" + i, "0");
                            continue;
                        }
                        mlmap.put("je" + i, String.valueOf(val.getStringCellValue()));
                    }
                }
                mllist.add(mlmap);
                //第十八列开始为毛利二数据
                mlmap = new HashMap<>();
                mlmap.put("start",map.get("start1"));
                mlmap.put("end",map.get("end1"));
                for (int i = Integer.valueOf(map.get("start1")); i < Integer.valueOf(map.get("end1")); i++) {
                    mlmap.put("km"+i,lmarr[i]);
                    Cell val = row.getCell(i);
                    if (val != null) {
                        val.setCellType(CellType.STRING);
                        if (StringUtils.isBlank(val.getStringCellValue())) {
                            mlmap.put("je" + i, "0");
                            continue;
                        }
                        mlmap.put("je" + i, String.valueOf(val.getStringCellValue()));
                    }
                }
                mllist.add(mlmap);
                llmArr.add(mllist);
            }
        }catch (Exception e){

            ByteArrayOutputStream ba = new ByteArrayOutputStream();
            e.printStackTrace(new PrintStream(ba));
            log.error(ba.toString());
        }
        return llmArr;
    }

    /**
     * 计算毛利三
     * @param mllist 明细集合
     */
    public void calML3(List<Map<String,String>> mllist,String xmlb) throws Exception{
        String fpsl = mllist.get(0).get("je2");
        Map<String,String> mlmap = new HashMap<>();
        //1、设备材料费
        mlmap.put("km0",mllist.get(0).get("km5"));
        mlmap.put("je0",stringToDou(mllist.get(0).get("je5"))/1.13+"");
        //2、施工人工机械辅材费
        mlmap.put("km1",mllist.get(0).get("km6"));
        mlmap.put("je1",stringToDou(mllist.get(0).get("je6"))/1.03+"");
        //3、项目外包部分
        mlmap.put("km2","3、项目外包部分");
        mlmap.put("je2","0");
        //4、总包配合费(含临设、水电费、修补等）
        mlmap.put("km3",mllist.get(0).get("km7"));
        mlmap.put("je3",mllist.get(0).get("je7"));
        //5、代理服务费
        mlmap.put("km4",mllist.get(0).get("km8"));
        mlmap.put("je4",mllist.get(0).get("je8"));
        //6、公司综合费用（不取数）
        mlmap.put("km5",mllist.get(0).get("km9"));
        mlmap.put("je5","");
        //7、建造师费用
        mlmap.put("km6",mllist.get(0).get("km10"));
        mlmap.put("je6","");
        //2 外协
        if("2".equals(xmlb)){
            mlmap.put("je6",mllist.get(0).get("je10"));
        }
        //8、施工过程业务费
        mlmap.put("km7",mllist.get(0).get("km11"));
        mlmap.put("je7",mllist.get(0).get("je11"));
        //9、工程税金（不取数）
        mlmap.put("km8",mllist.get(0).get("km12"));
        mlmap.put("je8","");
        //（1）协助费
        mlmap.put("km9",mllist.get(1).get("km21"));
        mlmap.put("je9",mllist.get(1).get("je21"));
        //（2）投标业务费
        mlmap.put("km10",mllist.get(1).get("km22"));
        mlmap.put("je10",mllist.get(1).get("je22"));
        //（3）其他
        mlmap.put("km11",mllist.get(1).get("km23"));
        mlmap.put("je11",mllist.get(1).get("je23"));

        //收入金额 合同额/发票税率
        Double sr = stringToDou(mllist.get(0).get("je4"))/(stringToDou(fpsl)/100+1);
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
     * 保存毛利明细
     * @param mllist 明细集合
     */
    public void addMLDetail(List<Map<String,String>> mllist,String xmid,String xmbh,JSONObject json) throws Exception{
        RecordSet rs = new RecordSet();
        String mainid = "";
        //查询主表id
        rs.execute("select id from uf_mlbtz where xmbh = '"+xmbh+"'");
        json.put("xmbh",xmbh);
        if(rs.next()){
            mainid = Util.null2String(rs.getString("id"));
            json.put("mainid",mainid);
            json.put("mllist.size()",mllist.size());
            for(int i=0; i< mllist.size(); i++){
                Map<String,String> amap = mllist.get(i);
                rs.execute("delete uf_mlbtz_dt"+(i+1)+" where mainid = "+mainid);
                json.put("sqlz","delete uf_mlbtz_dt"+(i+1)+" where mainid = "+mainid);
                json.put("sta",Integer.valueOf(amap.get("start")));
                json.put("end",Integer.valueOf(amap.get("end")));
                for (int j = Integer.valueOf(amap.get("start")); j < Integer.valueOf(amap.get("end")); j++) {
                    if(!amap.containsKey("km"+j)){
                        continue;
                    }
                    rs.executeQuery("INSERT INTO uf_mlbtz_dt"+(i+1)+" (mainid,km,je,px) VALUES (?,?,?,?)"
                            , new Object[]{mainid,amap.get("km"+j),stringForMat(amap.get("km"+j),amap.get("je"+j)),j-Integer.valueOf(amap.get("start"))});
                    json.put("mx"+j+"_"+i,"INSERT INTO uf_mlbtz_dt"+(i+1)+" (mainid,km,je,px) VALUES ("+mainid+",?,?,?)");
                }
            }

            //更新项目表中的毛利值
            rs.executeUpdate("update uf_xmb set ml1 = ? , ml2 = ? , ml3 = ? where id = ?",
                    new Object[]{mllist.get(0).get("je16"),mllist.get(1).get("je25"),mllist.get(2).get("je13"),xmid});
        }
    }

    /**
     * 将数字字符串转换成double
     * @param st 数字字符串
     * @return
     */
    public double stringToDou(String st) throws Exception{
        if(org.apache.commons.lang.StringUtils.isNotBlank(st)){
            return Double.parseDouble(st);
        }
        return 0;
    }

    /**
     * 格式化金额
     * @param st 金额
     * @return
     */
    public String stringForMat(String km,String st) throws Exception{
        if(org.apache.commons.lang.StringUtils.isNotBlank(st)) {
            if (km.indexOf("率") > -1) {
                return (String.format("%.2f", Double.valueOf(st) * 100)) + "%";
            }
            return String.format("%.2f", Double.valueOf(st));
        }
        return "0.00";
    }

}
