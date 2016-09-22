//
//  OYEAppClient.m
//  recognize
//
//  Created by 温国力 on 16/9/22.
//  Copyright © 2016年 wenguoli. All rights reserved.
//

#import "OYEAppClient.h"
static NSString *const APIBaseURLString = @"http://v.juhe.cn/certificates";


@implementation OYEAppClient

+ (instancetype)sharedClient
{
    static OYEAppClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OYEAppClient alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
    });
    return _sharedClient;
}
#pragma mark - 重写initWithBaseURL
/**
 *
 *
 *  @param url baseUrl
 *
 *  @return 通过重写夫类的initWithBaseURL方法,返回网络请求类的实例
 */

-(instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        /**设置请求超时时间*/
        self.requestSerializer.timeoutInterval = 3;
        /**设置相应的缓存策略*/
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        /**分别设置请求以及相应的序列化器*/
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        self.responseSerializer = response;
        
        
        /**复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /**设置接受的类型*/
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html", nil]];
        
    }
    
    return self;
}
@end
