//
//  SearchFriendsController.m
//  Clan
//
//  Created by 昔米 on 15/7/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SearchFriendsController.h"
#import "FriendsViewModel.h"
#import "FriendsCell.h"
#import "UserInfoModel.h"
#import "MeViewController.h"
#import "SearchViewModel.h"
#import "YZButton.h"
#import "FriendVerifyViewController.h"

@interface SearchFriendsController ()<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSIndexPath *_tobeReloadPath;
    NSString *_keyWord;
    BOOL _isSearch;
}
@property (strong, nonatomic) NSMutableArray *searchResultsArr;
@property (strong, nonatomic) NSMutableArray *applyArr;
@property (strong, nonatomic) NSMutableArray *fiendsArr;
@property (strong, nonatomic) FriendsViewModel *friendsViewModel;
@property (strong, nonatomic) SearchViewModel *searchViewModel;
@property (assign, nonatomic) int currentpage;
@end

@implementation SearchFriendsController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applySuccess:) name:@"Apply_Success" object:nil];
    [self loadModel];
    [self buildUI];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.tableview.delegate = nil;
    self.tableview.dataSource = nil;
    self.searchBar.delegate = nil;
    _friendsViewModel = nil;
    _searchViewModel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.searchDisplayController.delegate = nil;
    DLog(@"SearchFriendsController dealloc");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_tobeReloadPath) {
        if (_isSearch) {
            [self.searchDisplayController.searchResultsTableView reloadData];
            _tobeReloadPath = nil;
        } else {
            [self.tableview deselectRowAtIndexPath:_tobeReloadPath animated:YES];
            _tobeReloadPath = nil;
        }
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_searchType == FriendsSearchTypeMyFriends) {
        [self.searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#pragma mark - 初始化
- (void)loadModel
{
    if (!_friendsList) {
        _friendsList = [NSMutableArray new];
    }
    if (!_searchResultsArr) {
        _searchResultsArr = [NSMutableArray new];
    }
    _applyArr = [NSMutableArray new];
    _friendsViewModel = [FriendsViewModel new];
    _fiendsArr = [NSMutableArray new];
    if (_searchType == FriendsSearchTypeSearchFriends) {
        _searchViewModel = [SearchViewModel new];
    }
}

- (void)buildUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    // 1.创建一个UISearchBar,添加在tableView上面
    UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0, kSCREEN_WIDTH, 45)];
    if (_searchType == FriendsSearchTypeMyFriends) {
        searchBar.placeholder=@"查找好友";
    } else if (_searchType == FriendsSearchTypeSearchFriends){
        searchBar.placeholder=@"通过用户名添加好友";
    }
    searchBar.delegate = self;
    [searchBar setImage:kIMG(@"sousuo_gray") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBar.barTintColor = UIColorFromRGB(0xf3f3f3);//搜索条颜色
    searchBar.backgroundImage = [Util imageWithColor:UIColorFromRGB(0xf3f3f3)];
//    searchBar.backgroundImage = [Util imageWithColor:[UIColor redColor]];
    self.searchBar = searchBar;
//    [self.view addSubview:searchBar];
    // 2.用创立的searchBar和UIViewController的view初始化出UISearchDisplayController
    _displayVC = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    
    // 3.设置代理
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
    [self.tableview registerNib:nib forCellReuseIdentifier:@"FriendsCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"FriendsCell" ];
    [Util setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_searchType == FriendsSearchTypeSearchFriends) {
        [self requestRecommandFriends];
    }
}

- (void)addTableFooter
{
    if (!self.searchDisplayController.searchResultsTableView.footer) {
        [self.searchDisplayController.searchResultsTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(searchUser)];
    }
}

#pragma mark - 
- (void)applySuccess:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"Apply_Success"]) {
        NSString *uid = noti.object;
        if (uid && uid.length > 0) {
            [_applyArr addObject:uid];
            [self resetUI];
        }
    }
}

- (void)resetUI
{
    if (_isSearch) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableview reloadData];
    }
}

#pragma mark - request data
//推荐好友
- (void)requestRecommandFriends
{
    WEAKSELF
    [_friendsViewModel requests_FindFriednWithReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        [strongSelf.tableview endHeaderRefreshing];
        if (success) {
            strongSelf.friendsList = data;
            [strongSelf.tableview reloadData];
        }
    }];
}

- (void)searchUser
{
    WEAKSELF
    [_searchViewModel requestSearchWithType:KSearchUser andkeyWord:_keyWord andPage:[NSString stringWithFormat:@"%d",_currentpage+1] andBlock:^(NSArray *searchArray, BOOL isMore) {
        STRONGSELF
        if (searchArray && searchArray.count > 0) {
            strongSelf.searchResultsArr = [NSMutableArray arrayWithArray:searchArray];
            [strongSelf.searchDisplayController.searchResultsTableView reloadData];
        }
        strongSelf.currentpage = !searchArray ?  strongSelf.currentpage : strongSelf.currentpage+1;
        if (isMore) {
            [strongSelf addTableFooter];
        }
        [strongSelf.searchDisplayController.searchResultsTableView.footer endRefreshing];
    }];
}

//检查好友
- (void)checkUser:(NSString *)uid agree:(BOOL)agree withUser:(UserInfoModel *)user
{
    [self showProgressHUDWithStatus:@"" withLock:YES];
    ;
    WEAKSELF
    [_friendsViewModel checkFriend:uid isAgreePage:NO withchecktype:@"1" WithReturnBlock:^(BOOL success, id data) {
        STRONGSELF
        [strongSelf dissmissProgress];
        if (success) {
            NSString *suc = (NSString *)data;
            if (suc && suc.intValue ==2) {
                //同意好友
                [strongSelf request_dealFriendApplys:uid agree:YES];
            } else {
                [strongSelf request_dealFriendApply:user agree:agree];
            }
        } else {
            [strongSelf dissmissProgress];
        }
    }];
    
}

//处理好友申请
- (void)request_dealFriendApplys:(NSString *)uid agree:(BOOL)agree
{
    WEAKSELF
    [_friendsViewModel request_dealFriendApply:uid agree:agree withBlock:^(BOOL success) {
        STRONGSELF
        [strongSelf hideProgressHUD];
        if (success) {
            if (agree) {
                //成为好友
                [strongSelf.fiendsArr addObject:uid];
                [strongSelf showHudTipStr:@"已添加好友成功"];
                [strongSelf resetUI];
            }
        }
    }];
}

//处理好友申请
- (void)request_dealFriendApply:(UserInfoModel *)user agree:(BOOL)agree
{
    //跳到好友申请界面
    FriendVerifyViewController *verify = [[FriendVerifyViewController alloc]init];
    verify.uid = user.uid;
    verify.username = user.username;
    [self.navigationController pushViewController:verify animated:YES];
}

#pragma mark - tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableView!=_tableview ? _searchResultsArr.count : _friendsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"FriendsCell";
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    UserInfoModel *friend = nil;
    if (tableView!=_tableview) {
        friend = _searchResultsArr[indexPath.row];
    } else {
        friend = _friendsList[indexPath.row];
    }
    [cell.iv_avatar sd_setImageWithURL:[NSURL URLWithString:friend.avatar] placeholderImage:kIMG(@"portrait")];
    cell.lbl_name.text = friend.username;
    cell.lbl_grouptitle.text = friend.groupname;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    if (_searchType == FriendsSearchTypeSearchFriends) {
        YZButton *addFbtn = (YZButton *)[cell.contentView viewWithTag:1122];
        if (!addFbtn) {
            addFbtn = [YZButton buttonWithType:UIButtonTypeCustom];
            addFbtn.layer.cornerRadius = 3;
            addFbtn.clipsToBounds = YES;
            [addFbtn.titleLabel setFont:[UIFont fontWithSize:12.f]];
            addFbtn.tag = 1122;
            addFbtn.frame = CGRectMake(kSCREEN_WIDTH-15-55, 20, 55, 25);
            [cell.contentView addSubview:addFbtn];
        }
        addFbtn.path = indexPath;
      if ([_applyArr containsObject:friend.uid]) {
            [Util setButton:addFbtn withCellButtonType:CellButtonTypeApplyed];
      }
        
      else if ([_fiendsArr containsObject:friend.uid] || (friend.isfriend && friend.isfriend.intValue == 1)) {
          [Util setButton:addFbtn withCellButtonType:CellButtonTypeAdded];
      }
      else {
          [Util setButton:addFbtn withCellButtonType:CellButtonTypeAdd];
          if (tableView!=_tableview) {
              [addFbtn addTarget:self action:@selector(dealWithUserApply:) forControlEvents:UIControlEventTouchUpInside];
          } else {
              [addFbtn addTarget:self action:@selector(dealWithUserApplyForRecommends:) forControlEvents:UIControlEventTouchUpInside];
          }
      }
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
    UserInfoModel *friend = nil;
    if (tableView != _tableview) {
        _isSearch = YES;
        friend = _searchResultsArr[indexPath.row];
    } else {
        _isSearch = NO;
        friend = _friendsList[indexPath.row];
    }
    MeViewController *main = [[MeViewController alloc]init];
    UserModel *model = [UserModel new];
    [model setValueWithObject:friend];
    main.user = model;
    main.isSelf = NO;
    [self.navigationController pushViewController:main animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == _tableview &&  section == 0)
    {
        return 30.f;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableview &&  section == 0) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
            view.backgroundColor = kCOLOR_BG_GRAY;
            UIView *whitebg = [UIView new];
            whitebg.backgroundColor = [UIColor whiteColor];
            [view addSubview:whitebg];
            [whitebg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(view.mas_leading);
                make.trailing.equalTo(view.mas_trailing);
                make.top.equalTo(view.mas_top).offset(0);
                make.bottom.equalTo(view.mas_bottom);
            }];
            UILabel *label = [UILabel new];
            label.font = [UIFont fontWithSize:12.f];
            label.textColor = K_COLOR_DARK_Cell;
            label.text = @"可能认识的朋友";
            [view addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(view.mas_leading).offset(15);
                make.trailing.equalTo(view.mas_trailing).offset(-10);
                make.centerY.equalTo(view.mas_centerY);
                make.height.equalTo(@30);
            }];
            UIView *line = [UIView new];
            line.backgroundColor = K_COLOR_MOST_LIGHT_GRAY;
            [view addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(view.mas_leading);
                make.trailing.equalTo(view.mas_trailing);
                make.bottom.equalTo(view.mas_bottom).offset(0);
                make.height.equalTo(@(0.5));
            }];
            return view;
    }
    return nil;
}

#pragma mark -
//现在来实现当搜索文本改变时的回调函数。这个方法使用谓词进行比较，并讲匹配结果赋给searchResults数组:
- (void)filterContentForSearchText:(NSString*)keyword
{
    if (isNull(keyword)) {
        [self showHudTipStr:@"请输入关键字"];
        return;
    }
    _keyWord = keyword;
    if (_searchType == FriendsSearchTypeSearchFriends) {
        [self searchUser];
        return;
    }
    NSMutableArray *arr = [NSMutableArray new];
    for (UserInfoModel *user in _friendsList) {
        if ([user.username rangeOfString:keyword].location != NSNotFound) {
            [arr addObject:user];
        }
    }
    self.searchResultsArr = arr;
    [self.searchDisplayController.searchResultsTableView reloadData];
//    [self.tableview reloadData];
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
    
//    self.searchResultsArr = [self. filteredArrayUsingPredicate:resultPredicate];
    
}

//接下来是UISearchDisplayController的委托方法，负责响应搜索事件：
#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
}

- (IBAction)dealWithUserApply:(id)sender
{
    _isSearch = YES;
    YZButton *btn = (YZButton *)sender;
    UserInfoModel *user = _searchResultsArr[btn.path.row];
    [self checkUser:user.uid agree:btn.agree withUser:user];
}

- (IBAction)dealWithUserApplyForRecommends:(id)sender
{
    _isSearch = NO;
    YZButton *btn = (YZButton *)sender;
    UserInfoModel *user = _friendsList[btn.path.row];
    [self checkUser:user.uid agree:btn.agree withUser:user];
}
@end
