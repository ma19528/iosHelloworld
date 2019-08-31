//
//  YHChatHelper.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatHelper.h"
#import "YHChatModel.h"
#import "YHChatHeader.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHExpressionHelper.h"
#import "NSDate+Extension.h"
#import "YHChatTextLayout.h"
#import "CellChatAlipayLeft.h"

@interface YHChatHelper()

@property (nonatomic,strong) NSMutableDictionary *heightDict;

@end

@implementation YHChatHelper

- (instancetype)init{
    if (self = [super init]) {
        self.heightDict = [NSMutableDictionary new];
    }
    return  self;
}

#pragma mark - Public
// TODO... 在这里面构造发送的消息。
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID {
    YHChatModel *model  = [YHChatModel new];
    model.speakerId     = MYUID;
    model.speakerAvatar = MYAVTARURL;
    model.speakerName   = @"samuelandkevin";
    model.direction     = 0;
    model.msgType       = msgType;
    model.audienceId = toID;
    model.chatType   = msgType;
    model.chatId        = [NSString stringWithFormat:@"%ld",1000 + random()%1000];//本地消息记录ID是手动设置，等消息发送成功后将此替换。
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];

    UIColor *textColor = [UIColor blackColor];
    UIColor *matchTextColor = UIColorHex(527ead);
    UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
    if (model.direction == 0) {
        textColor = [UIColor whiteColor];
        matchTextColor = [UIColor greenColor];
        matchTextHighlightBGColor = [UIColor grayColor];
    }
    model.msgContent = msg;
    YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
    [layout layoutWithText:msg fontSize:addFontSize+14 textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
    model.layout = layout;
    NSDate *date = [[NSDate alloc] init ];
    model.createTime  = [date getNowDate];
    return model;
}

+ (YHChatModel *)creatRecvMessage:(NSString *)msg msgType:(YHMessageType)msgType
                          agentID:(NSString *)agentID
                          agentAvater:(NSString *)agentAvater
                          agentName:(NSString *)agentName
                          msgID:(NSString *)msgID
        msgTime:(NSString *)msgTime
{
    YHChatModel *model  = [YHChatModel new];
    model.direction     = 1;
    model.msgType       = msgType;
    model.chatType      = msgType;

    model.speakerId     = agentID; //MYUID
    // TODO...现在写死做测试放开
    agentAvater = @"https://static.oschina.net/uploads/space/2015/0629/170157_rxDh_1767531.png";

    model.speakerAvatar = [NSURL URLWithString:agentAvater]; //  MYAVTARURL;
    model.speakerName   = agentName;   //@"samuelandkevin";  // 这个是 显示用的。


    model.audienceId = MYUID;
    model.audienceAvatar = MYAVTARURL;
    model.audienceName =@"samuelandkevin";

    model.agentId = agentID;
    model.agentAvatar = [NSURL URLWithString:agentAvater]; ;
    model.agentName = agentName;


    model.chatId        = msgID;//本地消息记录ID是手动设置，等消息发送成功后将此替换。
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];

    UIColor *textColor = [UIColor blackColor];
    UIColor *matchTextColor = UIColorHex(527ead);
    UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
    if (model.direction == 0) {
        textColor = [UIColor whiteColor];
        matchTextColor = [UIColor greenColor];
        matchTextHighlightBGColor = [UIColor grayColor];
    }
    model.msgContent = msg;
    YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
    [layout layoutWithText:msg fontSize:addFontSize+14 textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
    model.layout = layout;

//    NSDate *datenow =[NSDate date];//现在时间,你可以输出来看下是什么格式
//
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//
//    NSInteger interval = [zone secondsFromGMTForDate:datenow];
//
//    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
//
//    NSString *timeSp = [NSString stringWithFormat:@"%d", (long)[localeDate timeIntervalSince1970]];


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH时mm分ss秒"];
    NSTimeInterval time =  [msgTime doubleValue]/1000;
    NSString *strData = [NSString stringWithFormat:@"%@",
            [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]]];


    NSDate *date = [[NSDate alloc] init ];
    NSString *dat = [date getNowDate];
    model.createTime  = strData;//  [date getNowDate];
    return model;
}

// current message time
+ (int)currentMsgTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    int iTime     = (int)(time * 1000);
    return iTime;
}

- (void)registerCellClassWithTableView:(__weak UITableView *)tableView{
   
    [tableView registerClass:[CellChatTextLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatTextLeft class])];
    [tableView registerClass:[CellChatTextRight class] forCellReuseIdentifier:NSStringFromClass([CellChatTextRight class])];
    [tableView registerClass:[CellChatImageLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatImageLeft class])];
    [tableView registerClass:[CellChatImageRight class] forCellReuseIdentifier:NSStringFromClass([CellChatImageRight class])];
    [tableView registerClass:[CellChatVoiceLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
    [tableView registerClass:[CellChatVoiceRight class] forCellReuseIdentifier:NSStringFromClass([CellChatVoiceRight class])];
    [tableView registerClass:[CellChatTips class] forCellReuseIdentifier:NSStringFromClass([CellChatTips class])];
    [tableView registerClass:[CellChatFileLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatFileLeft class])];
    [tableView registerClass:[CellChatFileRight class] forCellReuseIdentifier:NSStringFromClass([CellChatFileRight class])];
    [tableView registerClass:[CellChatGIFLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatGIFLeft class])];
    [tableView registerClass:[CellChatGIFRight class] forCellReuseIdentifier:NSStringFromClass([CellChatGIFRight class])];

    [tableView registerClass:[CellChatAlipayLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatAlipayLeft class])];

}


- (UITableViewCell *)test:(__weak YHChatModel *)model tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    
    if(model.status == 1){
        //消息撤回
        CellChatTips *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTips class])];
        cell.model = model;
        return cell;
    }else{
        if (model.msgType == YHMessageType_Image){
            if (model.direction == 0) {

                CellChatImageRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageRight class])];
                [cell setupModel:model];
                return cell;

            }else{
                
                CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                [cell setupModel:model];
                return cell;
            }
            
        }else if (model.msgType == YHMessageType_Voice){
            
            if (model.direction == 0) {
                CellChatVoiceRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceRight class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }else{
                CellChatVoiceLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }
            
        }else{
            if (model.direction == 0) {
                CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                cell.delegate = self;
                cell.indexPath = indexPath;
                [cell setupModel:model];
                return cell;
            }else{
                CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                cell.delegate = self;
                cell.indexPath = indexPath;
                [cell setupModel:model];
                return cell;
            }
        }
        
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)heightWithModel:(__weak YHChatModel *)model tableView:(__weak UITableView *)tableView{
    
    CGFloat height;
    if (model.chatId) {
        height = [_heightDict[model.chatId] floatValue];
        if (height) {
            return height;
        }
    }
    
    if(model.status == 1){
        //消息撤回
        height = [CellChatTips hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            CellChatTips *cell = (CellChatTips *)sourceCell;
            cell.model = model;
        }];
    }else{
        if (model.msgType == YHMessageType_Image) {
            if (model.direction == 0) {
                
                height = [CellChatImageRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageRight *cell = (CellChatImageRight *)sourceCell;
                    [cell setupModel:model];
                }];
            }else{
                
                height = [CellChatImageLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageLeft *cell = (CellChatImageLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
            
        }else if (model.msgType == YHMessageType_Voice){
            if (model.direction == 0) {
                height = [CellChatVoiceRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceRight *cell = (CellChatVoiceRight *)sourceCell;
                    [cell setupModel:model];
                } ];
            }else{
                height = [CellChatVoiceLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceLeft *cell = (CellChatVoiceLeft *)sourceCell;
                    [cell setupModel:model];
                } ];
            }
        } else if (model.msgType == YHMessageType_Doc){
            if (model.direction == 0) {
                height = [CellChatFileRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatFileRight *cell = (CellChatFileRight *)sourceCell;
                    [cell setupModel:model];
                } ];
            }else{
                height = [CellChatFileLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatFileLeft *cell = (CellChatFileLeft *)sourceCell;
                    [cell setupModel:model];
                } ];
            }
            
        }   else if (model.msgType == YHMessageType_ALIPAY){
            if (model.direction == 0) {
                height = [CellChatFileRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatFileRight *cell = (CellChatFileRight *)sourceCell;
                    [cell setupModel:model];
                } ];
            }else{
                height = [CellChatAlipayLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatAlipayLeft *cell = (CellChatAlipayLeft *)sourceCell;
                    [cell setupModel:model];
                } ];
            }

        }

        else if (model.msgType == YHMessageType_GIF){
            
            if (model.direction == 0) {
                height = [CellChatGIFRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatGIFRight *cell = (CellChatGIFRight *)sourceCell;
                    [cell setupModel:model];
                }];
                
            }else{
                height = [CellChatGIFLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatGIFLeft *cell = (CellChatGIFLeft *)sourceCell;
                    [cell setupModel:model];
                }];
                
            }
            
        }else{
            if (model.direction == 0) {
                height = [CellChatTextRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextRight *cell = (CellChatTextRight *)sourceCell;
                    [cell setupModel:model];
                }];
                

            }else{
                height = [CellChatTextLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextLeft *cell = (CellChatTextLeft *)sourceCell;
                    [cell setupModel:model];
                }];
                
            }
        }
        
    }
    
    if (model.chatId) {
        [_heightDict setObject:@(height) forKey:model.chatId];
    }
   
    return height;
}


+ (NSDictionary *)fileTypeDictionary
{
    NSDictionary *dic = @{
                          @"mp3":@1,@"mp4":@2,@"mpe":@2,@"docx":@5,
                          @"amr":@1,@"avi":@2,@"wmv":@2,@"xls":@6,
                          @"wav":@1,@"rmvb":@2,@"mkv":@2,@"xlsx":@6,
                          @"mp3":@1,@"rm":@2,@"vob":@2,@"ppt":@7,
                          @"aac":@1,@"asf":@2,@"html":@3,@"pptx":@7,
                          @"wma":@1,@"divx":@2,@"htm":@3,@"png":@8,
                          @"ogg":@1,@"mpg":@2,@"pdf":@4,@"jpg":@8,
                          @"ape":@1,@"mpeg":@2,@"doc":@5,@"jpeg":@8,
                          @"gif":@8,@"bmp":@8,@"tiff":@8,@"svg":@8
                          };
    return dic;
}

+ (NSNumber *)fileType:(NSString *)type
{
    NSDictionary *dic = [self fileTypeDictionary];
    return [dic objectForKey:type];
}

+ (UIImage *)imageWithFileType:(YHFileType)type
{
    switch (type) {
        case YHFileType_Audio:
            return [UIImage imageNamed:@"yinpin"];
            break;
        case YHFileType_Video:
            return [UIImage imageNamed:@"shipin"];
            break;
        case YHFileType_Html:
            return [UIImage imageNamed:@"html"];
            break;
        case YHFileType_Pdf:
            return  [UIImage imageNamed:@"pdf"];
            break;
        case YHFileType_Doc:
            return  [UIImage imageNamed:@"word"];
            break;
        case YHFileType_Xls:
            return [UIImage imageNamed:@"excerl"];
            break;
        case YHFileType_Ppt:
            return [UIImage imageNamed:@"ppt"];
            break;
        case YHFileType_Img:
            return [UIImage imageNamed:@"zhaopian"];
            break;
        case YHFileType_Txt:
            return [UIImage imageNamed:@"txt"];
            break;
        default:
            return [UIImage imageNamed:@"iconfont-wenjian"];
            break;
    }
}


- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}
@end
