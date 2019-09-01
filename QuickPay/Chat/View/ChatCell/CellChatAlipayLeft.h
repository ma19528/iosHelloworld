//
//  CellChatAlipayLeft.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatAlipayLeft;
@protocol CellChatAlipayLeftDelegate <NSObject>

- (void)onChatAlipay:(YHChatModel*)chatFile inLeftCell:(CellChatAlipayLeft *)leftCell;

@end

@interface CellChatAlipayLeft : CellChatBase

@property (nonatomic,assign)id<CellChatAlipayLeftDelegate>delegate;

@end
