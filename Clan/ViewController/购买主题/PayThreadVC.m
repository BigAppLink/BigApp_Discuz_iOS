//
//  PayThreadVC.m
//  Clan
//
//  Created by 昔米 on 15/12/9.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "PayThreadVC.h"
#import "PostDetailVC.h"

@interface PayThreadVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) BaseTableView *table;

@end

@implementation PayThreadVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModel];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"PayThreadVC 销毁了");
}

#pragma mark - 初始化
- (void)loadModel
{
    
}

- (void)buildUI
{
    self.title = @"购买主题";
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.separatorColor = kfsc_table_border;
    self.table = table;
    [self.view addSubview:table];
}

@end
