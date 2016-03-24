//
//  FriendsViewController.m
//  Clan
//
//  Created by 昔米 on 15/7/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "FriendsViewController.h"
#import "SearchBar.h"
#import "MLBlackTransition.h"
#import "DialogListCell.h"
#import "FriendsViewModel.h"
#import "UserInfoModel.h"
#import "FriendsCell.h"
#import "MeViewController.h"
#import "SearchFriendsController.h"
#import "NewFriendsController.h"

@interface FriendsViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
{
    NSIndexPath *_tobeReloadPath;
}
@property (strong, nonatomic) NSMutableArray *friendsList;
@property (strong, nonatomic) NSMutableArray *searchResultsArr;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *displayVC;
@property (strong, nonatomic) BaseTableView *tableview;

@property (strong, nonatomic) FriendsViewModel *friendsViewModel;
@property (strong, nonatomic) UIButton *newsFriendsBTN;



@property (nonatomic) BOOL searching;
@end

@implementation FriendsViewController

#pragma mark - 生命周期方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModal];
    [self buildUI];
    [self requestFriendsList];
    if (!_uid) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"KNEWS_FRIEND_MESSAGE" object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_tobeReloadPath) {
        [self.tableview deselectRowAtIndexPath:_tobeReloadPath animated:YES];
        _tobeReloadPath = nil;
    }
    [self requestFriendsList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self checkNewFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableview.delegate = nil;
    _tableview.dataSource = nil;
    _friendsViewModel = nil;
    _searchBar.delegate = nil;
    DlogMethod;
}

#pragma mark - 初始化数据源
- (void)loadModal
{
    self.friendsList = [NSMutableArray new];
    self.searchResultsArr = [NSMutableArray new];
    _friendsViewModel = [FriendsViewModel new];
}

#pragma mark - UI创建
- (void)buildUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildNewMessageView];
    if (!_uid) {
        self.title = @"我的好友";
    } else {
        self.title = @"TA的好友";
    }
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor clearColor];
    rightButton.frame = CGRectMake(0, 0, 24, 21);
    [rightButton setBackgroundImage :[UIImage imageNamed:@"tianjiapengyou"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(gotoFriendSearch) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0.0, 0.0, kSCREEN_WIDTH, 45)];
    searchBar.placeholder=@"查找好友";
    [searchBar setImage:kIMG(@"sousuo_gray") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBar.barTintColor = UIColorFromRGB(0xf3f3f3);//搜索条颜色
    searchBar.backgroundImage = [Util imageWithColor:UIColorFromRGB(0xf3f3f3)];
    searchBar.delegate = self;
    searchBar.showsCancelButton = NO;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchBar = searchBar;
    
    _displayVC = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    _displayVC.searchResultsDelegate = self;
    _displayVC.searchResultsDataSource = self;
    _displayVC.delegate = self;
    
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.dataSource = self;
    table.tableHeaderView = searchBar;
    self.tableview = table;
    [self.view addSubview:table];
    [Util setExtraCellLineHidden:_tableview];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FriendsCell class]) bundle:nil];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"FriendsCell" ];
    [Util setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableview registerNib:nib forCellReuseIdentifier:@"FriendsCell"];
    WEAKSELF
    [self.tableview createHeaderViewBlock:^{
        STRONGSELF
        [strongSelf requestFriendsList];
        [strongSelf checkNewFriends];
    }];
}

- (void)buildNewMessageView
{
    _newsFriendsBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [_newsFriendsBTN.titleLabel setFont:[UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE]];
    [_newsFriendsBTN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_newsFriendsBTN setBackgroundImage:[Util imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [_newsFriendsBTN setBackgroundColor:[UIColor redColor]];
    _newsFriendsBTN.enabled = NO;
    _newsFriendsBTN.layer.cornerRadius = 10;
    _newsFriendsBTN.clipsToBounds = YES;
    _newsFriendsBTN.bounds = CGRectMake(0, 0, 20, 20);
}

#pragma mark - GOTO
- (void)gotoFriendSearch
{
    SearchFriendsController *search = [[SearchFriendsController alloc]init];
    search.searchType = FriendsSearchTypeSearchFriends;
    search.title = @"添加好友";
    [self.navigationController pushViewController:search animated:YES];
}

#pragma mark - request Datas
//获取好友列表
- (void)requestFriendsList
{
    WEAKSELF
    [_friendsViewModel getFriednsListWithUid:_uid withReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        [strongSelf.tableview endHeaderRefreshing];
        if (success) {
            strongSelf.friendsList = data;
            [strongSelf.tableview reloadData];
        }
    }];
}

- (void)checkNewFriends
{
    if (!_uid) {
        WEAKSELF
        [_friendsViewModel getNewFriendsCountWithReturnBlock:^(NSString *count) {
            STRONGSELF
            [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"KNEWS_FRIEND_MESSAGE"];
            if (count&&[count isEqualToString:@"0"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
            }
            [strongSelf.tableview reloadData];
        }];
    }
}

- (void)doUpdate
{
    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = !_uid ? _friendsList.count+1 : _friendsList.count;
    return tableView!=_tableview ? _searchResultsArr.count : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *identifer = @"FriendsCell";
        FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!_uid && tableView==_tableview && indexPath.row == 0) {
            cell.iv_avatar.image = kIMG(@"xinhaoyou");
            cell.lbl_name.text = @"新的朋友";
            cell.lbl_grouptitle.text = @"";
            NSString *fcount = [[NSUserDefaults standardUserDefaults] objectForKey:@"KNEWS_FRIEND_MESSAGE"];
            if (fcount && fcount.intValue > 0) {
                cell.accessoryView = _newsFriendsBTN;
                [_newsFriendsBTN setTitle:[NSString stringWithFormat:@"%@",fcount] forState:UIControlStateNormal];
            } else {
                [_newsFriendsBTN setTitle:@"0" forState:UIControlStateNormal];
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else {
            UserInfoModel *friend = nil;
            if (tableView == _tableview) {
                NSInteger indexRow = !_uid ? (indexPath.row-1) : indexPath.row;
                friend = _friendsList[indexRow];
            }
            else {
                friend = _searchResultsArr[indexPath.row];
            }
            [cell.iv_avatar sd_setImageWithURL:[NSURL URLWithString:friend.avatar] placeholderImage:kIMG(@"portrait")];
            cell.lbl_name.text = friend.username;
            cell.lbl_grouptitle.text = friend.groupname;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
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
    if (!_uid && tableView==_tableview && indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"KNEWS_FRIEND_MESSAGE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
        NewFriendsController *newsF = [[NewFriendsController alloc]init];
        newsF.title = @"新的朋友";
        [self.navigationController pushViewController:newsF animated:YES];

    } else {
        UserInfoModel *friend = nil;
        if (tableView==_tableview) {
            NSInteger indexRow = !_uid ? (indexPath.row-1) : indexPath.row;
            friend = _friendsList[indexRow];
        } else {
            friend = _searchResultsArr[indexPath.row];
        }
        MeViewController *main = [[MeViewController alloc]init];
        UserModel *model = [UserModel new];
        [model setValueWithObject:friend];
        main.user = model;
        main.isSelf = NO;
        [self.navigationController pushViewController:main animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *keyword = searchBar.text;
    if (isNull(keyword)) {
        [self showHudTipStr:@"请输入关键字"];
        return;
    }
    NSMutableArray *arr = [NSMutableArray new];
    for (UserInfoModel *user in _friendsList) {
        if ([user.username rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [arr addObject:user];
        }
    }
    self.searchResultsArr = arr;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterWithKeyWords:searchString];
    return YES;
}

- (void)filterWithKeyWords:(NSString *)keyword
{
    NSMutableArray *arr = [NSMutableArray new];
    for (UserInfoModel *user in _friendsList) {
        if ([user.username rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [arr addObject:user];
        }
    }
    self.searchResultsArr = arr;
}

#pragma mark - notification
- (void)notificationCome:(NSNotification *)noti
{
  if ([noti.name isEqualToString:@"KNEWS_FRIEND_MESSAGE"]) {
        [self.tableview reloadData];
    }
}

@end
