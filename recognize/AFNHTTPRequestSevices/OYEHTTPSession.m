//
//  OYEHTTPSession.m
//  recognize
//
//  Created by 温国力 on 16/9/22.
//  Copyright © 2016年 wenguoli. All rights reserved.
//
//调试、发布
#ifdef DEBUG
#define GlLog(...) NSLog(__VA_ARGS__)
#else
#define GlLog(...)
#endif
#define GlLogFunc GlLog(@"%s", __func__);


#import "OYEHTTPSession.h"
#import "OYEAppClient.h"
#import "OYEUploadParam.h"
@implementation OYEHTTPSession

#pragma mark - GRT请求
+ (nullable NSURLSessionDataTask *)GET:(nonnull NSString *)urlString
                             paraments:(nullable id)paraments
                         completeBlock:(nullable completeBlock)completeBlock
{
    return [[OYEAppClient sharedClient] GET:urlString
                                parameters:paraments
                                  progress:^(NSProgress * _Nonnull downloadProgress) {
                                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      
                                      completeBlock(responseObject,nil);
                                      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                                      GlLog(@"dict start ----\n%@   \n ---- end  -- ", dict);
                                      
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      
                                      completeBlock(nil,error);
                                      GlLog(@"%@", [error localizedDescription]);
                                      
                                  }];
}
#pragma mark - POST请求
+ (nullable NSURLSessionDataTask *)POST:(nonnull NSString *)urlString
                              paraments:(nullable id)paraments
                          completeBlock:(nullable completeBlock)completeBlock
{
    // 不加上这句话，会报“Request failed: unacceptable content-type: text/plain”错误
    [OYEAppClient sharedClient].requestSerializer = [AFJSONRequestSerializer serializer];//请求
    [OYEAppClient sharedClient].responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    return [[OYEAppClient sharedClient] POST:urlString
                                  parameters:paraments progress:nil
                                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                                         completeBlock(responseObject,nil);
                                         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                                         GlLog(@"dict start ----\n%@   \n ---- end  -- ", dict);
        
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
                                         completeBlock(nil,error);
                                         GlLog(@"%@", [error localizedDescription]);
        
                                     }];
}
#pragma mark - GET/POST请求简化
+ (nullable NSURLSessionDataTask *)requestWithRequestType:(HTTPSRequestType)type
                                                urlString:(nonnull NSString *)urlString
                                                paraments:(nullable id)paraments
                                            completeBlock:(nullable completeBlock)completeBlock
{
    switch (type) {
        case HTTPSRequestTypeGet:
        {
            return [OYEHTTPSession GET:urlString paraments:paraments completeBlock:^(id  _Nullable responseObject, NSError * _Nullable error) {
                completeBlock(responseObject,error);
            }];
        }
        case HTTPSRequestTypePost:
            return [OYEHTTPSession POST:urlString paraments:paraments completeBlock:^(id  _Nullable responseObject, NSError * _Nullable error) {
                completeBlock(responseObject,error);
            }];
    }
    
}
#pragma mark - 上传图片
+ (NSURLSessionDataTask *)uploadWithURLString:(NSString *)URLString parameters:(id)parameters uploadParam:(OYEUploadParam *)uploadParam completeBlock:(completeBlock)completeBlock
{
    [OYEAppClient sharedClient].requestSerializer = [AFJSONRequestSerializer serializer];
    [OYEAppClient sharedClient].responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return [[OYEAppClient sharedClient] POST:URLString
                                  parameters:parameters
                   constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                       [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.filename mimeType:uploadParam.mimeType];
                   } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                       
                       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                       GlLog(@"dict start ----\n%@   \n ---- end  -- ", dict);
                       completeBlock(responseObject,nil);
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       
                       GlLog(@"%@", [error localizedDescription]);
                       completeBlock(nil,error);
                       
                   }];
}

#pragma mark -  取消所有的网络请求
/**
 *  取消所有的网络请求
 *  a finished (or canceled) operation is still given a chance to execute its completion block before it iremoved from the queue.
 */
+(void)cancelAllRequest
{
    [[OYEAppClient sharedClient].operationQueue cancelAllOperations];
}
#pragma mark -   取消指定的url请求/
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的完整url
 */

+(void)cancelHttpRequestWithRequestType:(NSString *)requestType
                       requestUrlString:(NSString *)string
{
    NSError * error;
    /**根据请求的类型 以及 请求的url创建一个NSMutableURLRequest---通过该url去匹配请求队列中是否有该url,如果有的话 那么就取消该请求*/
    NSString * urlToPeCanced = [[[[OYEAppClient sharedClient].requestSerializer
                                  requestWithMethod:requestType
                                  URLString:string
                                  parameters:nil error:&error] URL] path];
    
    for (NSOperation * operation in [OYEAppClient sharedClient].operationQueue.operations) {
        //如果是请求队列
        if ([operation isKindOfClass:[NSURLSessionTask class]]) {
            //请求的类型匹配
            BOOL hasMatchRequestType = [requestType isEqualToString:[[(NSURLSessionTask *)operation currentRequest] HTTPMethod]];
            //请求的url匹配
            BOOL hasMatchRequestUrlString = [urlToPeCanced isEqualToString:[[[(NSURLSessionTask *)operation currentRequest] URL] path]];
            //两项都匹配的话  取消该请求
            if (hasMatchRequestType&&hasMatchRequestUrlString) {
                [operation cancel];
            }
        }
    }
}
#pragma mark - 检查网络状态
- (void)AFNetworkStatus
{
    
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                networkReachabilityStatusUnknown();
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                networkReachabilityStatusReachableViaWWAN();
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                
                break;
                
            default:
                break;
        }
        
    }] ;
}

void networkReachabilityStatusUnknown()
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已关闭蜂窝移动数据" message:@"您可以在”设置“中为此应用程序打开蜂窝移动数据。" preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"设置"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                canOpenURLString(@"prefs:root=MOBILE_DATA_SETTINGS_ID");
        
                                                }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"好"
                                              style:UIAlertActionStyleCancel handler:nil]];
}

void networkReachabilityStatusReachableViaWWAN()
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"正在使用流量，确定要使用流量吗？" message:@"建议开启WIFI后观看视频。"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"设置"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                canOpenURLString(@"prefs:root=MOBILE_DATA_SETTINGS_ID");
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"好"
                                              style:UIAlertActionStyleCancel handler:nil]];
}

void canOpenURLString(NSString *myURLString)
{
    [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:myURLString]];
}
@end
