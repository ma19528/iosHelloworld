//
//  CellChatList.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHChatModel;
@class CellChatPayList;

@protocol CellChatPayListDelegate<NSObject>
- (void)touchOnCell:(CellChatPayList *)cell;
- (void)onAvatarInCell:(CellChatPayList *)cell;
@end

@interface CellChatPayList : UITableViewCell

@property (nonatomic,strong) YHChatModel *model;
@property (nonatomic,weak) id <CellChatPayListDelegate> touchDelegate;
@end
