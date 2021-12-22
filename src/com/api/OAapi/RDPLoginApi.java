package com.api.OAapi;

import com.alibaba.fastjson.JSONObject;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.hrm.HrmUserVarify;
import weaver.hrm.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

@Path("/rdploginApi")
public class RDPLoginApi {

    /**
     * 查询报表权限API，提供给RDP报表使用判断是否有权限打开报表，有权限返回 1 无权限返回 0
     * 查询报表权限配置列表
     * 创建 2021-12-16 刘港
     *
     * @return
     */
    @Path("/rdplogin")
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public JSONObject rdplogin(@Context HttpServletRequest req, @Context HttpServletResponse res) {
        User user= HrmUserVarify.getUser(req,res);
        JSONObject json = new JSONObject();
        RecordSet xmbRec = new RecordSet();
        String bbid = Util.null2String(req.getParameter("bbid"));
        String xmbsql = "SELECT COUNT(uz.id) as userNum FROM uf_zhdybbqx uz LEFT JOIN uf_xxhmk uxk ON uxk.id = uz.bb" +
                " WHERE uxk.bblj = '"+bbid+"' and (cast(uz.ry as varchar(99)) = '"+user.getUID()+"' or uz.ry like '%,"+user.getUID()+",%' or uz.ry like '"+user.getUID()+",%' or uz.ry like '%,"+user.getUID()+"' or (sfgk = '1' AND ry IS NULL))";
        xmbRec.execute(xmbsql);
        if(xmbRec.next()){
            json.put("userNum",xmbRec.getString("userNum"));
            json.put("userID",user.getUID());
            json.put("userDept",user.getUserDepartment());
        }
        String xgbm = "select field8 AS xgbm from cus_fielddata WHERE id = '"+user.getUID()+"' AND scopeid = '-1'";
        xmbRec.execute(xgbm);
        String xgbmid = "";
        if(xmbRec.next()){
            xgbmid = xmbRec.getString("xgbm");
        }
        json.put("userxgbm",xgbmid);
        return json;
    }
}
