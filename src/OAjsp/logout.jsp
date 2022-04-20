<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>退出</title>

<script type="text/javascript" src="/cloudstore/resource/pc/jquery/jquery.min.js"></script>
<script>
    {
        $.ajax({
            url: "/api/hrm/login/checkLogout",
            type: "post",
            data: {status: "1"},
            success: function success(msg) {
                opener.location.href="http://220.189.214.90:2019/";
                setTimeout(function(){
                    window.close();
                },300);
            }
        })
    }

</script>
</head>


<body style="text-align: center;margin-top: 3%">
    <div><a>退出成功</a></div>
</body>
</html>
