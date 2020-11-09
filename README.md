 cordova.plugin.networkinfo - 1.0.0<!-- omit in toc -->

 注意！！！ 测试务必在真机下运行，目标该仅支持iOS
 注意！！！ 测试务必在真机下运行，目标该仅支持iOS
 注意！！！ 测试务必在真机下运行，目标该仅支持iOS

 iOS12+获取ssid需开启定位且在开发者证书开启Access WiFi Information

## wifiSSID 

获取的ssid

用法示例
cordova.plugins.NetworkInfo.wifiSSID(function(data) {
    console.log('wifiSSID:'+data);
}, function (error) {
    alert('error:'+error);
});

数据示例
{
	"ssid":"ssid",
	"bssid":"bssid"
}


## networkStatus 
获取网络状态

用法示例
cordova.plugins.NetworkInfo.networkStatus(function(data) {
    console.log('networkStatus:'+data);
}, function (error) {
    alert('error:'+error);
});

数据示例
{
	"code":0,
	"desc":"网络不可用"
}
code说明：-1 未知网络， 0 网络不可用， 1 移动网络， 2 wifi网络， 3 wifi断开


## getWifiRouterIP 
获取路由网关IP

用法示例
cordova.plugins.NetworkInfo.getWifiRouterIP(function(data) {
    console.log('get router ip:'+data);
}, function (error) {
    alert('error:'+error);
});
数据返回：String routerip


## getWifiIP 
获取本机IP

用法示例
cordova.plugins.NetworkInfo.getWifiIP(function(data) {
    console.log('get wifi ip:'+data);
}, function (error) {
    alert('error:'+error);
});
数据返回：String localip


## getNetworkInfo 
获取网络信息，包括网关IP，本机IP，子网掩码

用法示例
cordova.plugins.NetworkInfo.getWifiInfo(function(data) {
    console.log('get wifi info:'+data);
    alert(data);
}, function (error) {
    alert('error:'+error);
});

数据示例
{
	"routerip": "192.168.1.1",
	"localip": "192.168.1.100",
	"netmask": "255.255.255.0"
}

