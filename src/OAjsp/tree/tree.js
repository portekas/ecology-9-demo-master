$(function() {
    $("#rebut").click(function(){
        if($("#weleft").hasClass("ant-col-lg-5")){
            $("#weleft").attr("class","wea-left-right-layout-left ant-col-xs-0 ant-col-sm-0 ant-col-md-0 ant-col-lg-0");
        }else{
            $("#weleft").attr("class","wea-left-right-layout-left ant-col-xs-8 ant-col-sm-7 ant-col-md-6 ant-col-lg-5");
            $("#weleft").css({"overflow":"auto"});
        }
    })

});
function attifram(url){
    $('#lbifram').attr("src",url);
}