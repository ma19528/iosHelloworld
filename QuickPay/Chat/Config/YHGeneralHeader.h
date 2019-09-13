//
//  YHChatHeader.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#ifndef YHGeneralHeader_h
#define YHGeneralHeader_h

#import "YHDebug.h"

#define KEYWINDOW [UIApplication sharedApplication].keyWindow
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define isiPad [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#pragma mark - 颜色
//颜色
#ifndef RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#endif

#ifndef RGBACOLOR
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define RGB16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define kGrayColor  RGBCOLOR(196, 197, 198)
#define kGreenColor kBlueColor    //绿色主调
#define kBlueColor  RGB16(0x0e92dd)          //蓝色主调

#define DDLog(FORMAT, ...)   fprintf(stderr, "\n[%s]  function:%s line:%d content:%s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#define WeakSelf  __weak __typeof(&*self)weakSelf = self;

#endif

#endif /* YHGeneralHeader_h */
