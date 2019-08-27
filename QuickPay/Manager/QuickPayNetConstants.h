//
//  QuickPayNetConstants.h
//  MyProject
//
//  Created by user on 14-3-24.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "YHUserInfo.h"
//#import "AFNetworking.h"


/**********QuickPayNetConstants 的一些宏定义*************/
#define kKey_Params  @"params"
#define kKey_Method  @"method"
#define kKey_ID      @"id"
#define kKey_AgentId @"agent_id"
#define kKey_Token   @"token"

// chat agent 用
#define kKey_Avatar       @"avatar"
#define kKey_Content      @"content"
#define kKey_ContentType  @"content_type"
#define kKey_FromId       @"from_id"
#define kKey_MsgId        @"msg_id"
#define kKey_Nickname     @"nickname"
#define kKey_SendTime     @"send_time"
#define kKey_ToId         @"to_id"

// 获取离线消息请求
#define kReqMethod_ChatOffMsg @"chat.off_msg"
// 聊天初始化，连接上要发送的第一条。
#define kReqMethod_ChatInit @"chat.init"
// 获取支持的支付类型
#define kReqMethod_ChatPay @"chat.pay"
// 正常的聊天类型，包括文本聊天， 请求各种支付信息
#define kReqMethod_ChatAgent @"chat.agent"

//"avatar":"https://www.weilan246.com/images/weilan.jpg",
//"content":"用微信充值",
//"content_type":"2",
//"from_id":"1130610",
//"msg_id":"a507381e-586d-4e24-a782-93a321c96627",
//"nickname":"猪猪侠1",
//"send_time":"1564733213099",
//"to_id":"1"


@interface QuickPayNetConstants : NSObject


+ (QuickPayNetConstants*)sharedInstance;

// 组装 Chat init 请求
- (void)assembleReqChatInit:(NSString *)toUserId isGroupChat:(BOOL)isGroupChat;


@end
