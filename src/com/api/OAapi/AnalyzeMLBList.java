package com.api.OAapi;

import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import weaver.conn.RecordSet;
import weaver.formmode.customjavacode.modeexpand.AnalyzeMLB;
import weaver.general.Util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.core.Context;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 创建 刘港 2022-04-13 批量导入毛利表
 */
@Path("/AnalyzeMLBList")
public class AnalyzeMLBList {
    private AnalyzeMLB analyzeMLB;

    @GET
    @Path("/getAnalyzeMLB")
    public void getAnalyzeMLB(@Context HttpServletRequest req, @Context HttpServletResponse res) {
        try {
            String bate = "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";
            byte[] bytes = bate.getBytes(StandardCharsets.UTF_8);
            InputStream inputStream =new ByteArrayInputStream(bytes);
            Workbook xss = new XSSFWorkbook(inputStream);

            //解析流文件
            List<List<Map<String, String>>> mllist = fileAnalyze(xss);

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

                    //计算毛利三
                    calML3(li,xmlb);

                    //保存毛利数据
                    addMLDetail(li,id,xmbh);
                }


            }
        }catch (Exception e){

        }
    }

    /**
     * 解析文件流的内容
     * @param hssfWorkbook excle
     * @return 文件内容集合
     */
    public List<List<Map<String,String>>> fileAnalyze(Workbook hssfWorkbook) throws Exception {
        List<List<Map<String,String>>> llmArr = new ArrayList<>();

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
        for(int z = 2; z < totoalRows; z++){
            mlmap = new HashMap<>();

            //取二三列分别为编号和税率
            Cell val_1 = sheetAt.getRow(z).getCell(1);
            //遍历到没有项目编号结束，防止读到空行
            if(StringUtils.isBlank(val_1.toString())){
                break;
            }
            mlmap.put("je1",val_1.toString());
            Cell val_2 = sheetAt.getRow(z).getCell(2);
            mlmap.put("je2",val_2.toString());

            //第四列开始为毛利一数据
            for (int i = Integer.valueOf(map.get("start0")); i < Integer.valueOf(map.get("end0")); i++) {
                Cell val = sheetAt.getRow(z).getCell(i);
                mlmap.put("km"+i,lmarr[i]);
                mlmap.put("je"+i,String.valueOf(val.getNumericCellValue()));
                mllist.add(mlmap);
            }
            //第十八列开始为毛利二数据
            mlmap = new HashMap<>();
            for (int i = Integer.valueOf(map.get("start1")); i < Integer.valueOf(map.get("end1")); i++) {
                Cell val = sheetAt.getRow(z).getCell(i);
                mlmap.put("km"+i,lmarr[i]);
                mlmap.put("je"+i,String.valueOf(val.getNumericCellValue()));
                mllist.add(mlmap);
            }
            llmArr.add(mllist);
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
        mlmap.put("je0",analyzeMLB.stringToDou(mllist.get(0).get("je5"))/1.13+"");
        //2、施工人工机械辅材费
        mlmap.put("km1",mllist.get(0).get("km6"));
        mlmap.put("je1",analyzeMLB.stringToDou(mllist.get(0).get("je6"))/1.03+"");
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
        Double sr = analyzeMLB.stringToDou(mllist.get(0).get("je3"))/(analyzeMLB.stringToDou(fpsl)/100+1);
        //成本
        Double cb = analyzeMLB.stringToDou(mlmap.get("je0"))+analyzeMLB.stringToDou(mlmap.get("je1"))+analyzeMLB.stringToDou(mlmap.get("je2"))
                +analyzeMLB.stringToDou(mlmap.get("je3"))+analyzeMLB.stringToDou(mlmap.get("je4"))+analyzeMLB.stringToDou(mlmap.get("je6"))+analyzeMLB.stringToDou(mlmap.get("je7"))
                +analyzeMLB.stringToDou(mlmap.get("je9"))+analyzeMLB.stringToDou(mlmap.get("je10"))+analyzeMLB.stringToDou(mlmap.get("je11"));

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
    public void addMLDetail(List<Map<String,String>> mllist,String xmid,String xmbh) throws Exception{
        RecordSet rs = new RecordSet();

        //保存毛利主表信息
        rs.executeQuery("INSERT INTO uf_mlbtz_dt (xmmc,xmbh,fpsl) VALUES (?,?,?)",
                new Object[]{xmid,xmbh,mllist.get(0).get("je2")});

        String mainid = "";
        //查询主表id
        rs.execute("select id from uf_mlbtz_dt where xmbh = "+xmbh);
        if(rs.next()){
            mainid = Util.null2String(rs.getString("id"));

            for(int i=0; i< mllist.size(); i++){
                Map<String,String> amap = mllist.get(i);
                rs.execute("delete uf_mlbtz_dt"+(i+1)+" where mainid = "+mainid);
                for (int j = Integer.valueOf(amap.get("start")); j < Integer.valueOf(amap.get("end")); j++) {
                    if(!amap.containsKey("km"+j)){
                        continue;
                    }
                    rs.executeQuery("INSERT INTO uf_mlbtz_dt"+(i+1)+" (mainid,km,je,px) VALUES (?,?,?,?)"
                            , new Object[]{mainid,amap.get("km"+j),analyzeMLB.stringForMat(amap.get("km"+j),amap.get("je"+j)),j-Integer.valueOf(amap.get("start"))});
                }
            }

            //更新项目表中的毛利值
            rs.executeUpdate("update uf_xmb set ml1 = ? , ml2 = ? , ml3 = ? where id = ?",
                    new Object[]{mllist.get(0).get("je16"),mllist.get(1).get("je25"),mllist.get(2).get("je13"),xmid});
        }
    }

}
