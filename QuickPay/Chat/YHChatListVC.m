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
#import "QuickPayConfigModel.h"
#import "UIImage+Extension.h"
#import "TestData.h"
#import "QuickPayNetConstants.h"
#import "YHChatManager.h"
#import "SqliteManager.h"
//#import "CellChatPayList.h"

@interface YHChatListVC () <UITableViewDelegate, UITableViewDataSource, CellChatListDelegate>
@property(nonatomic, strong) YHRefreshTableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation YHChatListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"信息";
    self.navigationController.navigationBar.translucent = NO;

    // self.navigationController.navigationBar.barTintColor    = kGrayColor;
    [self initUI];

    //模拟数据源
    [self.dataArray addObjectsFromArray:[TestData randomGenerateChatListModel:3]];

}

- (void)viewWillAppear:(BOOL)animated {
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
//                                                  forBarMetrics:UIBarMetricsCompact];
    self.navigationController.navigationBar.barTintColor  = kBlueColor ;
    //self.navigationController.navigationBar.barTintColor = RGBCOLOR(244, 244, 244);
    [super viewWillAppear:animated];
    NSLog(@"执行刷新数据了");
    [self loadData];
}

- (void)loadData {
    // TODO... 暂不清除数据，上线要放开。
    // [self.dataArray removeAllObjects];
    [[SqliteManager sharedInstance] queryChatListTableWithType:DBChatType_ChatList sessionID:KChatList userInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
        if (success) {
            CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
            for (YHChatListModel *model in obj) {
                [self.dataArray addObject:model];
            }
            if (self.dataArray.count) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        } else {
            DDLog(@"查询数据库数据库失败，没获取到数据。:%@", obj);
        }
    }];

    if (self.dataArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}


- (void)initUI {
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(244, 244, 244);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CellChatList class] forCellReuseIdentifier:NSStringFromClass([CellChatList class])];
}

#pragma mark - @protocol CellChatListDelegate

//3DTouch
- (void)touchOnCell:(CellChatList *)cell {
    [YHChatTouch registerForPreviewInVC:self sourceView:cell model:cell.model];
}

- (void)onAvatarInCell:(CellChatList *)cell {
    YHChatDetailVC *vc = [[YHChatDetailVC alloc] init];
    vc.model = cell.model;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CellChatList *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatList class])];
    if (indexPath.row < self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
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
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    YHChatListModel *listModel = [self.dataArray objectAtIndex:indexPath.row];
    //删除数据，和删除动画
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [[SqliteManager sharedInstance] deleteOneChatListWithType:DBChatType_ChatList sessionID:KChatList agentId:listModel.agentId complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@" 删除成功成功:%@ ", obj);
        } else {
            DDLog(@"删除失败。:%@", obj);
        }
    }];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
