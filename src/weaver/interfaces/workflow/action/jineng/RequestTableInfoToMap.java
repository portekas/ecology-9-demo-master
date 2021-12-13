package weaver.interfaces.workflow.action.jineng;

import weaver.general.Util;
import weaver.soa.workflow.request.*;

import java.util.ArrayList;
import java.util.HashMap;

public class RequestTableInfoToMap {

    private HashMap<String, String> mainTableMap;
    private ArrayList<ArrayList<HashMap<String, String>>> detailTablesMaps;
    public RequestTableInfoToMap(RequestInfo requestInfo) {
//        获取主表单数据
        this.mainTableMap=new HashMap<String, String>();
        Property[] mainProperties = requestInfo.getMainTableInfo().getProperty();
        for (Property property : mainProperties) {
            String name = property.getName();
            String value = Util.null2String(property.getValue());
            mainTableMap.put(name, value);
        }
//        获取明细表（们）的数据（们）
        this.detailTablesMaps=new ArrayList<ArrayList<HashMap<String, String>>>();
        DetailTable[] detailTables=requestInfo.getDetailTableInfo().getDetailTable();
        for(DetailTable detailTable:detailTables){
            ArrayList<HashMap<String, String>> detailTableMaps = new ArrayList<HashMap<String, String>>();
            for(Row row:detailTable.getRow()){
                HashMap<String, String>detailTableMap = new HashMap<String, String>();
                for(Cell cell:row.getCell()){
                    String name=cell.getName();
                    String value=Util.null2String(cell.getValue());
                    detailTableMap.put(name,value);
                }
                detailTableMaps.add(detailTableMap);
            }
            this.detailTablesMaps.add(detailTableMaps);
        }
    }

    public HashMap<String, String> getMainTableMap() {
        return mainTableMap;
    }

    public ArrayList<ArrayList<HashMap<String, String>>> getDetailTablesMaps() {
        return detailTablesMaps;
    }

    public ArrayList<HashMap<String, String>> getDetailTableMaps(int index) {
        return detailTablesMaps.get(index);
    }
}
