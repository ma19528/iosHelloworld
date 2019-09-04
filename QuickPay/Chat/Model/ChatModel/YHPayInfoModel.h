//
//  YHChatModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHChatServiceDefs.h"


#pragma mark - 聊天记录Model
@interface YHPayInfoModel : NSObject

@property (nonatomic,assign) int displayType;        // 显示的类型
@property (nonatomic,copy) NSString *payQrcodeUrl;   // 二维码显示地址。
@property (nonatomic,copy) NSString *downUrl;        //二维码下载地址
@property (nonatomic,copy) NSString *accounts;      // 账号的号码
@property (nonatomic,copy) NSString *firstName;     //账号的姓
@property (nonatomic,copy) NSString *lastName;     //用户名
@property (nonatomic,copy) NSString *accountAddr;     // 开户行
@property (nonatomic,copy) NSString *accountSubAddr;     // 开户支行

@property (nonatomic,copy) NSString *extra;      // 额外的字段，json，有可能作为动态提示。


@end


