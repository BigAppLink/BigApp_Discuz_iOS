//
//  CollectionViewController.m
//  Clan
//
//  Created by chivas on 15/3/16.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewModel.h"
#import "MyPostCollectionCell.h"
#import "CollectionModel.h"
#import "CollectionListModel.h"
#import "BoardCell.h"
#import "ForumsModel.h"
#import "PostViewController.h"
#import "PostDetailViewController.h"
#import "PostDetailVC.h"
#import "PostModel.h"
#import "ArticleDetailViewController.h"
#import "ArticleListModel.h"

@interface CollectionViewController ()
{
    MyPostCollectionCell *_tempCell;
    BoardCell *_tempBoardCell;
}
//@property (assign) int currentPage;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) CollectionViewModel *collcetion;

@property (nonatomic, strong)  UIBarButtonItem *cancelButton;
@property (nonatomic, strong)  UIBarButtonItem *deleteButton;
@property (nonatomic, strong)  UIBarButtonItem *backButton;
@property (nonatomic, strong)  UIBarButtonItem *editButton;
@property (nonatomic, assign)  int currentPage;

@end

@implementation CollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_dataArray.count <= 0) {
        [_tableView hideTableFooter];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.frame = CGRectMake(0, 44, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-44);
    self.tableView.frame = CGRectMake(0, 0, kSCREEN_WIDTH,kSCREEN_HEIGHT-64-44);
    [self.tableView configBlankPage:DataIsNothingWithDefault hasData:(self.dataArray.count > 0) hasError:(NO) reloadButtonBlock:^(id sender) {
        [self requestDataWithPage:_currentPage];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _isMyPost = YES;
    [self initNavi];
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    self.dataArray = [NSMutableArray new];
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-44) style:UITableViewStyleGrouped];
    table.allowsMultipleSelectionDuringEditing = YES;
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = kCOLOR_BG_GRAY;
    table.separatorColor = kCOLOR_BORDER;
    if (kIOS8) {
        table.rowHeight = UITableViewAutomaticDimension;
        table.estimatedRowHeight = 70.0;
    }
    _tableView = table;
    [self.view addSubview:table];
    
    
    //计算cell高度用得
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([MyPostCollectionCell class]) bundle:nil];
    _tempCell = [nib instantiateWithOwner:nil options:nil][0];
    [table registerNib:nib forCellReuseIdentifier:@"postCollection"];
    
    UINib *nib_reply = [UINib nibWithNibName:NSStringFromClass([BoardCell class]) bundle:nil];
    _tempBoardCell = [nib_reply instantiateWithOwner:nil options:nil][0];
    [table registerNib:nib_reply forCellReuseIdentifier:@"boardCollection"];
    [self addPullRefreshAction];
}

- (void)notificationCome:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"POSTFAVO_UPDATE"]) {
        //要更新数据哦
        _currentPage = 1;
        [self requestDataWithPage:_currentPage];
    }
    else if ([noti.name isEqualToString:@"PLATEFAVO_UPDATE"]) {
        //要更新数据哦
        _currentPage = 1;
        [self requestDataWithPage:_currentPage];
    }
}

#pragma mark - dealloc
- (void)dealloc
{
    _collcetion = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _target = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"❤️ CollectionViewController dealooc");
}

//上拉下拉刷新
- (void)addPullRefreshAction
{
    //下拉刷新
    WEAKSELF
    [_tableView createHeaderViewBlock:^{
        STRONGSELF
        strongSelf.currentPage = 0;
        [strongSelf.tableView hideTableFooter];
        [strongSelf requestDataWithPage:++strongSelf.currentPage];
    }];
    
    //加载更多
    [_tableView createFooterViewBlock:^{
        STRONGSELF
        [strongSelf requestDataWithPage:++strongSelf.currentPage];
    }];
}

//TODO 请求数据
- (void)requestDataWithPage:(int)page
{
    UserModel *_cuser = [UserModel currentUserInfo];
    if (!_cuser || !_cuser.logined) {
        [self.tableView endHeaderRefreshing];
        [self.tableView hideTableFooter];
        [self goToLoginPage];
        [self setUpNavi];
        return;
    }
    //若没有数据，隐藏掉footer
    if (_dataArray.count == 0) {
        [_tableView hideTableFooter];
    }
    if (!_collcetion) {
        _collcetion = [CollectionViewModel new];
    }
    WEAKSELF
    if (_collcetionType == myPost) {
        [_collcetion request_MyCollection:myPost antPage:[NSNumber numberWithInt:page] andBlock:^(id data, BOOL need_more) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.tableView endHeaderRefreshing];
            if ([data isKindOfClass:[NSString class]]) {
                [strongSelf showHudTipStr:data];
                [self.tableView hideTableFooter];
                [strongSelf goToLoginPage];
                return;
            }
            NSMutableArray *arr = (NSMutableArray *)[(CollectionModel *)data list];
            if (page == 1) {
                [strongSelf.dataArray removeAllObjects];
            }
            if (!need_more) {
                [strongSelf.tableView hideTableFooter];
            } else {
                [strongSelf.tableView resetFooterState:MJRefreshFooterStateIdle];
            }
            [strongSelf.dataArray addObjectsFromArray:arr];
            [strongSelf.tableView reloadData];
            [strongSelf updateButtonsToMatchTableState];
            if (strongSelf.dataArray.count == 0) {
                [strongSelf.tableView hideTableFooter];
            }
            [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data) reloadButtonBlock:^(id sender) {
                [strongSelf requestDataWithPage:strongSelf.currentPage];
            }];
            [strongSelf setUpNavi];
        }];
    }
    else if (_collcetionType == myPlate){
        [_collcetion request_MyCollection:myPlate antPage:[NSNumber numberWithInt:page] andBlock:^(id data, BOOL need_more) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.tableView endHeaderRefreshing];
            if ([data isKindOfClass:[NSString class]]) {
                [strongSelf showHudTipStr:data];
                [strongSelf goToLoginPage];
                return;
            }
            NSArray *arr = (NSArray *)data;
            if (page == 1) {
                [strongSelf.dataArray removeAllObjects];
            }
            if (!need_more) {
                [strongSelf.tableView removeFooter];
            } else {
                [strongSelf.tableView resetFooterState:MJRefreshFooterStateIdle];
            }
            [strongSelf.dataArray addObjectsFromArray:arr];
            [strongSelf.tableView reloadData];
            [strongSelf updateButtonsToMatchTableState];
            if (strongSelf.dataArray.count == 0) {
                [strongSelf.tableView hideTableFooter];
            }
            [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data) reloadButtonBlock:^(id sender) {
                [strongSelf requestDataWithPage:strongSelf.currentPage];
            }];
            [strongSelf setUpNavi];
        } ];
    }
    else {
        [_collcetion request_MyCollection:myArticle antPage:[NSNumber numberWithInt:page] andBlock:^(id data, BOOL need_more) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.tableView endHeaderRefreshing];
            if ([data isKindOfClass:[NSString class]]) {
                [strongSelf showHudTipStr:data];
                [strongSelf.tableView hideTableFooter];
                [strongSelf goToLoginPage];
                return;
            }
            NSMutableArray *arr = (NSMutableArray *)[(CollectionModel *)data list];
            if (page == 1) {
                [strongSelf.dataArray removeAllObjects];
            }
            if (!need_more) {
                [strongSelf.tableView hideTableFooter];
            } else {
                [strongSelf.tableView resetFooterState:MJRefreshFooterStateIdle];
            }
            [strongSelf.dataArray addObjectsFromArray:arr];
            [strongSelf.tableView reloadData];
            [strongSelf updateButtonsToMatchTableState];
            if (strongSelf.dataArray.count == 0) {
                [strongSelf.tableView hideTableFooter];
            }
            [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data) reloadButtonBlock:^(id sender) {
                [strongSelf requestDataWithPage:strongSelf.currentPage];
            }];
            [strongSelf setUpNavi];
        } ];
    }
}


- (void)setCollcetionType:(CollcetionType)collcetionType
{
    _collcetionType = collcetionType;
    if (_collcetionType == myPost) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"POSTFAVO_UPDATE" object:nil];
    }
    else if (_collcetionType == myPlate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"PLATEFAVO_UPDATE" object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"ARTICLEFAVO_UPDATE" object:nil];
    }
    [self requestDataWithPage:++_currentPage];
}

- (void)editTable
{
    [_tableView setEditing:YES animated:YES];
}
- (void)doneTable
{
    [_tableView setEditing:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_collcetionType == myPost || _collcetionType == myArticle) {
        //我的帖子收藏
        static NSString *postCollection = @"postCollection";
        MyPostCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:postCollection];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyPostCollectionCell" owner:self options:nil] lastObject];
        }
        [cell setModel:_dataArray[indexPath.row]];
        return cell;
    }
    else if (_collcetionType == myPlate) {
        static NSString *boardCollection = @"boardCollection";
        BoardCell *cell = [tableView dequeueReusableCellWithIdentifier:boardCollection];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BoardCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"jiantou_me")];
        cell.forumsModel = _dataArray[indexPath.row];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_collcetionType == myPlate) {
        return 80.f;
    }
//    if (kIOS8) {
//        return UITableViewAutomaticDimension;
//    }
    else {
        if (_collcetionType == myPost || _collcetionType == myArticle)
        {
            [_tempCell setModel:_dataArray[indexPath.row]];
            [_tempCell setNeedsLayout];
            CGFloat height = [_tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            //由于分割线，所以contentView的高度要小于row 一个像素。
            return height + 1;
        }
        _tempBoardCell.forumsModel = _dataArray[indexPath.row];
        [_tempBoardCell setNeedsLayout];
        CGFloat height = [_tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //由于分割线，所以contentView的高度要小于row 一个像素。
        return height + 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self updateButtonsToMatchTableState];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_collcetionType == myPlate) {
        PostViewController *postVc = [[PostViewController alloc]init];
        postVc.forumsModel = _dataArray[indexPath.row];
        [self.navigationController pushViewController:postVc animated:YES];
    }
    else if(_collcetionType == myPost) {
//        PostDetailViewController *detail = [[PostDetailViewController alloc]init];
//        CollectionListModel *model = _dataArray[indexPath.row];
//        PostModel *post = [PostModel new];
//        post.tid = model.fid;
//        detail.postModel = post;
//        [self.navigationController pushViewController:detail animated:YES];
        
        PostDetailVC *detail = [[PostDetailVC alloc]init];
        CollectionListModel *model = _dataArray[indexPath.row];
        PostModel *post = [PostModel new];
        post.tid = model.fid;
        detail.postModel = post;
        [self.navigationController pushViewController:detail animated:YES];
    }
    else {
//        CollectionListModel *model = _dataArray[indexPath.row];
//        PostDetailVC *detail = [[PostDetailVC alloc]init];
//        detail.isArticle = YES;
//        PostModel *postModel = [PostModel new];
//        postModel.tid = model.fid;
//        detail.postModel =  postModel;
//        detail.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:detail animated:YES];
        ArticleDetailViewController *articleDetail = [[ArticleDetailViewController alloc]init];
        CollectionListModel *model = _dataArray[indexPath.row];
        PostModel *post = [PostModel new];
        post.tid = model.fid;
        ArticleListModel *articleModel = [ArticleListModel new];
        articleModel.aid = model.fid;
        articleModel.favid = model.favid;
        articleModel.title = model.title;
        articleDetail.articleModel = articleModel;
        [self.navigationController pushViewController:articleDetail animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing)
        [self updateDeleteButtonTitle];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1f;
}
#pragma mark - 设置导航
- (void)initNavi
{
    UIViewController *vc = (UIViewController *)self.target;
    self.backButton = vc.navigationItem.leftBarButtonItem;
    self.editButton = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
    self.deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    self.cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction:)];
}

//重置导航
- (void)setUpNavi
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_FAVOTYPE"];
    CollcetionType selectedType = num.intValue;
    if ((selectedType == myPlate && _collcetionType == myPlate)
        ||(selectedType == myPost && _collcetionType == myPost)
        ||(selectedType == myArticle && _collcetionType == myArticle)) {
        DLog(@"执行更新");
        UIViewController *vc = (UIViewController *)self.target;
        vc.navigationItem.rightBarButtonItem = self.editButton;
        vc.navigationItem.leftBarButtonItem = self.backButton;
        [self.tableView setEditing:NO animated:NO];
        [self updateButtonsToMatchTableState];
    } else {
        DLog(@"未执行更新");
    }
}


#pragma mark - Action 事件


- (IBAction)editAction:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancleAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteAction:(id)sender
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSString *toBeDeleteString = @"";
    NSString *type = @"";
    for (int i = 0; i < selectedRows.count; i++) {
        NSIndexPath *path = selectedRows[i];
        NSString *str = [_dataArray[path.row] favid];
        if (i != 0) {
            str = [NSString stringWithFormat:@"_%@",[_dataArray[path.row] favid]];
        }
        toBeDeleteString = [toBeDeleteString stringByAppendingString:str];
        type = [_dataArray[path.row] idtype];
    }
    
    WEAKSELF
    [_collcetion request_DeleteCollection:toBeDeleteString andType:type andBlock:^(BOOL state) {
        STRONGSELF
        if (state) {
            //清除local
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                NSString *fid = [_dataArray[selectionIndex.row] fid];
                CollcetionType coltype = myPost;
                if ([@"tid" isEqualToString:type]) {
                    coltype = myPost;
                }
                else if ([@"aid" isEqualToString:type]) {
                    coltype = myArticle;
                }
                else {
                    coltype = myPlate;
                }
                [Util deleteFavoed_withID:fid forType:coltype];
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            [strongSelf.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            [strongSelf.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        [strongSelf.tableView setEditing:NO animated:YES];
        [strongSelf updateButtonsToMatchTableState];
    }];
}


- (void)updateButtonsToMatchTableState
{
//    BOOL isSelectedPlate = [[NSUserDefaults standardUserDefaults] boolForKey:@"S_FAVOTYPE_PLATE"];
//    if ((isSelectedPlate && _collcetionType == myPlate)||(!isSelectedPlate && _collcetionType == myPost))
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_FAVOTYPE"];
    CollcetionType selectedType = num.intValue;
    if ((selectedType == myPlate && _collcetionType == myPlate)
        ||(selectedType == myPost && _collcetionType == myPost)
        ||(selectedType == myArticle && _collcetionType == myArticle))
    {
        UIViewController *vc = (UIViewController *)self.target;
        if (self.tableView.editing)
        {
            // Show the option to cancel the edit.
            vc.navigationItem.rightBarButtonItem = self.cancelButton;
            
            [self updateDeleteButtonTitle];
            
            // Show the delete button.
            vc.navigationItem.leftBarButtonItem = self.deleteButton;
        }
        else
        {
            vc.navigationItem.leftBarButtonItem = self.backButton;
            self.editButton.enabled = (!_dataArray || _dataArray.count ==0) ? NO : YES;
            vc.navigationItem.rightBarButtonItem = self.editButton;
        }
    }
}

- (void)updateDeleteButtonTitle
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if (!selectedRows) {
        self.deleteButton.enabled = NO;
    } else {
        self.deleteButton.enabled = YES;
    }
    if (!selectedRows) {
        self.deleteButton.title = NSLocalizedString(@"删除", @"");
        return;
    }
    BOOL allItemsAreSelected = selectedRows.count == _dataArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"删除全部", @"");
    }
    else
    {
        NSString *titleFormatString = NSLocalizedString(@"删除 (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}


@end
