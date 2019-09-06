//
//  CellChatAlipayLeft.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatBankLeft;
@protocol CellChatBankLeftDelegate <NSObject>

- (void)onChatBank:(YHChatModel*)chatFile inLeftCell:(CellChatBankLeft *)leftCell;

@end

@interface CellChatBankLeft : CellChatBase

@property (nonatomic,assign)id<CellChatBankLeftDelegate>delegate;

@end
