//
//  YHChatDetailVC.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatModel.h"

@class QuickPayConfigModel;

@interface YHChatShowAlipay : UIViewController

@property (nonatomic,strong) YHChatModel     *model;
@property (nonatomic,strong)QuickPayConfigModel *quickPayConfigModel;



@end
