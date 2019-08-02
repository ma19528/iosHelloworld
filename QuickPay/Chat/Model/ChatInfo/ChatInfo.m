//
//  YHChatModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "ChatInfo.h"

// 全局变量
NSString *serviceToken = @"ldMSnrHQWeEw6ciw";
NSString *myID = @"1130610";               // 本人的ID
NSString *myNickName = @"猪猪侠1";          // 本人的昵称
NSString *myAvater = @"https://www.weilan246.com/images/weilan.jpg";  // 本人的头像
NSString *agentID = @"1";                          // 发送给那个代理
NSString *agentNickName = @"VIP 24小时服务";         // 代理的昵称
NSString *agentAvater = @"https://static.oschina.net/uploads/space/2015/0629/170157_rxDh_1767531.png";  // 代理的头像
NSString *uploadPicHost = @"http://192.168.188.126:9501/im/image?serviceToken=";  // 图片上传的主机，要更换。
NSString *packageName = @"com.jbl.quickpay";
NSString *preFixWs = @"ws://192.168.188.126:9512/websocket?token=";

NSString *wsServiceAddr = @"ws://192.168.188.126:9512/websocket?token=ldMSnrHQWeEw6ciw";     //[NSString initWithFormat:@"%@,%@", preFixWs, serviceToken ];




@implementation ChatInfo


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


@end


