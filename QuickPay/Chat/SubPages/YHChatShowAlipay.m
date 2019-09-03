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


@property (nonatomic,strong) UIImageView *imgPayQrcodeBg;
@property (nonatomic,strong) UIImageView *imgPayIcon;
@property (nonatomic,strong) UIImageView *imgPaySubline;
@property (nonatomic,strong) UILabel *lbTitle;

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
        [btn setTitle:@"更多" forState:UIControlStateNormal];
    }];

    self.navigationController.navigationBar.clipsToBounds == 0.0;
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setShadowImage:[self.navigationItem lineImageWithColor:[UIColor colorWithHexString:@"#fb9966"]]];

    // [self.navigationController.navigationBar setShadowImage:[self.navigationController.navigationBar :[UIColor colorWithHexString:@"#fb9966"]]];
    // [self.navigationController.navigationBar setShadowImage:[self.tabBar lineImageWithColor:[UIColor colorWithHexString:@"#fb9966"]]];

    self.title = @"收款";
    [self setupUI];
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



- (void)setupUI {

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.backgroundColor = RGB16(0x6ba5f7);
    self.view.backgroundColor = RGB16(0x6ba5f7); //RGBCOLOR(239, 236, 236);

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
}

- (void)layoutUI{
    WeakSelf
    // 给黑色view添加约束
    [_imgPayQrcodeBg mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加左、上边距约束
        make.left.and.top.mas_equalTo(10);
        // 添加右边距约束
        make.right.mas_equalTo(-10);
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
