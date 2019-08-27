//
//  QuickPayNetConstants.m
//  MyProject
//
//  Created by user on 14-3-24.
//
//


#import "QuickPayNetConstants.h"

@interface QuickPayNetConstants ()

@end

@implementation QuickPayNetConstants


+ (QuickPayNetConstants *)sharedInstance {
    static QuickPayNetConstants *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[QuickPayNetConstants alloc] init];
    });
    return g_sharedInstance;
}


@end
