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
     * 查询报表权限
     * @param req
     * @param res
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
        String xmbsql = "SELECT COUNT(uz.id) as userNum FROM uf_zhdybbqx uz " +
                "WHERE uz.dybbid = '"+bbid+"' and (uz.ry like '%,"+user.getUID()+",%' or uz.ry like '"+user.getUID()+",%' or uz.ry like '%,"+user.getUID()+"' or uz.ry is null)";
        xmbRec.execute(xmbsql);
        if(xmbRec.next()){
            json.put("userNum",xmbRec.getString("userNum"));
        }
        return json;
    }
}
