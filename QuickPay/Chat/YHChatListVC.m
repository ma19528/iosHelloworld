//
//  YHChatListVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatListVC.h"
#import "YHRefreshTableView.h"
#import "YHChatDetailVC.h"
#import "CellChatList.h"
#import "UIImage+Extension.h"
#import "TestData.h"
#import "QuickPayNetConstants.h"
#import "YHChatManager.h"

@interface YHChatListVC ()<UITableViewDelegate,UITableViewDataSource,CellChatListDelegate>
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation YHChatListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"信息";
    self.navigationController.navigationBar.translucent = NO;

//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"chat_pay_bg"]
//                                                       forBarMetrics:UIBarMetricsDefault];

    [self initUI];

    //模拟数据源
    [self.dataArray addObjectsFromArray:[TestData randomGenerateChatListModel:40]];

    if (self.dataArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }


//    //1 获得json文件的全路径
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"response_pay_mehtod.json" ofType:nil];
//
//    //2 加载json文件到data中
//        NSData *data = [NSData dataWithContentsOfFile:path];
//
//    //3 解析json数据
//    //json数据中的[] 对应OC中的NSArray
//    //json数据中的{} 对应OC中的NSDictionary
//
//    NSArray *jsonArray =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
// 这个是 解析 支付类型的 例子
//    NSString *jsonStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response_offSingle" ofType:@"json"] encoding:0 error:nil];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketdidReceiveMessageNote object:jsonStr];

//    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//    //handleJsonProcess();
//    NSLog(@"%lu", [jsonDic count]);
//    NSEnumerator *enumeratorKey = [jsonDic keyEnumerator];
////    for (NSObject *object in enumeratorKey) {
////        NSLog(@"==========key:%@", object);
////    }
//    NSNumber *resultCode = [jsonDic objectForKey:kKey_code];
//    NSString *resultMsg  = [jsonDic objectForKey:kKey_message];
//    NSDictionary *result = [jsonDic objectForKey:kKey_result];
//    NSString *msgID  = [jsonDic objectForKey:kKey_id];
//
//
//    if(resultCode != nil && resultMsg != nil ) {
//        // 从最外层开始解析。
//        if ([resultCode longValue] == kValueSucessCode && [resultMsg isEqualToString:kValueSucessMsg]) {
//            // 正确的消息解析。
//            NSLog(@"==========key:%@", resultCode);
//            NSString *emit = [result objectForKey:kKey_emit];
//
//        } else {
//            // 错误消息解析。
//        }
//    } else {
//        // 第二层开始解析。
//    }
//
////
////    for(NSString * akey in jsonDic) {
////        //........
////        NSLog(@"==========key:%@", akey);
////        BOOL result = [akey isEqualToString:kKey_code];
////        if(result) {
////            NSNumber *number = [jsonDic objectForKey:kKey_code];
////        }
////    }
////    NSLog(@"%@",jsonDic );

}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}


- (void)initUI{
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH
                                                                          , SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(244, 244, 244);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CellChatList class] forCellReuseIdentifier:NSStringFromClass([CellChatList class])];
}

#pragma mark - @protocol CellChatListDelegate
//3DTouch
- (void)touchOnCell:(CellChatList *)cell{
    [YHChatTouch registerForPreviewInVC:self sourceView:cell model:cell.model];
}

- (void)onAvatarInCell:(CellChatList *)cell {
    YHChatDetailVC *vc = [[YHChatDetailVC alloc] init];
    vc.model = cell.model;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CellChatList *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatList class])];
    if (indexPath.row < self.dataArray.count) {
        cell.model         = self.dataArray[indexPath.row];
        cell.touchDelegate = self;
    }
    return cell;
}

//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    
    //删除数据，和删除动画
    //[self.myDataArr removeObjectAtIndex:deleteRow];
    //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YHChatDetailVC *vc = [[YHChatDetailVC alloc] init];
    vc.model = self.dataArray[indexPath.row];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
