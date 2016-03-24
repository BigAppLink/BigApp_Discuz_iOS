//
//  CustomModuleViewController.m
//  Clan
//
//  Created by chivas on 15/10/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomModuleViewController.h"
#import "HomeViewModel.h"
#import "SDCycleScrollView.h"
#import "BannerModel.h"
#import "BannerCell.h"
#import "LinkCell.h"
#import "ForumCell.h"
//#import "HotPostCell.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"
#import "YZGridView.h"
#import "SearchViewController.h"
#import "APostCell.h"
#import "CustomGridView.h"
#import "CustomHomeListModel.h"
#import "ArticleCell.h"
#import "ArticleDetailViewController.h"
#import "ArticleListModel.h"
#import "CustomTransferViewController.h"
#import "ClanAPostCell.h"
#import "PostSendViewController.h"
#import "BoardModel.h"
#import "MeViewController.h"
#import "CustomRightItemView.h"
@interface CustomModuleViewController ()<SDCycleScrollViewDelegate,CustomRightItemDelegate>


@property (strong, nonatomic)BaseTableView *tableView;
@property (strong, nonatomic)HomeViewModel *homeViewModel;
@property (strong, nonatomic)NSMutableArray *hotArray;
@property (strong, nonatomic)NSMutableArray *forumArray;
@property (strong, nonatomic)YZGridView *gridview;
@property (strong, nonatomic) ClanAPostCell *tempPostCell;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (assign, nonatomic) NSInteger selectListIndex;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) CustomHomeListModel *listType;
@property (strong, nonatomic) NSMutableArray *titleNameArray;
@property (strong, nonatomic) NSArray *customTabbarArray;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) CustomRightItemView *rightItemView;
@property (assign, nonatomic) BOOL isReadMore;

@end

static NSString *aPostCellIdentifer = @"ClanAPostCell";
//内容型
static NSString *const customContentType = @"1";
//推荐型
static NSString *const customRecommendType = @"2";
@implementation CustomModuleViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([UserModel currentUserInfo].logined) {
        AppDelegate *dele = [AppDelegate appDelegate];
        [dele getUserAllFavos];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:KCustomItemNotifi object:_customHomeModel];
    //设置头部右侧按钮
    _rightItemView = [[CustomRightItemView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    _rightItemView.delegate = self;
    _rightItemView.customHomeModel = _customHomeModel;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightItemView];
    if (!_hotArray) {
        _hotArray = [NSMutableArray array];
    }
    _page = 1;
    _selectListIndex = 0;
    //设置banner区
    [self initForums];
    //设置link区
    [self resetGridView];

    //是否显示搜索按钮
    [self searchActionEnable];
    //排序按钮
    [self viewForOrderBy];
    //sectionHeaderView
    [self addGridView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAutoUpdate) name:@"AUTO_REFRESH_SHOWYE" object:nil];
    self.navigationItem.title = _customHomeModel.navTitle.length > 0 ? _customHomeModel.navTitle : [NSString returnStringWithPlist:YZBBSName];
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
    }
    [self initWithTable];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)navback:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma rightItem Delegate
- (void)customRightPostSend{
    [self sendPost];
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _rightItemView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - tableview

- (void)doAutoUpdate
{
    if (!self.tableView.header.isRefreshing) {
        //是否正在下拉刷新
        [self.tableView beginRefreshing];
    }
}

- (void)initWithTable
{
    CGFloat height ;
    if (self.tabBarController) {
        height = ScreenBoundsHeight-49;
    }else{
        height = ScreenBoundsHeight;
    }
    if (_isTabBar) {
        height  = ScreenBoundsHeight-49-38;
    }
    
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height)style:_customHomeModel.recommend.count > 1 ? UITableViewStylePlain: UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionFooterHeight = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    WEAKSELF
    [_tableView createHeaderViewBlock:^{
        STRONGSELF
        strongSelf.page = 1;
        [strongSelf requestData:strongSelf.listType];
    }];
    [_tableView registerClass:[BannerCell class] forCellReuseIdentifier:@"BannerCell"];
    [_tableView registerClass:[LinkCell class] forCellReuseIdentifier:@"LinkCell"];
    UINib *ArticleNib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [_tableView registerNib:ArticleNib forCellReuseIdentifier:@"ArticleCell"];
    UINib *cellNib = [UINib nibWithNibName:@"ForumCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"ForumCell"];
    
    [_tableView registerClass:[ClanAPostCell class] forCellReuseIdentifier:aPostCellIdentifer];

    //加载缓存数据
    [self loadCache];
    [Util setExtraCellLineHidden:_tableView];
}

- (void)addPullRefreshActionWithUp
{
    if (!_tableView.legendFooter) {
        WEAKSELF
        [_tableView createFooterViewBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.page ++;
            [strongSelf requestData:strongSelf.listType];
        }];
    }
}

#pragma mark - 请求刷新数据
- (void)requestData:(CustomHomeListModel *)listType
{
    [self.view endLoading];
    if (!listType && !_customHomeModel) {
        [self.view endLoading];
        [self.tableView endHeaderRefreshing];
        [self.tableView configBlankPage:DataIsNothingWithDefault hasData:NO hasError:(NO) reloadButtonBlock:^(id sender) {
            [self.view beginLoading];
            [self requestData:listType];
        }];
        return;
    }
    if (!listType) {
        [self.tableView endHeaderRefreshing];
        return;
    }
    BOOL isFirst = (_hotArray == nil);
    WEAKSELF
    [_homeViewModel request_customHomeWithType:listType page:@(_page).stringValue andBlock:^(BOOL isMore,NSArray *hotArray, BOOL isError) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.hud) {
            [strongSelf.hud hide:YES];
            [strongSelf.hud removeFromSuperview];
        }
        [strongSelf.view endLoading];
        [strongSelf.tableView endHeaderRefreshing];
        [strongSelf.tableView.footer endRefreshing];
        if (isError) {
            if (isFirst) {
                BOOL isdata = (strongSelf.customHomeModel.banner && strongSelf.customHomeModel.banner.count > 0) || (strongSelf.customHomeModel.link && strongSelf.customHomeModel.link.count > 0) || (strongSelf.customHomeModel.forum && strongSelf.customHomeModel.forum.count > 0);
                [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:isdata hasError:(isError) reloadButtonBlock:^(id sender) {
                    [strongSelf.view beginLoading];
                    [strongSelf requestData:listType];
                }];
                [strongSelf.tableView reloadData];
                return ;
            }
        }else{
            if (strongSelf.page != 1) {
                if (!isMore) {
                    [strongSelf.tableView.footer noticeNoMoreData];
                }
            } else {
                if (!isMore) {
                    [strongSelf.tableView removeFooter];
                    strongSelf.tableView.contentInset = UIEdgeInsetsMake(strongSelf.tableView.contentInset.top, 0, 44, 0);
                    strongSelf.isReadMore = NO;
                } else {
                    [strongSelf addPullRefreshActionWithUp];
                    strongSelf.tableView.contentInset = UIEdgeInsetsMake(strongSelf.tableView.contentInset.top, 0, 0, 0);
                    strongSelf.isReadMore = YES;
                    
                }
                [strongSelf.hotArray removeAllObjects];
            }
            [strongSelf.hotArray addObjectsFromArray:hotArray];
        }
        [strongSelf.tableView reloadData];
    }];
}
- (void)initForums{
    //创建forum数组 一个CELL显示两个
    if (!_forumArray) {
        _forumArray = [NSMutableArray array];
    }
    NSMutableArray *temp = nil;
    [_forumArray removeAllObjects];
    for (int index = 0; index < _customHomeModel.forum.count; index++) {
        ForumsModel *expenseDic = _customHomeModel.forum[index];
        if (index % 2 == 0) {
            temp = [[NSMutableArray alloc] initWithCapacity:2];
            [_forumArray addObject:temp];
        }
        [temp addObject:expenseDic];
    }
}
- (void)loadCache
{
    WEAKSELF
    [_homeViewModel request_cacheWithCustomType:_listType andBlock:^(NSArray *hotArray, BOOL isError) {
        STRONGSELF
        [strongSelf dealWithData:hotArray andSuccess:isError];
    }];
    [_tableView beginRefreshing];
}

- (void)dealWithData:(NSArray *)hotArray andSuccess:(BOOL)isError
{
    [self.hotArray addObjectsFromArray:hotArray];
    [self.tableView reloadData];
}

- (void)resetGridView
{
    if (self.customHomeModel.link) {
        if (!_gridview) {
            _gridview = [[YZGridView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 0)];
            _gridview.tag = 11444;
        }
        _gridview.customHomeModel = _customHomeModel;
    } else {
        [_gridview removeFromSuperview];
        _gridview = nil;
    }
    
}


#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return _forumArray.count;
    }else if (section == 3){
        return _hotArray.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        if (_customHomeModel.recommend.count > 1) {
            return 44;
        } else {
            return ([_listType.type isEqualToString:customRecommendType]) ? 30 : CGFLOAT_MIN;
        }
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (section == 1) {
//        return (_customHomeModel.link && _customHomeModel.link.count > 0) ? 10 : CGFLOAT_MIN;
//    }
//    else if (section == 2) {
//        return (_customHomeModel.forum && _customHomeModel.forum.count > 0) ? 10 : CGFLOAT_MIN;
//    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        if (_customHomeModel) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
            view.backgroundColor = kCOLOR_BG_GRAY;
            return view;
        }
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 3) {
        if (_customHomeModel.recommend.count > 1) {
            return _headerView;
        }else{
            if (_hotArray.count > 0 && [_listType.type isEqualToString:customRecommendType]) {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
                view.backgroundColor = [UIColor whiteColor];
                UILabel *label = [UILabel new];
                label.font = [UIFont fontWithSize:12.f];
                label.textColor = K_COLOR_DARK_Cell;
                label.text = [NSString stringWithFormat:@"%@",[(CustomHomeListModel *)_customHomeModel.recommend[0] title]];
                [view addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(view.mas_leading).offset(15);
                    make.trailing.equalTo(view.mas_trailing).offset(-10);
                    make.top.equalTo(view.mas_top).offset(0);
                    make.bottom.equalTo(view.mas_bottom);
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
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BannerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BannerCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.customHomeModel = _customHomeModel;
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *identifer = @"LLLIKn";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (![cell.contentView viewWithTag:11444]) {
            [cell.contentView addSubview:_gridview];
        }
        return cell;

    } else if (indexPath.section == 2){
        ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForumCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.forumArray = _forumArray[indexPath.row];
        UILabel *lineLabel = [self lineViewWithFrame:CGRectMake(0, cell.contentView.bottom - 0.5, ScreenWidth, 0.5)];
        [cell.contentView addSubview:lineLabel];
        return cell;
    } else if (indexPath.section == 3){
        if ([_hotArray[indexPath.row] isKindOfClass:[PostModel class]]) {

            ClanAPostCell *cell = [tableView dequeueReusableCellWithIdentifier:aPostCellIdentifer forIndexPath:indexPath];
            cell.type = @"1";
            cell.postModel = _hotArray[indexPath.row];
            return cell;
        }else{
            ArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
            //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lineLabel = [self lineViewWithFrame:CGRectMake(0, cell.contentView.bottom - 0.5, ScreenWidth, 0.5)];
            [cell.contentView addSubview:lineLabel];
            cell.articleModel = _hotArray[indexPath.row];
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        //跳转到详情页面
        if ([_hotArray[indexPath.row] isKindOfClass:[ArticleListModel class]]) {
//            ArticleListModel *listModel = _hotArray[indexPath.row];
//            PostDetailVC *detail = [[PostDetailVC alloc]init];
//            detail.isArticle = YES;
//            PostModel *modelPost = [PostModel new];
//            modelPost.tid = listModel.aid;
//            detail.postModel = modelPost;
//            detail.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:detail animated:YES];
            ArticleDetailViewController *articleDetailVc = [[ArticleDetailViewController alloc]init];
            articleDetailVc.articleModel = _hotArray[indexPath.row];
            articleDetailVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:articleDetailVc animated:YES];
        }else{
//            PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//            detail.postModel =  _hotArray[indexPath.row];
//            detail.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:detail animated:YES];
//            [Util readPost:detail.postModel.tid];
            
            PostDetailVC *detail = [[PostDetailVC alloc]init];
            detail.postModel =  _hotArray[indexPath.row];
            detail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detail animated:YES];
            [Util readPost:detail.postModel.tid];
        }
        [tableView performSelector:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:@[indexPath] afterDelay:0.1];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //等比例调整banner
        float heightCycle = (kSCREEN_WIDTH * 342.f)/750.f;
        return (_customHomeModel.banner && _customHomeModel.banner.count > 0) ? heightCycle : 0;
    }else if (indexPath.section == 1){
        return _customHomeModel.link ? kVIEW_H(_gridview) : 0;
    }else if (indexPath.section == 2){
        return _customHomeModel.forum ? 59 : 0;
    }else if (indexPath.section == 3){
        if (_customHomeModel.recommend.count == 0) {
            return 0;
        } else {
            if ([_hotArray[indexPath.row] isKindOfClass:[ArticleListModel class]]) {
                //文章列表高度
                return 108;
            }else{

                id cellmodel = _hotArray[indexPath.row];
                PostModel *model = cellmodel;
                return model.frame;
            }
        }
    }
    return 0;
}

#pragma mark - 添加分割线
- (UILabel *)lineViewWithFrame:(CGRect)frame
{
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:frame];
    lineLabel.backgroundColor = UIColorFromRGB(0xeeeeee);
    return lineLabel;
}

#pragma mark - 搜索
- (void)searchAction
{
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchVC];
    [self presentViewController:nav animated:NO completion:nil];
}

#pragma mark - 是否显示搜索按钮
- (void)searchActionEnable{
    NSDictionary *searchDic = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanSearchSetting];
    //清空之前的状态
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ClanSearchSetWithForum"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"ClanSearchSetWithGroup"];
    
    if (searchDic) {
        if ([searchDic[@"enable"] isEqualToString:@"1"]) {
//            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sousuoshouye"] style:UIBarButtonItemStylePlain target:self action:@selector(searchAction)] animated:NO];
            for (NSDictionary *dic in searchDic[@"setting"]) {
                if ([dic[@"key"] isEqualToString:@"forum"]) {
                    //论坛搜索
                    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:@"ClanSearchSetWithForum"];
                }else if ([dic[@"key"] isEqualToString:@"group"]){
                    //用户搜索
                    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:@"ClanSearchSetWithGroup"];
                }
                
            }
        }
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - 排序设置
- (void)viewForOrderBy{
    NSArray *listArray = _customHomeModel.recommend;
    if (listArray && listArray.count > 0) {
        _listType = listArray[0];
    }
}

#pragma mark - gridView
- (void)addGridView
{
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    _headerView.backgroundColor = [UIColor whiteColor];
    CustomGridView *gridView = [[CustomGridView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 41)];
    gridView.gridType = @"searchType";
    [gridView initScrollView];
    gridView.backgroundColor = [UIColor clearColor];
    gridView.target = self;
    for (int index = 0; index<_customHomeModel.recommend.count; index++) {
        [gridView addCardWithTitle:[(CustomHomeListModel *)_customHomeModel.recommend[index] title] withSel:@selector(customListAction:)];
        
    }
    [gridView addCardDone];
    
    //添加阴影线
    UIImageView *lineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, gridView.bottom, ScreenWidth, 3)];
    lineView.image = kIMG(@"qiehuanxuanxiang");
    [_headerView addSubview:gridView];
    [_headerView addSubview:lineView];
}

- (void)customListAction:(id)sender{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    UIButton *button = sender;
    _page = 1;
    _listType = _customHomeModel.recommend[button.tag - 1000];
//    WEAKSELF
//    [_homeViewModel request_cacheWithType:_listType andBlock:^(CustomHomeMode *customHomeModel, NSArray *hotArray, BOOL isError) {
//        STRONGSELF
//        [strongSelf dealWithData:customHomeModel withHotArr:hotArray andSuccess:isError];
//    }];
    [self requestData:_listType];
    //如果是第三个section 返回头部
    CGPoint offset =  self.tableView.contentOffset;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];
    if (indexPath && indexPath.section == 3) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
        [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - scrollview delegate 修复错位问题

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset =  self.tableView.contentOffset;
    if (offset.y <= 0) {
        return;
    }
    if (_isReadMore) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];
        if (indexPath && indexPath.section >= 3) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return _navSideTitle;
}

#pragma mark - Action

- (void)sendPost
{
    if ([self checkLoginState])
    {
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [_homeViewModel request_boardBlock:^(id data) {
            STRONGSELF
            [SVProgressHUD dismiss];
            id forumsdata = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ForumsStore];
            if (forumsdata && [forumsdata isKindOfClass:[NSArray class]]) {
                NSArray *forumsDataArr = (NSArray *)forumsdata;
                NSMutableArray *forumsArr = [NSMutableArray new];
                for (NSDictionary *dic in forumsDataArr) {
                    BoardModel *boardModel = [BoardModel objectWithKeyValues:dic];
                    [forumsArr addObject:boardModel];
                }
                //存储forums
                if (forumsArr && forumsArr.count > 0) {
                    //存在版块儿 跳转到
                    PostSendViewController *send = [[PostSendViewController alloc]init];
                    send.fromShouYe = YES;
                    send.dataSourceArray = [[NSArray alloc]initWithArray:forumsArr];
                    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:send];
                    [strongSelf presentViewController:navi animated:YES completion:NULL];
                } else {
                    [strongSelf showHudTipStr:@"抱歉，暂无板块儿可以发帖！"];
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
