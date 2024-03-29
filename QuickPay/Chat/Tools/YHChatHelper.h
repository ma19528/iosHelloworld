//
//  YHChatHelper.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHChatServiceDefs.h"
#import <UIKit/UIKit.h>

@class YHChatModel;
@class YHChatListModel;

@interface YHChatHelper : NSObject

//从本地创建一条消息
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID;
+ (YHChatModel *)creatRecvMessage:(NSString *)msg
                          msgType:(YHMessageType)msgType
                          msgBody:(NSString *)msgBody
                          agentID:(NSString *)agentID
                      agentAvater:(NSString *)agentAvater
                        agentName:(NSString *)agentName
                            msgID:(NSString *)msgID
                          msgTime:(NSString *)msgTime;

+ (YHChatListModel *)creatChatListMessage:(NSString *)msg
                                  msgType:(YHMessageType)msgType
                                  msgBody:(NSString *)msgBody
                                  agentID:(NSString *)agentID
                              agentAvater:(NSString *)agentAvater
                                agentName:(NSString *)agentName
                                    msgID:(NSString *)msgID
                                  msgTime:(NSString *)msgTime;
//注册Cell
- (void)registerCellClassWithTableView:(__weak UITableView *)tableView;

//行高
- (CGFloat)heightWithModel:(__weak YHChatModel *)model tableView:(__weak UITableView *)tableView;


+ (NSNumber *)fileType:(NSString *)type;
//获取相应文件类型的图片
+ (UIImage *)imageWithFileType:(YHFileType)type;
@end
