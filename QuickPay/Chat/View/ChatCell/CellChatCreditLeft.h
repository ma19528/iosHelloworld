//
//  CellChatAlipayLeft.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatCreditLeft;
@protocol CellChatCreditLeftDelegate <NSObject>

- (void)onChatCredit:(YHChatModel *)chatFile inLeftCell:(CellChatCreditLeft *)leftCell;

@end

@interface CellChatCreditLeft : CellChatBase

@property (nonatomic,assign)id<CellChatCreditLeftDelegate>delegate;

@end
