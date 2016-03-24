//
//  ClassifiedViewController.m
//  Clan
//
//  Created by 昔米 on 15/5/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ClassifiedViewController.h"
//#import "PostCell.h"
//#import "PostImageCell.h"
//#import "PostNoImageCell.h"
#import "PostModel.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"
#import "PostViewModel.h"
#import "ClanAPostCell.h"
@interface ClassifiedViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSIndexPath *_toBeReload;
}
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) ClanAPostCell *tempCell;
//@property (strong, nonatomic) UITableViewCell *tempNoImageCell;
//@property (strong, nonatomic) UITableViewCell *tempNormalCell;
@property (assign, nonatomic) BOOL isMoreImageType;
@property (strong, nonatomic) PostViewModel *viewmodel;
@property (assign) int page;
@end

@implementation ClassifiedViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_toBeReload) {
        [_tableView reloadRowsAtIndexPaths:@[_toBeReload] withRowAnimation:UITableViewRowAnimationAutomatic];
        _toBeReload = nil;
    }
}

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
    _toBeReload = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DLog(@"ClassifiedViewController dealloc");
}

#pragma mark - 数据源 & 视图
- (void)loadModel
{
    self.listArray = [NSMutableArray new];
    self.isMoreImageType = [[NSUserDefaults standardUserDefaults]boolForKey:KOpen_image_mode];
}

- (void)buildUI
{
    [self initWithTable];
    [self addPullRefreshActionWithDown];
    [_tableView beginRefreshing];
}


- (void)initWithTable
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenBoundsHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.sectionHeaderHeight = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionFooterHeight = 0;
    [Util setExtraCellLineHidden:_tableView];
    [self.view addSubview:_tableView];

//    UINib *cellNib = [UINib nibWithNibName:@"PostImageCell" bundle:nil];
//    [_tableView registerNib:cellNib forCellReuseIdentifier:@"PostImages"];
//    _tempCell  = [_tableView dequeueReusableCellWithIdentifier:@"PostImages"];
//    
//    UINib *tempNoImageCell = [UINib nibWithNibName:@"PostNoImageCell" bundle:nil];
//    [_tableView registerNib:tempNoImageCell forCellReuseIdentifier:@"PostNoImages"];
//    _tempNoImageCell  = [_tableView dequeueReusableCellWithIdentifier:@"PostNoImages"];
    
    [_tableView registerClass:[ClanAPostCell class] forCellReuseIdentifier:@"ClanAPostCell"];

}

//下拉刷新
- (void)addPullRefreshActionWithDown
{
    WEAKSELF
    //下拉刷新
    [_tableView createHeaderViewBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.page = 1;
        [strongSelf requestData];
    }];
}

//上拉加载更多
- (void)addPullRefreshActionWithUp
{
    WEAKSELF
    [_tableView createFooterViewBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.page ++;
        [strongSelf requestData];
    }];
}

- (void)resetFooterForNeedMore:(BOOL)need_more
{
    if (need_more) {
        if (!self.tableView.footer) {
            [self addPullRefreshActionWithUp];
        }
        self.tableView.footer.state = MJRefreshFooterStateIdle;
    } else {
        self.tableView.footer.state = MJRefreshFooterStateNoMoreData;
    }
}

#pragma mark - request data
- (void)requestData
{
    if (!_viewmodel) {
        _viewmodel = [PostViewModel new];
    }
    //请求帖子列表
    WEAKSELF
    [_viewmodel request_classifiedPostsWithFid:_fid andTypeId:_type_id andPage:_page andBlock:^(NSArray *listArray, BOOL isMore) {
        STRONGSELF
        [strongSelf.tableView endHeaderRefreshing];
        if (listArray && listArray.count > 0) {
            if (strongSelf.page == 1) {
                [strongSelf.listArray removeAllObjects];
            }
            [strongSelf.listArray addObjectsFromArray:listArray];
            [strongSelf.tableView reloadData];
        }
        if (!_listArray) {
            --strongSelf.page;
        }
        [strongSelf resetFooterForNeedMore:isMore];
        [strongSelf.view configBlankPage:DataIsNothingWithDefault hasData:strongSelf.listArray.count > 0 hasError:NO reloadButtonBlock:^(id sender) {
            strongSelf.page = 1;
            [strongSelf requestData];
        }];
    }];
}

#pragma mark - tableview Delegate
#pragma mark Table M
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return _lis;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *postcellindentifer = @"APostCell";
    ClanAPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanAPostCell" forIndexPath:indexPath];
    cell.showTopic = NO;
    cell.listable = NO;
    cell.postModel = _listArray[indexPath.row];
    return cell;
}
//{
//    //帖子CELL
//    if (!_isMoreImageType) {
//        static NSString *postCollection = @"Post";
//        PostCell *cell = [tableView dequeueReusableCellWithIdentifier:postCollection];
//        if (cell == nil) {
//            cell = [[[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil] lastObject];
//        }
//        cell.postModel = _listArray[indexPath.section];
//        return cell;
//        
//    }
//    else {
//        PostModel *postModel = _listArray[indexPath.section];
//        if (postModel.attachment_urls.count > 0) {
//            //有图
//            static NSString *postImages = @"PostImages";
//            PostImageCell *cell = [tableView dequeueReusableCellWithIdentifier:postImages];
//            if (cell == nil) {
//                cell = [[[NSBundle mainBundle] loadNibNamed:@"PostImageCell" owner:self options:nil] lastObject];
//            }
//            cell.postModel = postModel;
//            return cell;
//        }else{
//            static NSString *postNoImages = @"PostNoImages";
//            PostNoImageCell *cell = [tableView dequeueReusableCellWithIdentifier:postNoImages];
//            if (cell == nil) {
//                cell = [[[NSBundle mainBundle] loadNibNamed:@"PostNoImageCell" owner:self options:nil] lastObject];
//            }
//            cell.postModel = postModel;
//            return cell;
//        }
//        
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellmodel = _listArray[indexPath.row];
    PostModel *model = cellmodel;
    return model.frame;
}
//{
//    if (!_isMoreImageType) {
//        PostCell *cell = (PostCell *)self.tempNormalCell;
//        cell.postModel = _listArray[indexPath.section];
//        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        return height+1;
//    } else {
//        PostModel *postModel = _listArray[indexPath.section];
//        if (postModel.attachment_urls.count > 0) {
//            PostImageCell *cell = (PostImageCell *)self.tempCell;
//            cell.postModel = postModel;
//            CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//            return height+1;
//        }else{
//            PostNoImageCell *cell = (PostNoImageCell *)self.tempNoImageCell;
//            cell.postModel = postModel;
//            CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//            return height+1;
//        }
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//    detail.postModel =  _listArray[indexPath.row];
//    _toBeReload = indexPath;
//    [Util readPost:detail.postModel.tid];
//    [self.navigationController pushViewController:detail animated:YES];
    PostDetailVC *detail = [[PostDetailVC alloc]init];
    detail.postModel =  _listArray[indexPath.row];
    _toBeReload = indexPath;
    [Util readPost:detail.postModel.tid];
    [self.navigationController pushViewController:detail animated:YES];
}


@end
