//
//  YHChatListModel.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/23.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "YHChatListModel.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHChatListModel
#pragma mark - 数据库操作
+ (NSString *)yh_primaryKey{
    return @"agentId";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"agentId":YHDB_PrimaryKey};
    //return @{@"id":@"agentId"};
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{

}
@end
