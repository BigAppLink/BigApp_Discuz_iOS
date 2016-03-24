//
//  SearchView.m
//  Clan
//
//  Created by chivas on 15/7/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SearchView.h"
#import "YZSearchGridView.h"
#import "SearchViewModel.h"
#import "BoardCell.h"
#import "APostCell.h"
#import "UserSearchCell.h"
#import "UserInfoModel.h"
#import "PostDetailViewController.h"
#import "UIView+Additions.h"
#import "PostViewController.h"
#import "MeViewController.h"
#import "UserModel.h"
#import "ForumsModel.h"
#import "PostDetailVC.h"
@interface SearchView()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) BaseTableView *searchTableView;
@property (strong, nonatomic) NSArray *formsArray;
@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) SearchViewModel *searchViewModel;
@property (assign, nonatomic) NSInteger page;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *keyword;
@property (strong, nonatomic) APostCell *tempPostCell;
@property (strong, nonatomic) UIView *headerView;
@property (copy, nonatomic) NSString *tempKeyWord;
@end
@implementation SearchView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        if (!_searchViewModel) {
            _searchViewModel = [SearchViewModel new];
        }
        _page = 1;
        [self addGridView];
        [self addTableView];
    }
    return self;
}

#pragma mark - gridView
- (void)addGridView
{
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    YZSearchGridView *gridView = [[YZSearchGridView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 41)];
    gridView.gridType = @"searchType";
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.target = self;
    [gridView addCardWithTitle:@"搜帖子" withSel:@selector(searchPost)];
    [gridView addCardWithTitle:@"搜版块" withSel:@selector(searchForum)];
    [gridView addCardWithTitle:@"搜用户" withSel:@selector(searchUser)];
    [gridView addCardDone];
    //添加阴影线
    UIImageView *lineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, gridView.bottom, ScreenWidth, 3)];
    lineView.image = kIMG(@"qiehuanxuanxiang");
    [_headerView addSubview:gridView];
    [_headerView addSubview:lineView];
    [self addSubview:_headerView];
}

#pragma mark - addTableView
- (void)addTableView{
    _searchTableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, _headerView.bottom, ScreenWidth, ScreenHeight-64-_headerView.height)];
    _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.tableFooterView = [[UIView alloc]init];
    [self addSubview:_searchTableView];
    //初始化cell
    [self initCell];
}

#pragma mark - 初始化cell
- (void)initCell{
    UINib *boardCell = [UINib nibWithNibName:@"BoardCell" bundle:nil];
    [_searchTableView registerNib:boardCell forCellReuseIdentifier:@"BoardCell"];
    UINib *APostCell = [UINib nibWithNibName:@"APostCell" bundle:nil];
    [_searchTableView registerNib:APostCell forCellReuseIdentifier:@"APostCell"];
    self.tempPostCell = [_searchTableView dequeueReusableCellWithIdentifier:@"APostCell"];
    UINib *userSearchCell = [UINib nibWithNibName:@"UserSearchCell" bundle:nil];
    [_searchTableView registerNib:userSearchCell forCellReuseIdentifier:@"UserSearchCell"];
}
#pragma mark - 点击搜索按钮
- (void)searchPost{
    _searchTableView.footer.hidden = NO;
    _type = KSearchPost;
    if ([self.delegate respondsToSelector:@selector(selectType:)]) {
        [self.delegate selectType:_type];
    }
    //发delegate告诉之前页面 点击的是哪个
    if (!_postArray) {
        _postArray = [NSMutableArray array];
        [self searchWithString:_keyword andType:KSearchPost isFirst:YES];
    }
    [self configBlankPage:DataIsNothingWithSearch hasData:(_postArray.count > 0) hasError:(!_postArray) reloadButtonBlock:^(id sender) {
        [self beginLoading];
        [self requestData:_type andString:_keyword];
    }];

    [_searchTableView reloadData];

    
}
- (void)searchForum{
    _searchTableView.footer.hidden = YES;
    _type = KSearchForum;
    if ([self.delegate respondsToSelector:@selector(selectType:)]) {
        [self.delegate selectType:KSearchForum];
    }
    if (!_formsArray) {
        _formsArray = [NSArray array];
        [self searchWithString:_keyword andType:KSearchForum isFirst:YES];
    }
    [self configBlankPage:DataIsNothingWithSearch hasData:(_formsArray.count > 0) hasError:(!_formsArray) reloadButtonBlock:^(id sender) {
        [self beginLoading];
        [self requestData:_type andString:_keyword];
    }];
    [_searchTableView reloadData];

}
- (void)searchUser{
    _searchTableView.footer.hidden = YES;
    _type = KSearchUser;
    if ([self.delegate respondsToSelector:@selector(selectType:)]) {
        [self.delegate selectType:KSearchUser];
    }
    if (!_userArray) {
        _userArray = [NSArray array];
        [self searchWithString:_keyword andType:KSearchUser isFirst:YES];
    }
    [self configBlankPage:DataIsNothingWithSearch hasData:(_userArray.count > 0) hasError:(!_userArray) reloadButtonBlock:^(id sender) {
        [self beginLoading];
        [self requestData:_type andString:_keyword];
    }];
    [_searchTableView reloadData];

}

#pragma mark - 执行搜索
- (void)searchWithString:(NSString *)string andType:(NSString *)type isFirst:(BOOL)isFirst{
    //判断搜索的时间
    if ([type isEqualToString:KSearchPost] || [type isEqualToString:KSearchForum]) {
        NSDictionary *dic = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanSearchSetWithForum];
        if (dic) {
            if (dic[@"postTime"]) {
                //如果有时间的话 拿发帖时间和当前时间做对比 如果小于searchctrl 则限制搜索
                NSDate *oldDate = dic[@"postTime"];
                long long dtime = [[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] - [oldDate timeIntervalSince1970]] longLongValue];
                if (dtime < [(NSNumber *)dic[@"searchctrl"] floatValue]) {
                    //没到站长设置的搜索间隔
                    [self alertWithWarning:[NSString stringWithFormat:@"两次搜索间隔不能小于%ld秒",(long)[(NSNumber *)dic[@"searchctrl"] integerValue]]];
                    return;
                }else{
                    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [postDic setObject:[NSDate date] forKey:@"postTime"];
                    [UserDefaultsHelper saveDefaultsValue:postDic forKey:kUserDefaultsKey_ClanSearchSetWithForum];
                }
            }else{
                //写入时间
                NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [postDic setObject:[NSDate date] forKey:@"postTime"];
                [UserDefaultsHelper saveDefaultsValue:postDic forKey:kUserDefaultsKey_ClanSearchSetWithForum];
            }
        }
    }else if ([type isEqualToString:KSearchUser]){
        NSDictionary *dic = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanSearchSetWithGroup];
        if (dic) {
            if (dic[@"postTime"]) {
                //如果有时间的话 拿发帖时间和当前时间做对比 如果小于searchctrl 则限制搜索
                NSDate *oldDate = dic[@"postTime"];
                NSLog(@"%f",[[NSDate date]timeIntervalSince1970] - [oldDate timeIntervalSince1970]);
                long long dtime = [[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] - [oldDate timeIntervalSince1970]] longLongValue];
                if (dtime < [(NSNumber *)dic[@"searchctrl"] floatValue]) {
                    //没到站长设置的搜索间隔
                    [self alertWithWarning:[NSString stringWithFormat:@"两次搜索间隔不能小于%ld秒",(long)[(NSNumber *)dic[@"searchctrl"] integerValue]]];
                    return;
                }else{
                    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [postDic setObject:[NSDate date] forKey:@"postTime"];
                    [UserDefaultsHelper saveDefaultsValue:postDic forKey:kUserDefaultsKey_ClanSearchSetWithGroup];
                }
            }else{
                //写入时间
                NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [postDic setObject:[NSDate date] forKey:@"postTime"];
                [UserDefaultsHelper saveDefaultsValue:postDic forKey:kUserDefaultsKey_ClanSearchSetWithGroup];

            }
        }
    }
    if (isFirst) {
        //是否是由搜索按钮触发
        if ([type isEqualToString:KSearchPost]) {
            _postArray = [NSMutableArray array];
        }
        _type = type;
        _keyword = string;
        [self requestData:type andString:string];
    }
}

#pragma mark - 请求数据
- (void)requestData:(NSString *)type andString:(NSString *)string{
    WEAKSELF
    if (_page == 1) {
        [self beginLoading];
    }
    [_searchViewModel requestSearchWithType:type andkeyWord:string andPage:@(_page).stringValue andBlock:^(NSArray *searchArray,BOOL isMore) {
        STRONGSELF
        [strongSelf endLoading];
        [strongSelf.searchTableView endHeaderRefreshing];
        if ([type isEqualToString:KSearchPost] && _page == 1) {
            [strongSelf.postArray removeAllObjects];
        }
        if (searchArray) {
            if ([type isEqualToString:KSearchPost]) {
                [strongSelf.postArray addObjectsFromArray:searchArray];
                if (isMore) {
                    [strongSelf addPullRefreshActionWithUpWithType:type andKeyword:string];
                }else{
                    [strongSelf.searchTableView.footer noticeNoMoreData];
                }

            }else if ([type isEqualToString:KSearchForum]){
                strongSelf.formsArray = searchArray;
            }else if([type isEqualToString:KSearchUser]){
                strongSelf.userArray = searchArray;
            }
        }
        [strongSelf.searchTableView reloadData];
        //刷新tableview
        [strongSelf configBlankPage:DataIsNothingWithSearch hasData:(searchArray.count > 0) hasError:(!searchArray) reloadButtonBlock:^(id sender) {
            [strongSelf beginLoading];
            [strongSelf requestData:type andString:string];
        }];
    }];
}

- (void)addPullRefreshActionWithUpWithType:(NSString *)type andKeyword:(NSString *)keyword;
{
    WEAKSELF
    [_searchTableView createFooterViewBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //        [strongSelf.tableView hideTableFooter];
        strongSelf.page ++;
        [strongSelf requestData:type andString:keyword];
    }];
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_type isEqualToString:KSearchPost]) {
        return _postArray.count;
    }else if ([_type isEqualToString:KSearchForum]){
        return _formsArray.count;
    }else if ([_type isEqualToString:KSearchUser]){
        return _userArray.count;
    }else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_type isEqualToString:KSearchPost]) {
        id cellmodel = _postArray[indexPath.row];
        APostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"APostCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.showTopic = NO;
        cell.listable = NO;
        cell.postModel = cellmodel;
        return cell;
    }else if ([_type isEqualToString:KSearchForum]){
        BoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BoardCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.forumsModel = _formsArray[indexPath.row];
        return cell;
    }else if ([_type isEqualToString:KSearchUser]){
        UserSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSearchCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.infoModel = _userArray[indexPath.row];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_type isEqualToString:KSearchPost]) {
        id cellmodel = _postArray[indexPath.row];
        APostCell *cell = self.tempPostCell;
        cell.showTopic = NO;
        cell.listable = NO;
        cell.postModel = cellmodel;
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height+1;
        return 1;
    }else if ([_type isEqualToString:KSearchForum]){
        return 80;
    }else if ([_type isEqualToString:KSearchUser]){
        return 64;
    }
    return 44;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    for (UIView *view in self.additionsViewController.navigationController.view.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            UISearchBar *searchBar = (UISearchBar *)view;
            if ([searchBar isFirstResponder]) {
                [searchBar resignFirstResponder];
            }
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_type isEqualToString:KSearchPost]) {
//            PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//            detail.postModel =  _postArray[indexPath.row];
            PostDetailVC *detail = [[PostDetailVC alloc]init];
            detail.postModel =  _postArray[indexPath.row];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:detail];
            [self.additionsViewController presentViewController:nav animated:YES completion:nil];
        }else if ([_type isEqualToString:KSearchForum]){
            PostViewController *postVc = [[PostViewController alloc]init];
            ForumsModel *forumsModel = _formsArray[indexPath.row];
            postVc.forumsModel = forumsModel;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:postVc];
            [self.additionsViewController presentViewController:nav animated:YES completion:nil];
        }else if ([_type isEqualToString:KSearchUser]){
            MeViewController *mainHomeVc = [[MeViewController alloc]init];
            UserModel *userModel = [UserModel new];
            userModel.uid = [(UserInfoModel *)_userArray[indexPath.row] uid];
            mainHomeVc.user = userModel;
            mainHomeVc.isPresentMode = YES;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainHomeVc];
            [self.additionsViewController presentViewController:nav animated:YES completion:nil];
        }
    });
}

#pragma mark - alert
- (void)alertWithWarning:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

@end
