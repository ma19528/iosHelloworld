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

@interface YHChatShowBank : UIViewController

@property (nonatomic,strong) YHPayInfoModel     *model;
@property (nonatomic,strong)QuickPayConfigModel *quickPayConfigModel;



@end