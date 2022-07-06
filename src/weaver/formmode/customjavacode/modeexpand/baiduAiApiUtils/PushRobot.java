package weaver.formmode.customjavacode.modeexpand.baiduAiApiUtils;

import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * 创建 刘港 2022-05-05 异常或失败请求推送钉钉机器人消息
 */
public class PushRobot {
    public static void pushRobot(String type,String text){
        try {
            String jqrUrl = "https://oapi.dingtalk.com/robot/send?access_token=0bee9aad7e37fc61f04647da9a965f5aff56922afd34e124e7cc988ed0f4c569";
            URL reqURL = new URL(jqrUrl); //创建URL对象
            StringBuilder stringA = new StringBuilder();
            stringA.append("{'at':{'atMobiles':[''],'atUserIds':[''],'isAtAll':false},'text':{'content':'"+type+"\n"+text+"'},'msgtype':'text'}");
            HttpURLConnection httpsConn = (HttpURLConnection)reqURL.openConnection();
            httpsConn.setDoOutput(true);
            httpsConn.setRequestMethod("POST");
            httpsConn.setRequestProperty("Content-type", "application/json");
            httpsConn.setRequestProperty("Accept-Charset", "utf-8");
            httpsConn.setRequestProperty("contentType", "utf-8");
            httpsConn.setRequestProperty("Content-Length", String.valueOf(stringA.length()));
            OutputStreamWriter out = new OutputStreamWriter(httpsConn.getOutputStream(),"utf-8");
            out.write(stringA.toString());
            out.flush();
            out.close();
            InputStreamReader insr = new InputStreamReader(httpsConn.getInputStream(),"utf-8");
            String result = "";
            int respInt = insr.read();
            while(respInt != -1){
                result += (char)respInt;
                respInt = insr.read();
            }
//            System.out.println(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
