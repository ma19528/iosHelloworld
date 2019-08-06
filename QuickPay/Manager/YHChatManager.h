//
//  YHChatManager.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/16.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <SocketRocket.h>
#import <SocketRocket/SRWebSocket.h>


extern NSString * const kNeedPayOrderNote;
extern NSString * const kWebSocketDidOpenNote;
extern NSString * const kWebSocketDidCloseNote;
extern NSString * const kWebSocketdidReceiveMessageNote;

@interface YHChatManager : NSObject

+ (YHChatManager*)sharedInstance;

//连接
- (void)connectToUserID:(NSString *)toUserId isGroupChat:(BOOL)isGroupChat;


/** 获取连接状态 */
@property (nonatomic,assign,readonly) SRReadyState socketReadyState;

/** 开始连接 */
- (void)SRWebSocketOpenWithURLString:(NSString *)urlString;

/** 关闭连接 */
- (void)SRWebSocketClose;

/** 发送数据 */
- (void)sendData:(id)data;


@end
