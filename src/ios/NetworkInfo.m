/********* NetworkInfo.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworkReachabilityManager.h"

#include <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "getgateway.h"

@interface NetworkInfo : CDVPlugin<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CDVInvokedUrlCommand* command;



- (void)coolMethod:(CDVInvokedUrlCommand*)command;
- (void)getWifiSSID:(CDVInvokedUrlCommand*)command;
- (void)networkStatus:(CDVInvokedUrlCommand*)command;
- (void)getWifiRouterIP:(CDVInvokedUrlCommand*)command;
- (void)getWifiIP:(CDVInvokedUrlCommand*)command;
- (void)getNetworkInfo:(CDVInvokedUrlCommand*)command;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

@implementation NetworkInfo

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self searchWIFIName];
    }
}

- (void)getWifiSSID:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            _command = command;
            if (@available(iOS 13, *)) {
                
                if (!self.locationManager) {
                    self.locationManager = [[CLLocationManager alloc] init];
                    self.locationManager.delegate = self; // Tells the location manager to send updates to this object
                }
                
                if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {//开启了权限，直接搜索
                    [self searchWIFIName];
                }
                else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied) {//如果用户没给权限，则提示
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"你关闭了定位权限，导致无法使用WIFI功能"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
                    _command = nil;
                }
                else { // 请求权限
                    
                    if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
                        [self.locationManager requestWhenInUseAuthorization];
                    } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                        [self.locationManager  requestAlwaysAuthorization];
                    }
                }
            }
            else {
                [self searchWIFIName];
            }
            
        });
    }];
}

- (void)networkStatus:(CDVInvokedUrlCommand*)command
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        CDVPluginResult* pluginResult = nil;
        NSString *network = @"error";
        NSDictionary *infoDic;
        switch (status) {
            case -1:
                network = @"未知网络";
                infoDic = @{@"code":@"-1", @"desc":network};
                NSLog(@"未知网络");
                break;
            case 0:
                network = @"网络不可用";
                infoDic = @{@"code":@"0", @"desc":network};
                NSLog(@"网络不可用");
                break;
            case 1:
                network = @"移动网络";
                infoDic = @{@"code":@"1", @"desc":network};
                NSLog(@"GPRS网络");
                break;
            case 2:
                network = @"wifi网络";
                infoDic = @{@"code":@"2", @"desc":network};
                NSLog(@"wifi网络");
                break;
            default:
                break;
        }

        if(status != AFNetworkReachabilityStatusReachableViaWiFi)
        {
            network = @"wifi断开";
            infoDic = @{@"code":@"3", @"desc":network};
            NSLog(@"wifi断开");
        }
        if (infoDic)
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:infoDic options:1 error:nil];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    }];
}

- (void)getWifiRouterIP:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    NSString *routerIP = [self routerIP][@"routerip"];
    if ([routerIP length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:routerIP];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)getWifiIP:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;

    NSString *localIP = [self routerIP][@"localip"];
    if ([localIP isEqualToString:@"error"] || [localIP length] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:localIP];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)getNetworkInfo:(CDVInvokedUrlCommand*)command
{
    NSDictionary *infoDic = [self routerIP];
    NSData *data = [NSJSONSerialization dataWithJSONObject:infoDic options:1 error:nil];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSDictionary *)routerIP
{
    NSString *address = @"error";
    NSString *localIp = @"error";
    NSString *netmask = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr)->sin_addr)];
                    // 广播地址
                    NSLog(@"broadcast address : %@", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    // 本机地址
                    NSLog(@"local device ip : %@", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                    localIp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    // 子网掩码
                    NSLog(@"netmask : %@", [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    // 端口地址
                    NSLog(@"interface : %@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    
    // Free memory
    freeifaddrs(interfaces);

    in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x =&i;


    unsigned char *s=  getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];

    NSLog(@"路由器地址-----%@",ip);
    
    NSDictionary *result = @{@"routerip":ip, @"localip":localIp, @"netmask":netmask};

    return result;
}


- (void)searchWIFIName
{
    NSString *ssid = @"error";
    NSString *bssid = @"error";
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *item in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item);
        NSLog(@"info : %@",info);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
        if (info[@"BSSID"]) {
            bssid = info[@"BSSID"];
        }
    }
    
    NSDictionary *info = @{@"ssid":ssid, @"bssid":bssid};
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:1 error:nil];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
    _command = nil;
}

@end
