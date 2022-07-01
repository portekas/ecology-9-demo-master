package OAclass;

import org.apache.commons.lang3.StringUtils;
import weaver.conn.RecordSet;
import weaver.interfaces.workflow.action.Action;
import weaver.soa.workflow.request.RequestInfo;

/**
 * 创建 刘港 2022-06-17 入职流程提交更新附件名称
 */
public class UpdateInductionFile implements Action {
    @Override
    public String execute(RequestInfo reqInfo) {
        RecordSet rs = new RecordSet();
        rs.executeQuery("select xm,sfzrxm,sfzghm,xlzs,xwzs,qgslzzm,xlzsyjs,xwzsyjs,xsz,jytjb from formtable_main_9 where requestId = "+reqInfo.getRequestid());
        if(rs.next()){
            String xm = rs.getString("xm");
            String sfzrxm = rs.getString("sfzrxm");
            updateFileName(sfzrxm,xm+"身份证正面");

            String sfzghm = rs.getString("sfzghm");
            updateFileName(sfzghm,xm+"身份证反面");

            String xlzs = rs.getString("xlzs");
            updateFileName(xlzs,xm+"毕业证");

            String xwzs = rs.getString("xwzs");
            updateFileName(xwzs,xm+"学位证");

            String qgslzzm = rs.getString("qgslzzm");
            updateFileName(qgslzzm,xm+"离职证明");

            String xlzsyjs = rs.getString("xlzsyjs");
            updateFileName(xlzsyjs,xm+"毕业证（研究生） ");

            String xwzsyjs = rs.getString("xwzsyjs");
            updateFileName(xwzsyjs,xm+"学位证（研究生）");

            String xsz = rs.getString("xsz");
            updateFileName(xsz,xm+"学生证");

            String jytjb = rs.getString("jytjb");
            updateFileName(jytjb,xm+"就业推荐表");
        }

        return null;
    }

    /**
     * 更新附件名称
     * @param fileid 附件ID
     * @param filename 附件名
     */
    public void updateFileName(String fileid, String filename){
        if(StringUtils.isNotBlank(fileid)){
            RecordSet rs = new RecordSet();
            //查询原附件名
            rs.executeQuery("select imagefilename from docimagefile WHERE docid = '"+fileid+"' ");
            if(rs.next()){
                String imagefilename = rs.getString("imagefilename");
                String suf = imagefilename.substring(imagefilename.lastIndexOf("."));
                String newName = filename+suf;//文件带后缀名
                rs.executeUpdate("update imagefile set imagefilename = '"+newName+"' where " +
                        "imagefileid in (SELECT imagefileid from docimagefile WHERE docid = '"+fileid+"')");

                rs.executeUpdate("update docimagefile SET imagefilename = '"+newName+"' WHERE docid = '"+fileid+"'");

                rs.executeUpdate("update DocDetail SET docsubject = '"+filename+"' WHERE id ='"+fileid+"'");
            }
        }
    }
}
