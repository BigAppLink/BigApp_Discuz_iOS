//
//  MyPostViewController.m
//  Clan
//
//  Created by 昔米 on 15/4/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "MyPostViewController.h"
#import "YZCardView.h"
#import "MyPostViewModel.h"
#import "MyPostsCell.h"
#import "MyReplyCell.h"
#import "PostModel.h"
#import "MJRefresh.h"
#import "BaseTableView.h"
#import "ReplyModel.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"

@interface MyPostViewController () <UITableViewDelegate, UITableViewDataSource>
{
    MyPostsCell *_tempPostCell;
    MyReplyCell *_tempReplyCell;
    MyPostViewModel *_viewmodel;
    YZCardView *_card;
    NSArray *_cardTitle;
}

@property (assign) int currentPostPage;
@property (assign) int currentReplyPage;
@property (assign) BOOL isReplyView;
@property (assign) BOOL isReplyRequestCompleted;;
@property (strong, nonatomic) BaseTableView *maintable;
@property (strong, nonatomic) NSMutableArray *postsArr;
@property (strong, nonatomic) NSMutableArray *replysArr;
@property (assign) MJRefreshFooterState postFootState;
@property (assign) MJRefreshFooterState replyFootState;
@property (assign) BOOL isSelf;


@end

@implementation MyPostViewController

#pragma mark - 生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initModel];
    [self buildUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DLog(@"MypostVC dealloc");
    _viewmodel = nil;
    _maintable.delegate = nil;
    _maintable.dataSource = nil;
}

#pragma mark - 初始化

- (void)initModel
{
    _replyFootState = MJRefreshFooterStateIdle;
    _postFootState = MJRefreshFooterStateIdle;
    _replysArr = [NSMutableArray array];
    _postsArr = [NSMutableArray array];
}

- (void)buildUI
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    //插片
    YZCardView *carda = [[YZCardView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 44)];
    carda.target = self;
    if (!_cardTitle) {
        _cardTitle = @[@"我的主帖", @"我的回帖"];
    }
    [carda addCardWithTitle:_cardTitle[0] withSel:@selector(myPostsAction)];
    [carda addCardWithTitle:_cardTitle[1] withSel:@selector(myReplysAction)];
    _card = carda;
    [self.view addSubview:carda];
    
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, kVIEW_BY(carda)+1, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-kVIEW_H(carda)) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = kCOLOR_BG_GRAY;
    table.separatorColor = kCLEARCOLOR;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (kIOS8) {
        table.rowHeight = UITableViewAutomaticDimension;
        table.estimatedRowHeight = 70.0;
    }
    table.sectionFooterHeight = 0;
    _maintable = table;
    [self addPullRefreshAction];
    [self.view addSubview:table];
    
    //计算cell高度用得
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([MyPostsCell class]) bundle:nil];
    _tempPostCell = [nib instantiateWithOwner:nil options:nil][0];
    [table registerNib:nib forCellReuseIdentifier:@"PostCell1"];
    UINib *nib_reply = [UINib nibWithNibName:NSStringFromClass([MyReplyCell class]) bundle:nil];
    _tempReplyCell = [nib_reply instantiateWithOwner:nil options:nil][0];
    [table registerNib:nib_reply forCellReuseIdentifier:@"MyReplyCell"];
    if (_selectedIndex) {
        [_card changeSelectBtn:_selectedIndex];
    }
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    UserModel *_cUser = [UserModel currentUserInfo];
    if ([_userId isEqualToString:_cUser.uid]) {
        self.title = @"我的帖子";
        _cardTitle = @[@"我的主帖", @"我的回帖"];
        _isSelf = YES;
    } else {
        self.title = @"TA的帖子";
        _cardTitle = @[@"TA的主帖",@"TA的回帖"];
        _isSelf = NO;
    }
    //请求posts第一页数据
    [self requestDataWithPage:++_currentPostPage];}

#pragma mark - 请求刷新数据
//请求数据
- (void)requestDataWithPage:(int)page
{
    BOOL islogin = [UserModel currentUserInfo].logined;
    if (!islogin) {
        [self.maintable endHeaderRefreshing];
        [self.maintable hideTableFooter];
        [self goToLoginPage];
        return;
    }
    if (!_viewmodel) {
        _viewmodel = [MyPostViewModel new];
    }
    WEAKSELF
    if (!_isReplyView)
    {
        [_viewmodel requestPostsForPage:[NSNumber numberWithInt:page] withUserID:_userId
                           andReturnBlock:^(bool success, id data) {
                               STRONGSELF
                               [strongSelf.maintable endHeaderRefreshing];
                               if (success) {
                                   NSArray *arr = (NSArray *)data;
                                   if (page == 1) {
                                       [strongSelf.postsArr removeAllObjects];
                                   }
                                   [weakSelf.postsArr addObjectsFromArray:arr];
                                   if (!strongSelf.isReplyView) {
                                       [strongSelf.maintable reloadData];
                                   }
                                   strongSelf.postFootState = arr.count < 20 ? MJRefreshFooterStateNoMoreData : MJRefreshFooterStateIdle;
                                   [strongSelf resetFooterState];
                               } else {
                                   if (strongSelf.postsArr.count == 0 && !strongSelf.isReplyView) {
                                       [strongSelf.maintable hideTableFooter];
                                   }
                                   if (data && [data isEqualToString:kCookie_expired]) {
                                       [strongSelf resetUI];
                                       [strongSelf goToLoginPage];
                                       return ;
                                   }
                               }
                               if (!strongSelf.isReplyView) {
                                   [strongSelf resetUI];
                               }
                           } ];
    }
    else {
        [_viewmodel requestReplysForPage:[NSNumber numberWithInt:page] withUserID:_userId
                            andReturnBlock:^(bool success, id data) {
                                STRONGSELF
                                [strongSelf.maintable endHeaderRefreshing];
                                if (success) {
                                    weakSelf.isReplyRequestCompleted = YES;
                                    NSArray *arr = (NSArray *)data;
                                    if (page == 1) {
                                        [strongSelf.replysArr removeAllObjects];
                                    }
                                    [weakSelf.replysArr addObjectsFromArray:arr];
                                    if (strongSelf.isReplyView) {
                                        [strongSelf.maintable reloadData];
                                    }
                                    strongSelf.replyFootState = arr.count < 20 ? MJRefreshFooterStateNoMoreData : MJRefreshFooterStateIdle;
                                    [strongSelf resetFooterState];
                                    
                                } else {
                                    if (strongSelf.replysArr.count == 0 && strongSelf.isReplyView) {
                                        [strongSelf.maintable hideTableFooter];
                                    }
                                    if (strongSelf.isSelf && data && [data isEqualToString:kCookie_expired]) {
                                        [strongSelf resetUI];
                                        [strongSelf goToLoginPage];
                                        return ;
                                    }
                                }
                                
                                if (strongSelf.isReplyView) {
                                    [strongSelf resetUI];
                                }
                            }];
    }
}

- (void)resetUI
{
    if (_isReplyView) {
        [self.view configBlankPage:DataIsNothingWithDefault hasData:(self.replysArr.count > 0) hasError:(NO) reloadButtonBlock:^(id sender) {
            [self requestDataWithPage:_currentReplyPage];
        }];
    }
    else {
        [self.view configBlankPage:DataIsNothingWithDefault hasData:(self.postsArr.count > 0) hasError:(NO) reloadButtonBlock:^(id sender) {
            [self requestDataWithPage:_currentPostPage];
        }];
    }
}

//重置table footer的状态
- (void)resetFooterState
{
    [self performSelector:@selector(resetfooter) withObject:nil afterDelay:0.2];
}

- (void)resetfooter
{
    if (!_maintable.footer) {
        [self addFooter];
    }
    if (!_isReplyView) {
        if (_postFootState == MJRefreshFooterStateNoMoreData) {
            [_maintable hideTableFooter];
        } else {
            [_maintable showTableFooter];
            [_maintable resetFooterState:_postFootState];
        }
    }
    else {
        if (_replyFootState == MJRefreshFooterStateNoMoreData) {
            [_maintable hideTableFooter];
        }else {
            [_maintable showTableFooter];
            [_maintable resetFooterState:_replyFootState];
        }
    }
}

//上拉下拉刷新
- (void)addPullRefreshAction
{
    WEAKSELF
    [_maintable createHeaderViewBlock:^{
        STRONGSELF;
        [strongSelf resetState];
        [strongSelf resetFooterState];
        [strongSelf requestDataWithPage:weakSelf.isReplyView ? ++weakSelf.currentReplyPage : ++weakSelf.currentPostPage];
    }];
}

- (void)addFooter
{
    WEAKSELF
    [_maintable createFooterViewBlock:^{
        STRONGSELF;
        [strongSelf requestDataWithPage:weakSelf.isReplyView ? ++weakSelf.currentReplyPage : ++weakSelf.currentPostPage];
    }];
}

- (void)resetState
{
    if (_isReplyView) {
        _currentReplyPage = 0;
        _replyFootState = MJRefreshFooterStateIdle;
    } else {
        _currentPostPage = 0;
        _postFootState = MJRefreshFooterStateIdle;
    }
}


#pragma mark - actions
//切换到“我的主帖”
- (void)myPostsAction
{
    [_maintable hideTableFooter];
    [self.view configBlankPage:DataIsNothingWithDefault hasData:YES hasError:(NO) reloadButtonBlock:^(id sender) {
    }];
    _isReplyView = NO;
    [_maintable reloadData];
    [self resetFooterState];
    if (_postsArr.count == 0) {
        [_maintable hideTableFooter];
    }
    [self resetUI];
}

//切换到“我的回帖”
- (void)myReplysAction
{
    [_maintable hideTableFooter];
    [self.view configBlankPage:DataIsNothingWithDefault hasData:YES hasError:(NO) reloadButtonBlock:^(id sender) {
    }];
    _isReplyView = YES;
    [_maintable reloadData];
    if (_replysArr.count == 0) {
        [_maintable hideTableFooter];
    } else {
        [self resetFooterState];
    }
    if (_isReplyRequestCompleted) {
        [self resetUI];
    } else {
        if (_replysArr.count == 0 && !_isReplyRequestCompleted) {
            [_maintable performSelector:@selector(beginRefreshing) withObject:nil afterDelay:.3];
        }
    }
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isReplyView ? _replysArr.count : _postsArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isReplyView) {
        MyReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyReplyCell"];
        cell.backgroundColor = [UIColor whiteColor];
        ReplyModel *reply = _replysArr[indexPath.section];
        cell.model = reply;
        return cell;
    }
    MyPostsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell1"];
    cell.backgroundColor = [UIColor whiteColor];
    PostModel *post = _postsArr[indexPath.section];
    cell.post = post;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kIOS8) {
        return UITableViewAutomaticDimension;
    }
    else {
        if (_isReplyView) {
            _tempReplyCell.model = _replysArr[indexPath.section];
            CGFloat height = [_tempReplyCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            //由于分割线，所以contentView的高度要小于row 一个像素。
            return height + 1;

        }
        _tempPostCell.post = _postsArr[indexPath.section];
        CGFloat height = [_tempPostCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //由于分割线，所以contentView的高度要小于row 一个像素。
        return height + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_isReplyView) {
//        PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//        detail.postModel =  _postsArr[indexPath.section];
//        [self.navigationController pushViewController:detail animated:YES];
        
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        detail.postModel =  _postsArr[indexPath.section];
        [self.navigationController pushViewController:detail animated:YES];
        
    } else {
        
//        PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//        PostModel *post = [PostModel new];
//        PostModel *sModel =  _replysArr[indexPath.section];
//        post.tid = sModel.tid;
//        detail.postModel = post;
//        [self.navigationController pushViewController:detail animated:YES];
        
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        PostModel *post = [PostModel new];
        PostModel *sModel =  _replysArr[indexPath.section];
        post.tid = sModel.tid;
        detail.postModel = post;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

@end
