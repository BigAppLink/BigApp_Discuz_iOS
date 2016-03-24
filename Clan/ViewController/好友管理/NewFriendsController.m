//
//  NewFriendsController.m
//  Clan
//
//  Created by 昔米 on 15/7/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "NewFriendsController.h"
#import "FriendsViewModel.h"
#import "FriendsCell.h"
#import "UserInfoModel.h"
#import "MeViewController.h"
#import "YZButton.h"


@interface NewFriendsController () <UITableViewDataSource, UITableViewDelegate>
{
    NSIndexPath *_tobeReloadPath;
}
@property (strong, nonatomic) BaseTableView *tableview;
@property (strong, nonatomic) NSMutableArray *friendsList;
@property (strong, nonatomic) NSMutableArray *agreeList;
@property (strong, nonatomic) NSMutableArray *refuseList;
@property (strong, nonatomic) NSMutableArray *alreadyFriendsList;

@property (strong, nonatomic) FriendsViewModel *friendsViewModel;
@end

@implementation NewFriendsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModal];
    [self buildUI];
    [self.tableview beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_tobeReloadPath) {
        [self.tableview deselectRowAtIndexPath:_tobeReloadPath animated:YES];
        _tobeReloadPath = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}


#pragma mark - 初始化数据源
- (void)loadModal
{
    self.friendsList = [NSMutableArray new];
    _friendsViewModel = [FriendsViewModel new];
    _agreeList = [NSMutableArray new];
    _refuseList = [NSMutableArray new];
    _alreadyFriendsList = [NSMutableArray new];
}


#pragma mark - UI创建
- (void)buildUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.dataSource = self;
    self.tableview = table;
    [self.view addSubview:table];
    [Util setExtraCellLineHidden:_tableview];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FriendsCell class]) bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"FriendsCell"];
    WEAKSELF
    [self.tableview createHeaderViewBlock:^{
        STRONGSELF
        [strongSelf requestFriendsList];
    }];
}

#pragma mark - request Datas
//获取好友列表
- (void)requestFriendsList
{
    WEAKSELF
    [_friendsViewModel getNewFriendsListWithReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        [strongSelf.tableview endHeaderRefreshing];
        if (success) {
            strongSelf.friendsList = data;
            [strongSelf.tableview reloadData];
        }
        [strongSelf configNoFriendsWithError:success];
    }];
}

//检查好友
- (void)checkUser:(NSString *)uid agree:(BOOL)agree
{
    [self showProgressHUDWithStatus:@"请求中..."];
    WEAKSELF
    [_friendsViewModel checkFriend:uid isAgreePage:YES withchecktype:agree?@"2":@"3" WithReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        if (success) {
            [strongSelf request_dealFriendApply:uid agree:agree];
        }else {
            [strongSelf dissmissProgress];
        }
        
//        if (success) {
//            [strongSelf request_dealFriendApply:uid agree:agree];
//        } else {
//            [strongSelf dissmissProgress];
//        }
    }];
    
}

//处理好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree
{
    WEAKSELF
    [_friendsViewModel request_dealFriendApply:uid agree:agree withBlock:^(BOOL success) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (success) {
            if (agree) {
                //申请成功
                [strongSelf.agreeList addObject:uid];
            } else {
                //拒绝成功
                [strongSelf.refuseList addObject:uid];
            }
            [strongSelf.tableview reloadData];
        }
    }];
}

- (void)configNoFriendsWithError:(BOOL)noError
{
    [self.tableview configBlankPage:DataIsNothingWithDefault hasData:self.friendsList.count > 0 hasError:!noError reloadButtonBlock:^(id sender) {
        
    }];
}

#pragma mark - tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friendsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"FriendsCell";
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        UserInfoModel *friend =  _friendsList[indexPath.row];
        [cell.iv_avatar sd_setImageWithURL:[NSURL URLWithString:friend.avatar] placeholderImage:kIMG(@"portrait")];
        cell.lbl_name.text = friend.username;
        cell.lbl_grouptitle.text = friend.note;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    YZButton *ignorebtn = (YZButton *)[cell.contentView viewWithTag:2233];
    if (!ignorebtn) {
        ignorebtn = [YZButton buttonWithType:UIButtonTypeCustom];
        ignorebtn.layer.cornerRadius = 3;
        ignorebtn.clipsToBounds = YES;
        [ignorebtn.titleLabel setFont:[UIFont fontWithSize:12.f]];
        ignorebtn.tag = 2233;
        ignorebtn.frame = CGRectMake(kSCREEN_WIDTH-15-44, 20, 44, 25);
        [cell.contentView addSubview:ignorebtn];
    }
    
    YZButton *addFbtn = (YZButton *)[cell.contentView viewWithTag:1122];
    if (!addFbtn) {
        addFbtn = [YZButton buttonWithType:UIButtonTypeCustom];
        addFbtn.layer.cornerRadius = 3;
        addFbtn.clipsToBounds = YES;
        [addFbtn.titleLabel setFont:[UIFont fontWithSize:12.f]];
        addFbtn.tag = 1122;
        addFbtn.frame = CGRectMake(kSCREEN_WIDTH-15-44-6-55, 20, 55, 25);
        [cell.contentView addSubview:addFbtn];
    }
    if ([_refuseList containsObject:friend.uid]) {
        addFbtn.hidden = YES;
        [Util setButton:ignorebtn withCellButtonType:CellButtonTypeIgnored];
    }
    else if ([_agreeList containsObject:friend.uid]) {
        addFbtn.hidden = YES;
        [Util setButton:ignorebtn withCellButtonType:CellButtonTypeAdded];
    }
    else {
        ignorebtn.agree = NO;
        ignorebtn.path = indexPath;
        [ignorebtn addTarget:self action:@selector(dealWithUserApply:) forControlEvents:UIControlEventTouchUpInside];
        [Util setButton:ignorebtn withCellButtonType:CellButtonTypeIgnore];
        
        addFbtn.path = indexPath;
        addFbtn.agree = YES;
        [addFbtn addTarget:self action:@selector(dealWithUserApply:) forControlEvents:UIControlEventTouchUpInside];
        [Util setButton:addFbtn withCellButtonType:CellButtonTypeAdd];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tobeReloadPath = indexPath;
    UserInfoModel *friend = _friendsList[indexPath.row];;
    MeViewController *main = [[MeViewController alloc]init];
    UserModel *model = [UserModel new];
    [model setValueWithObject:friend];
    main.user = model;
    main.isSelf = NO;
    [self.navigationController pushViewController:main animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (IBAction)dealWithUserApply:(id)sender
{
    YZButton *btn = (YZButton *)sender;
    UserInfoModel *user = _friendsList[btn.path.row];
    [self checkUser:user.uid agree:btn.agree];
}
@end
