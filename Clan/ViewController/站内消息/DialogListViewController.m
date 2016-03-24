//
//  DialogListViewController.m
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "DialogListViewController.h"
#import "DialogListModel.h"
#import "DialogListViewModel.h"
#import "DialogListCell.h"
#import "MeViewController.h"
#import "ChatViewController.h"

@interface DialogListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    DialogListViewModel *_viewmodel;
    DialogListCell *_tempCell;
    NSIndexPath *_tobeReloadPath;
}
@property (nonatomic, assign) BOOL laterDisappear;
@property (nonatomic, assign) BOOL update;
@property (nonatomic, strong)  NSMutableArray *dataSourceArr;
@property (nonatomic, strong)  UIBarButtonItem *cancelButton;
@property (nonatomic, strong)  UIBarButtonItem *deleteButton;
@property (nonatomic, strong)  UIBarButtonItem *backButton;
@property (nonatomic, strong)  UIBarButtonItem *editButton;
@property (nonatomic, weak)  BaseViewController *targetVC;

@end

@implementation DialogListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataSourceArr = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"dialog_list_update" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAutoUpdate) name:@"AUTO_REFRESH_XINXI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"DO_DIALOG_UPDATE" object:nil];
    self.title = @"消息";
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.backgroundColor = kCOLOR_BG_GRAY;
    //计算cell高度用得
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([DialogListCell class]) bundle:nil];
    _tempCell = [nib instantiateWithOwner:nil options:nil][0];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"DialogListCell"];
    self.tableview.allowsMultipleSelectionDuringEditing = YES;
    //请求posts第一页数据
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 70.0;
    [Util setExtraCellLineHidden:self.tableview];
    
    if (!_isRightItemBar) {
        self.backButton = self.navigationItem.leftBarButtonItem;
    }else{
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    }

    self.editButton = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
    self.deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    self.cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    [self addPullRefreshAction];
    [self.tableview beginLoading];
    [self requestData];
    
    
    if (self.tabBarController) {
        self.bottomToSuperView.constant = kTABBAR_HEIGHT;
    }else{
        self.bottomToSuperView.constant = 0;
    }
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_update) {
        [self requestData];
    }
    
    if (_tobeReloadPath) {
        [self.tableview deselectRowAtIndexPath:_tobeReloadPath animated:YES];
        DialogListModel *model = _dataSourceArr[_tobeReloadPath.row];
        model.isnew = @"0";
        [self.tableview reloadRowsAtIndexPaths:@[_tobeReloadPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        _tobeReloadPath = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"DialogListViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableview.delegate = nil;
    self.tableview.dataSource = nil;
    _viewmodel = nil;
}

- (void)doAutoUpdate
{
    if (!self.tableview.header.isRefreshing) {
        //是否正在下拉刷新
        [self.tableview beginRefreshing];
    }
}


#pragma mark - 接收通知
- (void) receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"dialog_list_update"])
    {
        _update = YES;
    }
    else if ([notification.name isEqualToString:@"DO_DIALOG_UPDATE"]) {
        _laterDisappear = YES;
        [self requestData];
    }
}

- (void)buildUI
{
    self.title = @"对话列表";
    
}

- (void)requestData
{
    BOOL islogin = [UserModel currentUserInfo].logined;
    if (!islogin) {
        [self.tableview endHeaderRefreshing];
        [self.tableview hideTableFooter];
        [self goToLoginPage];
        return;
    }
    if (!_viewmodel) {
        _viewmodel = [DialogListViewModel new];
    }
    WEAKSELF
    [_viewmodel requestDialogListWithReturnBlock:^(bool success, id data) {
        STRONGSELF
        if (!strongSelf.laterDisappear) {
            [strongSelf removeTheTip];
        }
        [strongSelf.tableview endLoading];
        [strongSelf.tableview endHeaderRefreshing];
        if (success) {
            strongSelf.update = NO;
            [strongSelf.dataSourceArr removeAllObjects];
            [strongSelf.dataSourceArr addObjectsFromArray:data];
            [strongSelf.tableview reloadData];
        } else {
            if (data && [data isKindOfClass:[NSString class]] && [data isEqualToString:kCookie_expired]) {
                [strongSelf showHudTipStr:data];
                [strongSelf goToLoginPage];
            }
        }
        [strongSelf.view configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataSourceArr.count > 0) hasError:(NO) reloadButtonBlock:^(id sender) {
            [strongSelf requestData];
        }];
        [strongSelf updateButtonsToMatchTableState];
    }];
}

- (void)removeTheTip
{
    //无新消息
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"KNEWS_MESSAGE"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_MESSAGE_COME" object:nil];
}

//上拉下拉刷新
- (void)addPullRefreshAction
{
    WEAKSELF
    [_tableview createHeaderViewBlock:^{
        STRONGSELF;
        [strongSelf requestData];
    }];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DialogListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DialogListCell"];
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
//    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor whiteColor];
//    cell.selectedBackgroundView = view;
    DialogListModel *dialog = _dataSourceArr[indexPath.row];
    cell.dialog = dialog;
    cell.btn_avatar.path = indexPath;
    [cell.btn_avatar addTarget:self action:@selector(avatarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tempCell.dialog = _dataSourceArr[indexPath.row];
    [_tempCell setNeedsLayout];
    CGFloat height = [_tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    //由于分割线，所以contentView的高度要小于row 一个像素。
    return height + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self.view endEditing:YES];
        [self updateButtonsToMatchTableState];
        return;
    } else {
        [self removeTheTip];
    }
    _tobeReloadPath = indexPath;
    ChatViewController *chatVC = [[ChatViewController alloc]initWithNibName:NSStringFromClass([ChatViewController class]) bundle:nil];
    chatVC.hidesBottomBarWhenPushed = YES;
    DialogListModel *model = _dataSourceArr[indexPath.row];
    model.isnew = @"0";
    chatVC.dialogModel = _dataSourceArr[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (tableView.editing) {
        [self updateDeleteButtonTitle];
    }
}

#pragma mark - actions
- (IBAction)avatarBtnAction:(id)sender
{
    YZButton *btn = (YZButton *)sender;
    DialogListModel *dialog = _dataSourceArr[btn.path.row];
    MeViewController *home = [[MeViewController alloc]init];
    home.hidesBottomBarWhenPushed = YES;
    UserModel *user = [UserModel new];
    user.uid = dialog.msgtoid;
    home.user = user;
    [self.navigationController pushViewController:home animated:YES];
}

- (IBAction)editAction:(id)sender
{
    [self.tableview setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancleAction:(id)sender
{
    [self.tableview setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteAction:(id)sender
{
    NSArray *selectedRows = [self.tableview indexPathsForSelectedRows];
    NSString *toBeDeleteString = @"";
    for (int i = 0; i < selectedRows.count; i++) {
        NSIndexPath *path = selectedRows[i];
        DialogListModel *model = _dataSourceArr[path.row];
        NSString *str = model.msgtoid;
        if (i != 0) {
            str = [NSString stringWithFormat:@"_%@",model.msgtoid];
        }
        toBeDeleteString = [toBeDeleteString stringByAppendingString:str];
    }
    WEAKSELF
    [_viewmodel delete_DialogListwithDeletepm_deluid:toBeDeleteString andReturnBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            [strongSelf.dataSourceArr removeObjectsAtIndexes:indicesOfItemsToDelete];
            [strongSelf.tableview deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } ];
    [self.tableview setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableview.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        if (_targetVC) {
            _targetVC.navigationItem.rightBarButtonItem = self.cancelButton;
        }
        
        [self updateDeleteButtonTitle];
        
        // Show the delete button.
        self.navigationItem.leftBarButtonItem = self.deleteButton;
        if (_targetVC) {
            _targetVC.navigationItem.leftBarButtonItem = self.deleteButton;
        }
    }
    else
    {
        self.navigationItem.leftBarButtonItem = self.backButton;
        if (_targetVC) {
            if (self.backButton) {
                if (!_isRightItemBar) {
                    [_targetVC addBackBtn];
                }else{
                    _targetVC.navigationItem.leftBarButtonItem = self.backButton;
                }
            } else {
                if (_isRightItemBar) {
                    _targetVC.navigationItem.leftBarButtonItem = self.backButton;
                }
                _targetVC.navigationItem.leftBarButtonItem = nil;
            }
        }
        if (_dataSourceArr.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
        if (_targetVC) {
            _targetVC.navigationItem.rightBarButtonItem = self.editButton;
        }
    }
}

- (void)updateDeleteButtonTitle
{
    NSArray *selectedRows = [self.tableview indexPathsForSelectedRows];
    if (!selectedRows) {
        self.deleteButton.enabled = NO;
    } else {
        self.deleteButton.enabled = YES;
    }
    if (!selectedRows) {
        self.deleteButton.title = NSLocalizedString(@"删除", @"");
        return;
    }
    BOOL allItemsAreSelected = selectedRows.count == _dataSourceArr.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"删除全部", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"删除(%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

- (void)setupNavigationButtonsForVC:(UIViewController *)vc
{
    _targetVC = vc;
    _targetVC.navigationItem.rightBarButtonItem = _editButton;
    if (!_isRightItemBar) {
        _targetVC.navigationItem.leftBarButtonItem = nil;
    }else{
        _targetVC.navigationItem.leftBarButtonItem = self.backButton;
    }
    [_tableview setEditing:NO];
}

- (void)backView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//=======
//- (void)setupNavigationButtonsForVC:(UIViewController *)vc
//{
//    _targetVC = vc;
//    _targetVC.navigationItem.rightBarButtonItem = _editButton;
//    if (self.tabBarController) {
//        _targetVC.navigationItem.leftBarButtonItem = nil;
//    } else {
//        [_targetVC addBackBtn];
//    }
//    [_tableview setEditing:NO];
//}
//
//>>>>>>> .merge-right.r5261
@end
