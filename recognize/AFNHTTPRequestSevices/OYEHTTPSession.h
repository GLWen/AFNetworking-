//
//  OYEHTTPSession.h
//  recognize
//
//  Created by 温国力 on 16/9/22.
//  Copyright © 2016年 wenguoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
@class OYEUploadParam;

/**
 *  网络请求类型
 */
typedef NS_ENUM(NSUInteger,HTTPSRequestType)
{
    /**
     *  get请求
     */
    HTTPSRequestTypeGet = 0,
    /**
     *  post请求
     */
    HTTPSRequestTypePost
};
/**
 *  成功后回调出去
 *
 *  @param responseObject 请求成功的回调
 *  @param error          请求失败的回调
 */
typedef void(^completeBlock)( id _Nullable responseObject,NSError * _Nullable error);


@interface OYEHTTPSession : NSObject


/**
 *  发送get请求
 *
 *  @param urlString     请求的网址需要拼接的字符串
 *  @param paraments     请求的参数
 *  @param completeBlock 请求的回调
 *
 */
+ (nullable NSURLSessionDataTask *)GET:(nonnull NSString *)urlString
                             paraments:(nullable id)paraments
                         completeBlock:(nullable completeBlock)completeBlock;
/**
 *  发送post请求
 *
 *  @param urlString     请求的网址需要拼接的字符串
 *  @param paraments     请求的参数
 *  @param completeBlock 请求的回调
 *
 */
+ (nullable NSURLSessionDataTask *)POST:(nonnull NSString *)urlString
                              paraments:(nullable id)paraments
                          completeBlock:(nullable completeBlock)completeBlock;
/**
 *  发送get/post请求
 *
 *  @param type          请求类型
 *  @param urlString     请求的网址需要拼接的字符串
 *  @param paraments     请求的参数
 *  @param completeBlock 请求的回调
 *
 */
+ (nullable NSURLSessionDataTask *)requestWithRequestType:(HTTPSRequestType)type
                                                urlString:(nonnull NSString *)urlString
                                                paraments:(nullable id)paraments
                                            completeBlock:(nullable completeBlock)completeBlock;
/**
 *  发送post请求上传图片
 *
 *  @param URLString     请求的网址需要拼接的字符串
 *  @param parameters    请求的参数
 *  @param uploadParam   请求图片的参数
 *  @param completeBlock 请求的回调
 *
 */
+ (nullable NSURLSessionDataTask *)uploadWithURLString:(nonnull NSString *)URLString
                                            parameters:(nullable id)parameters
                                           uploadParam:(nullable OYEUploadParam *)uploadParam
                                         completeBlock:(nullable completeBlock)completeBlock;
/**
 *  检查网络状态
 */
- (void)AFNetworkStatus;


@end
