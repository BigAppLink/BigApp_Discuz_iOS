//
//  CustomViewController.m
//  Clan
//
//  Created by chivas on 15/6/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CustomViewController.h"
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
@interface CustomViewController ()<SDCycleScrollViewDelegate>

@property (strong, nonatomic)BaseTableView *tableView;
@property (strong, nonatomic)HomeViewModel *homeViewModel;
@property (strong, nonatomic)CustomHomeMode *customHomeModel;
@property (strong, nonatomic)NSArray *hotArray;
@property (strong, nonatomic)NSMutableArray *forumArray;
@property (strong, nonatomic)YZGridView *gridview;
@property (strong, nonatomic) APostCell *tempPostCell;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (assign, nonatomic) NSInteger selectListIndex;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) CustomHomeListModel *listType;
@property (strong, nonatomic) NSMutableArray *titleNameArray;

//首页滑动栏
@end

static NSString *aPostCellIdentifer = @"APostCell";

@implementation CustomViewController

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
    _selectListIndex = 0;
    //是否显示搜索按钮
    
    [self searchActionEnable];
    //排序按钮
    [self viewForOrderBy];
    //sectionHeaderView
    [self addGridView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAutoUpdate) name:@"AUTO_REFRESH_SHOWYE" object:nil];
    self.navigationItem.title = [NSString returnStringWithPlist:YZBBSName];
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
    }
    [self initWithTable];
    [_tableView registerClass:[BannerCell class] forCellReuseIdentifier:@"BannerCell"];
    [_tableView registerClass:[LinkCell class] forCellReuseIdentifier:@"LinkCell"];
    UINib *ArticleNib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [_tableView registerNib:ArticleNib forCellReuseIdentifier:@"ArticleCell"];
    UINib *cellNib = [UINib nibWithNibName:@"ForumCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"ForumCell"];
    
    UINib *apostCell = [UINib nibWithNibName:NSStringFromClass([APostCell class]) bundle:nil];
    [_tableView registerNib:apostCell forCellReuseIdentifier:aPostCellIdentifer];
    _tempPostCell = [_tableView dequeueReusableCellWithIdentifier:aPostCellIdentifer];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
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
        height  = ScreenBoundsHeight-49-40;
    }
    
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height)style:_listArray.count > 1 ? UITableViewStylePlain: UITableViewStyleGrouped];
    WEAKSELF
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf requestData:weakSelf.listType];
    }];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionFooterHeight = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    //加载缓存数据
    [self loadCache];
    [Util setExtraCellLineHidden:_tableView];
}

#pragma mark - 请求刷新数据
- (void)requestData:(CustomHomeListModel *)listType
{
    WEAKSELF
    [_homeViewModel request_customHomeWithListType:listType andBlock:^(CustomHomeMode *customHomeModel, NSArray *hotArray,BOOL isError) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.hud) {
            [strongSelf.hud hide:YES];
            [strongSelf.hud removeFromSuperview];
        }
        [strongSelf.view endLoading];
        [strongSelf.tableView endHeaderRefreshing];
        if (isError) {
            BOOL isdata = (strongSelf.customHomeModel.banner && strongSelf.customHomeModel.banner.count > 0) || (strongSelf.customHomeModel.link && strongSelf.customHomeModel.link.count > 0) || (strongSelf.customHomeModel.forum && strongSelf.customHomeModel.forum.count > 0);
                [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:isdata hasError:(isError) reloadButtonBlock:^(id sender) {
                [strongSelf.view beginLoading];
                [strongSelf requestData:listType];
            }];
            [strongSelf.tableView reloadData];
            return ;
        }
        strongSelf.customHomeModel = nil;
        strongSelf.hotArray = nil;
        if (!customHomeModel.banner && !customHomeModel.link && !customHomeModel.forum && !hotArray) {

        } else {
            strongSelf.customHomeModel = customHomeModel;
            [strongSelf resetGridView];
            //创建forum数组 一个CELL显示两个
            if (!strongSelf.forumArray) {
                strongSelf.forumArray = [NSMutableArray array];
            }
            NSMutableArray *temp = nil;
            [strongSelf.forumArray removeAllObjects];
            for (int index = 0; index < strongSelf.customHomeModel.forum.count; index++) {
                ForumsModel *expenseDic = strongSelf.customHomeModel.forum[index];
                if (index % 2 == 0) {
                    temp = [[NSMutableArray alloc] initWithCapacity:2];
                    [strongSelf.forumArray addObject:temp];
                }
                [temp addObject:expenseDic];
            }
        }
        strongSelf.hotArray = hotArray;
        [strongSelf.tableView reloadData];
    }];
}

- (void)loadCache
{
    WEAKSELF
    [_homeViewModel request_cacheWithType:_listType andBlock:^(CustomHomeMode *customHomeModel, NSArray *hotArray, BOOL isError) {
         STRONGSELF
         [strongSelf dealWithData:customHomeModel withHotArr:hotArray andSuccess:isError];
     }];
    [_tableView beginRefreshing];
}

- (void)dealWithData:(CustomHomeMode *)customHomeModel withHotArr:(NSArray *)hotArray andSuccess:(BOOL)isError
{
    self.customHomeModel = customHomeModel;
    [self resetGridView];
    //创建forum数组 一个CELL显示两个
    if (!_forumArray) {
        _forumArray = [NSMutableArray array];
    }
    NSMutableArray *temp = nil;
    [_forumArray removeAllObjects];
    for (int index = 0; index < self.customHomeModel.forum.count; index++) {
        ForumsModel *expenseDic = self.customHomeModel.forum[index];
        if (index % 2 == 0) {
            temp = [[NSMutableArray alloc] initWithCapacity:2];
            [_forumArray addObject:temp];
        }
        [temp addObject:expenseDic];
    }
    self.hotArray = hotArray;
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
//    if (section == 1 && section == 2) {
//        return CGFLOAT_MIN;
//    }
//    if (section == 2) {
//        return _customHomeModel.link || _customHomeModel.banner ? 10 : CGFLOAT_MIN;
//    }
    if (section == 3) {
        if (_listArray.count > 1) {
            return 44;
        } else {
            return ((_customHomeModel.link && _customHomeModel.link.count > 0) || (_customHomeModel.forum && _customHomeModel.forum.count>0)|| (_customHomeModel.banner && _customHomeModel.banner.count>0)) ? 30 : CGFLOAT_MIN;
        }
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return (_customHomeModel.link && _customHomeModel.link.count > 0) ? 10 : CGFLOAT_MIN;
    }
    else if (section == 2) {
        return (_customHomeModel.forum && _customHomeModel.forum.count > 0) ? 10 : CGFLOAT_MIN;
    }
//    if (section == 1 || section == 2) {
//        
//         return _customHomeModel.link || _customHomeModel.banner ? 10 : CGFLOAT_MIN;
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
        if (_listArray.count > 1) {
            return _headerView;
        }else{
            if (_hotArray.count > 0) {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
                view.backgroundColor = [UIColor whiteColor];
//                UIView *whitebg = [UIView new];
//                whitebg.backgroundColor = [UIColor whiteColor];
//                [view addSubview:whitebg];
//                [whitebg mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.leading.equalTo(view.mas_leading);
//                    make.trailing.equalTo(view.mas_trailing);
//                    make.top.equalTo(view.mas_top).offset(10);
//                    make.bottom.equalTo(view.mas_bottom);
//                }];
                UILabel *label = [UILabel new];
                label.font = [UIFont fontWithSize:12.f];
                label.textColor = K_COLOR_DARK_Cell;
                label.text = [NSString stringWithFormat:@"%@",[(CustomHomeListModel *)_listArray[0] title]];
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
        if ([_listType.type isEqualToString:@"4"]) {
            //文章
            ArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
            //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *lineLabel = [self lineViewWithFrame:CGRectMake(0, cell.contentView.bottom - 0.5, ScreenWidth, 0.5)];
            [cell.contentView addSubview:lineLabel];
            cell.articleModel = _hotArray[indexPath.row];
            return cell;
        }else{
            APostCell *cell = [tableView dequeueReusableCellWithIdentifier:aPostCellIdentifer forIndexPath:indexPath];
            cell.postModel = _hotArray[indexPath.row];
            return cell;

        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        //跳转到详情页面
        if ([_listType.type isEqualToString:@"4"]) {
//            ArticleListModel *listmodel = _hotArray[indexPath.row];
//            PostDetailVC *detail = [[PostDetailVC alloc]init];
//            detail.isArticle = YES;
//            PostModel *model = [PostModel new];
//            model.tid = listmodel.aid;
//            detail.postModel = model;
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
        }
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //等比例调整banner
        float heightCycle = (kSCREEN_WIDTH * 342.f)/750.f;
        return _customHomeModel.banner ? heightCycle : 0;
    }else if (indexPath.section == 1){
        return _customHomeModel.link ? kVIEW_H(_gridview) : 0;
    }else if (indexPath.section == 2){
        return _customHomeModel.forum ? 59 : 0;
    }else if (indexPath.section == 3){
        if (_hotArray.count == 0 || _listArray.count == 0) {
            return 0;
        } else {
            if ([_listType.type isEqualToString:@"4"]) {
                //文章列表高度
                return 108;
            }else{
                _tempPostCell.postModel = _hotArray[indexPath.row];
                CGFloat height = [_tempPostCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                //由于分割线，所以contentView的高度要小于row 一个像素。
                return height + 1;

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
    [UserDefaultsHelper cleanDefaultsForKey:kUserDefaultsKey_ClanSearchSetWithForum];
    [UserDefaultsHelper cleanDefaultsForKey:kUserDefaultsKey_ClanSearchSetWithGroup];

    if (searchDic) {
        if ([searchDic[@"enable"] isEqualToString:@"1"]) {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sousuoshouye"] style:UIBarButtonItemStylePlain target:self action:@selector(searchAction)] animated:NO];
            for (NSDictionary *dic in searchDic[@"setting"]) {
                if ([dic[@"key"] isEqualToString:@"forum"]) {
                    //论坛搜索
                    [UserDefaultsHelper saveDefaultsValue:dic forKey:kUserDefaultsKey_ClanSearchSetWithForum];
                }else if ([dic[@"key"] isEqualToString:@"group"]){
                    //用户搜索
                    [UserDefaultsHelper saveDefaultsValue:dic forKey:kUserDefaultsKey_ClanSearchSetWithGroup];
                }
                
            }
        }
    }
}

#pragma mark - 排序设置
- (void)viewForOrderBy
{
    NSArray *listArray = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanCustomVc];
    if (!_listArray) {
        _listArray = [NSMutableArray arrayWithCapacity:listArray.count];
    }
    [_listArray removeAllObjects];
    if (listArray && listArray.count > 0) {
        for (NSDictionary *dic in listArray) {
            CustomHomeListModel *model = [CustomHomeListModel objectWithKeyValues:dic];
            [_listArray addObject:model];
        }
        _listType = _listArray[0];
    }else if(!listArray){
        NSArray *tempArray = @[@"new",@"hot",@"digest"];
        NSArray *titleArray = @[@"最新",@"热门",@"精华"];
        for (NSInteger index = 0; index<tempArray.count; index++) {
            CustomHomeListModel *model = [CustomHomeListModel new];
            model.title = titleArray[index];
            model.module = tempArray[index];
            model.type = @"0";
            [_listArray addObject:model];
        }
        _listType = _listArray[0];
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
    for (int index = 0; index<_listArray.count; index++) {
        [gridView addCardWithTitle:[(CustomHomeListModel *)_listArray[index] title] withSel:@selector(customListAction:)];

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
    _listType = _listArray[button.tag - 1000];
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
        [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"首页";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
