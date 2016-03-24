//
//  MessageVC.m
//  Clan
//
//  Created by 昔米 on 15/12/10.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "MessageVC.h"
#import "DialogListModel.h"
#import "DialogListViewModel.h"
#import "MeViewController.h"
#import "ChatViewController.h"

@interface MessageVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BaseTableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *btn_tiezi;
@property (strong, nonatomic) UIButton *btn_tanyou;
@property (strong, nonatomic) UIButton *btn_xitong;
@property (strong, nonatomic) UIButton *btn_gonggong;

@property (nonatomic, strong)  UIBarButtonItem *cancelButton;
@property (nonatomic, strong)  UIBarButtonItem *deleteButton;
@property (nonatomic, strong)  UIBarButtonItem *backButton;
@property (nonatomic, strong)  UIBarButtonItem *editButton;

@property (strong, nonatomic) DialogListViewModel *viewmodel;


@end

@implementation MessageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadModel];
    [self buildUI];
    [self requestData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _tableview.delegate = nil;
    _tableview.dataSource = nil;
    _viewmodel = nil;
}

#pragma mark - 初始化
- (void)loadModel
{
    
}

- (void)buildUI
{
    self.title = @"消息提醒";
    [self setUpNaviButtons];
    BaseTableView *table = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    if (_fromTabbar) {
        table.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-kTABBAR_HEIGHT);
    }
    table.separatorColor = kfsc_table_border;
    table.backgroundColor = kCOLOR_BG_GRAY;
    table.delegate = self;
    table.dataSource = self;
    table.allowsMultipleSelectionDuringEditing = YES;
    [Util setExtraCellLineHidden:table];
    self.tableview = table;
    [self.view addSubview:table];
    [self buildUpTopView];
}

//导航栏按钮
- (void)setUpNaviButtons
{
    if (!_fromTabbar) {
        UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.backButton = itemBtn;
        self.navigationItem.leftBarButtonItem = itemBtn;
    }
    self.editButton = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
    self.deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    self.cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}

//顶部view
- (void)buildUpTopView
{
    UIView *topview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 120)];
    topview.backgroundColor = [UIColor whiteColor];
    self.topView = topview;
    
    //添加按钮 我的帖子 坛友互动 系统提醒 公共消息
    float btnWidth = 43.f;
    float btnHeigh = btnWidth;
    float space_h = 16.f;
    float space_v = 21.f;
    float valibleWidth = kSCREEN_WIDTH-2*space_h;
    float btnTempSpace = (valibleWidth-4*btnWidth)/3.0;
    //计算起始坐标 使其保持居中
    float btnSpace = btnTempSpace > 50 ? 50 : btnTempSpace;
    float space_h_final = btnTempSpace > 50 ? (kSCREEN_WIDTH-4*btnWidth-3*50)/2.0 : space_h;

    //帖子消息
    UIButton *btn_tiezi = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_tiezi setImage:kIMG(@"message_tiezi") forState:UIControlStateNormal];
    btn_tiezi.frame = CGRectMake(space_h_final, space_v, btnWidth, btnHeigh);
    btn_tiezi.exclusiveTouch = YES;
    [btn_tiezi addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    btn_tiezi.tag = 1;
    self.btn_tiezi = btn_tiezi;
    [self resetButtonTitlePos:btn_tiezi WithTitle:@"帖子消息"];
    [topview addSubview:btn_tiezi];
    
    //坛友互动
    UIButton *btn_tanyou = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_tanyou setImage:kIMG(@"message_tanyou") forState:UIControlStateNormal];
    btn_tanyou.frame = CGRectMake(kVIEW_BX(btn_tiezi)+btnSpace, kVIEW_TY(btn_tiezi), btnWidth, btnHeigh);
    btn_tanyou.exclusiveTouch = YES;
    btn_tanyou.tag = 2;
    [btn_tanyou addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_tanyou = btn_tanyou;
    [self resetButtonTitlePos:btn_tanyou WithTitle:@"坛友互动"];
    [topview addSubview:btn_tanyou];
    
    //系统提醒
    UIButton *btn_xitong = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_xitong setImage:kIMG(@"message_xitong") forState:UIControlStateNormal];
    btn_xitong.frame = CGRectMake(kVIEW_BX(btn_tanyou)+btnSpace, kVIEW_TY(btn_tiezi), btnWidth, btnHeigh);
    btn_xitong.exclusiveTouch = YES;
    [btn_xitong addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self resetButtonTitlePos:btn_xitong WithTitle:@"系统提醒"];
    btn_xitong.tag = 3;
    self.btn_xitong = btn_xitong;
    [topview addSubview:btn_xitong];
    
    //公共消息
    UIButton *btn_gonggong = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_gonggong setImage:kIMG(@"message_gonggong") forState:UIControlStateNormal];
    btn_gonggong.frame = CGRectMake(kVIEW_BX(btn_xitong)+btnSpace, kVIEW_TY(btn_tiezi), btnWidth, btnHeigh);
    btn_gonggong.exclusiveTouch = YES;
    btn_gonggong.tag = 4;
    [btn_gonggong addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_gonggong = btn_gonggong;
    [self resetButtonTitlePos:btn_gonggong WithTitle:@"公共消息"];
    [topview addSubview:btn_gonggong];
}


#pragma mark - 请求数据
- (void)requestData
{
    if (![UserModel currentUserInfo].logined) {
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
        [strongSelf.tableview endLoading];
        [strongSelf.tableview endHeaderRefreshing];
        if (success) {
            strongSelf.dataSourceArr = [NSMutableArray arrayWithArray:data];
            [strongSelf.tableview reloadData];
        } else {
            if (data && [data isKindOfClass:[NSString class]] && [data isEqualToString:kCookie_expired]) {
                [strongSelf showHudTipStr:data];
                [strongSelf goToLoginPage];
            }
        }
    }];
}


#pragma mark - 自定义 methods
//调整按钮title的位置
- (void)resetButtonTitlePos:(UIButton *)button WithTitle:(NSString *)title
{
    if (button) {
        UIButton *btn_title = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_title.frame = CGRectMake(0, 0, 60, 30);
        [btn_title.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [btn_title setTitleColor:kColorWithRGB(102, 102, 102, 1) forState:UIControlStateNormal];
        [btn_title setTitle:title forState:UIControlStateNormal];
        btn_title.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        btn_title.center = CGPointMake(kVIEW_CENTERX(button), kVIEW_BY(button)+15);
        btn_title.tag = 1000+button.tag;
        [_topView addSubview:btn_title];
    }
}

//更新导航的按钮状态
- (void)updateButtonsToMatchTableState
{
    if (self.tableview.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        [self updateDeleteButtonTitle];
        // Show the delete button.
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = self.backButton;
        if (_dataSourceArr.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

//选中的时候 更新删除按钮状态
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
        NSString *titleFormatString = NSLocalizedString(@"删除(%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark - Action methods
//添加按钮 我的帖子 坛友互动 系统提醒 公共消息
- (IBAction)topButtonClick:(id)sender
{
    if (sender) {
        if (sender == _btn_tiezi || [sender tag] == 1001) {
            //帖子消息
            
        }
        else if (sender == _btn_tanyou || [sender tag] == 1002) {
            //坛友互动
            
        }
        else if (sender == _btn_tanyou || [sender tag] == 1003) {
            //系统提醒
            
        }
        else if (sender == _btn_gonggong || [sender tag] == 1004) {
            //公共消息
            
        }
    }
}

//点击返回按钮
- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

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

#pragma mark - tableview DataSource & delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120+15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewww = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 120+15)];
    viewww.backgroundColor = kCOLOR_BG_GRAY;
    [viewww addSubview:_topView];
    UIImageView *iv_sper = [[UIImageView alloc]initWithFrame:CGRectMake(0, kVIEW_BY(_topView), kSCREEN_WIDTH, 0.5)];
    [viewww addSubview:iv_sper];
    return viewww;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *dialogCell = @"dialogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dialogCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dialogCell];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        UIView *seview = [UIView new];
        seview.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = seview;
        //头像
        UIImageView *iv_avatar = [[UIImageView alloc]initWithFrame:CGRectMake(16, 14, 42, 42)];
        iv_avatar.contentMode = UIViewContentModeScaleAspectFit;
        iv_avatar.clipsToBounds = YES;
        iv_avatar.image = kIMG(@"portrait");
        iv_avatar.tag = 10;
        [cell.contentView addSubview:iv_avatar];
        
        //覆盖头像上面的圆形透明
        UIImageView *iv_covered = [[UIImageView alloc]initWithFrame:iv_avatar.frame];
        iv_covered.image = [Util circleCoveredImage];
        iv_covered.contentMode = UIViewContentModeScaleAspectFill;
        iv_covered.clipsToBounds = YES;
        [cell.contentView addSubview:iv_covered];
        
        //用户名
        UILabel *lbl_name = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_BX(iv_covered)+10, kVIEW_TY(iv_covered), (kSCREEN_WIDTH-32-42-10)-100, 20)];
        lbl_name.textColor = [UIColor darkTextColor];
        lbl_name.font = [UIFont systemFontOfSize:14.f];
        lbl_name.tag = 11;
        [cell.contentView addSubview:lbl_name];
        
        //日期
        UILabel *lbl_date = [[UILabel alloc]initWithFrame:CGRectMake(kSCREEN_WIDTH-100-16, kVIEW_TY(iv_covered), 100, 20)];
        lbl_date.textColor = kColourWithRGB(153, 153, 153);
        lbl_date.textAlignment = NSTextAlignmentRight;
        lbl_date.font = [UIFont systemFontOfSize:10.f];
        lbl_date.tag = 12;
        [cell.contentView addSubview:lbl_date];
        
        //内容
        UILabel *lbl_content = [[UILabel alloc]initWithFrame:CGRectMake(kVIEW_TX(lbl_name), kVIEW_CENTERY(iv_covered), kSCREEN_WIDTH-32-10-42, 20)];
        lbl_content.textColor = kColourWithRGB(153, 153, 153);
        lbl_content.font = [UIFont systemFontOfSize:14.f];
        lbl_content.tag = 13;
        [cell.contentView addSubview:lbl_content];
    }
    UIImageView *iv_avatar = [cell.contentView viewWithTag:10];
    UILabel *lbl_name = [cell.contentView viewWithTag:11];
    UILabel *lbl_date = [cell.contentView viewWithTag:12];
    UILabel *lbl_content = [cell.contentView viewWithTag:13];
    DialogListModel *dialog = _dataSourceArr[indexPath.row];
    [iv_avatar sd_setImageWithURL:[NSURL URLWithString:dialog.msgtoid_avatar] placeholderImage:kIMG(@"portrait")];
    lbl_name.text = dialog.tousername;
    lbl_date.text = [Util compareTime:[Util changeTimestamp:dialog.dateline] withTime:[NSDate date]];
    lbl_content.text = dialog.message;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self.view endEditing:YES];
        [self updateButtonsToMatchTableState];
        return;
    }
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
@end
