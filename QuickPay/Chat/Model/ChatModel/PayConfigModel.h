//
//  PayConfigModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

// 导出给外面的model
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHChatServiceDefs.h"
#import "YHChatTextLayout.h"
#import "YHFileModel.h"
#import "YHGIFModel.h"

#pragma mark - 聊天记录Model
@interface PayConfigModel : NSObject

@property (nonatomic,copy) NSString *serviceToken;   // 这个是 websocet 的服务token
@property (nonatomic,copy) NSString *myID;           // 本人的ID
@property (nonatomic,copy) NSString *myNickName;     //
@property (nonatomic,copy) NSString *myAvater;       //
@property (nonatomic, assign) NSInteger myAvaterID;  // 如果 myAvatar 没有值，就用本地的ID

@property (nonatomic,copy) NSString *agentId;       // 代理Id
@property (nonatomic,copy) NSURL *agentNickName;    // 代理名字
@property (nonatomic,copy) NSString *agentAvater;   // 代理头像
@property (nonatomic,copy) NSString *uploadPicHost;
@property (nonatomic,copy) NSString *wsServiceAddr;

@property (nonatomic,copy) NSString *getTokenAddr;
@property (nonatomic,copy) NSString *accountType;   // 默认为 2
@property (nonatomic,copy) NSString *tokenSign;     // @"yHlm^5pR3vs3Lxr^2VfA";



@end


