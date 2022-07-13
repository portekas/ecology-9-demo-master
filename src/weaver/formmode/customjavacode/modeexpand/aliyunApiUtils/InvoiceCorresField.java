package weaver.formmode.customjavacode.modeexpand.aliyunApiUtils;


import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

/**
 * 创建 刘港 2022-07-07 阿里接口返回字段对应发票表
 */
public class InvoiceCorresField {

    //将阿里返回的字段名更改为表字段名
    public static JSONObject corres(JSONObject json) throws Exception{
        //替换主表
        json.put("InvoiceCode",json.get("invoiceCode"));
        json.put("InvoiceNum",json.get("invoiceNumber"));
        json.put("InvoiceDate",json.get("invoiceDate"));
        json.put("PurchaserName",json.get("purchaserName"));
        json.put("TotalAmount",json.get("invoiceAmountPreTax"));
        json.put("TotalTax",json.get("invoiceTax"));
        json.put("AmountInWords",json.get("totalAmountInWords"));
        json.put("AmountInFiguers",json.get("totalAmount"));
        json.put("SellerName",json.get("sellerName"));
        json.put("SellerRegisterNum",json.get("sellerTaxNumber"));
        json.put("SellerAddress",json.get("sellerContactInfo"));
        json.put("SellerBank",json.get("sellerBankAccountInfo"));

        //替换明细表
        JSONArray jsonArray = (JSONArray) json.get("invoiceDetails");
        for(int i = 0; i < jsonArray.size(); i++){
            JSONObject obj = (JSONObject) jsonArray.get(i);
            obj.put("CommodityName",obj.get("itemName"));
            obj.put("CommodityType",obj.get("specification"));
            obj.put("CommodityUnit",obj.get("unit"));
            obj.put("CommodityNum",obj.get("quantity"));
            obj.put("CommodityPrice",obj.get("unitPrice"));
            obj.put("CommodityAmount",obj.get("amount"));
            obj.put("CommodityTaxRate",obj.get("taxRate"));
            obj.put("CommodityTaxRate",obj.get("tax"));
            jsonArray.set(i,obj);
        }
        json.put("invoiceDetails",jsonArray);
        return json;
    }
}
