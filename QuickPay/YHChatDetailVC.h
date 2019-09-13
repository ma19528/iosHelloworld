//
//  YHChatDetailVC.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatListModel.h"
#import "PayConfigModel.h"

// @class PayConfigModel;

@interface YHChatDetailVC : UIViewController

// 这里接受直接进来的数据
@property(nonatomic, strong) PayConfigModel *payConfigModel;

// 这里接受从list 进来的数据。
@property(nonatomic, strong) YHChatListModel *chatListModel;


- (void)processMsgEntry:(NSDictionary *)dict;

- (void)processOffSinleMsg:(NSDictionary *)dict;

- (void)processPayMethodMsg:(NSDictionary *)dict;

- (void)processReceivedMsg:(NSDictionary *)dict;

- (void)processChatMsg:(NSDictionary *)dict;
@end
