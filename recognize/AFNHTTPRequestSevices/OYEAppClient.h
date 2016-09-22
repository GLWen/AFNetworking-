//
//  OYEAppClient.h
//  recognize
//
//  Created by 温国力 on 16/9/22.
//  Copyright © 2016年 wenguoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"


@interface OYEAppClient : AFHTTPSessionManager

+ (instancetype)sharedClient;


@end
