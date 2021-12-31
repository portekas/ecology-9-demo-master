package com.api.OAapi;

import com.alibaba.fastjson.JSONObject;
import org.apache.commons.lang.StringUtils;
import weaver.conn.RecordSet;
import weaver.general.Util;
import weaver.hrm.HrmUserVarify;
import weaver.hrm.User;

import javax.servlet.http.Cookie;
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
     * 修改 2021-12-21 刘港 返回参数中添加当前登录人ID、部门ID、相关部门ID、子部门ID
     * 修改 2021-12-31 刘港 验证报表是否需要填写安全码 、 获取cookie信息验证是否填写过
     * @return
     */
    @GET
    @Path("/rdplogin")
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
        //查询相关部门
        String xgbm = "select field8 AS xgbm from cus_fielddata WHERE id = '"+user.getUID()+"' AND scopeid = '-1'";
        xmbRec.execute(xgbm);
        String xgbmid = "";
        if(xmbRec.next()){
            xgbmid = xmbRec.getString("xgbm");
        }
        json.put("userxgbm",xgbmid);

        //查询子部门
        String zbm = "SELECT id FROM HrmDepartment hd WHERE hd.supdepid = '"+user.getUserDepartment()+"' AND (hd.canceled != 1 OR hd.canceled IS NULL)";
        xmbRec.execute(zbm);
        StringBuilder zbmid = new StringBuilder();
        while (xmbRec.next()){
            if(zbmid.length() != 0 ){
                zbmid.append(",");
            }
            zbmid.append(xmbRec.getString("id"));
        }
        json.put("userzbm",zbmid.toString());
        return json;
    }

    /**
     * 验证报表是否需要填写安全码
     */
    @GET
    @Path("/rdpIsConfidential")
    @Produces(MediaType.APPLICATION_JSON)
    public JSONObject isConfidential(@Context HttpServletRequest req, @Context HttpServletResponse res) {
        JSONObject json = new JSONObject();
        RecordSet xmbRec = new RecordSet();
        String isCon = "0";
        String bbid = Util.null2String(req.getParameter("bbid"));
        String xmbsql = "SELECT sfbmbb FROM uf_zhdybbqx uz LEFT JOIN uf_xxhmk uxk ON uxk.id = uz.bb WHERE uxk.bblj = '"+bbid+"' ";
        xmbRec.execute(xmbsql);
        //需要填写
        if(xmbRec.next() && "1".equals(xmbRec.getString("sfbmbb"))){
            //获取cookie信息验证是否填写过
            boolean isHasKeyCok = getKeyCookie(req,res);
            if(!isHasKeyCok){
                isCon = "1";//需要填写验证
            }
        }
        json.put("isCon",isCon);
        return json;
    }

    /**
     * 将报表安全码信息写入Cookie
     */
    @GET
    @Path("/rdpAddKeyCookie")
    @Produces(MediaType.APPLICATION_JSON)
    public JSONObject addKeyCookie(@Context HttpServletRequest req, @Context HttpServletResponse res) {
        JSONObject json = new JSONObject();
        User user= HrmUserVarify.getUser(req,res);
        json.put("userID",user.getUID());
        return json;
    }

    /**
     * 获取cookie信息验证是否填写过
     * true 有填写过
     * false 没填写过
     */
    public boolean getKeyCookie(@Context HttpServletRequest req, @Context HttpServletResponse res){
        Cookie[] cookies = req.getCookies();
        User user= HrmUserVarify.getUser(req,res);
        String usCk = "UserKey_"+user.getUID();
        for (Cookie cookie : cookies) {
            if (usCk.equals(cookie.getName()) && StringUtils.isNotBlank(cookie.getValue())) {
                return true;//有填写过
            }
        }
        return false;//无填写过
    }

}
