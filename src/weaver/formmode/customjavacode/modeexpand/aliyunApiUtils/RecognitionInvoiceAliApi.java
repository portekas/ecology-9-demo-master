package weaver.formmode.customjavacode.modeexpand.aliyunApiUtils;

import com.alibaba.fastjson.JSONObject;
import com.aliyun.tea.*;
import com.aliyun.ocr_api20210707.models.*;
import com.aliyun.teaopenapi.models.*;
import com.aliyun.teautil.models.*;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.Map;

/**
 * 创建 刘港 2022-07-06 解析普通电子发票 请求阿里发票识别API
 */
public class RecognitionInvoiceAliApi {

    /**
     * 使用AK&SK初始化账号Client
     * @param accessKeyId
     * @param accessKeySecret
     * @return Client
     * @throws Exception
     */
    private static com.aliyun.ocr_api20210707.Client createClient(String accessKeyId, String accessKeySecret) throws Exception {
        Config config = new Config()
                // 您的 AccessKey ID
                .setAccessKeyId(accessKeyId)
                // 您的 AccessKey Secret
                .setAccessKeySecret(accessKeySecret);
        // 访问的域名
        config.endpoint = "ocr-api.cn-hangzhou.aliyuncs.com";
        return new com.aliyun.ocr_api20210707.Client(config);
    }

    /**
     * 请求阿里云发票接口
     * @param inp
     * @return
     * @throws Exception
     */
    public static JSONObject analyze(InputStream inp,String filetype) throws Exception{
        com.aliyun.ocr_api20210707.Client client = createClient("LTAI5tPQFGeJTQehBDhZ8LUR", "Ncpu88FYiFuq6ZhPnugwnDxf5VOVUa");
        RecognizeInvoiceRequest recognize = new RecognizeInvoiceRequest();
        //将pdf转为图片

        if ("jpg".equalsIgnoreCase(filetype) || "jpeg".equalsIgnoreCase(filetype)
                || "png".equalsIgnoreCase(filetype) || "bmp".equalsIgnoreCase(filetype)) {
            recognize.body = inp;

        }else if("pdf".equalsIgnoreCase(filetype)){
            recognize.body = pdfToImage(inp);

        }else{
            new RuntimeException("附件格式不支持");
        }

        RuntimeOptions runtime = new RuntimeOptions();
        RecognizeInvoiceResponse resp = client.recognizeInvoiceWithOptions(recognize, runtime);
        Map<String,Object> resMap = TeaModel.buildMap(resp);
        JSONObject bodyjson = (JSONObject) JSONObject.toJSON(resMap.get("body"));
        JSONObject Datajson = JSONObject.parseObject((String)JSONObject.toJSON(bodyjson.get("Data")));
        JSONObject datajson = (JSONObject) (Datajson.get("data"));

        return InvoiceCorresField.corres(datajson);
    }

    /**
     * pdf转图片
     */
    private static InputStream pdfToImage(InputStream inp) throws Exception {
        PDDocument document = PDDocument.load(inp);
        InputStream inputStream = null;
        PDFRenderer renderer = new PDFRenderer(document);
        //读取pdf只读第一页
        BufferedImage bufferedImage = renderer.renderImageWithDPI(0, 100);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(bufferedImage, "jpg", out);
        inputStream = new ByteArrayInputStream(out.toByteArray());
        return inputStream;
    }
}
