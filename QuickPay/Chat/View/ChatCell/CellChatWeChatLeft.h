//
//  CellChatAlipayLeft.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatWeChatLeft;
@protocol CellChatWeChatLeftDelegate <NSObject>

- (void)onChatWeChat:(YHChatModel*)chatFile inLeftCell:(CellChatWeChatLeft *)leftCell;

@end

@interface CellChatWeChatLeft : CellChatBase

@property (nonatomic,assign)id<CellChatWeChatLeftDelegate>delegate;

@end
