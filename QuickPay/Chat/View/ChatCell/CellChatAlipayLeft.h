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

- (void)onChatFile:(YHFileModel *)chatFile inLeftCell:(CellChatAlipayLeft *)leftCell;

@optional
- (void)retweetFile:(YHFileModel *)chatFile inLeftCell:(CellChatAlipayLeft *)leftCell;//转发文件

@end

@interface CellChatAlipayLeft : CellChatBase

@property (nonatomic,assign)id<CellChatAlipayLeftDelegate>delegate;

@end
