//
//  CellChatAlipayLeft.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatHuabieLeft;
@protocol CellChatHuabieLeftDelegate <NSObject>

- (void)onChatHuabie:(YHChatModel*)chatFile inLeftCell:(CellChatHuabieLeft *)leftCell;

@end

@interface CellChatHuabieLeft : CellChatBase

@property (nonatomic,assign)id<CellChatHuabieLeftDelegate>delegate;

@end
