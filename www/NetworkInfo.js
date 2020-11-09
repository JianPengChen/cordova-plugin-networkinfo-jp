var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'NetworkInfo', 'coolMethod', [arg0]);
};
exports.wifiSSID = function (success, error) {
    exec(success, error, 'NetworkInfo', 'getWifiSSID', []);
};
exports.networkStatus = function (success, error) {
    exec(success, error, 'NetworkInfo', 'networkStatus', []);
};
exports.getWifiRouterIP = function (success, error) {
    exec(success, error, 'NetworkInfo', 'getWifiRouterIP', []);
};
exports.getWifiIP = function (success, error) {
    exec(success, error, 'NetworkInfo', 'getWifiIP', []);
};
exports.getNetworkInfo = function (success, error) {
    exec(success, error, 'NetworkInfo', 'getNetworkInfo', []);
};