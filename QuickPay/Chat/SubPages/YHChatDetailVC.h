//
//  YHChatDetailVC.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatListModel.h"

@class QuickPayConfigModel;

@interface YHChatDetailVC : UIViewController

@property (nonatomic,strong)YHChatListModel     *model;
@property (nonatomic,strong)QuickPayConfigModel *quickPayConfigModel;


- (void)processMsgEntry:(NSDictionary *)dict;
- (void)processOffSinleMsg:(NSDictionary *)dict;
- (void)processPayMethodMsg:(NSDictionary *)dict;
- (void)processReceivedMsg:(NSDictionary *)dict;
- (void)processChatMsg:(NSDictionary *)dict ;
@end
