//
//  YHChatDetailVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <ZLPhotoBrowser/ZLPhotoBrowser.h>
#import <ZLPhotoBrowser/ZLCustomCamera.h>

#import "YHChatDetailVC.h"
#import "YHRefreshTableView.h"
#import "YHChatHeader.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
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
#import "YHChatShowAlipay.h"
#import "CellChatWeChatLeft.h"
#import "CellChatCreditLeft.h"
#import "CellChatHuabieLeft.h"
#import "CellChatBankLeft.h"
#import "YHChatShowWePay.h"


@interface YHChatDetailVC () <UITableViewDelegate, UITableViewDataSource, YHExpressionKeyboardDelegate, CellChatTextLeftDelegate, CellChatTextRightDelegate, CellChatVoiceLeftDelegate, CellChatVoiceRightDelegate, CellChatImageLeftDelegate, CellChatImageRightDelegate, CellChatBaseDelegate,
        CellChatFileLeftDelegate, CellChatFileRightDelegate,
        CellChatAlipayLeftDelegate, CellChatWeChatLeftDelegate,
        CellChatCreditLeftDelegate, CellChatBankLeftDelegate,
        CellChatHuabieLeftDelegate> {

}
@property(nonatomic, strong) YHRefreshTableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NSMutableArray *layouts;
@property(nonatomic, strong) YHExpressionKeyboard *keyboard;
@property(nonatomic, strong) YHVoiceHUD *imgvVoiceTips;

@property(nonatomic, strong) YHChatHelper *chatHelper;

@property(nonatomic, assign) BOOL showCheckBox;

@end

@implementation YHChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.translucent = NO;
    // self.navigationController.navigationBar.barTintColor    = kBlueColor;
    //设置导航栏
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];

//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"更多" target:self selector:@selector(onMore:) block:^(UIButton *btn) {
//        btn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [btn setTitle:@"取消" forState:UIControlStateSelected];
//        [btn setTitle:@"更多" forState:UIControlStateNormal];
//    }];

    if (self.model.agentName != nil) {
        self.title = self.model.agentName;
    } else {
        self.title = self.model.isGroupChat ? [NSString stringWithFormat:@"%@(%lu)", self.model.sessionUserName, (unsigned long) self.model.sessionUserHead.count] : self.model.sessionUserName;
    }

    [self initUI];


    //模拟数据源
    // [self.dataArray addObjectsFromArray:[TestData randomGenerateChatModel:5 aChatListModel:self.model]];
    //---TODO...从数据库拿数据。
    // TODO。。。 sessionID 用 代理的id。。
    [[SqliteManager sharedInstance] queryChatLogTableWithType:DBChatType_Private sessionID:self.model.agentId userInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
        if (success) {
            //----
            CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
            for (YHChatModel *chatModel in obj) {
                [self.dataArray addObject:chatModel];
                UIColor *textColor = [UIColor blackColor];
                UIColor *matchTextColor = UIColorHex(527ead);
                UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
                if (chatModel.direction == 0) {
                    textColor = [UIColor blackColor];  //whiteColor
                    matchTextColor = [UIColor greenColor];
                    matchTextHighlightBGColor = [UIColor grayColor];
                }
                YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
                [layout layoutWithText:chatModel.msgContent fontSize:(14 + addFontSize) textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
                chatModel.layout = layout;
                [self.layouts addObject:layout];
            }

            if (self.dataArray.count) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0]
                                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                });

            }
        } else {
            DDLog(@"查询数据库数据库失败，没获取到数据。:%@", obj);
        }
    }];

    //设置WebScoket
    //[[YHChatManager sharedInstance] connectToUserID:@"99f16547-637c-4d84-8a55-ef24031977dd" isGroupChat:NO];
    [[YHChatManager sharedInstance] connectQuickpay];


    // 有收到网络的数据，及时去数据库拿数据进行更新。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:kWebSocketDidOpenNote object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:kWebSocketdidReceiveMessageNote object:nil];

    // 测试要发送的消息的数据结构json
    NSString *initStr = [[QuickPayNetConstants sharedInstance] assembleReqChatInit:@"1234567890"];
    NSString *testOffMsg = [[QuickPayNetConstants sharedInstance] assembleReqOffMsg:@"1234567890"];
    NSString *testSupportPay = [[QuickPayNetConstants sharedInstance] assembleReqChatPay:@"1234567890"];
    NSString *alipy = [[QuickPayNetConstants sharedInstance] assembleSendAlipay:@"1234567890"];
    NSString *wechat = [[QuickPayNetConstants sharedInstance] assembleSendWeChat:@"1234567890"];
    NSString *bank = [[QuickPayNetConstants sharedInstance] assembleSendBank:@"1234567890"];
    NSString *credit = [[QuickPayNetConstants sharedInstance] assembleSendCredit:@"1234567890"];
    NSString *hub = [[QuickPayNetConstants sharedInstance] assembleSendHuaBie:@"1234567890"];
    NSString *sendok = [[QuickPayNetConstants sharedInstance] assembleSendOK:@"1234567890"];
    NSString *normakltext = [[QuickPayNetConstants sharedInstance] assembleSendNormalText:@"hellowod" agentID:@"1234567890"];
    NSString *normakltext2 = [[QuickPayNetConstants sharedInstance] assembleSendNormalText:@"hellowoddd4444" agentID:@"1234567890"];

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

- (YHVoiceHUD *)imgvVoiceTips {
    if (!_imgvVoiceTips) {
        _imgvVoiceTips = [[YHVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _imgvVoiceTips.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
        [self.view addSubview:_imgvVoiceTips];
    }
    return _imgvVoiceTips;
}


- (void)initUI {


    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = RGBCOLOR(239, 236, 236);

    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(239, 236, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //注册Cell
    _chatHelper = [[YHChatHelper alloc] init];
    [_chatHelper registerCellClassWithTableView:self.tableView];

    //表情键盘
    YHExpressionKeyboard *keyboard = [[YHExpressionKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;

}


#pragma mark - @protocol CellChatTextLeftDelegate

- (void)tapLeftAvatar:(YHUserInfo *)userInfo {
    DDLog(@"点击左边头像");
}

- (void)retweetMsg:(NSString *)msg inLeftCell:(CellChatTextLeft *)leftCell {
    DDLog(@"转发左边消息:%@", msg);
    DDLog(@"所在的行是:%ld", leftCell.indexPath.row);
}

- (void)onLinkInChatTextLeftCell:(CellChatTextLeft *)cell linkType:(int)linkType linkText:(NSString *)linkText {
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) url:[NSURL URLWithString:linkText]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatTextRightDelegate

- (void)tapRightAvatar:(YHUserInfo *)userInfo {
    DDLog(@"点击右边头像");
}

- (void)retweetMsg:(NSString *)msg inRightCell:(CellChatTextRight *)rightCell {
    DDLog(@"转发右边消息:%@", msg);
    DDLog(@"所在的行是:%ld", (long) rightCell.indexPath.row);
}

- (void)tapSendMsgFailImg {
    DDLog(@"重发该消息?");
    [HHUtils showAlertWithTitle:@"重发该消息?" message:nil okTitle:@"重发" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes) {
        if (resultYes) {
            DDLog(@"点击重发");
        }
    }];
}

- (void)withDrawMsg:(NSString *)msg inRightCell:(CellChatTextRight *)rightCell {
    DDLog(@"撤回消息:\n%@", msg);
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)onLinkInChatTextRightCell:(CellChatTextRight *)cell linkType:(int)linkType linkText:(NSString *)linkText {
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) url:[NSURL URLWithString:linkText]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatImageLeftDelegate

- (void)retweetImage:(UIImage *)image inLeftCell:(CellChatImageLeft *)leftCell {
    DDLog(@"转发图片：%@", image);
}

#pragma mark - @protocol CellChatImageRightDelegate

- (void)retweetImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell {
    DDLog(@"转发图片：%@", image);
}

- (void)withDrawImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell {
    DDLog(@"撤回图片：%@", image);
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }

}


#pragma mark - @protocol CellChatVoiceLeftDelegate

- (void)playInLeftCellWithVoicePath:(NSString *)voicePath {
    DDLog(@"播放:%@", voicePath);

}

- (void)retweetVoice:(NSString *)voicePath inLeftCell:(CellChatVoiceLeft *)leftCell {
    DDLog(@"转发语音:%@", voicePath);
}

#pragma mark - @protocol CellChatVoiceRightDelegate

- (void)playInRightCellWithVoicePath:(NSString *)voicePath {
    DDLog(@"播放:%@", voicePath);

}

//转发语音
- (void)retweetVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell {
    DDLog(@"转发语音:%@", voicePath);
}

//撤回语音
- (void)withDrawVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell {
    DDLog(@"撤回语音:%@", voicePath);
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - @protocol CellChatAlipayLeftDelegate

- (void)onChatAlipay:(YHChatModel *)chatAlipay inLeftCell:(CellChatAlipayLeft *)leftCell {
    DDLog(@"alipay jump:%@", chatAlipay);
    YHChatShowAlipay *vc = [[YHChatShowAlipay alloc] init];
    vc.msgBody = chatAlipay.msgBodyJson;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)onChatWeChat:(YHChatModel *)chatAlipay inLeftCell:(CellChatWeChatLeft *)leftCell {
    DDLog(@"alipay jump:%@", chatAlipay);
    YHChatShowWePay *vc = [[YHChatShowWePay alloc] init];
    vc.msgBody = chatAlipay.msgBodyJson;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)onChatCredit:(YHChatModel *)chatFile inLeftCell:(CellChatCreditLeft *)leftCell {
    DDLog(@"alipay jump:%@", chatFile);
    YHChatShowAlipay *vc = [[YHChatShowAlipay alloc] init];
    //vc.model = chatFile.payInfoModel;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onChatBank:(YHChatModel *)chatAlipay inLeftCell:(CellChatBankLeft *)leftCell {
    DDLog(@"alipay jump:%@", chatAlipay);
    YHChatShowAlipay *vc = [[YHChatShowAlipay alloc] init];
    //vc.model = chatAlipay.payInfoModel;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)onChatHuabie:(YHChatModel *)chatAlipay inLeftCell:(CellChatHuabieLeft *)leftCell {
    DDLog(@"alipay jump:%@", chatAlipay);
    YHChatShowAlipay *vc = [[YHChatShowAlipay alloc] init];
    //vc.model = chatAlipay.payInfoModel;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}


#pragma mark - @protocol CellChatFileLeftDelegate

//点击文件
- (void)onChatFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell {
    if (chatFile.filePathInLocal) {
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal]];
        vc.title = chatFile.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }

}

//转发文件
- (void)retweetFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell {

}

#pragma mark - @protocol CellChatFileRightDelegate

//点击文件
- (void)onChatFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell {
    if (chatFile.filePathInLocal) {
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal]];
        vc.title = chatFile.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }

}

//转发文件
- (void)retweetFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell {

}

//撤回文件
- (void)withDrawFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell {
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - @protocol CellChatBaseDelegate

- (void)onCheckBoxAtIndexPath:(NSIndexPath *)indexPath model:(YHChatModel *)model {
    DDLog(@"选择第%ld行的聊天记录", (long) indexPath.row);
}


#pragma mark - @protocol UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_keyboard endEditing];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}


#pragma mark - @protocol UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        if (model.status == 1) {
            //消息撤回
            CellChatTips *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTips class])];
            cell.model = model;
            return cell;
        } else {
            if (model.msgType == YHMessageType_Image) {
                if (model.direction == 0) {

                    CellChatImageRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;

                } else {

                    CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];

                    return cell;
                }

            } else if (model.msgType == YHMessageType_Voice) {

                if (model.direction == 0) {
                    CellChatVoiceRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatVoiceLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }

            } else if (model.msgType == YHMessageType_Doc) {
                if (model.direction == 0) {
                    CellChatFileRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatFileRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatFileLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatFileLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }

            } else if (model.msgType == YHMessageType_GIF) {

                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatGIFLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFLeft class])];
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }

            } else if (model.msgType == YHMessageType_ALIPAY) {

                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    //cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatAlipayLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatAlipayLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            } else if (model.msgType == YHMessageType_WECHAT) {

                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    //cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatWeChatLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatWeChatLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            } else if (model.msgType == YHMessageType_BANK) {

                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    //cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatBankLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatBankLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            } else if (model.msgType == YHMessageType_CREDIT) {

                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    //cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatCreditLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatCreditLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            } else if (model.msgType == YHMessageType_HUABIE) {

                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    //cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatHuabieLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatHuabieLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            } else {
                if (model.direction == 0) {
                    CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                } else {
                    CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            }

        }


    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - @protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        return [_chatHelper heightWithModel:model tableView:tableView];
    }
    return 44.0f;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLog(@"选择第%ld行的聊天记录", (long) indexPath.row);
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        DDLog(@"选择第%ld行的聊天记录", (long) indexPath.row);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}


// 松手时已经静止,只会调用scrollViewDidEndDragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) { // scrollView已经完全静止
        [self _handleAnimatedImageView];
    }
}

// 松手时还在运动, 先调用scrollViewDidEndDragging,在调用scrollViewDidEndDecelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // scrollView已经完全静止
    [self _handleAnimatedImageView];
}

- (void)_handleAnimatedImageView {
    for (UITableViewCell *visiableCell in self.tableView.visibleCells) {
        if ([visiableCell isKindOfClass:[CellChatGIFLeft class]]) {
            [(CellChatGIFLeft *) visiableCell startAnimating];
        } else if ([visiableCell isKindOfClass:[CellChatGIFRight class]]) {
            [(CellChatGIFRight *) visiableCell startAnimating];
        }
    }
}

#pragma mark - Private

- (NSString *)currentRecordFileName {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long) timeInterval];
    return fileName;
}

//显示录音时间太短Tips
- (void)showShortRecordTips {
    WeakSelf
    self.imgvVoiceTips.hidden = NO;
    self.imgvVoiceTips.image = [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.imgvVoiceTips.hidden = YES;
    });
}

#pragma mark - @protocol YHExpressionKeyboardDelegate

//发送-click keyboad sending button.
- (void)didTapSendBtn:(NSString *)text {
    DDLog(@"构造发送消息%@", text);
    if (text.length) {
        YHChatModel *chatModel = [YHChatHelper creatMessage:text msgType:YHMessageType_Text toID:nil];
        // TODO.... agentID 要写如对应的那个代理。
        chatModel.agentId = @"67553";
        if (_model.agentAvatar == nil) {
            if (_model.sessionUserHead != nil) {
                chatModel.agentAvatar = _model.sessionUserHead[0];
            }
        } else {
            chatModel.agentAvatar = _model.agentAvatar;
        }

        if (_model.agentName != nil) {
            chatModel.agentName = _model.agentName;
        } else if (_model.sessionUserName != nil) {
            chatModel.agentName = _model.sessionUserName;
        }

        [self.dataArray addObject:chatModel];

        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }

    // TODO...这个shi本地测试。。。。
    NSString *jsonStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response_offSingle" ofType:@"json"] encoding:0 error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketdidReceiveMessageNote object:jsonStr];

}

- (void)didStartRecordingVoice {
    WeakSelf
    self.imgvVoiceTips.hidden = NO;
    [[YHAudioRecorder shareInstanced] startRecordingWithFileName:[self currentRecordFileName] completion:^(NSError *error) {
        if (error) {
            if (error.code != 122) {
                [HHUtils showAlertWithTitle:@"" message:error.localizedDescription okTitle:@"确定" cancelTitle:nil inViewController:self dismiss:^(BOOL resultYes) {

                }];
            }
        }
    }                                                      power:^(float progress) {
        weakSelf.imgvVoiceTips.progress = progress;
    }];
}

- (void)didStopRecordingVoice {
    self.imgvVoiceTips.hidden = YES;
    WeakSelf
    [[YHAudioRecorder shareInstanced] stopRecordingWithCompletion:^(NSString *recordPath) {
        if ([recordPath isEqualToString:shortRecord]) {
            [weakSelf showShortRecordTips];
        } else {
            DDLog(@"record finish , file path is :\n%@", recordPath);
            NSString *voiceMsg = [NSString stringWithFormat:@"voice[local://%@]", recordPath];
            [weakSelf.dataArray addObject:[YHChatHelper creatMessage:voiceMsg msgType:YHMessageType_Voice toID:@"1"]];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToBottomAnimated:NO];
        }
    }];
}

- (void)didDragInside:(BOOL)inside {
    if (inside) {

        [[YHAudioRecorder shareInstanced] resumeUpdateMeters];
        self.imgvVoiceTips.image = [UIImage imageNamed:@"voice_1"];
        self.imgvVoiceTips.hidden = NO;
    } else {

        [[YHAudioRecorder shareInstanced] pauseUpdateMeters];
        self.imgvVoiceTips.image = [UIImage imageNamed:@"cancelVoice"];
        self.imgvVoiceTips.hidden = NO;
    }
}

- (void)didCancelRecordingVoice {
    self.imgvVoiceTips.hidden = YES;
    [[YHAudioRecorder shareInstanced] removeCurrentRecordFile];
}

// TODO... select system's photo选择相片，照相机。 然后上传。 这个要添加相应的代码。
- (void)didSelectExtraItem:(NSString *)itemName {
    if ([itemName isEqualToString:@"文件"]) {
        YHDocumentVC *vc = [[YHDocumentVC alloc] init];
        YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
        [vc didSelectFilesComplete:^(NSArray<NSString *> *files) {
            DDLog(@"准备发送文件。");
        }];
        [self.navigationController presentViewController:nav animated:YES completion:NULL];
    } else if ([itemName isEqualToString:@"拍摄"]) {
        DDLog(@"拍摄");
        //        YHShootVC *vc = [[YHShootVC alloc] init];
        //        [self.navigationController presentViewController:vc animated:YES completion:NULL];


        // 直接调用相机
        ZLCustomCamera *camera = [[ZLCustomCamera alloc] init];

        camera.allowTakePhoto = YES;
        camera.allowRecordVideo = NO;
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            // 自己需要在这个地方进行图片或者视频的保存
            DDLog(@"paoz");
        };

        [self showDetailViewController:camera sender:nil];

    } else if ([itemName isEqualToString:@"照片"]) {
        DDLog(@"照片");
        ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
        // 相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
        ac.configuration.maxSelectCount = 3;
        ac.configuration.maxPreviewCount = 10;
        ac.sender = self;
        // 选择回调
        [ac setSelectImageBlock:^(NSArray<UIImage *> *_Nonnull images, NSArray<PHAsset *> *_Nonnull assets, BOOL isOriginal) {
            //your codes
            DDLog(@"选择成功");
        }];

        // 调用相册
        [ac showPreviewAnimated:YES];

    }
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [picker dismissViewControllerAnimated:YES completion:^{
//        DDLog(@"选择成功");
//    }];
//
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    //self.headImage.image = image;
//}


#pragma mark - 网络请求

- (void)uploadRecordFile:(NSString *)filePath {
    //上传录音文件
    [[YHUploadManager sharedInstance] uploadChatRecordWithPath:filePath complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"上传成功,%@", obj);
        } else {
            DDLog(@"上传失败,%@", obj);
        }
    }                                                 progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        DDLog(@"bytesWritten:%lld -- totalBytesWritten:%lld", bytesWritten, totalBytesWritten);
    }];

}

#pragma mark - Action

- (void)onMore:(UIButton *)sender {
    sender.selected = !sender.selected;
    _showCheckBox = sender.selected ? YES : NO;
    [self.tableView reloadData];
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

#pragma mark - 收到消息通知

- (void)SRWebSocketDidOpen {
    NSLog(@"开启成功");
    //在成功后需要做的操作。。。

}

- (void)SRWebSocketDidReceiveMsg:(NSNotification *)note {
    //收到服务端发送过来的消息
    NSString *jsonStr = nil;


    // 测试的时候用本地的数据
// TODO>>> 重要重要重要
    jsonStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response_offSingle" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    // jsonStr = note.object; // TODO。。用网络服务器时候要打开打开。
    NSLog(@"%@", jsonStr);


    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];

    NSNumber *resultCode = [jsonDic objectForKey:kKey_code];
    NSString *resultMsg = [jsonDic objectForKey:kKey_message];
    NSDictionary *resultDict = [jsonDic objectForKey:kKey_result];
    NSString *msgID = [jsonDic objectForKey:kKey_id];

    if (resultCode != nil && resultMsg != nil) {
        // 从最外层开始解析。
        if ([resultCode longValue] == kValueSucessCode && [resultMsg isEqualToString:kValueSucessMsg]) {
            // 正确的消息解析。
            NSLog(@"==========key:%@", resultCode);
            [self processMsgEntry:resultDict];
        } else {
            // 错误消息解析。
            NSLog(@"========= json 有错误");
        }
    } else {
        // 第二层开始解析。
    }


    [self.tableView reloadData];
    //[self.tableView scrollToBottomAnimated:YES];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];


}

- (void)processMsgEntry:(NSDictionary *)dict {
    NSString *emit = [dict objectForKey:kKey_emit];
    if (emit == nil) {
        // 有错误错误。
        NSLog(@"==========emit == nil, json 有错误");
    } else {
        id dataDict = [dict objectForKey:kKey_data];
        if ([emit isEqualToString:kValueEmit_off_single]) {
            [self processOffSinleMsg:dataDict];
        } else if ([emit isEqualToString:kValueEmit_pay_method]) {
            [self processPayMethodMsg:dataDict];
        } else if ([emit isEqualToString:kValueEmit_receive]) {
            [self processReceivedMsg:dataDict];
        } else if ([emit isEqualToString:kValueEmit_chat]) {
            [self processChatMsg:dataDict];
        }
    }
}

- (void)processOffSinleMsg:(NSArray *)dict {
    NSLog(@"==========processOffSinleMsg 开始");
    int count = [dict count];
    for (int i = 0; i < count; i++) {
        NSDictionary *dataDict = [[dict[i] objectForKey:kKey_data] objectForKey:kKey_data];
        if (dataDict != nil) {
            [self processChatMsg:dataDict];
        }
    }
    //NSDictionary *dataDict = [dict objectForKey:kKey_data];

    NSLog(@"==========processOffSinleMsg end");
}

- (void)processPayMethodMsg:(NSDictionary *)dict {
    NSLog(@"==========processPayMethodMsg 开始");
}

- (void)processReceivedMsg:(NSDictionary *)dict {
    NSLog(@"==========processReceivedMsg 开始");
}

- (void)processChatMsg:(NSDictionary *)dict {
    NSLog(@"==========processChatMsg 开始");
    NSString *fromId = [dict objectForKey:kKey_formId];
    NSString *avatar = [dict objectForKey:kKey_avatar];
    NSNumber *msgType = [dict objectForKey:kKey_msgType];
    NSString *nickName = [dict objectForKey:kKey_nickname];
    NSNumber *sendTime = [dict objectForKey:kKey_sendTime];
    id msgID = [dict objectForKey:kKey_msgId]; // 这个服务器怎么发过来是 number，要统一转换为NSString
    // 解析msgBody的时候，要根据 msgType来进行解析， 不同的类型装进去的数据结构不一样。
    NSDictionary *msgBodyDict = [dict objectForKey:kKey_body];
    NSString *strBody = [self convertToJsonData:msgBodyDict];

    NSLog(@"==========processChatMsg end");
    //BOOL test = [msgID isKindOfClass:[NSString class]];
    BOOL test1 = [msgID isKindOfClass:[NSNumber class]];
    NSString *strMsgID = nil;
    if (test1) {
        strMsgID = [msgID stringValue];
    } else {
        strMsgID = msgID;
    }

    NSString *strMessageText = [NSString new];
    if ([msgType longValue] == TEXT) {
        NSLog(@"==========msgBody 为 text 类型");
        strMessageText = [msgBodyDict objectForKey:kKey_message];
    } else if ([msgType longValue] >= ALIPAY && [msgType longValue] <= PAYOK) {
        NSLog(@"==========msgBody 为 支付 类型");
    } else if ([msgType longValue] == IMAGE) {
        NSLog(@"==========msgBody 为 图片 类型");
        strMessageText = [msgBodyDict objectForKey:kKey_message];
    }

    // 构造要显示的消息。


    YHChatModel *chatModel = [YHChatHelper creatRecvMessage:strMessageText
                                                    msgType:[msgType longValue]
                                                    msgBody:strBody
                                                    agentID:fromId
                                                agentAvater:avatar
                                                  agentName:nickName
                                                      msgID:strMsgID
                                                    msgTime:sendTime];

    [self.dataArray addObject:chatModel];

    // 历史消息存在数据库里面。
    [[SqliteManager sharedInstance] createOneChat:chatModel.agentId chatModel:chatModel complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"createOneChat sucess:%@", obj);
        } else {
            DDLog(@"createOneChat fail 数据库:%@", obj);
        }
    }];

    YHChatListModel *listModel = [YHChatHelper creatChatListMessage:strMessageText
                                                            msgType:[msgType longValue]
                                                            msgBody:strBody
                                                            agentID:fromId
                                                        agentAvater:avatar
                                                          agentName:nickName
                                                              msgID:strMsgID
                                                            msgTime:sendTime];


    [[SqliteManager sharedInstance] createOneChatList:KChatList chaListtModel:listModel complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"createOneChatList sucess:%@", obj);
        } else {
            DDLog(@"createOneChatList 到数据库失败:%@", obj);
        }
    }];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0, jsonString.length};

    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0, mutStr.length};

    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}

@end
