
//
//  PostViewController.m
//  Clan
//
//  Created by chivas on 15/3/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostViewController.h"
#import "PostViewModel.h"
#import "ForumsModel.h"
#import "PostCell.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "ClanApiUrl.h"
#import "PostDetailViewController.h"
#import "PostSendViewController.h"
#import "CheckPostModel.h"
#import "LoginViewController.h"
#import "PostModel.h"
#import "TopListCell.h"
#import "TopAListCell.h"
#import "HotPostCell.h"
#import "BaseTableView.h"
#import "PostSendModel.h"
#import "PopoverView.h"
#import "NSDate+Helper.h"
#import "PostImageCell.h"
#import "PostNoImageCell.h"
#import "TOWebViewController.h"
#import "AboutViewController.h"
#import "SubsCell.h"
#import "APostCell.h"
#import "PostActivityViewController.h"
#import "PostDetailVC.h"
#import "YZSearchGridView.h"
#import "SubsModel.h"
#import "ClanAPostCell.h"
#import "CustomGridView.h"
static NSString *postcellindentifer = @"ClanAPostCell";
static NSInteger const topListHeight = 37;
@interface PostViewController ()<YALContextMenuTableViewDelegate,BoardFavDelegate>
{
    NSIndexPath *_toBeReload;
}
@property (assign) int tobeShowAdIndex;
@property (assign) BOOL first;
@property (assign, nonatomic) BOOL isMoreImageType;
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSMutableArray *topArray;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) PostViewModel *postList;
@property (strong, nonatomic) YALContextMenuTableView* contextMenuTableView;
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) NSArray *menuIcons;
@property (strong, nonatomic) CheckPostModel *checkModel;
@property (assign, nonatomic) BOOL isMoreArray;//切换置顶视图
@property (strong, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) int page;
@property (assign, nonatomic) ListType type;
@property (assign, nonatomic) NSInteger selectIndex;
@property (strong, nonatomic) UIView *headerView;
@property (assign, nonatomic) BOOL isMoreSub;
@property (strong, nonatomic) UIImageView *moreBtn;
@property (assign, nonatomic) BOOL isReadMore;
//@property (strong, nonatomic) UITableViewCell *tempCell;
//@property (strong, nonatomic) UITableViewCell *tempNoImageCell;
//@property (strong, nonatomic) UITableViewCell *tempNormalCell;
@property (strong, nonatomic) APostCell *tempPostCell;
@property (strong, nonatomic) UIButton *postBtn;

@end

@implementation PostViewController
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面结束
//    [Analysis endLogPageView:[NSString stringWithFormat:@"postlist_%@",_forumsModel.name]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_toBeReload) {
        [_tableView reloadRowsAtIndexPaths:@[_toBeReload] withRowAnimation:UITableViewRowAnimationAutomatic];
        _toBeReload = nil;
    }
    //页面开始
//    [Analysis beginLogPageView:[NSString stringWithFormat:@"postlist_%@",_forumsModel.name]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurSectionView];
    [self initModel];
    _isMoreArray = NO;
    _isMoreSub = NO;
    _selectIndex = 0;
    _type = allList;
    _first = YES;
    if (!_postList) {
        _postList = [PostViewModel new];
    }
    if (kIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkPost:) name:KCheckPost object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countUpdata:) name:@"imageCount" object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(favTypeUpdate:) name:@"KUpdateFavType" object:nil];
    
    [self initWithNav];
    [self initWithTable];
}

- (void)initModel
{
    if (!_topArray) {
        _topArray = [NSMutableArray array];
    }
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
}


- (void)initWithNav
{
    self.navigationItem.title = _forumsModel.name;
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navback) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
//    UIButton *listBrn = [UIButton buttonWithTitle:nil andImage:@"order_list" andFrame:CGRectMake(rightView.right - 30, (44-30)/2, 30, 30) target:self action:@selector(moreList:)];
//    [rightView addSubview:listBrn];
    UIButton *postBrn = [UIButton buttonWithTitle:nil andImage:@"post_action" andFrame:CGRectMake(rightView.right - 30, (44-30)/2, 30, 30) target:self action:@selector(viewMoreAction:)];
    self.postBtn = postBrn;
    [rightView addSubview:postBrn];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightItem ;
    self.postBtn.enabled = NO;
}

- (void)navback{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)initWithTable
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenBoundsHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    UIView *footView = [[UIView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = footView;
    [self.view addSubview:_tableView];
    //注册cell
    [self regTableViewCell];
    //刷新数据
    [self addPullRefreshActionWithDown];
    
}
#pragma mark - 注册cell
- (void)regTableViewCell{
    [_tableView registerClass:[ClanAPostCell class] forCellReuseIdentifier:postcellindentifer];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"subMoreCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"subForumsCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"topListCell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"topMoreCell"];
    
}
#pragma mark - 刷新
//上拉下拉刷新
- (void)addPullRefreshActionWithDown
{
    WEAKSELF
    //下拉刷新
    [_tableView createHeaderViewBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.page = 1;
        [strongSelf requestData:strongSelf.type];
    }];
    //第一次加载
    self.page = 1;
//    [self loadCache:self.type];
    [_tableView beginRefreshing];
}

- (void)loadCache:(ListType)type
{
    BOOL isFirstSet = (_listArray == nil);
    WEAKSELF
    [_postList request_cache_postListWithFid:_forumsModel.fid andListType:type andViewController:self andPage:@(_page).stringValue andBlock:^(NSArray *topArray,NSArray *listArray,id forumInfo,BOOL isMore) {
        STRONGSELF
        if (forumInfo != nil) {
            NSString *icon = strongSelf.forumsModel.icon;
            NSArray *tempSubsModelArray = strongSelf.forumsModel.subs;
            strongSelf.forumsModel = forumInfo;
            strongSelf.forumsModel.subs = tempSubsModelArray;
            strongSelf.forumsModel.icon = icon;
        }
        //是否开启多图模式
        strongSelf.isMoreImageType = [[NSUserDefaults standardUserDefaults]boolForKey:KOpen_image_mode];
        if (strongSelf.page == 1) {
            [strongSelf.topArray removeAllObjects];
            [strongSelf.listArray removeAllObjects];
            [strongSelf.topArray addObjectsFromArray:topArray];
        }
        [strongSelf.listArray addObjectsFromArray:listArray];
        if (isFirstSet) {
            [strongSelf.tableView reloadData];
            //动画加载完毕 创建加载更多按钮
            double delayInSeconds2 = 0.5;
            dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
            dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
                if (isMore) {
                    //                    [strongSelf addPullRefreshActionWithUp];
                }
            });
            
        }else{
            [strongSelf.tableView reloadData];
            if (!isMore) {
                [strongSelf.tableView.footer noticeNoMoreData];
            }else{
            }
        }
    }];
}

- (void)addPullRefreshActionWithUp
{
    if (!_tableView.legendFooter) {
        WEAKSELF
        [_tableView createFooterViewBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.page ++;
            [strongSelf requestData:weakSelf.type];
        }];
    }
}
#pragma mark -拿到版块认证信息
- (void)checkPost:(NSNotification *)info
{
    _checkModel = (CheckPostModel *)info.object;
    _forumsModel.uploadhash = _checkModel.allowperm.uploadhash;
    _forumsModel.toDayPostImage = _checkModel.allowperm.imagecount;
    [[NSUserDefaults standardUserDefaults] setObject:_checkModel.allowperm.imagecount forKey:ClanImageStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setForumsModel:(ForumsModel *)forumsModel{
    _forumsModel = forumsModel;
    //    [self.tableView reloadData];
    //    [self.tableView beginUpdates];
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    //    [self.tableView endUpdates];
}
#pragma mark - 发帖
//更多按钮
- (IBAction)viewMoreAction:(id)sender
{
//    if ([_forumsModel.postActivityModel.allowpostactivity isEqualToString:@"0"]) {
//        //不支持活动 直接跳转
//        [self postAction];
//        return;
//    }
    NSArray *titls = @[@"主题帖",@"活动帖"];
    NSArray *imgsN = @[@"bm_zhutitie", @"bm_huodongtie"];
    NSArray *imgsH = @[@"bm_zhutitie", @"bm_huodongtie"];
    PopoverView *pop = [[PopoverView alloc]initWithFromBarButtonItem:_postBtn inView:self.view titles:titls images:imgsN selectImages:imgsH];
    pop.selectIndex = 0;
    WEAKSELF
    pop.selectRowAtIndex = ^(NSInteger index)
    {
        if (index == 0)
        {
            [weakSelf postAction];
        }
        else if (index == 1)
        {
            [weakSelf postActivityAction];
        }
    };
    [pop show];
}

- (void)postAction
{
    if (![UserModel currentUserInfo].logined) {
        //未登录,弹出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        login.fid = _forumsModel.fid;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:nil];
        return;
        
    }
    //当满足 存在&&非0 时，说明不允许发表普通主题
    if (_forumsModel.allowspecialonly && ![_forumsModel.allowspecialonly isEqualToString:@"0"]) {
        //不支持活动 直接跳转
        [self showHudTipStr:@"该版块儿不支持发表普通主题"];
        return;
    }
    if (!_checkModel.allowperm.allowpost){
        //权限没有调取到
        [self showHudTipStr:NetError];
        return;
    } else if (_checkModel.allowperm.allowpost.intValue != 1){
        //没有权限发表帖子
        [self showHudTipStr:@"没有权限在该版块下发帖"];
        return;
    }
    PostSendViewController *postSend = [[PostSendViewController alloc]init];
    postSend.forumsModel = _forumsModel;
    WEAKSELF
    postSend.sendPostReturnBlock = ^(id model){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        //把发帖的数据取回本地
        PostModel *postModel = [weakSelf getUpdateLocationPostListWithModel:model];
        //插到数组最前面
        if (strongSelf.listArray && strongSelf.type == newList) {
            [strongSelf.listArray insertObject:postModel atIndex:0];
            [strongSelf.tableView reloadData];
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postSend];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)postActivityAction
{
    if (![UserModel currentUserInfo].logined) {
        //未登录,弹出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        login.fid = _forumsModel.fid;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:nil];
        return;
        
    }
    if (!_forumsModel.postActivityModel.allowpostactivity || [_forumsModel.postActivityModel.allowpostactivity isEqualToString:@"0"]) {
        //不支持活动 直接跳转
        [self showHudTipStr:@"该版块儿不支持发活动贴"];
        return;
    }
    if (!_checkModel.allowperm.allowpost){
        //权限没有调取到
        [self showHudTipStr:NetError];
        return;
    } else if (_checkModel.allowperm.allowpost.intValue != 1){
        //没有权限发表帖子
        [self showHudTipStr:@"没有权限在该版块下发帖"];
        return;
    }
    //    PostSendViewController *postSend = [[PostSendViewController alloc]init];
    //    postSend.forumsModel = _forumsModel;
    //    WEAKSELF
    //    postSend.sendPostReturnBlock = ^(id model){
    //        __strong __typeof(weakSelf)strongSelf = weakSelf;
    //        //把发帖的数据取回本地
    //        PostModel *postModel = [weakSelf getUpdateLocationPostListWithModel:model];
    //        //插到数组最前面
    //        if (strongSelf.listArray && strongSelf.type == newList) {
    //            [strongSelf.listArray insertObject:postModel atIndex:0];
    //            [strongSelf.tableView reloadData];
    //        }
    //    };
    PostActivityViewController *postActivitySend = [[PostActivityViewController alloc]init];
    postActivitySend.forumModel = _forumsModel;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postActivitySend];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)setupForumStatus
{
    self.title = _forumsModel.name;
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationNone];
    
}
#pragma mark - 请求列表
- (void)requestData:(ListType)type
{
    //请求帖子列表
    WEAKSELF
    [_postList request_postListWithFid:_forumsModel.fid andListType:type andViewController:self andPage:@(_page).stringValue andBlock:^(NSArray *topArray,NSArray *listArray,id forumInfo,BOOL isMore, BOOL isError) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.postBtn.enabled = YES;
        [strongSelf.hud hide:YES];
        [strongSelf.hud removeFromSuperview];
        [strongSelf.tableView endHeaderRefreshing];
        [strongSelf.tableView.footer endRefreshing];
        if (isError) {
            return ;
        }
        if (forumInfo != nil) {
            NSString *icon = strongSelf.forumsModel.icon;
            NSArray *tempSubsModelArray = strongSelf.forumsModel.subs;
            strongSelf.forumsModel = forumInfo;
            strongSelf.forumsModel.subs = tempSubsModelArray;
            if (icon && icon.length > 0) {
                strongSelf.forumsModel.icon = icon;
            }
            //要改变当前的状态版块儿状态了
            [strongSelf setupForumStatus];
        }
        //是否开启多图模式
        strongSelf.isMoreImageType = [[NSUserDefaults standardUserDefaults]boolForKey:KOpen_image_mode];
        if (strongSelf.page == 1) {
            [strongSelf.topArray removeAllObjects];
            [strongSelf.listArray removeAllObjects];
            [strongSelf.topArray addObjectsFromArray:topArray];
            if (isMore) {
                [strongSelf addPullRefreshActionWithUp];
                strongSelf.isReadMore = YES;
                strongSelf.tableView.contentInset = UIEdgeInsetsMake(strongSelf.tableView.contentInset.top, 0, 0, 0);
            }else{
                [strongSelf.tableView removeFooter];
                strongSelf.tableView.contentInset = UIEdgeInsetsMake(strongSelf.tableView.contentInset.top, 0, 44, 0);
                strongSelf.isReadMore = NO;
            }
        }
        [strongSelf.listArray addObjectsFromArray:listArray];
        if (strongSelf.first) {
            strongSelf.first = NO;
            [strongSelf.tableView reloadData];
            if (!isMore) {
                [strongSelf.tableView.footer noticeNoMoreData];
            }else{
                [strongSelf.tableView.footer endRefreshing];
            }
//            //动画加载完毕 创建加载更多按钮
//            double delayInSeconds2 = 0.5;
//            dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
//            dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
//                if (isMore) {
//                    [strongSelf addPullRefreshActionWithUp];
//                    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//                }
//            });
            
        }else{
            [strongSelf.tableView reloadData];
            if (!isMore) {
                [strongSelf.tableView.footer noticeNoMoreData];
            }else{
                [strongSelf.tableView.footer endRefreshing];
            }
        }
    }];
}

#pragma mark - 排序按钮
//- (void)moreList:(id)sender{
//    
//    NSArray *titles = @[@"最新回复", @"最新发表",@"精华帖"];
//    NSArray *images = @[@"newcomment", @"new_post",@"new_post"];
//    NSArray *selectImages = @[@"newcomment_action",@"new_post_action",@"new_post"];
//    PopoverView *pop = [[PopoverView alloc] initWithFromBarButtonItem:sender inView:self.view titles:titles images:images selectImages:selectImages];
//    pop.selectIndex = _selectIndex;
//    WEAKSELF
//    pop.selectRowAtIndex = ^(NSInteger index){
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        if (strongSelf.selectIndex == index) {
//            return ;
//        }
//        strongSelf.hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
//        strongSelf.hud.mode = MBProgressHUDModeIndeterminate;
//        strongSelf.selectIndex = index;
//        if (index == 0) {
//            strongSelf.type = newList;
//        }else if (index == 1){
//            strongSelf.type = ordbydata;
//        }
//        [strongSelf requestData:strongSelf.type];
//        NSLog(@"select index:%ld", (long)index);
//    };
//    [pop show];
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        if (_forumsModel.subs.count == 0) {
            return 0;
        }else if (!_isMoreSub && _forumsModel.subs.count > 2) {
            return 2+1;
        }else{
            return _forumsModel.subs.count+1;
        }
    }else if(section == 2){
        if (_topArray.count == 0) {
            return 0;
        }else if (!_isMoreArray && _topArray.count > 2) {
            return 2+1;
        } else {
            return _topArray.count+1;
        }
    }else {
        return _listArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_tableView])
    {
        if (indexPath.section == 0) {
            //头文件
            static NSString *topList = @"listcell";
            TopListCell *cell = [tableView dequeueReusableCellWithIdentifier:topList];
            if (cell == nil) {
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TopListCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.forumsModel = _forumsModel;
            return cell;
        }else if (indexPath.section == 1){
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subMoreCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"子版块";
                cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
                cell.textLabel.textColor = UIColorFromRGB(0xa6a6a6);
                if (_forumsModel.subs.count > 2) {
                    UIView *accessoryView = [self viewWithAccessoryView];
                    for (UIImageView *imageView in accessoryView.subviews) {
                        imageView.highlighted = _isMoreSub;
                    }
                    cell.accessoryView = accessoryView;
                }
                [cell.contentView addSubview:[self lineViewWithFrame:CGRectMake(0, topListHeight-0.5, ScreenWidth, 0.5)]];
                return cell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subForumsCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
                cell.textLabel.textColor = UIColorFromRGB(0x424242);
                cell.textLabel.text = [(SubsModel *)_forumsModel.subs[indexPath.row -1]name];
                UILabel *todayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, topListHeight)];
                todayLabel.textColor = UIColorFromRGB(0xa6a6a6);
                todayLabel.font = [UIFont systemFontOfSize:15.0f];
                todayLabel.text = [NSString stringWithFormat:@"今日 %@",[(SubsModel *)_forumsModel.subs[indexPath.row -1]todayposts]];
                cell.accessoryView = todayLabel;
                [cell.contentView addSubview:[self lineViewWithFrame:CGRectMake(0, topListHeight-0.5, ScreenWidth, 0.5)]];
                return cell;
            }
        }else if (indexPath.section == 2) {
            //置顶CELL
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topMoreCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"置顶";
                cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
                cell.textLabel.textColor = UIColorFromRGB(0xa6a6a6);
                if (_topArray.count > 2) {
                    UIView *accessoryView = [self viewWithAccessoryView];
                    for (UIImageView *imageView in accessoryView.subviews) {
                        imageView.highlighted = _isMoreArray;
                    }
                    cell.accessoryView = accessoryView;
                }
                [cell.contentView addSubview:[self lineViewWithFrame:CGRectMake(0, topListHeight-0.5, ScreenWidth, 0.5)]];
                return cell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topListCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
                cell.textLabel.textColor = UIColorFromRGB(0x424242);
                cell.textLabel.text = [(PostModel *)_topArray[indexPath.row -1]subject];
                [cell.contentView addSubview:[self lineViewWithFrame:CGRectMake(0, topListHeight-0.5, ScreenWidth, 0.5)]];
                return cell;
            }
        }
        else {
            id cellmodel = _listArray[indexPath.row];
            ClanAPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanAPostCell" forIndexPath:indexPath];
            cell.showTopic = [self showTopic];
            cell.listable = [self listable];
            cell.postModel = cellmodel;
            return cell;
        }
    }
    return nil;
}

- (BOOL)showTopic
{
    NSString *prefix = self.forumsModel.threadtypes.prefix;
    //    if (!prefix || prefix.length <= 0 || [prefix isEqualToString:@"0"]) {
    if (!prefix || prefix.intValue == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)listable
{
    NSString *listable = self.forumsModel.threadtypes.listable;
    if (!listable || listable.intValue == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_tableView]) {
        if (indexPath.section == 0) {
            return 100;
        }else if(indexPath.section == 1 || indexPath.section == 2) {
            return topListHeight;
        }else {
            id cellmodel = _listArray[indexPath.row];
            PostModel *model = cellmodel;
            return model.frame;
        }
    }
    else {
        return 65;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        return 37;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        return _headerView;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 2) {
        if (section == 1) {
            if (_forumsModel.subs.count == 0) {
                return nil;
            }
        }else if (section == 2){
            if (_topArray.count == 0) {
                return nil;
            }
        }
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 12)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, footerView.bottom - 12, ScreenWidth, 12)];
        label.backgroundColor = UIColorFromRGB(0xf3f3f3);
        [footerView addSubview:label];
        return footerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 12;
    }else if (section == 1){
        if (_forumsModel.subs.count > 0) {
            return 12;
        }else{
            return CGFLOAT_MIN;
        }
    }else if (section == 2) {
        if (_topArray.count > 0) {
            return 12;
        }else{
            return CGFLOAT_MIN;
        }
    }else{
        return CGFLOAT_MIN;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_tableView]) {
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                if (_forumsModel.subs.count > 2) {
                    _isMoreSub =! _isMoreSub;
                    [_tableView reloadData];
                }
            }else{
                PostViewController *postVc = [[PostViewController alloc]init];
                ForumsModel *forumsModel = [ForumsModel new];
                [forumsModel reflectDataFromOtherObject:_forumsModel.subs[indexPath.row-1]];
                postVc.forumsModel = forumsModel;
                [self.navigationController pushViewController:postVc animated:YES];
            }
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                if (_topArray.count > 2) {
                    _isMoreArray =! _isMoreArray;
                    [_tableView reloadData];
                }
            }else{
                PostDetailVC *detail = [[PostDetailVC alloc]init];
                detail.postModel =  _topArray[indexPath.row-1];
                PostModel *p = _topArray[indexPath.row-1];
                [Util readPost:p.tid];
                [self.navigationController pushViewController:detail animated:YES];
                _toBeReload = indexPath;
            }
        }
        else if(indexPath.section >= 3) {
            id model = nil;
            model = _listArray[indexPath.row];
            
            PostDetailVC *detail = [[PostDetailVC alloc]init];
            //            if (!_isMoreImageType) {
            //                detail.postModel =  _listArray[indexPath.row];
            //            }else{
            detail.postModel =  _listArray[indexPath.row];
            //            }
            [Util readPost:detail.postModel.tid];
            [self.navigationController pushViewController:detail animated:YES];
            _toBeReload = indexPath;
        }
    }
}

#pragma mark - 更新可发图片数
- (void)countUpdata:(NSNotification *)info{
    NSNumber *imageCount = info.object;
    if (_forumsModel.toDayPostImage.integerValue > 0) {
        _forumsModel.toDayPostImage = @(_forumsModel.toDayPostImage.integerValue - imageCount.integerValue).stringValue;
    }
}

#pragma mark - 改变brn状态
- (void)changeTopCount:(id)sender{
    UIButton *btn = sender;
    btn.selected =! btn.selected;
    if (btn.selected) {
        _isMoreArray = YES;
    }else{
        _isMoreArray = NO;
    }
    [_tableView reloadData];
}
#pragma mark - 更新收藏状态
- (void)favTypeUpdate:(NSNotification *)info{
    
}
#pragma mark - 收藏回调
- (void)boardFavWithBool:(BOOL)isFav
{
    //判断是否登录
    if (![UserModel currentUserInfo].logined || ![[NSUserDefaults standardUserDefaults]objectForKey:Code_CookieData]) {
        //没有登录 跳出登录页面
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    WEAKSELF
    if (isFav) {
        //已收藏 删除收藏
        [_postList request_DeleteCollection:_forumsModel.fid andType:@"fid" andBlock:^(BOOL state) {
            if (state) {
                [weakSelf.tableView reloadData];
            }
        }];
    }else{
        [_postList request_favBoardWithFid:_forumsModel.fid andBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.tableView reloadData];
                
            }
        }];
    }
    
}

#pragma mark - 发帖后本地更新
- (PostModel *)getUpdateLocationPostListWithModel:(id)model{
    PostSendModel *sendModel = model;
    PostModel *postModel = [PostModel new];
    postModel.tid = sendModel.myPostTid;
    postModel.author = [UserModel currentUserInfo].username;
    postModel.avatar = [UserModel currentUserInfo].avatar;
    postModel.subject = sendModel.subject;
    postModel.message_abstract = sendModel.message;
    postModel.dateline = @"1秒前";
    postModel.views = @"0";
    postModel.replies = @"0";
    postModel.dbdateline = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
    return postModel;
}

#pragma mark - 切换List数据
- (void)postlist:(id)sender{
    self.page = 1;
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    UIButton *button = sender;
    switch (button.tag) {
        case 1000:
            self.type = allList;
            break;
        case 1001:
            self.type = ordbydata;
            break;
        case 1002:
            self.type = digestlist;
            break;
        case 1003:
            self.type = heats;
            break;
        default:
            break;
    }
    [self requestData:self.type];
    //如果是第三个section 返回头部
    CGPoint offset =  self.tableView.contentOffset;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];
    if (indexPath && indexPath.section == 3) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
        [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)configurSectionView{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 37)];
    }
    _headerView.backgroundColor = [UIColor whiteColor];
    YZSearchGridView *gridView = [[YZSearchGridView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 35)];
    gridView.isPostView = YES;
    gridView.textFont = [UIFont systemFontOfSize:13.0f];
    gridView.textColor = UIColorFromRGB(0xa6a6a6);
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.target = self;
    [gridView addCardWithTitle:@"全部" withSel:@selector(postlist:)];
    [gridView addCardWithTitle:@"最新" withSel:@selector(postlist:)];
    [gridView addCardWithTitle:@"精华" withSel:@selector(postlist:)];
    [gridView addCardWithTitle:@"热门" withSel:@selector(postlist:)];
    [gridView addCardDone];
    //添加阴影线
    UIImageView *lineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _headerView.bottom-3, ScreenWidth, 3)];
    lineView.image = kIMG(@"qiehuanxuanxiang");
    [_headerView addSubview:gridView];
    [_headerView addSubview:lineView];
}
#pragma mark - 置顶和子版块更多按钮
- (UIView *)viewWithAccessoryView{
    UIView *accessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 85, 37)];
    _moreBtn = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(accessoryView.right-10, accessoryView.height/2 - 3, 10, 6)];
        imageView.image = kIMG(@"jiantou_post");
        imageView.highlightedImage = kIMG(@"jiantou_post_up");
        imageView;
    });
    UILabel *moreLabel = [[UILabel alloc]initWithFrame:CGRectMake(_moreBtn.left-27, 0, 27, 37)];
    moreLabel.text = @"更多";
    moreLabel.textColor = UIColorFromRGB(0xa6a6a6);
    moreLabel.font = [UIFont systemFontOfSize:13.0f];
    [accessoryView addSubview:moreLabel];
    [accessoryView addSubview:_moreBtn];
    return accessoryView;
}
#pragma mark - 添加分割线
- (UILabel *)lineViewWithFrame:(CGRect)frame{
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:frame];
    lineLabel.backgroundColor = UIColorFromRGB(0xeeeeee);
    return lineLabel;
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


#pragma mark - dealloc
- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
