//
//  ChatViewController.m
//  Clan
//
//  Created by 昔米 on 15/4/15.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ChatViewController.h"
#import "UUInputFunctionView.h"
//#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "ChatViewModel.h"
#import "MeViewController.h"
#import "AGEmojiKeyBoardView.h"
#import "NSString+Common.h"


@interface ChatViewController () <UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate, AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
{
    ChatViewModel *_viewmodel;
    NSString *_lastPid;
}
@property (assign) int currentpage;
@property (assign) int totalPage;

@property (strong, nonatomic) NSMutableArray *tempArray;
@property (strong, nonatomic) UUInputFunctionView *IFView;
//=======
//@property (strong, nonatomic) UUInputFunctionView *IFView;
//@property (strong, nonatomic) NSMutableArray *tempArray;
//>>>>>>> .merge-right.r5261
@property (strong, nonatomic) ChatModel *chatModel;
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic, strong)  UIBarButtonItem *cancelButton;
@property (nonatomic, strong)  UIBarButtonItem *deleteButton;
@property (nonatomic, strong)  UIBarButtonItem *backButton;

@end

@implementation ChatViewController

#pragma mark - 生命周期

- (void)navback{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navback) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    }
    self.currentpage = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"CHAT_CELL_DELETE" object:nil];

    self.view.backgroundColor = kCOLOR_BG_GRAY;
    _tempArray = [NSMutableArray new];
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.allowsMultipleSelectionDuringEditing = YES;
    [self initBar];
    [self loadBaseViewsAndData];
    self.deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    self.cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.backButton = self.navigationItem.leftBarButtonItem;
}

- (void)receiveNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"CHAT_CELL_DELETE"])
    {
        NSDictionary* userInfo = notification.userInfo;
        NSIndexPath *path = (NSIndexPath*)userInfo[@"para"];
        if (path) {
            [self performSelector:@selector(editAction:) withObject:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _emojiKeyboardView.delegate = nil;
    DLog(@"ChatViewController dealloc");
}

#pragma mark - Action methods

- (IBAction)editAction:(id)sender
{
    [self.tableview setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableview setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteAction:(id)sender
{
    // Delete what the user selected.
    NSArray *selectedRows = [self.tableview indexPathsForSelectedRows];
    NSString *toBeDeleteString = @"";
    for (int i = 0; i < selectedRows.count; i++) {
        NSIndexPath *path = selectedRows[i];
        SessionModel *model = _tempArray[path.row];
        NSString *str = model.pmid;
        if (i != 0) {
            str = [NSString stringWithFormat:@"_%@",model.pmid];
        }
        toBeDeleteString = [toBeDeleteString stringByAppendingString:str];
    }
    WEAKSELF
    [_viewmodel deleteChatWithDialogId:_dialogModel.touid andDeleteChatID:toBeDeleteString WithReturnBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            [strongSelf.chatModel.dataSource removeObjectsAtIndexes:indicesOfItemsToDelete];
            [strongSelf.tempArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            [strongSelf.tableview deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    [self.tableview setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}


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
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
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
    
    BOOL allItemsAreSelected = selectedRows.count == self.chatModel.dataSource.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"删除全部", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"删除 (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark - 自定义方法
- (void)initBar
{
    if (_dialogModel) {
        self.title = _dialogModel.tousername;
    }
    BOOL isDown = [UserDefaultsHelper boolValueForDefaultsKey:kUserDefaultsKey_ClanZipIsDown];
    if (isDown) {
        if (!_emojiKeyboardView) {
            _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 216) dataSource:self];
            _emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            _emojiKeyboardView.delegate = self;
            [_emojiKeyboardView.easeTabBar.sendButton removeFromSuperview];
            _emojiKeyboardView.easeTabBar.sendButton = nil;
        }
    }
}

- (void)addRefreshViews
{
    if (!self.tableview.header) {
        [self.tableview addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(requestData)];
        // 隐藏时间
        self.tableview.header.updatedTimeHidden = YES;
        self.tableview.header.stateHidden = YES;
    }
    self.tableview.header.hidden = NO;
    [self.tableview.header endRefreshing];
}

- (void)removeRefreshHeader
{
    [self.tableview.header endRefreshing];
    [self.tableview performSelector:@selector(removeHeader) withObject:nil afterDelay:.25];
}

- (void)loadBaseViewsAndData
{
    if (!_chatModel) {
        self.chatModel = [[ChatModel alloc]init];
        self.chatModel.isGroupChat = NO;
        _IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
        _IFView.delegate = self;
        [self.view addSubview:_IFView];
        [_IFView.btnSendPicture setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_IFView.btnSendPicture addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view beginLoading];
    [self requestData];
}

- (void)requestData
{
    BOOL islogin = [UserModel currentUserInfo].logined;
    if (!islogin) {
        [self goToLoginPage];
        return;
    }
    if (_currentpage < 1) {
        [self.tableview.header endRefreshing];
        return;
    }
    if (!_viewmodel) {
        _viewmodel = [ChatViewModel new];
    }
    WEAKSELF
    [_viewmodel requestSessionListAtPage:--_currentpage withDialogId:_dialogModel.msgtoid WithReturnBlock:^(bool success, id data, bool needmore, int totalpage) {
       STRONGSELF
        [strongSelf.view endLoading];
        [strongSelf.tableview.header endRefreshing];
        if (success) {
            BOOL firstpage = NO;
            strongSelf.totalPage = totalpage;
            if (strongSelf.currentpage == 0) {
                firstpage = YES;
                strongSelf.currentpage = totalpage == 0 ? 1 : totalpage;
                //清除所有数据源
                [strongSelf.tempArray removeAllObjects];
                [strongSelf.chatModel.dataSource removeAllObjects];
            }
            if (needmore) {
                [strongSelf addRefreshViews];
            } else {
                //没有历史记录 就没有下拉更新
                strongSelf.tableview.header.hidden = YES;
            }
            NSArray *arr = (NSArray *)data;
            [strongSelf.tempArray insertObjects:data atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)]];
            [strongSelf.chatModel insertSpecifiedItems:data atIndex:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, arr.count)]];
            [strongSelf.tableview reloadData];
            if (firstpage) {
                //第一页就主动滑动到底部
                CGPoint bottomOffset = CGPointMake(0, strongSelf.tableview.contentSize.height - strongSelf.tableview.bounds.size.height < 0 ? 0 : ( strongSelf.tableview.contentSize.height - strongSelf.tableview.bounds.size.height));
                [strongSelf.tableview setContentOffset:bottomOffset animated:NO];
            }
        } else {
            strongSelf.currentpage = 1;
            if (data && [data isEqualToString:kCookie_expired]) {
                [strongSelf goToLoginPage];
                return ;
            }
        }
        if (strongSelf.currentpage == 0) {
            [strongSelf.tableview configBlankPage:DataIsNothingWithDefault hasData:strongSelf.chatModel.dataSource.count>0 hasError:!success reloadButtonBlock:^(id sender) {
                [strongSelf requestData];
            }];
        }
    }];
}

- (void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust tableview's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = keyboardEndFrame.size.height+50;
    }else{
        self.bottomConstraint.constant = 50;
    }
    [self.view layoutIfNeeded];
    
    CGRect newFrame = _IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height-64;
    _IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - InputFunctionViewDelegate
// text
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    WEAKSELF
    [_viewmodel sendMess:message toUser:_dialogModel.msgtoid withReturnBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dialog_list_update" object:nil];
            [[strongSelf.IFView TextViewInput] setText:@""];
            [strongSelf.tempArray addObject:data];
            [strongSelf.chatModel addSpecifiedItem:data];
            [strongSelf.tableview reloadData];
            [strongSelf scrollviewToBottomWithAnimated:YES];
        }
    }];
}

- (void)scrollviewToBottomWithAnimated:(BOOL)animated
{
    [self.tableview scrollRectToVisible:CGRectMake(0, self.tableview.contentSize.height - self.tableview.bounds.size.height, self.tableview.bounds.size.width, self.tableview.bounds.size.height) animated:animated];
}

// image
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    
}

// audio
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
        UIView *view = [UIView new];
        view.backgroundColor = self.view.backgroundColor;
        cell.selectedBackgroundView = view;
    }
    [cell.btnHeadImage addTarget:self action:@selector(headImageDidClick:) forControlEvents:UIControlEventTouchDown];
    cell.btnHeadImage.path = indexPath;
    cell.btnContent.path = indexPath;
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self updateButtonsToMatchTableState];
    }
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self updateDeleteButtonTitle];
    }
    [self.view endEditing:YES];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (IBAction)headImageDidClick:(id)sender
{
    YZButton *btn = (YZButton *)sender;
    SessionModel *session = _tempArray[btn.path.row];
    UserModel *user = [UserModel new];
    user.username = session.author;
    user.uid = session.authorid;

    NSArray *arr = self.navigationController.viewControllers;
    if ([arr[arr.count-2] isKindOfClass:[MeViewController class]]) {
        MeViewController *main = arr[arr.count - 2];
        main.user = user;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    MeViewController *main = [[MeViewController alloc]init];
    main.user = user;
    [self.navigationController pushViewController:main animated:YES];
}

- (void)emotionButtonClicked:(id)sender
{
    if (_IFView.TextViewInput.inputView != _emojiKeyboardView) {
        _IFView.TextViewInput.inputView = self.emojiKeyboardView;
        [_IFView.btnSendPicture setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
    }else{
        _IFView.TextViewInput.inputView = nil;
        [_IFView.btnSendPicture setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    }
    [_IFView.TextViewInput resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_IFView.TextViewInput becomeFirstResponder];
    });
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji
{
    NSRange selectedRange = _IFView.TextViewInput.selectedRange;
    
    NSString *emotion_monkey = [emoji emotionWithCategory:emojiKeyBoardView.category];
    if (emotion_monkey) {
        emotion_monkey = [NSString stringWithFormat:@"%@", emotion_monkey];
        _IFView.TextViewInput.text = [_IFView.TextViewInput.text stringByReplacingCharactersInRange:selectedRange withString:emotion_monkey];
        _IFView.TextViewInput.selectedRange = NSMakeRange(selectedRange.location +emotion_monkey.length, 0);
        if ([_IFView respondsToSelector:@selector(textViewDidChange:)]) {
            [_IFView performSelector:@selector(textViewDidChange:) withObject:_IFView.TextViewInput];
        }
    }else{
        _IFView.TextViewInput.text = [_IFView.TextViewInput.text stringByReplacingCharactersInRange:selectedRange withString:emoji];
        _IFView.TextViewInput.selectedRange = NSMakeRange(selectedRange.location +emoji.length, 0);
        if ([_IFView respondsToSelector:@selector(textViewDidChange:)]) {
            [_IFView performSelector:@selector(textViewDidChange:) withObject:_IFView.TextViewInput];
        }
    }}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView
{
    [_IFView.TextViewInput deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView
{
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category
{
    return [UIImage imageNamed:@"keyboard_emotion_emoji"];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category
{
    return [UIImage imageNamed:@"keyboard_emotion_emoji"];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
{
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

@end
