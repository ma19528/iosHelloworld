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
#import "YHChatTextLayout.h"
#import "YHFileModel.h"
#import "YHGIFModel.h"

extern NSString *serviceToken;           // Token
extern NSString *myID ;                  // 本人的ID
extern NSString *myNickName ;            // 本人的昵称
extern NSString *myAvater ;              // 本人的头像
extern NSString *agentID ;               // 发送给那个代理
extern NSString *agentNickName ;         // 代理的昵称
extern NSString *agentAvater ;           // 代理的头像
extern NSString *uploadPicHost ;         // 图片上传的主机，要更换。
extern NSString *packageName ;
extern NSString *preFixWs ;
extern NSString *wsServiceAddr ;         //[NSString initWithFormat:@"%@,%@", preFixWs, serviceToken ];



#pragma mark - 聊天记录Model
@interface ChatInfo : NSObject


@end




