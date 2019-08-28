//
//  QuickPayNetConstants.m
//  MyProject
//
//  Created by user on 14-3-24.
//
//


#import "QuickPayNetConstants.h"

@interface QuickPayNetConstants ()

@end

@implementation QuickPayNetConstants


+ (QuickPayNetConstants *)sharedInstance {
    static QuickPayNetConstants *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[QuickPayNetConstants alloc] init];
    });
    return g_sharedInstance;
}

/*************
 * 组装如下形式的json串
{
    "id":"f17d25ab-e526-4440-83d9-6b848812b562",
     "method":"chat.init",
     "params":{
        "token":"hUAFOBPk4gqY9HKe"
    }
}
*****************/
- (NSString *)assembleReqChatInit:(NSString *)token {
    NSString *result;
    //NSMutableDictionary *chatInit = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dictChatInit = [NSMutableDictionary dictionary];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    // 设置 key id
    [dictChatInit setObject:uuid forKey:kKey_ID];
    // 设置 key method
    [dictChatInit setObject:kReqMethod_ChatInit forKey:kKey_Method];

    // 因为key params 是一个子json，所以创建子字典。
    NSMutableDictionary *dictParames = [NSMutableDictionary dictionary];
    [dictParames setObject:token forKey:kKey_Token];
    // 设置 key params
    [dictChatInit setObject:dictParames forKey:kKey_Params];

    // 1.判断当前对象是否能够转换成JSON数据.
    // YES if obj can be converted to JSON data, otherwise NO
    BOOL isYes = [NSJSONSerialization isValidJSONObject:dictChatInit];
    if (isYes) {
        NSLog(@"可以转换");
        /* JSON data for obj, or nil if an internal error occurs. The resulting data is a encoded in UTF-8.
         */
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictChatInit options:0 error:NULL];

        result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"组装的 chat.init请求为：%@", result);
        return result;
    } else {
        NSLog(@"JSON数据生成失败，请检查数据格式");
    }
    return nil;
}


/*************
 * 组装如下形式的json串
{
    "id":"c98acc4d-a062-49e1-9379-c732bc33e0f1",
     "method":"chat.off_msg",
     "params":{
        "agent_id":"1"
    }
}
*****************/
- (NSString *)assembleReqOffMsg:(NSString *)agentID {
    return [self assembleReqFuncMsg:kReqMethod_ChatOffMsg agentID:agentID];
}

/*************
 * 组装如下形式的json串
{
    "id":"e24d4cb2-52fe-4fe3-a749-15156bc1a8b1",
    "method":"chat.pay",
    "params":{
        "agent_id":"1"
    }
}
*****************/

- (NSString *)assembleReqChatPay:(NSString *)agentID {
    return [self assembleReqFuncMsg:kReqMethod_ChatPay agentID:agentID];
}

/**********
 *
 * 组装成 我要支付宝充值 的消息。
 *
 * ********/
- (NSString *)assembleSendAlipay:(NSString *)agentID {
    return [self assembleSendPay:ALIPAY agentID:agentID];
}

/**********
 *
 * 组装成 微信充值 的消息。
 *
 * ********/
- (NSString *)assembleSendWeChat:(NSString *)agentID {
    return [self assembleSendPay:WEPAY agentID:agentID];
}

/**********
 *
 * 组装成 银行卡充值 的消息。
 *
 * ********/
- (NSString *)assembleSendBank:(NSString *)agentID {
    return [self assembleSendPay:BANK_CARD agentID:agentID];
}

/**********
 *
 * 组装成 信用卡充值 的消息。
 *
 * ********/
- (NSString *)assembleSendCredit:(NSString *)agentID {
    return [self assembleSendPay:CREDIT_CARD agentID:agentID];
}

/**********
 *
 * 组装成 花呗 充值 的消息。
 *
 * ********/
- (NSString *)assembleSendHuaBie:(NSString *)agentID {
    return [self assembleSendPay:HUA_BEI agentID:agentID];
}

/**********
 *
 * 组装成 已经充值好le  的消息。
 *
 * ********/
- (NSString *)assembleSendOK:(NSString *)agentID {
    return [self assembleSendPay:PAYOK agentID:agentID];
}


- (NSString *)assembleSendNormalText:(NSString *)content agentID:(NSString *)agentID {
    // 在外面传进来的用户头像(config)
    NSString *myAvatar = @"https://www.weilan246.com/images/weilan.jpg";
    NSString *myNickname = @"猪猪侠1";
    NSString *fromID = @"63455";

    // 本次生成的
    NSString *msgID = [[NSUUID UUID] UUIDString];  // 生成 message id
    UInt64 nowTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *sendTime = [NSNumber numberWithLongLong:nowTime];

    return [self assembleSendMsg:kReqMethod_ChatAgent
                        myAvatar:myAvatar
                      myNickname:myNickname
                          msg_id:msgID
                     sendMsgType:TEXT
                     sendContent:content
                         from_id:fromID
                           to_id:agentID
                       send_time:sendTime];
}



/*************
 * 组装如下形式的json串
{
    "id":"e24d4cb2-52fe-4fe3-a749-15156bc1a8b1",
    "method":reqMethod,
    "params":{
        "agent_id":agentID
    }
}
*****************/
- (NSString *)assembleReqFuncMsg:(NSString *)reqMethod agentID:(NSString *)agentID {
    NSString *result;

    NSMutableDictionary *dictChatReq = [NSMutableDictionary dictionary];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    // 设置 key id
    [dictChatReq setObject:uuid forKey:kKey_ID];
    // 设置 key method
    [dictChatReq setObject:reqMethod forKey:kKey_Method];

    // 因为key params 是一个子json，所以创建子字典。
    NSMutableDictionary *dictParames = [NSMutableDictionary dictionary];
    [dictParames setObject:agentID forKey:kKey_AgentId];

    // 设置 key params
    [dictChatReq setObject:dictParames forKey:kKey_Params];

    // 1.判断当前对象是否能够转换成JSON数据.
    // YES if obj can be converted to JSON data, otherwise NO
    BOOL isYes = [NSJSONSerialization isValidJSONObject:dictChatReq];
    if (isYes) {
        NSLog(@"可以转换");
        /* JSON data for obj, or nil if an internal error occurs. The resulting data is a encoded in UTF-8.
         */
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictChatReq options:0 error:NULL];

        result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"组装的请求为：%@", result);
        return result;
    } else {
        NSLog(@"JSON数据生成失败，请检查数据格式");
    }
    return nil;
}


- (NSString *)assembleSendPay:(SendMsgType)content_type agentID:(NSString *)agentID {

    NSDictionary *payDict = @{kPayAlipayKey : kPayAlipay,
            kPayWeChatKey : kPayWeChat,
            kPayBankCardKey : kPayBankCard,
            kPayCreditKey : kPayCredit,
            kPayHuabieKey : kPayHuabie,
            kPayOKKey : kPayOK};

    NSString *key = [self getSendMsgType:content_type];
    NSString *contents = [payDict objectForKey:key];

    // 在外面传进来的用户头像 (config)
    NSString *myAvatar   = @"https://www.weilan246.com/images/weilan.jpg";
    NSString *myNickname = @"猪猪侠1";
    NSString *fromID     = @"63455";

    // 本次生成的
    NSString *msgID = [[NSUUID UUID] UUIDString];  // 生成 message id
    UInt64 nowTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *sendTime = [NSNumber numberWithLongLong:nowTime];

    return [self assembleSendMsg:kReqMethod_ChatAgent
                        myAvatar:myAvatar
                      myNickname:myNickname
                          msg_id:msgID
                     sendMsgType:content_type
                     sendContent:contents
                         from_id:fromID
                           to_id:agentID
                       send_time:sendTime];
}

/*************
 * 组装如下形式的json串
{
    "id":"03e6fff8-5630-421a-ab84-36d2499ebb66",
    "method":"chat.agent",
    "params":{
         "avatar":"https://www.weilan246.com/images/weilan.jpg",
         "nickname":"猪猪侠1",
         "msg_id":"03e6fff8-5630-421a-ab84-36d2499ebb66",
         "content_type":"0",
         "content":"模棱两可",
         "from_id":"1130610",
         "to_id":"1"
         "send_time":"1564733535699",
    }
}
*****************/

- (NSString *)assembleSendMsg:(NSString *)reqMethod
                     myAvatar:(NSString *)avatar
                   myNickname:(NSString *)nickname
                       msg_id:(NSString *)msg_id
                  sendMsgType:(SendMsgType)content_type
                  sendContent:(NSString *)content
                      from_id:(NSString *)from_id
                        to_id:(NSString *)to_id
                    send_time:(NSString *)send_time {
    NSString *result;

    NSMutableDictionary *dictChatReq = [NSMutableDictionary dictionary];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    // 设置 key id, 在这个里面，id 和里面的msgID是一样的。
    [dictChatReq setObject:msg_id forKey:kKey_ID];
    // 设置 key method
    [dictChatReq setObject:reqMethod forKey:kKey_Method];

    // 因为key params 是一个子json，所以创建子字典。
    NSMutableDictionary *dictParames = [NSMutableDictionary dictionary];
    [dictParames setObject:avatar forKey:kKey_Avatar];
    [dictParames setObject:nickname forKey:kKey_Nickname];
    dictParames[kKey_MsgId] = msg_id;
    // TODO... it may be a debug
    dictParames[kKey_ContentType] = [self getSendMsgType:content_type];

    [dictParames setObject:content forKey:kKey_Content];
    [dictParames setObject:from_id forKey:kKey_FromId];
    [dictParames setObject:to_id forKey:kKey_ToId];
    [dictParames setObject:send_time forKey:kKey_SendTime];


    // 设置 key params
    [dictChatReq setObject:dictParames forKey:kKey_Params];

    // 1.判断当前对象是否能够转换成JSON数据.
    // YES if obj can be converted to JSON data, otherwise NO
    BOOL isYes = [NSJSONSerialization isValidJSONObject:dictChatReq];
    if (isYes) {
        NSLog(@"可以转换");
        /* JSON data for obj, or nil if an internal error occurs. The resulting data is a encoded in UTF-8.
         */
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictChatReq options:0 error:NULL];

        result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"组装的请求为：%@", result);
        return result;
    } else {
        NSLog(@"JSON数据生成失败，请检查数据格式");
    }
    return nil;
}

- (NSString *)getSendMsgType:(SendMsgType)msgType {
    switch (msgType) {
        case TEXT:
            return kTextKey;
        case ALIPAY:
            return kPayAlipayKey;
        case WEPAY:
            return kPayWeChatKey;
        case BANK_CARD:
            return kPayBankCardKey;
        case CREDIT_CARD:
            return kPayCreditKey;
        case HUA_BEI:
            return kPayHuabieKey;
        case PAYOK:
            return kPayOKKey;
        case IMAGE:
            return kImageKey;
        default:
            return @"";
    }
}


@end
