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

#define kTextKey        @"0"
#define kPayAlipayKey   @"1"
#define kPayWeChatKey   @"2"
#define kPayBankCardKey @"3"
#define kPayCreditKey   @"4"
#define kPayHuabieKey   @"5"
#define kPayOKKey       @"6"
#define kImageKey       @"7"

#define keybordPayAlipay   @"支付宝"  //@"用支付宝充值"
#define keybordPayWeChat   @"微信"  //@"用微信充值"
#define keybordPayBankCard @"银行卡"  //@"用银行卡充值"
#define keybordPayCredit   @"信用卡"  //@"用信用卡充值"
#define keybordPayHuabie   @"花呗"  //@"用花呗充值"
#define keybordPayOK       @"我已经充好了"

#define kPayAlipay   @"用支付宝充值"
#define kPayWeChat   @"用微信充值"
#define kPayBankCard @"用银行卡充值"
#define kPayCredit   @"用信用卡充值"
#define kPayHuabie   @"用花呗充值"
#define kPayOK       @"我已经充好了"

#define kPayTipsPay       @"收款"

typedef enum {
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


typedef enum {
    Show_All = 0,           // 所有
    Show_Qrcode,            // 二维码
    Show_Account,           // 账号
    Show_Both               // 所有
} DisplayType;

//---------------------json 解析
//---1
#define kKey_code  @"code"
#define kKey_jsonrpc  @"jsonrpc"
#define kKey_message  @"message"
#define kKey_result   @"result"
// ----2
#define kKey_emit     @"emit"
#define kKey_data     @"data"
// -----3---pay support
#define kKey_id       @"id"
#define kKey_support  @"support"
// -----3--receive msg
#define kKey_msgId       @"msgId"
#define kKey_status      @"status"
#define kKey_msg         @"msg"
// ----3--off single
#define kKey_from_id       @"from_id"
// kKey_data
// ---3,5 normal msg,如果是 off-single，则包括每个代理的最后一条normal消息。
#define kKey_msgType     @"msgType"
#define kKey_sendTime    @"sendTime"
#define kKey_formId      @"formId"
#define kKey_formId      @"formId"
#define kKey_nickname    @"nickname"
#define kKey_avatar      @"avatar"
#define kKey_body        @"body"
#define kKey_message     @"message"

// 3 --- 支付信息
#define kKey_accounts      @"accounts"        // 账号
#define kKey_firstName     @"firstName"       // 姓
#define kKey_lastName      @"lastName"        // 名
#define kKey_payQrcodeUrl    @"payQrcodeUrl"    // 二维码地址
#define kKey_displayType     @"displayType"      // 显示方式
#define kKey_extra           @"extra"            // 额外数据。提示。
#define kKey_accountAddr     @"accountAddr"      // 开户行主地址
#define kKey_accountSubAddr  @"accountSubAddr"   // 开户行次地址
#define kKey_downUrl         @"downUrl"   // 二维码下载地址

#define kValueEmit_off_single @"off_single"   // 离线消息
#define kValueEmit_pay_method @"pay_method"   // 支持支付类型
#define kValueEmit_receive    @"receive"      // 消息回执
#define kValueEmit_chat       @"chat"         // 聊天（普通文本，图片，支付信息）注意的 各种聊天类型用的不同的data body。 要分开解析

#define kValueSucessCode   0
#define kValueSucessMsg    @"Success"

@interface QuickPayNetConstants : NSObject


+ (QuickPayNetConstants *)sharedInstance;

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
                  sendMsgType:(SendMsgType)content_type
                  sendContent:(NSString *)content
                      from_id:(NSString *)from_id
                        to_id:(NSString *)to_id
                    send_time:(NSString *)send_time;

- (NSString *)assembleSendPay:(SendMsgType)content_type agentID:(NSString *)agentID;

- (NSString *)assembleSendNormalText:(NSString *)content agentID:(NSString *)agentID;

- (NSString *)getSendMsgType:(SendMsgType)msgType;


@end
