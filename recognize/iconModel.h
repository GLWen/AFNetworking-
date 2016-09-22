//
//  iconModel.h
//  recognize
//
//  Created by 温国力 on 16/9/22.
//  Copyright © 2016年 wenguoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface iconModel : NSObject
/** 用户的头像 */
@property (nonatomic, copy) NSString *result;

@property (nonatomic, copy) NSString *error_code;

@property (nonatomic, copy) NSString *reason;
@end
