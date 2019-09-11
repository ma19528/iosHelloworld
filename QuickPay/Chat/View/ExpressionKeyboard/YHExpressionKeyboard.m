//
//  YHExpressionKeyboard.m
//  Expression
//
//  Created by samuelandkevin on 17/2/7.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHExpressionKeyboard.h"
#import "YYKit.h"
#import "YHExpressionHelper.h"
#import "Masonry.h"
#import "YHExpressionInputView.h"
#import "YHExpressionAddView.h"
#import "QuickPayNetConstants.h"

#define kNaviBarH       64   //导航栏高度
#define kTopToolbarH    50   //顶部工具栏高度
#define kToolbarBtnH    35   //顶部工具栏的按钮高度
#define kBotContainerH  216  //底部表情高度
#define DURTAION  0.25f      //键盘显示/收起动画时间
#define kTextVTopMargin 8
#define kTopPayLabelH    25   //顶部 支付label 的高度


@interface YHExpressionTextView : UITextView

@property (nonatomic,copy)  NSString *emoticon;
@property (nonatomic,strong) NSMutableArray <NSString *>*emoticonArray;
//删除表情
- (void)deleteEmoticon;
@end

@implementation YHExpressionTextView

- (NSMutableArray<NSString *> *)emoticonArray{
    if (!_emoticonArray) {
        _emoticonArray = [NSMutableArray new];
    }
    return _emoticonArray;
}


- (void)setEmoticon:(NSString *)emoticon{
    _emoticon = emoticon;
    
    NSMutableString *maStr = [[NSMutableString alloc] initWithString:self.text];
    if (_emoticon) {
        [maStr insertString:_emoticon atIndex:self.selectedRange.location];
        [self.emoticonArray addObject:_emoticon];
    }
    self.text = maStr;
}


- (void)deleteEmoticon{
    
    NSRange range = self.selectedRange;
    NSInteger location = (NSInteger)range.location;
    if (location == 0) {
        if (range.length) {
            self.text = @"";
        }
        return ;
    }
    //判断是否表情
    NSString *subString = [self.text substringToIndex:location];
    if ([subString hasSuffix:@"]"]) {
        
        //查询是否存在表情
        __block NSString *emoticon = nil;
        __block NSRange  emoticonRange;
        [[YHExpressionHelper regexEmoticon] enumerateMatchesInString:subString options:kNilOptions range:NSMakeRange(0, subString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            emoticonRange = result.range;
            emoticon = [subString substringWithRange:result.range];
            
            
            
        }];
        DDLog(@"要删除表情是：\n%@",emoticon);
        if (emoticon) {
            //是表情符号,移除
            if ([self.emoticonArray containsObject:emoticon]) {
                
                self.text = [self.text stringByReplacingCharactersInRange:emoticonRange withString:@" "];
                DDLog(@"删除后字符串为:\n%@",self.text);
                
                range.location -= emoticonRange.length;
                range.length = 1;
                self.selectedRange = range;
               
            }
        }else{
            self.text = [self.text stringByReplacingCharactersInRange:range withString:@""];
            range.location -= 1;
            range.length = 1;
            self.selectedRange = range;
        }
        
    }else{
        self.text = [self.text stringByReplacingCharactersInRange:range withString:@""];
        range.location -= 1;
        range.length = 1;
        self.selectedRange = range;
    }
    
}


@end


@interface YHExpressionKeyboard()<YYTextKeyboardObserver,YHExpressionInputViewDelegate,
                                    UITextViewDelegate,YHExpressionAddViewDelegate>{
    BOOL    _toolbarButtonTap; //toolbarBtn被点击
    CGFloat _height_oneRowText;//输入框每一行文字高度
    CGFloat _height_Toolbar;   //当前Toolbar高度
    NSMutableArray *_toolbarButtonArr;
    UIButton       *_toolbarButtonSelected;
    
    NSDate *_beginRecordDate;
    NSDate *_endRecordDate;
}

//表情键盘被添加到的VC 和 父视图
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIView  *superView;
@property (nonatomic, weak) UIView  *aboveView;

//TopToolBar
@property (nonatomic, strong) UIView *topToolBar;
@property (nonatomic, strong) YHExpressionTextView *textView;

@property (nonatomic, strong) UIButton *toolbarVioceButton;//语音
@property (nonatomic, strong) UIButton *toolbarPresstoSpeakButton;//按住说话
@property (nonatomic, strong) UIButton *toolbarEmoticonButton;//表情
@property (nonatomic, strong) UIButton *toolbarExtraButton;//“+”
@property (nonatomic, strong) UIView   *toolbarBackground;


@property(nonatomic, strong) UIScrollView   *payScrollView;
@property(nonatomic, strong) UILabel *lbAlipay;
@property(nonatomic, strong) UILabel *lbWechat;
@property(nonatomic, strong) UILabel *lbBank;
@property(nonatomic, strong) UILabel *lbCredit;
@property(nonatomic, strong) UILabel *lbHuabie;
@property(nonatomic, strong) UILabel *lbPayOK;

//BottomContainer
@property (nonatomic, strong) UIView *botContainer;
@property (nonatomic, strong) YHExpressionInputView *inputV;
@property (nonatomic, strong) YHExpressionAddView   *addView;//"+"视图

@property (nonatomic, weak)id <YHExpressionKeyboardDelegate>delegate;
@end

@implementation YHExpressionKeyboard


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _toolbarButtonArr = [NSMutableArray new];
        [self _addNotifations];
        [self _initUI];
    }
    return self;
}

#pragma mark - Public
- (instancetype)initWithViewController:( UIViewController <YHExpressionKeyboardDelegate>*)viewController aboveView:(UIView *)aboveView{
    if (self = [super init]) {
        //保存VC和父视图
        self.viewController = viewController;
        _delegate = viewController;
        self.superView = self.viewController.view;
        [self.superView addSubview:self];
        
        //在viewController中,表情键盘上方的视图(aboveView)
        WeakSelf
        if(aboveView){
            _aboveView = aboveView;
            if (![self.superView.subviews containsObject:_aboveView]) {
                [self.superView addSubview:_aboveView];
            }
            
            [_aboveView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.topToolBar.mas_top);
                make.left.right.equalTo(weakSelf.superView);
                make.height.mas_equalTo(SCREEN_HEIGHT-kTopToolbarH-kNaviBarH);
            }];
            
        }
        
        
        //在viewController中,表情键盘在父视图的位置
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(weakSelf.superView).offset(kBotContainerH);
            make.height.mas_equalTo(kBotContainerH+kTopToolbarH);
            make.left.right.equalTo(weakSelf.superView);
            
        }];
    }
    return self;
}

//结束编辑
- (void)endEditing{

    _toolbarButtonTap = NO;
    if (![_textView isFirstResponder]) {
        [self _onlyShowToolbar];
    }else{
        [self.textView resignFirstResponder];
    }
}

- (void) showPaySupport: (NSArray*) support {
    NSLog(@"==========showPaySupport 开始");
    int count = support.count;
    for (int i=0; i< count; i++) {
        NSString *pay =  support[i];
//        switch [pay intValue]:
//            case :
//                break;
    }
}

#pragma mark - filePrivate
- (void)_addNotifations {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_layoutUI{
    WeakSelf
    [_topToolBar setContentHuggingPriority:389 forAxis:UILayoutConstraintAxisVertical];
    [_topToolBar setContentCompressionResistancePriority:889 forAxis:UILayoutConstraintAxisVertical];
    
    [_topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.botContainer.mas_top);
        make.height.mas_equalTo(kTopToolbarH + kTopPayLabelH);
    }];
    
    [_toolbarBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.topToolBar);
        make.height.mas_equalTo(kBotContainerH);
    }];
    
    [_toolbarVioceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kToolbarBtnH);
        make.left.equalTo(weakSelf.topToolBar.mas_left); //.offset(5)
        make.bottom.equalTo(weakSelf.topToolBar).offset(-8);
    }];
    [_toolbarVioceButton setWidth:0];
    [_toolbarVioceButton setHidden:YES];


    [_toolbarEmoticonButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kToolbarBtnH);
        make.right.equalTo(weakSelf.toolbarExtraButton.mas_left);
        make.bottom.equalTo(weakSelf.topToolBar).offset(-8);
    }];

    [_toolbarExtraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kToolbarBtnH);
        make.right.equalTo(weakSelf.topToolBar.mas_right);
        make.bottom.equalTo(weakSelf.topToolBar).offset(-8);
    }];

    [_payScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.topToolBar);
        make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        make.width.mas_equalTo(900);
        make.height.mas_equalTo(kTopPayLabelH +5);
    }];

    [_lbAlipay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.payScrollView).offset(5);
        make.top.equalTo(weakSelf.payScrollView).offset(1);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.bottom.equalTo(weakSelf.textView).offset(-kTextVTopMargin);
        //make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];

    [_lbWechat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbAlipay).offset(60);
        make.top.equalTo(weakSelf.payScrollView).offset(1);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.bottom.equalTo(weakSelf.textView).offset(-kTextVTopMargin);
        //make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];

    [_lbBank mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbWechat).offset(45);
        make.top.equalTo(weakSelf.payScrollView).offset(1);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.bottom.equalTo(weakSelf.textView).offset(-kTextVTopMargin);
        //make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];
    [_lbCredit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbBank).offset(60);
        make.top.equalTo(weakSelf.payScrollView).offset(1);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.bottom.equalTo(weakSelf.textView).offset(-kTextVTopMargin);
        //make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];
    [_lbHuabie mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbCredit).offset(60);
        make.top.equalTo(weakSelf.payScrollView).offset(1);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.bottom.equalTo(weakSelf.textView).offset(-kTextVTopMargin);
        //make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];
    [_lbPayOK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbHuabie).offset(45);
        make.top.equalTo(weakSelf.payScrollView).offset(1);
        //make.top.equalTo(weakSelf.topToolBar).offset(kTextVTopMargin);
        //make.bottom.equalTo(weakSelf.textView).offset(-kTextVTopMargin);
        //make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];

    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        // make.left.equalTo(weakSelf.toolbarVioceButton.mas_right).offset(5);
        make.left.equalTo(weakSelf.topToolBar).offset(5);
        make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);

        make.top.equalTo(weakSelf.payScrollView).offset(kTopPayLabelH);
        make.bottom.equalTo(weakSelf.topToolBar).offset(-kTextVTopMargin);

    }];
    
    [_toolbarPresstoSpeakButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.toolbarVioceButton.mas_right).offset(5);
        make.centerY.equalTo(weakSelf.topToolBar.mas_centerY);
        make.height.mas_equalTo(30);
        make.right.equalTo(weakSelf.toolbarEmoticonButton.mas_left).offset(-5);
    }];
    [_toolbarPresstoSpeakButton setHidden:YES];

    [_botContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kBotContainerH);
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
    }];
    
    [_inputV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(weakSelf.botContainer);
        make.left.right.bottom.equalTo(weakSelf.botContainer);
    }];
    
    [_addView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(weakSelf.botContainer);
        make.left.right.equalTo(weakSelf.botContainer);
        make.bottom.equalTo(weakSelf.botContainer).offset(kBotContainerH);
    }];
}


- (void)_initUI{

    //顶部工具栏
    UIView *topToolBar = [UIView new];
    topToolBar.backgroundColor = [UIColor whiteColor];
    topToolBar.userInteractionEnabled = YES;
    [self addSubview:topToolBar];
    _topToolBar = topToolBar;
    _topToolBar.userInteractionEnabled = YES;
    
    
    //顶部线
    UIView *line = [UIView new];
    line.backgroundColor = UIColorHex(BFBFBF);
    [topToolBar addSubview:line];
    
    
    //顶部工具栏背景层
    UIView *topToolBarBG = [UIView new];
    topToolBarBG.backgroundColor = UIColorHex(F9F9F9);
    [topToolBar addSubview:topToolBarBG];
    _toolbarBackground = topToolBarBG;

    _payScrollView = [UIScrollView new];
    _payScrollView.showsVerticalScrollIndicator = NO;
    _payScrollView.showsHorizontalScrollIndicator = NO;
    _payScrollView.contentSize =  CGSizeMake(800, 0);
    _payScrollView.userInteractionEnabled = YES;
    _payScrollView.delaysContentTouches = NO;
    [self.topToolBar addSubview:_payScrollView];

    _lbAlipay = [UILabel new];
    _lbAlipay.font = [UIFont systemFontOfSize:16.0];
    _lbAlipay.numberOfLines = 1;
    _lbAlipay.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbAlipay.textColor = [UIColor blueColor];
    _lbAlipay.text = keybordPayAlipay;
    _lbAlipay.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _lbAlipay.layer.cornerRadius = 5;
    _lbAlipay.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapSendAlipay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendAlipay)];
    [_lbAlipay addGestureRecognizer:tapSendAlipay];

    [self.payScrollView addSubview:_lbAlipay];

    _lbWechat = [UILabel new];
    _lbWechat.font = [UIFont systemFontOfSize:16.0];
    _lbWechat.numberOfLines = 1;
    _lbWechat.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbWechat.textColor = [UIColor blueColor];
    _lbWechat.text = keybordPayWeChat;
    _lbWechat.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _lbWechat.layer.cornerRadius = 5;
    _lbWechat.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapSendWechat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendWechat)];
    [_lbWechat addGestureRecognizer:tapSendWechat];

    [self.payScrollView addSubview:_lbWechat];

    _lbBank = [UILabel new];
    _lbBank.font = [UIFont systemFontOfSize:16.0];
    _lbBank.numberOfLines = 1;
    _lbBank.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbBank.textColor = [UIColor blueColor];
    _lbBank.text = keybordPayBankCard;
    _lbBank.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _lbBank.layer.cornerRadius = 5;
    _lbBank.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapSendBank = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendBank)];
    [_lbBank addGestureRecognizer:tapSendBank];
    [self.payScrollView addSubview:_lbBank];

    _lbCredit = [UILabel new];
    _lbCredit.font = [UIFont systemFontOfSize:16.0];
    _lbCredit.numberOfLines = 1;
    _lbCredit.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbCredit.textColor = [UIColor blueColor];
    _lbCredit.text = keybordPayCredit;
    _lbCredit.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _lbCredit.layer.cornerRadius = 5;
    _lbCredit.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapSendCredit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendCredit)];
    [_lbCredit addGestureRecognizer:tapSendCredit];

    [self.payScrollView addSubview:_lbCredit];

    _lbHuabie = [UILabel new];
    _lbHuabie.font = [UIFont systemFontOfSize:16.0];
    _lbHuabie.numberOfLines = 1;
    _lbHuabie.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbHuabie.textColor = [UIColor blueColor];
    _lbHuabie.text = keybordPayHuabie;
    _lbHuabie.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _lbHuabie.layer.cornerRadius = 5;
    _lbHuabie.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapSendHuabie = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendHuabie)];
    [_lbHuabie addGestureRecognizer:tapSendHuabie];
    [self.payScrollView addSubview:_lbHuabie];

    _lbPayOK = [UILabel new];
    _lbPayOK.font = [UIFont systemFontOfSize:16.0];
    _lbPayOK.numberOfLines = 1;
    _lbPayOK.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbPayOK.textColor = [UIColor blueColor];
    _lbPayOK.text = keybordPayOK;
    _lbPayOK.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _lbPayOK.layer.cornerRadius = 5;
    _lbPayOK.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapSendPayOK = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendPayOK)];
    [_lbPayOK addGestureRecognizer:tapSendPayOK];

    [self.payScrollView addSubview:_lbPayOK];
    
    //拍照按钮
    _toolbarVioceButton = [self _creatToolbarButton];
    [self _setupBtnImage:_toolbarVioceButton];
    
    //输入框
    [self _initTextView];
    
    //按住说话 (默认是隐藏的)
    [self _initToolbarPresstoSpeakButton];

    //表情按钮
    _toolbarEmoticonButton = [self _creatToolbarButton];
    [self _setupBtnImage:_toolbarEmoticonButton];
    
    //"+"按钮
    _toolbarExtraButton = [self _creatToolbarButton];
    [self _setupBtnImage:_toolbarExtraButton];
    
    
    [_toolbarButtonArr addObjectsFromArray:@[_toolbarVioceButton,_toolbarEmoticonButton,_toolbarExtraButton]];
    
    //底部容器
    [self _initBotContainer];
    
    [self _layoutUI];
}

- (void)_initTextView {
    
    _textView = [YHExpressionTextView new];
    _textView.layer.cornerRadius =3;
    _textView.layer.borderWidth  = 1;
    _textView.layer.masksToBounds = YES;
    _textView.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;
    _textView.showsVerticalScrollIndicator = YES;
    _textView.alwaysBounceVertical = NO;
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    
    [_topToolBar addSubview:_textView];
    
    _height_oneRowText = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer].size.height;
    _height_Toolbar    = kTopToolbarH + kTopPayLabelH;
}

- (void)_initToolbarPresstoSpeakButton{
    _toolbarPresstoSpeakButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _toolbarPresstoSpeakButton.hidden = YES;
    _toolbarPresstoSpeakButton.exclusiveTouch = YES;
    
    [_toolbarPresstoSpeakButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [_toolbarPresstoSpeakButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_toolbarPresstoSpeakButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];

    [_toolbarPresstoSpeakButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_toolbarPresstoSpeakButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbarPresstoSpeakButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [_toolbarPresstoSpeakButton addTarget:self action:@selector(talkButtonTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    [_toolbarPresstoSpeakButton addTarget:self action:@selector(talkButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [_toolbarPresstoSpeakButton addTarget:self action:@selector(talkButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    
    _toolbarPresstoSpeakButton.layer.cornerRadius =3;
    _toolbarPresstoSpeakButton.layer.borderWidth  = 1;
    _toolbarPresstoSpeakButton.layer.masksToBounds = YES;
    _toolbarPresstoSpeakButton.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0].CGColor;
    _toolbarPresstoSpeakButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    
    UIImage *img = nil;
    
    img = [YHExpressionHelper
           imageNamed:@"compose_emotion_table_left_selected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [_toolbarPresstoSpeakButton setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [YHExpressionHelper imageNamed:@"compose_emotion_table_left_normal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [_toolbarPresstoSpeakButton setBackgroundImage:img forState:UIControlStateHighlighted];
    [_toolbarPresstoSpeakButton addTarget:self action:@selector(_onPresstoSpeak:) forControlEvents:UIControlEventTouchUpInside];
    [_topToolBar addSubview:_toolbarPresstoSpeakButton];
}

- (UIButton *)_creatToolbarButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button addTarget:self action:@selector(_onToolbarBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_topToolBar addSubview:button];
    return button;
}


- (void)_initBotContainer{
    _botContainer = [UIView new];
    _botContainer.backgroundColor = UIColorHex(F9F9F9);
    [self addSubview:_botContainer];
    
    //表情
    YHExpressionInputView *inputV =[YHExpressionInputView sharedView];
    inputV.delegate = self;
    [_botContainer addSubview:inputV];
    _inputV = inputV;
    
    //"+"视图内容
    YHExpressionAddView *addView = [YHExpressionAddView sharedView];
    addView.delegate = self;
    [_botContainer addSubview:addView];
    _addView = addView;
}


- (void)_aboveViewScollToBottom{
    if (_aboveView && [_aboveView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scr = (UIScrollView *) _aboveView;
        [self _scrollToBottom:scr];
        
    }
}

- (void)_scrollToBottom:(UIScrollView *)scrollView{
    CGPoint off = scrollView.contentOffset;
    off.y = scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom;
    [scrollView setContentOffset:off animated:YES];
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    for (UIButton *b in _toolbarButtonArr) {
        b.selected = NO;
        [self _setupBtnImage:b];
    }
    [self _aboveViewScollToBottom];
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@""]) {
        [_textView deleteEmoticon];
    }
    if([text isEqualToString:@"\n"]){
        //发送
        [self didTapSendBtn];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    
    [self _textViewChangeText];

}

-(void)_textViewChangeText{
    
    CGFloat textH = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer].size.height;
    
    int numberOfRowsShow;
    if (!_maxNumberOfRowsToShow) {
        numberOfRowsShow = 4;
    }
    else{
        numberOfRowsShow = _maxNumberOfRowsToShow;
    }
    
    CGFloat rows_h = _height_oneRowText*numberOfRowsShow;
    textH = textH>rows_h?rows_h:textH;
    
    //输入框高度
    CGFloat h_inputV = kTopToolbarH + kTopPayLabelH + 20 - 2*kTextVTopMargin;
    
    if (textH < h_inputV) {
        [_topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kTopToolbarH + kTopPayLabelH); //+ kTopPayLabelH - 20
        }];
        _height_Toolbar = kTopToolbarH + kTopPayLabelH - 20;
    }else{
        //工具栏高度
        CGFloat toolbarH = ceil(textH) + 2*kTextVTopMargin + kTopPayLabelH;
        [_topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(toolbarH);
        }];
        _height_Toolbar = toolbarH;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kBotContainerH+toolbarH);
        }];
    }
    WeakSelf
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
    
    [_textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];

    
}

#pragma mark - @protocol YHExpressionInputViewDelegate
- (void)emoticonInputDidTapText:(NSString *)text{
    if (text.length) {
        //设置表情符号
        _textView.emoticon = text;
        [self _textViewChangeText];
    }
   
}

- (void)emoticonInputDidTapBackspace{

    [_textView deleteEmoticon];
    [self _textViewChangeText];
    
}

- (void)didTapSendBtn {
    DDLog(@"点击发送,发送文本是：\n%@",_textView.text);
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:_textView.text];
    }
    
    //清空输入内容
    self.textView.text = @"";
    [self _textViewChangeText];
}

- (void)sendAlipay {
    DDLog(@"点击 发送 wo要支付宝充值");
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:kPayAlipay];
    }
}

- (void)sendWechat {
    DDLog(@"点击 sendWechat");
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:kPayWeChat];
    }
}

- (void)sendBank {
    DDLog(@"点击 sendBank");
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:kPayBankCard];
    }
}

- (void)sendCredit {
    DDLog(@"点击 sendCredit");
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:kPayCredit];
    }
}

- (void)sendHuabie {
    DDLog(@"点击 sendHuabie");
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:kPayHuabie];
    }
}

- (void)sendPayOK {
    DDLog(@"点击 sendPayOK");
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn:)]) {
        [_delegate didTapSendBtn:kPayOK];
    }
}

#pragma mark - @protocol YHExpressionAddViewDelegate

- (void)extraItemDidTap:(YHExtraModel *)model{
    if(_delegate && [_delegate respondsToSelector:@selector(didSelectExtraItem:)]){
        [_delegate didSelectExtraItem:model.name];
    }
}

#pragma mark - Action

/**
 设置btn图片
 */
- (void)_setupBtnImage:(UIButton *)btn{
    

    if(btn == _toolbarVioceButton){
        if (!btn.selected) {
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_toolbar_voice"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_toolbar_voice"] forState:UIControlStateHighlighted];
        }else{
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_keyboardbutton_background"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_keyboardbutton_background_highlighted"] forState:UIControlStateHighlighted];
            
        }

    }else if (btn == _toolbarEmoticonButton) {
        if (!btn.selected) {
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_emoticonbutton_background"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_emoticonbutton_background_highlighted"] forState:UIControlStateHighlighted];
        }else{
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_keyboardbutton_background"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"compose_keyboardbutton_background_highlighted"] forState:UIControlStateHighlighted];
            
        }
    }else if(btn == _toolbarExtraButton){
        if (!btn.selected) {
            [btn setImage:[YHExpressionHelper imageNamed:@"message_add_background"] forState:UIControlStateNormal];
            [btn setImage:[YHExpressionHelper imageNamed:@"message_add_background_highlighted"] forState:UIControlStateHighlighted];
        }
       
    }
    
}


/**
  点击toolBarButton
 */
- (void)_onToolbarBtn:(UIButton *)button {
    
    _toolbarButtonSelected = button;
    
    _toolbarButtonTap = YES;
    
    //重设toolBar其他按钮的selected状态
    for (UIButton *btn in _toolbarButtonArr) {
        if (btn != button) {
            btn.selected = NO;
            [self _setupBtnImage:btn];
        }
    }
    
    //设置选中button的selected状态
    button.selected = !button.selected;
    [self _setupBtnImage:button];
    
    
    //隐藏按住说话按钮
    if (button.selected && button != _toolbarVioceButton) {
        
        [self _hiddenPressToSpeakButton];
    }
    
    //aboveView滚到底部
    if(button != _toolbarVioceButton){
        [self _aboveViewScollToBottom];
    }
    
    
    if (button == _toolbarVioceButton) {
        if(button.selected){
            if([_textView isFirstResponder]){
                [_textView resignFirstResponder];
            }else{
    
                [self _onlyShowToolbar];
            }
            
            [self _showPressToSpeakButton];
            
        }else{
            [self _hiddenPressToSpeakButton];
            
            
            [_textView becomeFirstResponder];
        }
        
    }else if (button == _toolbarEmoticonButton) {
        
        if (!button.selected) {
            //显示键盘
            [_textView becomeFirstResponder];

        }else{
            
            //显示表情
            if (![_textView isFirstResponder]) {
                [self _showExpressionKeyboard];
            }else{
                [_textView resignFirstResponder];
            }

            
        }
        
        
    }else if (button == _toolbarExtraButton) {
        
        if (!button.selected){
            [self _onlyShowToolbar];
        }else {
            //显示"+"内容
            if (![_textView isFirstResponder]) {
                [self _showAddView];
            }else{
                [_textView resignFirstResponder];
            }

        }
    }
}


/**
 只显示toolBar
 */
- (void)_onlyShowToolbar {
    WeakSelf
    
    [_inputV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer).offset(kBotContainerH);
    }];
    [_addView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer).offset(kBotContainerH);
    }];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.superView).offset(kBotContainerH);
    }];
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
    
    
    
}


/**
 显示按住说话
 */
- (void)_showPressToSpeakButton{
    WeakSelf
    [self.topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kTopToolbarH);
    }];
    _textView.hidden = YES;
    self.toolbarPresstoSpeakButton.hidden = NO;
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
}

/**
 隐藏按住说话
 */
- (void)_hiddenPressToSpeakButton{
    WeakSelf
    [self.topToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_height_Toolbar);
    }];
    _textView.hidden = NO;
    self.toolbarPresstoSpeakButton.hidden = YES;
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
}


/**
 显示表情键盘
 */
- (void)_showExpressionKeyboard{
    //表情键盘上移，addView下移
    WeakSelf
    [_inputV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer);
    }];
    [_addView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer).offset(kBotContainerH);
    }];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.superView);
    }];
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];

}


/**
 显示AddView
 */
- (void)_showAddView{
    //表情键盘下移，addView上移
    WeakSelf
    [_inputV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer).offset(kBotContainerH);
    }];
    [_addView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.botContainer);
    }];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.superView);
    }];
    [UIView animateWithDuration:DURTAION animations:^{
        [weakSelf.superView layoutIfNeeded];
    }];
}

- (void)_onPresstoSpeak:(UIButton *)btn{
    btn.selected = !btn.selected;
    
}

// 说话按钮
- (void)talkButtonDown:(UIButton *)sender
{
//    DDLog(@"talkButtonDown");
    if(_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoice)]){
        [_delegate didStartRecordingVoice];
    }
}

- (void)talkButtonUpInside:(UIButton *)sender
{
//     DDLog(@"talkButtonUpInside");
    if(_delegate && [_delegate respondsToSelector:@selector(didStopRecordingVoice)]){
        [_delegate didStopRecordingVoice];
    }
}

- (void)talkButtonUpOutside:(UIButton *)sender
{
//     DDLog(@"talkButtonUpOutside");
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoice)]){
        [_delegate didCancelRecordingVoice];
    }
}

- (void)talkButtonDragOutside:(UIButton *)sender
{
//    DDLog(@"talkButtonDragOutside");
    if(_delegate && [_delegate respondsToSelector:@selector(didDragInside:)]){
        [_delegate didDragInside:NO];
    }
}

- (void)talkButtonDragInside:(UIButton *)sender
{
//     DDLog(@"talkButtonDragInside");
    if(_delegate && [_delegate respondsToSelector:@selector(didStopRecordingVoice)]){
        [_delegate didDragInside:YES];
    }
}

- (void)talkButtonTouchCancel:(UIButton *)sender
{
     DDLog(@"talkButtonTouchCancel");
}


#pragma mark - Gesture



#pragma mark - NSNotification

- (void)keyBoardHidden:(NSNotification*)noti{
    
    //隐藏键盘

    if (!_toolbarButtonTap) {

        
        [self _onlyShowToolbar];
        
    
    }else{
        _toolbarButtonTap = NO;
        
        if (_toolbarButtonSelected == _toolbarEmoticonButton) {
            [self _showExpressionKeyboard];
        }else{
            [self _onlyShowToolbar];
        }
    }
    
}

- (void)keyBoardShow:(NSNotification*)noti{
    //显示键盘
    WeakSelf
    CGRect endF = [[noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    if (!_toolbarButtonTap) {
    
        NSTimeInterval duration = [[noti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGFloat diffH = endF.size.height - kBotContainerH;//高度差
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.superView).offset(-diffH);
        }];
        [UIView animateWithDuration:duration animations:^{
            [weakSelf.superView layoutIfNeeded];
        }];
        
    }else{
        _toolbarButtonTap = NO;

        CGFloat diffH = endF.size.height - kBotContainerH;//高度差
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.superView).offset(-diffH);
           
        }];
       
    }

}


- (void)_changeDuration:(CGFloat)duration{
    //动态调整tableView高度
    if (_delegate && [self.delegate respondsToSelector:@selector(keyboard:changeDuration:)]) {
        [self.delegate keyboard:self changeDuration:duration];
    }
}


@end
