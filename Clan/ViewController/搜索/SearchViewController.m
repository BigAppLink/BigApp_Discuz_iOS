//
//  SearchViewController.m
//  Clan
//
//  Created by chivas on 15/7/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SearchViewController.h"
#import "HotPostCell.h"
#import "UISearchBar+Common.h"
#import "SearchView.h"
#import "LoginViewController.h"
@interface SearchViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,SearchViewDelegate>
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *historyTableView;
@property (strong, nonatomic) NSMutableArray *historyArray;
@property (strong, nonatomic) UITableView *searchTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UIView *footView;
@property (strong, nonatomic) SearchView *searchView;
@property (copy, nonatomic) NSString *searchType;
@property (strong, nonatomic) UILabel *cancel;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchType = KSearchPost;
    _historyArray = [[NSMutableArray alloc] initWithContentsOfFile:[self historyWithDocument]];
    [self addSearchView];
    [self addTableView];
}

#pragma mark - 添加搜索结果的VIEW
- (void)addSearchDataView{
    _searchView = [[SearchView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 49)];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
    [self.view bringSubviewToFront:_searchTableView];
}
#pragma mark - searchView
- (void)addSearchView{
    _cancel = [[UILabel alloc]initWithFrame:CGRectMake(self.navigationController.navigationBar.right - 30 - 21, 0, 30, self.navigationController.navigationBar.height)];
    _cancel.top = 20;
    _cancel.font = [UIFont systemFontOfSize:15.0f];
    _cancel.textColor = [UIColor whiteColor];
    _cancel.text = @"取消";
    _cancel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelSearchAction)];
    [_cancel addGestureRecognizer:tap];
    [self.navigationController.view addSubview:_cancel];
    if (!_mySearchBar) {
        _mySearchBar = ({
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchBar.delegate = self;
            [searchBar sizeToFit];
            [searchBar setPlaceholder:@"请输入关键字"];
            [searchBar setTintColor:[UIColor returnColorWithPlist:YZSegMentColor]];
//            searchBar.backgroundImage = [UIImage new];
            [searchBar insertBGColor:[UIColor returnColorWithPlist:YZSegMentColor]];
            searchBar;
        });
        [self.navigationController.view addSubview:_mySearchBar];
        _mySearchBar.left = 0;
        _mySearchBar.width = _cancel.left - 5;
        _mySearchBar.top = 20;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [_mySearchBar becomeFirstResponder];
    });
}
#pragma mark - 退出搜索界面
- (void)cancelSearchAction
{
    [self dismissViewControllerAnimated:NO completion:nil];
    _searchView.delegate = nil;
    _searchTableView.delegate = nil;
    _searchTableView.dataSource = nil;
}

#pragma mark - 创建TableView
- (void)addTableView
{
    if (!_searchTableView) {
        _searchTableView = ({
            UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64)];
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.dataSource = self;
            tableView.backgroundColor = [UIColor whiteColor];
            [self addTAbleViewFooter];
            tableView.tableFooterView = _footView;
            tableView.sectionFooterHeight = 0;
            [self.view addSubview:tableView];
            tableView.tableFooterView.hidden = _historyArray.count == 0;
            tableView;
        });
    }
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _historyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 33)];
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 0, kSCREEN_WIDTH-30, 33)];
    nameLabel.font = [UIFont systemFontOfSize:12.0f];
    nameLabel.textColor = UIColorFromRGB(0xa6a6a6);
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.text = @"历史搜索";
    [view addSubview:nameLabel];
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, view.bottom-0.5, ScreenWidth, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [view addSubview:line];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if ([_historyArray count]>0) {
    UIImageView *accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"lishixinxi")];
    accessoryView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accessoryAction:)];
    [accessoryView addGestureRecognizer:tap];
    cell.accessoryView = accessoryView;
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 0, ScreenWidth-50, cell.contentView.height)];
    textLabel.font = [UIFont systemFontOfSize:15.0f];
    textLabel.textColor = UIColorFromRGB(0x424242);
    textLabel.text = _historyArray[indexPath.row];
    [cell.contentView addSubview:textLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row != _historyArray.count - 1) {
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(textLabel.left, cell.contentView.bottom - 0.5, ScreenWidth, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xE6E6E6);
        [cell.contentView addSubview:line];
    }
    }
    return cell;
}

- (void)accessoryAction:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    UITableViewCell *cell = (UITableViewCell *)[[imageView superview] superview];
    NSInteger row = [_searchTableView indexPathForCell:cell].row;
    _mySearchBar.text = _historyArray[row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _mySearchBar.text = _historyArray[indexPath.row];
    _searchType = KSearchPost;
    [self searchBarSearchButtonClicked:_mySearchBar];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_mySearchBar isFirstResponder]) {
        [_mySearchBar resignFirstResponder];
    }
}

#pragma mark - tableViewFooter
- (void)addTAbleViewFooter
{
    _footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 56)];
    UIView *subview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, _footView.height)];
    subview.center = _footView.center;
    [_footView addSubview:subview];
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, _footView.top+0.5, ScreenWidth, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [_footView addSubview:line];
    UIImageView *clearImageView = [[UIImageView alloc]initWithImage:kIMG(@"shanchu")];
    clearImageView.top = subview.height/2 - 8;
    [subview addSubview:clearImageView];
    UILabel *clearLabel = [[UILabel alloc]initWithFrame:CGRectMake(clearImageView.right + 5, 0, subview.width - clearImageView.width - 5, subview.height)];
    clearLabel.font = [UIFont systemFontOfSize:16.0f];
    clearLabel.textAlignment = NSTextAlignmentCenter;
    clearLabel.text = @"清空历史记录";
    [subview addSubview:clearLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearhistory)];
    [_footView addGestureRecognizer:tap];
}

#pragma mark - 清空历史记录
- (void)clearhistory
{
    [_historyArray removeAllObjects];
    [_historyArray writeToFile:[self historyWithDocument] atomically:YES];
    _searchTableView.tableFooterView.hidden = YES;
    [_searchTableView reloadData];
}

#pragma mark - 查看沙盒plist历史记录文件
- (NSString *)historyWithDocument
{
    NSString *sandboxPath = NSHomeDirectory();
    NSString *documentPath = [sandboxPath stringByAppendingPathComponent:@"Documents"];
    NSString *fileName=[documentPath stringByAppendingPathComponent:@"searchhistory.plist"];
    return fileName;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - searchDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self clanSearchEnable];
    NSDictionary *dic = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanSearchSetWithForum];
    if (dic) {
        if (!dic[@"status"]) {
            //说明只有用户搜索功能，没有帖子收藏
            if (![UserModel currentUserInfo].logined) {
                //没有登录 跳出登录页面
                LoginViewController *login = [[LoginViewController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
                return;
            }else{
                //登录的情况下 把默认跳转定位到用户
                _searchType = KSearchUser;
            }
        }
    }
    [_mySearchBar resignFirstResponder];
    NSMutableArray *temp;
    if (!_historyArray) {
        _historyArray = [NSMutableArray array];
    }else{
        temp = [[NSMutableArray alloc] initWithContentsOfFile:[self historyWithDocument]];
    }
    if([_historyArray count]>10)
    {
        [temp removeLastObject];
    }
    if (_historyArray.count > 0) {
        _historyArray = (NSMutableArray *)[[temp reverseObjectEnumerator] allObjects];
        BOOL isExist = NO;
        for (NSString *name in _historyArray) {
            if ([name isEqualToString:searchBar.text]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [_historyArray addObject:searchBar.text];
            _historyArray = (NSMutableArray *)[[_historyArray reverseObjectEnumerator] allObjects];
            [_historyArray writeToFile:[self historyWithDocument] atomically:YES];
        }else{
            _historyArray = (NSMutableArray *)[[_historyArray reverseObjectEnumerator] allObjects];
        }
    }else{
        [_historyArray addObject:searchBar.text];
        [_historyArray writeToFile:[self historyWithDocument] atomically:YES];
    }
    _searchTableView.tableFooterView.hidden = NO;
    if (!_searchView) {
        [self addSearchDataView];
        [self.view bringSubviewToFront:_searchView];
    }
    [_searchView searchWithString:searchBar.text andType:_searchType isFirst:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchBar.text isEqualToString:@""]) {
        [_searchView removeFromSuperview];
        _searchView = nil;
        _searchType = KSearchPost;
        [_searchTableView reloadData];
    }
}

#pragma mark - searchView delegate
- (void)selectType:(NSString *)type{
    _searchType = type;
}
#pragma mark - searchEnable
- (void)clanSearchEnable{
    NSDictionary *searchDic = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanSearchSetting];
    if (searchDic) {
        if (![searchDic[@"enable"] isEqualToString:@"1"]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已关闭搜索功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
}
@end
