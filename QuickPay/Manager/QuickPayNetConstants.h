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

#define kTextKey     @"0"
#define kPayAlipayKey   @"1"
#define kPayWeChatKey   @"2"
#define kPayBankCardKey @"3"
#define kPayCreditKey   @"4"
#define kPayHuabieKey   @"5"
#define kPayOKKey       @"6"
#define kImageKey       @"7"

#define kPayAlipay   @"用支付宝充值"
#define kPayWeChat   @"用微信充值"
#define kPayBankCard @"用银行卡充值"
#define kPayCredit   @"用信用卡充值"
#define kPayHuabie   @"用花呗充值"
#define kPayOK       @"我已经充好了"

 typedef enum  {
     TEXT = 0,           // 文本消息
     ALIPAY,             // 支付宝充值消息
     WEPAY,              // 微信充值消息
     BANK_CARD,          // 银行卡充值消息
     CREDIT_CARD,        // 信用卡充值消息
     HUA_BEI,            // 花呗充值消息
     PAYOK,              // 我充好了。

     IMAGE, //图片消息
     AUDIO, //语音消息
     VIDEO, //视频消息
     FILE_TYPE,  //文件消息
     LOCATION, //位置消息
 } SendMsgType;




@interface QuickPayNetConstants : NSObject


+ (QuickPayNetConstants*)sharedInstance;

// 组装 Chat init 请求
- (NSString *)assembleReqChatInit:(NSString *)token;

// 组装 离线消息 off msg 请求
- (NSString *)assembleReqOffMsg:(NSString *)agentID;
// 组装 支持的支付类型 chat pay 请求
- (NSString *)assembleReqChatPay:(NSString *)agentID;

// 组装 我想支付包充值 请求
- (NSString *)assembleSendAlipay:(NSString *)agentID;
- (NSString *)assembleSendWeChat:(NSString *)agentID;
- (NSString *)assembleSendBank:(NSString *)agentID;
- (NSString *)assembleSendCredit:(NSString *)agentID;
- (NSString *)assembleSendHuaBie:(NSString *)agentID;
- (NSString *)assembleSendOK:(NSString *)agentID;



// 构造功能性的请求，如离线消息，支付类型类型。
- (NSString *)assembleReqFuncMsg:(NSString *)reqMethod agentID:(NSString *)agentID;
// 构造聊天性的请求，如文本聊天聊天，发送图片，发送我想进行支付包微信充值等。类型。
- (NSString *)assembleSendMsg:(NSString *)reqMethod
                     myAvatar:(NSString *)avatar
                   myNickname:(NSString *)nickname
                       msg_id:(NSString *)msg_id
                  sendMsgType:(SendMsgType) content_type
                  sendContent:(NSString *)content
                      from_id:(NSString *)from_id
                        to_id:(NSString *)to_id
                    send_time:(NSString *)send_time;
- (NSString *)assembleSendPay:(SendMsgType)content_type agentID:(NSString *)agentID;
- (NSString *)assembleSendNormalText:(NSString *)content agentID:(NSString *)agentID;

- (NSString *) getSendMsgType:(SendMsgType)msgType;
@end
