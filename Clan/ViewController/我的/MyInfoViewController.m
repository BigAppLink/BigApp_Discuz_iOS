//
//  MyInfoViewController.m
//  Clan
//
//  Created by chivas on 15/7/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyInfoViewController.h"

@interface MyInfoViewController ()
@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic)BaseTableView *tableView;
@property (strong, nonatomic) NSArray *vcArray;
@property (strong, nonatomic) NSArray *cellImageArray;
@property (strong, nonatomic) NSArray *cellTitleArray;
@end
static const CGFloat viewHeight = 235;
@implementation MyInfoViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [Analysis endLogPageView:@"hotpost"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [Analysis beginLogPageView:@"hotpost"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingWithCell];
    [self initWithTable];
    _headerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -viewHeight, ScreenWidth, viewHeight)];
    _headerView.image = [Util imageWithColor:[UIColor returnColorWithPlist:YZSegMentColor]];
    [_tableView addSubview:_headerView];
}
#pragma mark - 设置cell信息
- (void)settingWithCell{
    _vcArray = @[@"",@"",@"",@"",@""];
}
#pragma mark - 设置tableview
- (void)initWithTable
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _tableView.contentInset = UIEdgeInsetsMake(viewHeight-20, 0, 0, 0);
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.sectionFooterHeight = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
    if (contentOffset.y < viewHeight) {
        _headerView.top = contentOffset.y;
        _headerView.height = -contentOffset.y;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
