//
//  YHChatDetailVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <View+MASAdditions.h>
#import "YHChatShowAlipay.h"
#import "YHRefreshTableView.h"
#import "YHChatHeader.h"
#import "YHChatModel.h"
#import "YHExpressionKeyboard.h"
#import "QuickPayConfigModel.h"
#import "YHUserInfo.h"
#import "HHUtils.h"
#import "YHChatHeader.h"
#import "TestData.h"
#import "YHAudioPlayer.h"
#import "YHAudioRecorder.h"
#import "YHVoiceHUD.h"
#import "YHUploadManager.h"
#import "YHChatManager.h"
#import "UIBarButtonItem+Extension.h"
#import "YHChatTextLayout.h"
#import "YHDocumentVC.h"
#import "YHNavigationController.h"
#import "YHWebViewController.h"
#import "YHShootVC.h"
#import "YHChatManager.h"
#import "SqliteManager.h"
#import "QuickPayNetConstants.h"
#import "CellChatAlipayLeft.h"
#import "MASConstraintMaker.h"


@interface YHChatShowAlipay () {

}

@property(nonatomic, strong) UIImageView *imgPayBg;
/*----------------------------账号----------------------*/

@property(nonatomic, strong) UIImageView *imgPayBgType1;  // 不变
@property(nonatomic, strong) UIImageView *imgPaySubline;  // 不变

@property(nonatomic, strong) UIImageView *imgIconPayType;
@property(nonatomic, strong) UILabel *lbTitlePayType;
@property(nonatomic, strong) UILabel *lbPayTipsPayType;

// 账号-"内容"-复制
@property(nonatomic, strong) UILabel *lbPayAccountsT;
@property(nonatomic, strong) UILabel *lbPayAccountsContens;
@property(nonatomic, strong) UILabel *lbPayAccountsCopy;

// 姓-"内容"-复制
@property(nonatomic, strong) UILabel *lbPayFirstNameT;
@property(nonatomic, strong) UILabel *lbPayFirstNameContens;
@property(nonatomic, strong) UILabel *lbPayFirstNameCopy;

// 名-"内容"-复制
@property(nonatomic, strong) UILabel *lbPayLastNameT;
@property(nonatomic, strong) UILabel *lbPayLastNameContens;
@property(nonatomic, strong) UILabel *lbPayLastNameCopy;

// 姓名-"内容"-复制
@property(nonatomic, strong) UILabel *lbPayFullNameT;
@property(nonatomic, strong) UILabel *lbPayFullNameContens;
@property(nonatomic, strong) UILabel *lbPayFullNameCopy;

/* -------------------------二维码---------------------ß */

@property(nonatomic, strong) UIImageView *imgQcodePayBgType;  // 不变
@property(nonatomic, strong) UIImageView *imgQcodePaySubline;  // 不变

@property(nonatomic, strong) UIImageView *imgQcodeIconPayType;
@property(nonatomic, strong) UILabel *lbQcodeTitlePayType;
@property(nonatomic, strong) UILabel *lbQcodePayTipsPayType;

@end

@implementation YHChatShowAlipay

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.translucent = NO;

    //设置导航栏
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"更多" target:self selector:@selector(onMore:) block:^(UIButton *btn) {
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"取消" forState:UIControlStateSelected];
        [btn setTitle:@"人工协助" forState:UIControlStateNormal];
    }];

    self.navigationController.navigationBar.clipsToBounds == 0.0;
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setShadowImage:[self.navigationItem lineImageWithColor:[UIColor colorWithHexString:@"#fb9966"]]];

    // [self.navigationController.navigationBar setShadowImage:[self.navigationController.navigationBar :[UIColor colorWithHexString:@"#fb9966"]]];
    // [self.navigationController.navigationBar setShadowImage:[self.tabBar lineImageWithColor:[UIColor colorWithHexString:@"#fb9966"]]];

    self.title = @"收款";
    [self setupNavigationBar];
    [self setupTypeAccountsUI];
    [self layoutTypeAccountsUI];

    [self setupTypeQrcodeUI];
    [self layoutTypeQrcodeUI];

}


- (void)setupNavigationBar {
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = RGB16(0x6ba5f7);

}

- (void)setupTypeAccountsUI {

    self.view.backgroundColor = RGB16(0x6ba5f7); //RGBCOLOR(239, 236, 236);
//    _imgPayBg= [UIImageView new];
//    _imgPayBg.image = [UIImage imageNamed:@"alipay_bg"];;
//    [self.view addSubview:_imgPayBg];

    // 二维码背景
    _imgPayBgType1 = [UIImageView new];
    UIImage *imgBg = [UIImage imageNamed:@"pay_show_bg"];
    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 30, 30) resizingMode:UIImageResizingModeStretch];
    _imgPayBgType1.image = imgBg;
    [self.view addSubview:_imgPayBgType1];


    _imgIconPayType = [UIImageView new];
    UIImage *imgIcon = [UIImage imageNamed:@"icon_alipay"];
    _imgIconPayType.image = imgIcon;
    [self.imgPayBgType1 addSubview:_imgIconPayType];


    _imgPaySubline = [UIImageView new];
    _imgPaySubline.image = [UIImage imageNamed:@"pay_subline"];
    _imgPaySubline.alpha = 30;
    [self.imgPayBgType1 addSubview:_imgPaySubline];


    // 提示背景
    _lbTitlePayType = [UILabel new];
    _lbTitlePayType.font = [UIFont systemFontOfSize:16.0];
    _lbTitlePayType.numberOfLines = 1;
    _lbTitlePayType.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbTitlePayType.textColor = [UIColor blackColor];
    _lbTitlePayType.text = @"支付宝账号转帐";
    [self.imgPayBgType1 addSubview:_lbTitlePayType];

    _lbPayTipsPayType = [UILabel new];
    _lbPayTipsPayType.font = [UIFont systemFontOfSize:16.0];
    _lbPayTipsPayType.numberOfLines = 1;
    _lbPayTipsPayType.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayTipsPayType.textColor = [UIColor blackColor];
    _lbPayTipsPayType.text = @"复制支付宝账号，支付宝[转账]付钱";
    [self.imgPayBgType1 addSubview:_lbPayTipsPayType];

    // 支付宝账号一行
    _lbPayAccountsT = [UILabel new];
    _lbPayAccountsT.font = [UIFont systemFontOfSize:16.0];
    _lbPayAccountsT.numberOfLines = 1;
    _lbPayAccountsT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayAccountsT.textColor = [UIColor blackColor];
    _lbPayAccountsT.text = @"支付宝账号";
    [self.imgPayBgType1 addSubview:_lbPayAccountsT];

    _lbPayAccountsContens = [UILabel new]; //
    _lbPayAccountsContens.font = [UIFont systemFontOfSize:14.0];
    _lbPayAccountsContens.numberOfLines = 2;
    _lbPayAccountsContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayAccountsContens.textAlignment = NSTextAlignmentCenter;
    _lbPayAccountsContens.textColor = [UIColor blackColor];
    _lbPayAccountsContens.text = @"1234567890123456@qq.com";
    [self.imgPayBgType1 addSubview:_lbPayAccountsContens];

    _lbPayAccountsCopy = [UILabel new];
    _lbPayAccountsCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayAccountsCopy.numberOfLines = 1;
    _lbPayAccountsCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayAccountsCopy.textColor = [UIColor blueColor];
    _lbPayAccountsCopy.text = @"复制";
    [self.imgPayBgType1 addSubview:_lbPayAccountsCopy];

    // 支付宝名
    _lbPayFirstNameT = [UILabel new];
    _lbPayFirstNameT.font = [UIFont systemFontOfSize:16.0];
    _lbPayFirstNameT.numberOfLines = 1;
    _lbPayFirstNameT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFirstNameT.textColor = [UIColor blackColor];
    _lbPayFirstNameT.text = @"支付宝姓";
    [self.imgPayBgType1 addSubview:_lbPayFirstNameT];

    _lbPayFirstNameContens = [UILabel new]; //
    _lbPayFirstNameContens.font = [UIFont systemFontOfSize:16.0];
    _lbPayFirstNameContens.numberOfLines = 1;
    _lbPayFirstNameContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayFirstNameContens.textAlignment = NSTextAlignmentCenter;
    _lbPayFirstNameContens.textColor = [UIColor blackColor];
    _lbPayFirstNameContens.text = @"邓";
    [self.imgPayBgType1 addSubview:_lbPayFirstNameContens];

    _lbPayFirstNameCopy = [UILabel new];
    _lbPayFirstNameCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayFirstNameCopy.numberOfLines = 1;
    _lbPayFirstNameCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFirstNameCopy.textColor = [UIColor blueColor];
    _lbPayFirstNameCopy.text = @"复制";
    [self.imgPayBgType1 addSubview:_lbPayFirstNameCopy];

    // 支付宝姓
    _lbPayLastNameT = [UILabel new];
    _lbPayLastNameT.font = [UIFont systemFontOfSize:16.0];
    _lbPayLastNameT.numberOfLines = 1;
    _lbPayLastNameT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayLastNameT.textColor = [UIColor blackColor];
    _lbPayLastNameT.text = @"支付宝名";
    [self.imgPayBgType1 addSubview:_lbPayLastNameT];

    _lbPayLastNameContens = [UILabel new]; //
    _lbPayLastNameContens.font = [UIFont systemFontOfSize:16.0];
    _lbPayLastNameContens.numberOfLines = 1;
    _lbPayLastNameContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayLastNameContens.textAlignment = NSTextAlignmentCenter;
    _lbPayLastNameContens.textColor = [UIColor blackColor];
    _lbPayLastNameContens.text = @"超";
    [self.imgPayBgType1 addSubview:_lbPayLastNameContens];

    _lbPayLastNameCopy = [UILabel new];
    _lbPayLastNameCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayLastNameCopy.numberOfLines = 1;
    _lbPayLastNameCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayLastNameCopy.textColor = [UIColor blueColor];
    _lbPayLastNameCopy.text = @"复制";
    [self.imgPayBgType1 addSubview:_lbPayLastNameCopy];

    // 支付宝全名
    _lbPayFullNameT = [UILabel new];
    _lbPayFullNameT.font = [UIFont systemFontOfSize:16.0];
    _lbPayFullNameT.numberOfLines = 1;
    _lbPayFullNameT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFullNameT.textColor = [UIColor blackColor];
    _lbPayFullNameT.text = @"支付宝姓名";
    [self.imgPayBgType1 addSubview:_lbPayFullNameT];

    _lbPayFullNameContens = [UILabel new]; //
    _lbPayFullNameContens.font = [UIFont systemFontOfSize:16.0];
    _lbPayFullNameContens.numberOfLines = 1;
    _lbPayFullNameContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayFullNameContens.textAlignment = NSTextAlignmentCenter;
    _lbPayFullNameContens.textColor = [UIColor blackColor];
    _lbPayFullNameContens.text = @"邓超";
    [self.imgPayBgType1 addSubview:_lbPayFullNameContens];

    _lbPayFullNameCopy = [UILabel new];
    _lbPayFullNameCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayFullNameCopy.numberOfLines = 1;
    _lbPayFullNameCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFullNameCopy.textColor = [UIColor blueColor];
    _lbPayFullNameCopy.text = @"复制";
    [self.imgPayBgType1 addSubview:_lbPayFullNameCopy];

}

- (void)layoutTypeAccountsUI {
    WeakSelf
//    [_imgPayBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        // 添加左、上边距约束
//        make.left.and.right.and.bottom.and.top.mas_equalTo(0);
//    }];

    [_imgPayBgType1 mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.left.and.top.mas_equalTo(10);
        // 添加右边距约束
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(268);
    }];

    [_imgIconPayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(5);
        make.right.equalTo(weakSelf.lbTitlePayType.mas_left).offset(-5);

    }];


    [_lbTitlePayType mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.centerX.mas_equalTo(_imgPayBgType1).offset(3);
        // 添加右边距约束
        make.top.mas_equalTo(10);
    }];

    [_imgPaySubline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(_imgIconPayType).offset(32);
        make.leftMargin.and.rightMargin.mas_equalTo(1);
    }];

    [_lbPayTipsPayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_imgPayBgType1);
        make.top.mas_equalTo(_imgPaySubline).offset(20);
    }];

    // 支付宝账号一行
    [_lbPayAccountsT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayTipsPayType).offset(40);
        make.left.mas_equalTo(10);
    }];

    [_lbPayAccountsContens mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayTipsPayType).offset(40);
        make.right.mas_equalTo(_lbPayAccountsCopy).offset(-40);
    }];

    [_lbPayAccountsCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayTipsPayType).offset(40);
        make.right.mas_equalTo(-10);
    }];

    // 支付宝姓一行
    [_lbPayFirstNameT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayAccountsT).offset(40);
        make.left.mas_equalTo(10);
    }];

    [_lbPayFirstNameContens mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayAccountsT).offset(40);
        make.right.mas_equalTo(_lbPayFirstNameCopy).offset(-40);
    }];

    [_lbPayFirstNameCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayAccountsT).offset(40);
        make.right.mas_equalTo(-10);
    }];

    // 支付宝ming一行
    [_lbPayLastNameT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayFirstNameT).offset(40);
        make.left.mas_equalTo(10);
    }];

    [_lbPayLastNameContens mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayFirstNameT).offset(40);
        make.right.mas_equalTo(_lbPayLastNameCopy).offset(-40);
    }];

    [_lbPayLastNameCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayFirstNameT).offset(40);
        make.right.mas_equalTo(-10);
    }];


    // 支付宝姓一行
    [_lbPayFullNameT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayLastNameT).offset(40);
        make.left.mas_equalTo(10);
    }];

    [_lbPayFullNameContens mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayLastNameT).offset(40);
        make.right.mas_equalTo(_lbPayFullNameCopy).offset(-40);
    }];

    [_lbPayFullNameCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayLastNameT).offset(40);
        make.right.mas_equalTo(-10);
    }];
}


- (void)setupTypeQrcodeUI {

    self.view.backgroundColor = RGB16(0x6ba5f7); //RGBCOLOR(239, 236, 236);

    // 二维码背景
    _imgQcodePayBgType = [UIImageView new];
    UIImage *imgBg = [UIImage imageNamed:@"pay_show_bg"];
    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 30, 30) resizingMode:UIImageResizingModeStretch];
    _imgQcodePayBgType.image = imgBg;
    [self.view addSubview:_imgQcodePayBgType];


    _imgQcodeIconPayType = [UIImageView new];
    UIImage *imgIcon = [UIImage imageNamed:@"icon_alipay"];
    _imgQcodeIconPayType.image = imgIcon;
    [self.imgQcodePayBgType addSubview:_imgQcodeIconPayType];


    _imgQcodePaySubline = [UIImageView new];
    _imgQcodePaySubline.image = [UIImage imageNamed:@"pay_subline"];
    _imgQcodePaySubline.alpha = 30;
    [self.imgQcodePayBgType addSubview:_imgQcodePaySubline];


    // 提示背景
    _lbQcodeTitlePayType = [UILabel new];
    _lbQcodeTitlePayType.font = [UIFont systemFontOfSize:16.0];
    _lbQcodeTitlePayType.numberOfLines = 1;
    _lbQcodeTitlePayType.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbQcodeTitlePayType.textColor = [UIColor blackColor];
    _lbQcodeTitlePayType.text = @"支付宝账号转帐";
    [self.imgQcodePayBgType addSubview:_lbQcodeTitlePayType];

    _lbQcodePayTipsPayType = [UILabel new];
    _lbQcodePayTipsPayType.font = [UIFont systemFontOfSize:16.0];
    _lbQcodePayTipsPayType.numberOfLines = 1;
    _lbQcodePayTipsPayType.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbQcodePayTipsPayType.textColor = [UIColor blackColor];
    _lbQcodePayTipsPayType.text = @"复制支付宝账号，支付宝[转账]付钱";
    [self.imgQcodePayBgType addSubview:_lbQcodePayTipsPayType];


}

- (void)layoutTypeQrcodeUI {
    [self.imgPayBgType1 setHidden:YES];

    WeakSelf
    [_imgQcodePayBgType mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.left.and.top.mas_equalTo(10);
        // 添加右边距约束
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(268);
    }];

    [_imgQcodeIconPayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(5);
        make.right.equalTo(weakSelf.lbTitlePayType.mas_left).offset(-5);
    }];


    [_lbQcodeTitlePayType mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.centerX.mas_equalTo(_imgQcodePayBgType).offset(3);
        // 添加右边距约束
        make.top.mas_equalTo(10);
    }];

    [_imgQcodePaySubline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(_imgQcodeIconPayType).offset(32);
        make.leftMargin.and.rightMargin.mas_equalTo(1);
    }];

    [_lbQcodePayTipsPayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_imgQcodePayBgType);
        make.top.mas_equalTo(_imgQcodePaySubline).offset(20);
    }];
}

#pragma mark - Action

- (void)onMore:(UIButton *)sender {
    sender.selected = !sender.selected;
    //[self.tableView reloadData];
}

#pragma mark -  Action

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)dealloc {
    DDLog(@"%s is dealloc", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
