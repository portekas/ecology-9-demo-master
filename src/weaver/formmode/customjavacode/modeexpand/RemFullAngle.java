package weaver.formmode.customjavacode.modeexpand;

import org.apache.commons.lang3.StringUtils;
import weaver.conn.RecordSet;
import weaver.formmode.customjavacode.AbstractModeExpandJavaCodeNew;

import java.util.HashMap;
import java.util.Map;

/**
 * 创建 刘港 2022-04-19 建模保存后将变成全角的SQL关键字替换为正常字母
 */
public class RemFullAngle extends AbstractModeExpandJavaCodeNew {
    @Override
    public Map<String, String> doModeExpand(Map<String, Object> param) {
        Map<String, String> result = new HashMap<String, String>();

        try {
            String billid = (String) param.get("billid");//数据id
            String modeid = (String) param.get("modeId");//模块id
            String formId = (String) param.get("formId");//表单id

            //为空直接返回
            if(StringUtils.isBlank(billid) || StringUtils.isBlank(modeid) || StringUtils.isBlank(formId)){
                result.put("errmsg", "ID为空：billid="+billid+";modeid="+modeid+";formId="+formId);
                result.put("flag", "false");
                return result;
            }

            RecordSet rs = new RecordSet();
            //查询表名
            String tablename = "";
            rs.executeQuery("SELECT tablename FROM workflow_bill WHERE id = '"+formId+"'");
            if(rs.next()){
                tablename = rs.getString("tablename");
            }
            if(StringUtils.isBlank(tablename)){
                result.put("errmsg", "tablename为空");
                result.put("flag", "false");
                return result;
            }
            //查询表中的text字段信息
            StringBuffer setField = new StringBuffer();
            rs.executeQuery("SELECT fieldname  FROM workflow_billfield WHERE billid = '"+formId+"' AND fielddbtype = 'text'");
            while (rs.next()){
                if(setField.length() > 0){
                    setField.append(",");
                }
                setField.append(rs.getString("fieldname"));
            }
            //没有text字段直接返回
            if(setField.length() == 0){
                return result;
            }
            String fileIds = setField.toString();
            String temp = "";
            //查询表中的text字段值
            rs.execute("SELECT "+fileIds+" FROM "+tablename+" WHERE ID = "+billid);
            if(rs.next()){
                setField = new StringBuffer();
                for(String fileid : fileIds.split(",")){
                    if(setField.length() > 0){
                        setField.append(",");
                    }
                    setField.append(fileid);
                    setField.append("='");
                    temp = rs.getString(fileid);
                    setField.append(remFullAngle(temp));
                    setField.append("'");
                }
                if(setField.length() > 0){
                    rs.executeUpdate("update "+tablename+" set "+setField.toString()+" where id = "+billid);
                }
            }

        }catch (Exception e){
            result.put("errmsg", e.getMessage());
            result.put("flag", "false");
        }

        return result;
    }

    //去除字符串中的全角
    private String remFullAngle(String inp) {
        char[] c = inp.toCharArray();
        for (int i = 0; i < c.length; i++) {
            if (c[i] > 65280 && c[i] < 65375){
                c[i] = (char) (c[i] - 65248);
            }
        }

        //字符串中含有单引号无法执行update
        String temp = new String(c);
        temp = temp.replaceAll("'","''");
        return temp;
    }
}
