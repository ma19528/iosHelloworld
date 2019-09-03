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

@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NSMutableArray *layouts;

@property (nonatomic,strong) UIImageView *imgPayBg;

@property (nonatomic,strong) UIImageView *imgPayQrcodeBg;
@property (nonatomic,strong) UIImageView *imgPayIcon;
@property (nonatomic,strong) UIImageView *imgPaySubline;
@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UILabel *lbPayTips;

// 账号-"内容"-复制
@property (nonatomic,strong) UILabel *lbPayAccountsT;
@property (nonatomic,strong) UILabel *lbPayAccountsContens;
@property (nonatomic,strong) UILabel *lbPayAccountsCopy;

// 姓-"内容"-复制
@property (nonatomic,strong) UILabel *lbPayFirstNameT;
@property (nonatomic,strong) UILabel *lbPayFirstNameContens;
@property (nonatomic,strong) UILabel *lbPayFirstNameCopy;

// 名-"内容"-复制
@property (nonatomic,strong) UILabel *lbPayLastNameT;
@property (nonatomic,strong) UILabel *lbPayLastNameContens;
@property (nonatomic,strong) UILabel *lbPayLastNameCopy;

// 姓名-"内容"-复制
@property (nonatomic,strong) UILabel *lbPayFullNameT;
@property (nonatomic,strong) UILabel *lbPayFullNameContens;
@property (nonatomic,strong) UILabel *lbPayFullNameCopy;



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
    [self setupTypeAccountsUI];
    [self layoutUI];
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray *)layouts {
    if (!_layouts) {
        _layouts = [NSMutableArray new];
    }
    return _layouts;
}



- (void)setupTypeAccountsUI {

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = RGB16(0x6ba5f7);

    self.view.backgroundColor = RGB16(0x6ba5f7); //RGBCOLOR(239, 236, 236);

//    _imgPayBg= [UIImageView new];
//    _imgPayBg.image = [UIImage imageNamed:@"alipay_bg"];;
//    [self.view addSubview:_imgPayBg];

    // 二维码背景
    _imgPayQrcodeBg = [UIImageView new];
    UIImage *imgBg = [UIImage imageNamed:@"pay_show_bg"];
    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 30, 30) resizingMode:UIImageResizingModeStretch];
    _imgPayQrcodeBg.image = imgBg;
    [self.view addSubview:_imgPayQrcodeBg];


    _imgPayIcon = [UIImageView new];
    UIImage *imgIcon = [UIImage imageNamed:@"icon_alipay"];
    _imgPayIcon.image = imgIcon;
    [self.imgPayQrcodeBg addSubview:_imgPayIcon];


    _imgPaySubline = [UIImageView new];
    _imgPaySubline.image = [UIImage imageNamed:@"pay_subline"];
    _imgPaySubline.alpha = 30;
    [self.imgPayQrcodeBg addSubview:_imgPaySubline];


    // 提示背景
    _lbTitle = [UILabel new];
    _lbTitle.font = [UIFont systemFontOfSize:16.0];
    _lbTitle.numberOfLines = 1;
    _lbTitle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbTitle.textColor = [UIColor blackColor];
    _lbTitle.text = @"支付宝账号转帐";
    [self.imgPayQrcodeBg addSubview:_lbTitle];

    _lbPayTips = [UILabel new];
    _lbPayTips.font = [UIFont systemFontOfSize:16.0];
    _lbPayTips.numberOfLines = 1;
    _lbPayTips.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayTips.textColor = [UIColor blackColor];
    _lbPayTips.text = @"复制支付宝账号，支付宝[转账]付钱";
    [self.imgPayQrcodeBg addSubview:_lbPayTips];

    // 支付宝账号一行
    _lbPayAccountsT = [UILabel new];
    _lbPayAccountsT.font = [UIFont systemFontOfSize:16.0];
    _lbPayAccountsT.numberOfLines = 1;
    _lbPayAccountsT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayAccountsT.textColor = [UIColor blackColor];
    _lbPayAccountsT.text = @"支付宝账号";
    [self.imgPayQrcodeBg addSubview:_lbPayAccountsT];

    _lbPayAccountsContens = [UILabel new]; //
    _lbPayAccountsContens.font = [UIFont systemFontOfSize:14.0];
    _lbPayAccountsContens.numberOfLines = 2;
    _lbPayAccountsContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayAccountsContens.textAlignment = NSTextAlignmentCenter;
    _lbPayAccountsContens.textColor = [UIColor blackColor];
    _lbPayAccountsContens.text = @"1234567890123456@qq.com";
    [self.imgPayQrcodeBg addSubview:_lbPayAccountsContens];

    _lbPayAccountsCopy = [UILabel new];
    _lbPayAccountsCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayAccountsCopy.numberOfLines = 1;
    _lbPayAccountsCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayAccountsCopy.textColor = [UIColor blueColor];
    _lbPayAccountsCopy.text = @"复制";
    [self.imgPayQrcodeBg addSubview:_lbPayAccountsCopy];

    // 支付宝名
    _lbPayFirstNameT = [UILabel new];
    _lbPayFirstNameT.font = [UIFont systemFontOfSize:16.0];
    _lbPayFirstNameT.numberOfLines = 1;
    _lbPayFirstNameT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFirstNameT.textColor = [UIColor blackColor];
    _lbPayFirstNameT.text = @"支付宝姓";
    [self.imgPayQrcodeBg addSubview:_lbPayFirstNameT];

    _lbPayFirstNameContens = [UILabel new]; //
    _lbPayFirstNameContens.font = [UIFont systemFontOfSize:16.0];
    _lbPayFirstNameContens.numberOfLines = 1;
    _lbPayFirstNameContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayFirstNameContens.textAlignment = NSTextAlignmentCenter;
    _lbPayFirstNameContens.textColor = [UIColor blackColor];
    _lbPayFirstNameContens.text = @"邓";
    [self.imgPayQrcodeBg addSubview:_lbPayFirstNameContens];

    _lbPayFirstNameCopy = [UILabel new];
    _lbPayFirstNameCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayFirstNameCopy.numberOfLines = 1;
    _lbPayFirstNameCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFirstNameCopy.textColor = [UIColor blueColor];
    _lbPayFirstNameCopy.text = @"复制";
    [self.imgPayQrcodeBg addSubview:_lbPayFirstNameCopy];

    // 支付宝姓
    _lbPayLastNameT = [UILabel new];
    _lbPayLastNameT.font = [UIFont systemFontOfSize:16.0];
    _lbPayLastNameT.numberOfLines = 1;
    _lbPayLastNameT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayLastNameT.textColor = [UIColor blackColor];
    _lbPayLastNameT.text = @"支付宝名";
    [self.imgPayQrcodeBg addSubview:_lbPayLastNameT];

    _lbPayLastNameContens = [UILabel new]; //
    _lbPayLastNameContens.font = [UIFont systemFontOfSize:16.0];
    _lbPayLastNameContens.numberOfLines = 1;
    _lbPayLastNameContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayLastNameContens.textAlignment = NSTextAlignmentCenter;
    _lbPayLastNameContens.textColor = [UIColor blackColor];
    _lbPayLastNameContens.text = @"超";
    [self.imgPayQrcodeBg addSubview:_lbPayLastNameContens];

    _lbPayLastNameCopy = [UILabel new];
    _lbPayLastNameCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayLastNameCopy.numberOfLines = 1;
    _lbPayLastNameCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayLastNameCopy.textColor = [UIColor blueColor];
    _lbPayLastNameCopy.text = @"复制";
    [self.imgPayQrcodeBg addSubview:_lbPayLastNameCopy];

    // 支付宝全名
    _lbPayFullNameT = [UILabel new];
    _lbPayFullNameT.font = [UIFont systemFontOfSize:16.0];
    _lbPayFullNameT.numberOfLines = 1;
    _lbPayFullNameT.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFullNameT.textColor = [UIColor blackColor];
    _lbPayFullNameT.text = @"支付宝姓名";
    [self.imgPayQrcodeBg addSubview:_lbPayFullNameT];

    _lbPayFullNameContens = [UILabel new]; //
    _lbPayFullNameContens.font = [UIFont systemFontOfSize:16.0];
    _lbPayFullNameContens.numberOfLines = 1;
    _lbPayFullNameContens.lineBreakMode = NSLineBreakByWordWrapping;
    _lbPayFullNameContens.textAlignment = NSTextAlignmentCenter;
    _lbPayFullNameContens.textColor = [UIColor blackColor];
    _lbPayFullNameContens.text = @"邓超";
    [self.imgPayQrcodeBg addSubview:_lbPayFullNameContens];

    _lbPayFullNameCopy = [UILabel new];
    _lbPayFullNameCopy.font = [UIFont systemFontOfSize:16.0];
    _lbPayFullNameCopy.numberOfLines = 1;
    _lbPayFullNameCopy.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayFullNameCopy.textColor = [UIColor blueColor];
    _lbPayFullNameCopy.text = @"复制";
    [self.imgPayQrcodeBg addSubview:_lbPayFullNameCopy];
}

- (void)layoutUI{
    WeakSelf
//    [_imgPayBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        // 添加左、上边距约束
//        make.left.and.right.and.bottom.and.top.mas_equalTo(0);
//    }];

    [_imgPayQrcodeBg mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.left.and.top.mas_equalTo(10);
        // 添加右边距约束
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(268);
    }];

    [_imgPayIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(5);
        make.right.equalTo(weakSelf.lbTitle.mas_left).offset(-5);

    }];


    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.centerX.mas_equalTo(_imgPayQrcodeBg).offset(3);
        // 添加右边距约束
        make.top.mas_equalTo(10);
    }];

    [_imgPaySubline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(_imgPayIcon).offset(32);
        make.leftMargin.and.rightMargin.mas_equalTo(1);
    }];

    [_lbPayTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_imgPayQrcodeBg);
        make.top.mas_equalTo(_imgPaySubline).offset(20);
    }];

    // 支付宝账号一行
    [_lbPayAccountsT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayTips).offset(40);
        make.left.mas_equalTo(10);
    }];

    [_lbPayAccountsContens mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayTips).offset(40);
        make.right.mas_equalTo(_lbPayAccountsCopy).offset(-40);
    }];

    [_lbPayAccountsCopy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_lbPayTips).offset(40);
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
