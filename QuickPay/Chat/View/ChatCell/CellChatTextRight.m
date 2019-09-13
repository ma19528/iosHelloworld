//
//  CellChatRight.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatTextRight.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "YHChatLabel.h"
#import "SqliteManager.h"
#import "../../Config/YHGeneralHeader.h"


@interface CellChatTextRight()

@property (nonatomic,strong) UIImageView *imgvBubble;
@property (nonatomic,strong) YHChatLabel *lbContent;

@end


@implementation CellChatTextRight

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _imgvBubble = [UIImageView new];
    UIImage *imgBubble = [UIImage imageNamed:@"chat_bubbleRight"];
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 30, 30) resizingMode:UIImageResizingModeStretch];
    
    _imgvBubble.image = imgBubble;
    [self.contentView addSubview:_imgvBubble];
    
    _lbContent = [YHChatLabel new];
    _lbContent.isReceiver = YES;
    
    //-5-AvatarWidth-10-15-5-10-AvatarWidth
    _lbContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 133;
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    _lbContent.textColor = [UIColor blackColor];
    _lbContent.numberOfLines = 0;
    _lbContent.font = [UIFont systemFontOfSize:(20+addFontSize)];
    _lbContent.ignoreCommonProperties = YES;
    _lbContent.displaysAsynchronously = YES;
    
    
    WeakSelf
    _lbContent.retweetBlock = ^(NSString *text){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetMsg:inRightCell:)]) {
            [weakSelf.delegate retweetMsg:text inRightCell:weakSelf];
        }
    };
    _lbContent.withDrawBlock = ^(NSString *text){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(withDrawMsg:inRightCell:)]) {
            [weakSelf.delegate withDrawMsg:text inRightCell:weakSelf];
        }
    };

    
    [self.contentView addSubview:_lbContent];
    
    _lbContent.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
        
        NSString *linkText = [text.string substringWithRange:range];
        int linkType = 0;
        if([linkText hasPrefix:@"http"]){
            linkType = 1;
        }else if ([linkText hasPrefix:@"@"]){
            linkType = 0;
        }
        DDLog(@"点击:\n%@",linkText);
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onLinkInChatTextRightCell:linkType:linkText:)]) {
            [weakSelf.delegate onLinkInChatTextRightCell:weakSelf linkType:linkType linkText:linkText];
        }
        
    };

    
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    [self layoutCommonUI];

    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
    }];
    [self.lbName setHidden:YES];

    // TODO.. 在这里可以判断是否是同一个sesion的对话，如果同一个session 则不需要显示时间。
    [self.viewTimeBG setHidden:YES];
    [self.viewTimeBG setHeight:0.0];

    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbContent.mas_left).offset(-5);
        make.top.equalTo(weakSelf.lbName.mas_top).offset(0);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-5);
    }];
    

    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvBubble.mas_top).offset(5);
        make.right.equalTo(weakSelf.imgvBubble.mas_right).offset(-15);
        make.bottom.equalTo(weakSelf.imgvBubble.mas_bottom).offset(-5);
        make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH - 133);
    }];
    
    [self.activityV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
        make.right.equalTo(weakSelf.imgvBubble.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.imgvSendMsgFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
        make.right.equalTo(weakSelf.imgvBubble.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 5;
}


#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    [super onAvatarGesture:aRec];
    if (aRec.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(tapRightAvatar:)]) {
            [_delegate tapRightAvatar:nil];
        }
    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
    [super onImgSendMsgFailGesture:aRec];
    if (aRec.state == UIGestureRecognizerStateEnded) {
        if(_delegate && [_delegate respondsToSelector:@selector(tapSendMsgFailImg)]){
            [_delegate tapSendMsgFailImg];
        }
    }
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];

    _lbContent.str        = model.msgContent;
    _lbContent.textLayout = model.layout.textLayout;
    self.lbName.text    = self.model.speakerName;
    self.lbTime.text    = self.model.createTime;
    // self.imgvAvatar.image = [UIImage imageNamed:@"default_header"];
    if (self.model.speakerAvatar != nil) {
        [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    } else {
        self.imgvAvatar.image = [UIImage imageNamed:@"default_header"];
    }
    super.imgvSendMsgFail.hidden = NO;
    //关联聊天到数据库
    [[SqliteManager sharedInstance] createOneChat:model.agentId chatModel:model complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"下载文件关联到数据库成功:%@",obj);
        }else{
            DDLog(@"下载文件关联到数据库失败:%@",obj);
        }
    }];
}

#pragma mark - Life
- (void)dealloc{
    //DDLog(@"%s dealloc",__func__);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
