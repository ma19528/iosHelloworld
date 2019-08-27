//
//  YHChatListModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/23.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  聊天列表

#import <Foundation/Foundation.h>
#import "YHChatTouch.h"

@interface YHChatListModel : NSObject

@property(nonatomic, copy) NSString *chatId;
@property(nonatomic, assign) BOOL isGroupChat;     // 0：单聊内容 1： 群聊内容。
@property(nonatomic, copy) NSString *lastContent;  // 显示的是最后一条内容
@property(nonatomic, assign) int msgType;          // 0是文本 1是图片 2是语音 3是文件 4是gif
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSString *sessionUserId;
@property(nonatomic, copy) NSString *sessionUserName;
@property(nonatomic, assign) BOOL isRead;
@property(nonatomic, assign) int memberCount;
@property(nonatomic, copy) NSString *groupName;
@property(nonatomic, copy) NSString *creatTime;      //发布时间
@property(nonatomic, copy) NSString *lastCreatTime;
@property(nonatomic, strong) NSArray < NSURL *> *sessionUserHead;
@property(nonatomic, copy) NSString *msgId;
@property(nonatomic, assign) int status;             //消息是否已撤回
@property(nonatomic, copy) NSString *updateTime;

@property(nonatomic, strong) YHChatTouch *touchModel;
@end

