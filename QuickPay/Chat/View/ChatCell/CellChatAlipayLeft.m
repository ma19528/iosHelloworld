//
//  CellChatAlipayLeft.m
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatAlipayLeft.h"
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "YHChatHelper.h"
#import "YHDownLoadManager.h"
#import "NetManager.h"
#import "HHUtils.h"
#import "SqliteManager.h"
#import "YHChatButton.h"

@interface CellChatAlipayLeft()
@property (nonatomic,strong) UIImageView  *imgvBubble;
@property (nonatomic,strong) YHChatButton *btnTapScope;
@property (nonatomic,strong) UIImageView *imgvIcon;
@property (nonatomic,strong) UILabel *lbFileName;
@property (nonatomic,strong) UILabel *lbFileSize;
@property (nonatomic,strong) UILabel *lbStatus;
@property (nonatomic,strong) UIProgressView *progressView;
@end

@implementation CellChatAlipayLeft

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    // 泡泡对话框
    _imgvBubble = [UIImageView new];
    UIImage *imgBubble = [UIImage imageNamed:@"chat_bubbleRight"];//chat_bubbleLeft
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 15) resizingMode:UIImageResizingModeStretch];
    _imgvBubble.image = imgBubble;
    [self.contentView addSubview:_imgvBubble];
    
    
    _btnTapScope = [YHChatButton new];
    _btnTapScope.isReceiver = NO;
    [_btnTapScope addTarget:self action:@selector(onBtnTapScope:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btnTapScope];
    
//    WeakSelf
//    _btnTapScope.retweetFileBlock = ^(){
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetFile:inLeftCell:)]) {
//            [weakSelf.delegate retweetFile:weakSelf.model.fileModel inLeftCell:weakSelf];
//        }
//    };
    

    _imgvIcon = [UIImageView new];
    [self.contentView addSubview:_imgvIcon];

    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self layoutCommonUI];
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
    }];
    [self.lbName setHidden:YES];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnCheckBox.mas_right).offset(5);
    }];

    // 后面所有的对话都不显示自己的名字。
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(5);
        make.top.equalTo(weakSelf.lbName.mas_top).offset(0); // 不需要lbName了，
        make.width.mas_equalTo(SCREEN_WIDTH - 203);
        make.height.mas_equalTo(70);
    }];
    
    [_btnTapScope mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.imgvBubble);
        make.size.equalTo(weakSelf.imgvBubble);
    }];
    
    [_imgvIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(68);
        make.width.mas_equalTo(173); // 这个尺寸是根据图片的分辨率来的。

        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
        make.centerX.equalTo(weakSelf.imgvBubble.mas_centerX);
        make.left.equalTo(weakSelf.imgvBubble); //.offset(1)
    }];


    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 10;
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];

    self.lbName.text    = self.model.speakerName;
    [self.lbName setHidden:YES];
    self.lbTime.text    = self.model.createTime;

    // TODO.. 在这里可以判断是否是同一个sesion的对话，如果同一个session 则不需要显示时间。
    [self.viewTimeBG setHidden:YES];
    [self.viewTimeBG setHeight:0.0];

    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];

    NSString *msgContent = self.model.msgContent;
    if (self.model.msgType == YHMessageType_ALIPAY && msgContent) {
        self.imgvIcon.image = [UIImage imageNamed:@"chat_pay_alipay"];
    }

}

#pragma mark - Action
- (void)onBtnTapScope:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(onChatAlipay:inLeftCell:)]) {
        [_delegate onChatAlipay:self.model inLeftCell:self];
    }
    
}





@end
