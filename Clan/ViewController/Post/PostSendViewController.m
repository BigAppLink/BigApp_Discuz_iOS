//
//  PostSendViewController.m
//  Clan
//
//  Created by chivas on 15/3/25.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostSendViewController.h"
#import "YZHelper.h"
#import "PostSendCell.h"
#import "PostAddImageCell.h"
#import "PostSendModel.h"
#import "PostAddImageCell.h"
#import "PostSendModel.h"
#import "PostViewModel.h"
#import "ForumsModel.h"
#import "PostDetailViewModel.h"
#import "PostDetailModel.h"
#import "YZPickView.h"
#import "TypeModel.h"
#import "NSString+Emojize.h"
#import "UIAlertView+BlocksKit.h"
#import "ForumsModel.h"
#import "CheckPostModel.h"
#import "PostSendViewModel.h"
#import "threadtypesModel.h"
#import "SubsModel.h"
#import "BoardModel.h"

@interface PostSendViewController ()<YZPickViewDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) PostSendModel *sendModel;
@property (copy, nonatomic) NSString *toDayImageCount;
@property (strong, nonatomic) YZPickView *pickview;
@property (strong, nonatomic) NSMutableArray *typeNameArray;
@property (copy, nonatomic) NSString *typeName;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIPickerView *picker;
@property(nonatomic,assign)NSInteger pickeviewHeight;
@property (strong, nonatomic) UIView *viewPicker;
@property (assign) NSInteger selectedBoardIndex;
@property (assign) NSInteger selectedForumIndex;
@property (assign) NSInteger selectedSubForumIndex;
@property (copy, nonatomic) NSString *showSelectedForumsTitle;
@property (strong, nonatomic) UIButton *selectForumButton;
@property (strong, nonatomic) NSMutableDictionary *permissionDic;
@property (strong, nonatomic) NSMutableDictionary *threadtypeDic;
@property (strong, nonatomic) PostSendViewModel *sendViewModel;
@property (assign) BOOL pikerShowing;

@end

@implementation PostSendViewController

#pragma mark - lefecycle
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_pickview remove];
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectedBoardIndex = 0;
    _selectedForumIndex = -1;
    _selectedSubForumIndex = -1;
    _sendModel = [PostSendModel PostForSend];
    _sendModel.fid = _forumsModel.fid;
    _sendModel.uploadhash = _forumsModel.uploadhash;
    [self initWithNav];
    [self initWithTable];
    if (self.fromShouYe) {
        _sendViewModel = [PostSendViewModel new];
        _permissionDic = [NSMutableDictionary new];
        _threadtypeDic = [NSMutableDictionary new];
        [self setUpPickView];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _sendViewModel = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    DLog(@"发帖页面 PostSendViewController dealloc");
}


- (void)initWithNav
{
    if (_forumsModel.threadtypes.types.count > 0) {
        //如果有分类 则显示titleview
        [self resetNaviTitleThreadTypeSelectedView];
    }
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = CGRectMake(0, 0, 26, 26);
    [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    UIBarButtonItem *buttonItem = [UIBarButtonItem itemWithBtnTitle:@"发帖" target:self action:@selector(sendPost:)];
    [self.navigationItem setRightBarButtonItem:buttonItem animated:YES];
    NSString *title;
    if (!_postDetailModel) {
        title = @"发新帖";
        [buttonItem setTitle:@"发帖"];
    }else{
        [buttonItem setTitle:@"回复"];
        if (_postDetailModel.pid) {
            title = [NSString stringWithFormat:@"回复%@",_postDetailModel.author];
        }else{
            title = @"发表回复";
        }
    }
    self.navigationItem.title = title;
}

- (void)resetNaviTitleThreadTypeSelectedView
{
    _typeNameArray = [NSMutableArray new];
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.width/2, self.navigationController.navigationBar.height)];
    titleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickviewAction)];
    [titleView addGestureRecognizer:tap];
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleView.width, 30)];
    _titleLabel.text = @"选择分类";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [titleView addSubview:_titleLabel];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_titleLabel.width/2 - 13/2, _titleLabel.bottom, 13, 7)];
    imageView.image = kIMG(@"classChange");
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
}

- (void)setForumsModel:(ForumsModel *)forumsModel
{
    _forumsModel = forumsModel;

    if (_fromShouYe) {
        _sendModel.fid = _forumsModel.fid;
        _sendModel.uploadhash = _forumsModel.uploadhash;
    } else {
        _toDayImageCount = _forumsModel.toDayPostImage;
    }
}

- (void)setPostDetailModel:(PostDetailModel *)postDetailModel
{
    _postDetailModel = postDetailModel;
    _toDayImageCount = _postDetailModel.toDayPostImage;
}
- (void)initWithTable{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
}
- (void)cancelBtnClicked:(id)sender
{
    if (_sendModel.imageArray.count > 0 || _sendModel.subject.length > 0 || _sendModel.message.length > 0) {
        //有编辑 提示是否返回
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认要离开此页吗？" delegate:self cancelButtonTitle:@"留在此页" otherButtonTitles:@"离开此页", nil];
        [alertview show];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 显示分类选择器
- (void)pickviewAction
{
    if (_pikerShowing) {
        return;
    }
    [self.view endEditing:YES];
    if (!_pickview) {
        [_typeNameArray removeAllObjects];
        if (_fromShouYe) {
            threadtypesModel *model = _threadtypeDic[_forumsModel.fid];
            for (TypeModel *typeModel in model.types) {
                [_typeNameArray addObject:typeModel.typeName];
            }
        } else {
            for (TypeModel *typeModel in _forumsModel.threadtypes.types) {
                [_typeNameArray addObject:typeModel.typeName];
            }
        }
        [_typeNameArray insertObject:@"请选择分类" atIndex:0];
        _pickview = [[YZPickView alloc] initPickviewWithArray:_typeNameArray isHaveNavControler:NO];
        _pickview.delegate = self;
        [_pickview show];
    }
}

#pragma mark - 发帖
- (void)sendPost:(id)sender
{
    if (_fromShouYe) {
        if (!_forumsModel || _selectedForumIndex == -1) {
            [self showHudTipStr:@"请选择要发帖的版块儿"];
            return;
        }
        CheckPostModel *checkModel = _permissionDic[_forumsModel.fid];
        //当满足 存在&&非0 时，说明不允许发表普通主题
        if (_forumsModel.allowspecialonly && ![_forumsModel.allowspecialonly isEqualToString:@"0"]) {
            [SVProgressHUD dismiss];
            //不支持活动 直接跳转
            [self showHudTipStr:@"该版块儿不支持发表普通主题"];
            return;
        }
        if (checkModel && checkModel.allowperm.allowpost.intValue != 1){
            [SVProgressHUD dismiss];
            //没有权限发表帖子
            [self showHudTipStr:@"没有权限在该版块下发帖"];
            return;
        }
        NSString *allowuploaValue = checkModel.allowperm.allowupload[@"jpg"];
        NSString *allowuploaValuejpeg = checkModel.allowperm.allowupload[@"jpeg"];

        
        if (checkModel && _sendModel.imageArray.count > 0 && allowuploaValue.intValue == 0 && allowuploaValuejpeg.intValue == 0) {
            [self showHudTipStr:@"没有权限发图片"];
            return;
        }
        if (_forumsModel.threadtypes.required && _forumsModel.threadtypes.required.intValue == 1) {
            //没有选择分类
            if (!_sendModel.typeId || _sendModel.typeId.length == 0) {
                [self showHudTipStr:@"请选择分类"];
                return;
            }
        }
    } else {
        
        if (_sendModel.imageArray.count > 0) {
            if (![[NSUserDefaults standardUserDefaults]boolForKey:KimageType]) {
                [self showHudTipStr:@"不支持的图片格式"];
                return;
            }
        }
        //    if ([_forumsModel.threadtypes.required isEqualToString:@"1"]) {
        if (_forumsModel.threadtypes.required && _forumsModel.threadtypes.required.intValue == 1) {
            //没有选择分类
            if (!_sendModel.typeId || _sendModel.typeId.length == 0) {
                [self showHudTipStr:@"请选择分类"];
                return;
            }
        }
    }
    if (_postDetailModel) {
        //回帖
        WEAKSELF
        PostDetailViewModel *postDetailss = [PostDetailViewModel new];
        _sendModel.uploadhash = _postDetailModel.uploadhash;
        _sendModel.tid = _postDetailModel.tid;
        _sendModel.fid = _postDetailModel.fid;
        _sendModel.textMessage = [self removeQuote:_postDetailModel.textMessage];
        _sendModel.dateline = [_postDetailModel.dateline stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        _sendModel.author = _postDetailModel.author;
        _sendModel.pid = _postDetailModel.pid;
        _sendModel.dbdateline = _postDetailModel.dbdateline;
        [postDetailss request_postReplyPostWithSendModel:_sendModel andBlock:^(BOOL isSuccess, NSInteger imageCount, id data) {
            if (isSuccess) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"SendReply_Success" object:nil];
                }];
            }
        }];
        [self.view endEditing:YES];
    } else {
        if (_fromShouYe) {
            _sendModel.uploadhash = _forumsModel.uploadhash;
        }
        PostViewModel *postViewModel = [PostViewModel new];
        WEAKSELF
        [postViewModel request_postSendWithSendModel:_sendModel andBlock:^(BOOL isSuccess ,NSInteger imageCount,NSString *postTid) {
            if (isSuccess) {
                weakSelf.sendModel.myPostTid = postTid;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    //更新列表
                    if (weakSelf.sendPostReturnBlock) {
                        weakSelf.sendPostReturnBlock(_sendModel);
                    }
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"imageCount" object:@(imageCount)];
                }];
            }
        }];
        [self.view endEditing:YES];
    }
}

- (NSString *)removeQuote:(NSString *)text
{
    DLog(@"------- %@",text);
    static dispatch_once_t onceToken;
    static NSRegularExpression *regex = nil;
    static NSRegularExpression *regex1 = nil;
    
    dispatch_once(&onceToken, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"<div +class=\"reply_wrap\">.*?</div>" options:NSRegularExpressionCaseInsensitive error:NULL];
        //为了兼容2.5版本
        regex1 = [[NSRegularExpression alloc] initWithPattern:@"<div +class=\"quote\">.*?</div>" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    
    __block NSString *resultText = text;
    if (text == nil) {
        return @"";
    }
    NSRange matchingRange = NSMakeRange(0, [resultText length]);
    [regex enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                resultText = [text stringByReplacingOccurrencesOfString:code withString:@""];
            }
        }
    }];
    
    NSRange matchingRange1 = NSMakeRange(0, [resultText length]);
    [regex1 enumerateMatchesInString:resultText options:NSMatchingReportCompletion range:matchingRange1 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result && ([result resultType] == NSTextCheckingTypeRegularExpression) && !(flags & NSMatchingInternalError)) {
            NSRange range = result.range;
            if (range.location != NSNotFound) {
                NSString *code = [text substringWithRange:range];
                resultText = [text stringByReplacingOccurrencesOfString:code withString:@""];
            }
        }
    }];
    DLog(@"------- %@",resultText);
    return resultText;
}


- (void)initWithItemEnabled:(BOOL)isEnabled{
    self.navigationItem.rightBarButtonItem.enabled = isEnabled;
}

#pragma mark - Tableview Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[self view] endEditing:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 2;
    return row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        WEAKSELF
        static NSString *postSend = @"postSend";
        PostSendCell *cell = [tableView dequeueReusableCellWithIdentifier:postSend];
        if (cell == nil) {
            cell = [[PostSendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postSend];
        }
        cell.selectedForums = self.fromShouYe;
        cell.isRelayPost = _postDetailModel ? YES : NO;
        cell.subjectValueChangedBlock = ^(NSString *subjectStr){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.sendModel.subject = subjectStr;
        };
        cell.messageValueChangedBlock = ^(NSString *messageStr){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.sendModel.message = messageStr;
        };
        if (self.fromShouYe) {
            [cell.selectedForumsBtn addTarget:self action:@selector(showPicker) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.selectedForumsBtn removeTarget:self action:@selector(showPicker) forControlEvents:UIControlEventTouchUpInside];
        }
        self.selectForumButton = cell.selectedForumsBtn;
        return cell;
    }else{
        WEAKSELF
        static NSString *postAddImage = @"postAddImage";
        PostAddImageCell *cell = [tableView dequeueReusableCellWithIdentifier:postAddImage];
        if (cell == nil) {
            cell = [[PostAddImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postAddImage];
        }
        cell.sendModel = _sendModel;
        cell.addPicturesBlock = ^(){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.view endEditing:YES];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:strongSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
            [actionSheet showInView:kKeyWindow];
        };
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [PostSendCell cellHeight];
        if (self.fromShouYe) {
            cellHeight += 47;
        }
    }else{
        cellHeight = [PostAddImageCell cellHeightWithObj:_sendModel];
    }
    return cellHeight;
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        拍照
        if (![YZHelper checkCameraAuthorizationStatus]) {
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    }else if (buttonIndex == 1){
        //        相册
        if (![YZHelper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 9-_sendModel.imageArray.count;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
    
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    SendImage *sendImg = [SendImage sendImageWithImage:[originalImage scaledToSize:Screen_Bounds.size highQuality:YES]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddHH";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    sendImg.fileName = [NSString stringWithFormat:@"%@%@",str,[UserModel currentUserInfo].uid];
    sendImg.size = 24;
    sendImg.fileType = @"jpg";
    NSMutableArray *sendImages = [_sendModel mutableArrayValueForKey:@"imageArray"];
    [sendImages addObject:sendImg];
    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(originalImage, self,selectorToCall, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    for (ALAsset *assetItem in assets) {
        ALAssetRepresentation *assetRep = [assetItem defaultRepresentation];
        UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:assetItem];
        SendImage *sendImg = [SendImage sendImageWithImage:[highQualityImage scaledToSize:kScreen_Bounds.size highQuality:NO]];
        sendImg.fileName = assetRep.filename;
        sendImg.size = assetRep.size / 1024;
        sendImg.fileType = [assetRep.filename componentsSeparatedByString:@"."][1];
        NSMutableArray *tweetImages = [_sendModel mutableArrayValueForKey:@"imageArray"];
        [tweetImages addObject:sendImg];
    }
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark picker delegate 选择分类
- (void)toobarDonBtnHaveClick:(YZPickView *)pickView resultString:(NSString *)resultString
{
    [pickView remove];
    _pickview = nil;
    _titleLabel.text = resultString;
    if (_fromShouYe) {
        threadtypesModel *model = _threadtypeDic[_forumsModel.fid];
        for (TypeModel *typeModel in model.types) {
            if ([typeModel.typeName isEqualToString:resultString]) {
                _sendModel.typeId = typeModel.typeId;
                break;
            } else {
                _sendModel.typeId = nil;
            }
        }
        return;
    }
    for (TypeModel *type in _forumsModel.threadtypes.types) {
        if ([type.typeName isEqualToString:resultString]) {
            _sendModel.typeId = type.typeId;
            break;
        } else {
            _sendModel.typeId = nil;
        }
    }
}
- (void)toobarCancelClick
{
    _pickview = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - 初始化picker view
- (void)setUpPickView
{
    _viewPicker = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREEN_HEIGHT, kSCREEN_WIDTH, 258)];
    _viewPicker.backgroundColor = [UIColor whiteColor];
    UIToolbar   *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 44)];
    pickerDateToolbar.barStyle = UIBarStyleDefault;
    [pickerDateToolbar sizeToFit];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@" 取消" style:UIBarButtonItemStyleBordered target:self action:@selector(toolBarCanelClick)];
    [barItems addObject:cancelBtn];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成 " style:UIBarButtonItemStyleDone target:self action:@selector(toolBarDoneClick:)];
    [barItems addObject:doneBtn];
    [pickerDateToolbar setItems:barItems animated:YES];
    _picker = [[UIPickerView alloc]init] ;
    _picker.frame=CGRectMake(0, 44, kSCREEN_WIDTH, 216);
    _picker.delegate = self;
    _picker.dataSource = self;
    _picker.showsSelectionIndicator = YES;
    [_viewPicker addSubview:_picker];
    [_viewPicker addSubview:pickerDateToolbar];
    [self.view addSubview:_viewPicker];
}

-(IBAction)toolBarDoneClick:(id)sender
{
    [self dismissPicker];
    [self resetSelectedValue];
}

- (void)toolBarCanelClick
{
    [self dismissPicker];
}

- (void)showPicker
{
    if (_pickview) {
        return;
    }
    [self.view endEditing:YES];
    self.pikerShowing = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _viewPicker.frame = CGRectMake(0, kVIEW_H(self.view)-258, kSCREEN_WIDTH, 258);
    if (_dataSourceArray.count > _selectedBoardIndex) {
        BoardModel *board = _dataSourceArray[_selectedBoardIndex];
        if (board.forums.count > _selectedForumIndex) {
            ForumsModel *forum = board.forums[_selectedForumIndex];
            if (forum.subs && forum.subs.count > 0 && forum.subs.count > _selectedSubForumIndex) {
                //默认选中上次选择的
                [_picker selectRow:_selectedBoardIndex inComponent:0 animated:NO];
                [_picker selectRow:_selectedForumIndex+1 inComponent:1 animated:NO];
                [_picker selectRow:_selectedSubForumIndex+1 inComponent:2 animated:NO];
            }
        }
    }
//    if (_dataSourceArray.count > _selectedForumIndex) {
//        ForumsModel *forum = _dataSourceArray[_selectedForumIndex];
//        if (forum.subs && forum.subs.count > 0 && forum.subs.count > _selectedSubForumIndex+1) {
//            //默认选中上次选择的
//            [_picker selectRow:_selectedForumIndex inComponent:0 animated:NO];
//            [_picker selectRow:_selectedSubForumIndex+1 inComponent:1 animated:NO];
//        }
//    }
    [UIView commitAnimations];
}

- (void)dismissPicker
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _viewPicker.frame = CGRectMake(0, kVIEW_H(self.view), kSCREEN_WIDTH, 258);
    [UIView commitAnimations];
    self.pikerShowing = NO;
}

- (void)resetSelectedValue
{
    NSString *showTitle = @"请选择要发帖的版块儿";
    
    NSInteger selectBoardIndex = [_picker selectedRowInComponent:0];
    NSInteger selectForumIndex = [_picker selectedRowInComponent:1];

    if (_dataSourceArray.count > selectBoardIndex) {
        _selectedBoardIndex = selectBoardIndex;
        showTitle = @"请选择要发帖的版块儿";
        BoardModel *board = _dataSourceArray[selectBoardIndex];
        if (board.forums.count > selectForumIndex-1) {
            _selectedForumIndex = selectForumIndex-1;
            self.forumsModel = board.forums[_selectedForumIndex];
            showTitle = [NSString stringWithFormat:@"%@ %@",board.name,_forumsModel.name];
            NSInteger selectsubindex = [_picker selectedRowInComponent:2];
            NSInteger selectActureIndex = selectsubindex-1;
            if (selectsubindex > 0 && _forumsModel.subs && _forumsModel.subs.count > selectActureIndex) {
                _selectedSubForumIndex = selectActureIndex;
                SubsModel *subforum = _forumsModel.subs[selectActureIndex];
                ForumsModel *newForums = [ForumsModel new];
                [newForums reflectDataFromOtherObject:_forumsModel];
                [newForums reflectDataFromOtherObject:subforum];
                self.forumsModel = newForums;
                showTitle = [showTitle stringByAppendingString:[NSString stringWithFormat:@" → %@",subforum.name]];
            }
            else {
                //标示无子版块儿
                _selectedSubForumIndex = -1;
            }
        } else {
            _selectedForumIndex = -1;
        }
    } else {
        _selectedBoardIndex = 0;
    }
    
    
//    NSInteger selectForumindex = [_picker selectedRowInComponent:0];
//    if (_dataSourceArray.count > selectForumindex) {
//        _selectedForumIndex = selectForumindex;
//        showTitle = @"";
//        ForumsModel *forum = _dataSourceArray[selectForumindex];
//        self.forumsModel = forum;
//        showTitle = [showTitle stringByAppendingString:forum.name];
//        NSInteger selectsubindex = [_picker selectedRowInComponent:1];
//        NSInteger selectActureIndex = selectsubindex-1;
//        if (selectsubindex > 0 && forum.subs && forum.subs.count > selectActureIndex) {
//            _selectedSubForumIndex = selectActureIndex;
//            SubsModel *subforum = forum.subs[selectActureIndex];
//            ForumsModel *newForums = [ForumsModel new];
//            [newForums reflectDataFromOtherObject:forum];
//            [newForums reflectDataFromOtherObject:subforum];
//            self.forumsModel = newForums;
//            showTitle = [showTitle stringByAppendingString:[NSString stringWithFormat:@" → %@",subforum.name]];
//        }
//        else {
//            //标示无子版块儿
//            _selectedSubForumIndex = -1;
//        }
//    }
    if ([@"请选择要发帖的版块儿" isEqualToString:showTitle]) {
        self.forumsModel = nil;
    }
    self.showSelectedForumsTitle = showTitle;
    [self.selectForumButton setTitle:showTitle forState:UIControlStateNormal];
    //前置检查该用户的发帖权限
    [self checkPermissionForSendPost];
}


- (void)request_PermissionForSendPost:(NSString *)fid
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_checkSendPostWithFid:fid withBlock:^(id data, NSError *error) {
        STRONGSELF
        if (data) {
            id resultData = [data valueForKeyPath:@"Variables"];
            CheckPostModel *checkModel = [CheckPostModel objectWithKeyValues:resultData];
            [strongSelf.permissionDic setObject:checkModel forKey:fid];
            [strongSelf dealwithCheckPermissionResult:checkModel withFid:fid];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)checkPermissionForSendPost
{
    if (_showSelectedForumsTitle && ![_showSelectedForumsTitle isEqualToString:@"请选择要发帖的版块儿"]) {
        NSString *fid = nil;
        BoardModel *board = _dataSourceArray[_selectedBoardIndex];
        ForumsModel *forum = board.forums[_selectedForumIndex];
        fid = forum.fid;
        if ([_showSelectedForumsTitle rangeOfString:@" → "].location != NSNotFound) {
            SubsModel *subforum = forum.subs[_selectedSubForumIndex];
            fid = subforum.fid;
        }
        if (fid && fid.length > 0) {
            [self showProgressHUDWithStatus:@"" withLock:YES];
            if ([_permissionDic objectForKey:fid]) {
                CheckPostModel *checkModel = _permissionDic[fid];
                [self dealwithCheckPermissionResult:checkModel withFid:fid];
            } else {
                [self request_PermissionForSendPost:fid];
            }
        } else {
            [self showHudTipStr:@"请重新选择版块儿"];
            return;
        }
    }
}

- (void)dealwithCheckPermissionResult:(CheckPostModel *)checkModel withFid:(NSString *)fid
{
    
    //当满足 存在&&非0 时，说明不允许发表普通主题
    if (_forumsModel.allowspecialonly && ![_forumsModel.allowspecialonly isEqualToString:@"0"]) {
        [SVProgressHUD dismiss];
        //不支持活动 直接跳转
        [self showHudTipStr:@"该版块儿不支持发表普通主题"];
        return;
    }
    
    _forumsModel.uploadhash = checkModel.allowperm.uploadhash;
    _forumsModel.toDayPostImage = checkModel.allowperm.imagecount;
    if (checkModel.allowperm.allowpost.intValue != 1){
        [SVProgressHUD dismiss];
        //没有权限发表帖子
        [self showHudTipStr:@"没有权限在该版块下发帖"];
        return;
    }
    [self requestClassifysWithFid:fid];
}

- (void)requestClassifysWithFid:(NSString *)fid
{
    if ([_threadtypeDic objectForKey:fid]) {
        [self dealWithThreadTypeWithFid:fid forModel:nil];
        return;
    }
    [_sendViewModel request_classifyForForumsId:fid withBlock:^(id data, BOOL success) {
        if (success) {
            threadtypesModel *model = (threadtypesModel *)data;
            [_threadtypeDic setObject:model forKey:fid];
        } else {
            [SVProgressHUD dismiss];
        }
        [self dealWithThreadTypeWithFid:fid forModel:nil];
    }];
}

- (void)dealWithThreadTypeWithFid:(NSString *)fid forModel:(threadtypesModel *)model
{
    [SVProgressHUD dismiss];
    threadtypesModel *threadmodel = _threadtypeDic[fid];
    if (!threadmodel || threadmodel.types.count == 0) {
        self.navigationItem.titleView = nil;
        self.title = @"发新帖";
    } else {
        [self resetNaviTitleThreadTypeSelectedView];
    }
}

#pragma mark piackView 数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == _picker) {
        return 3;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _picker) {
        if (component == 0) {
            return _dataSourceArray.count;
        }
        else if (component == 1) {
            NSInteger seleted = [pickerView selectedRowInComponent:0];
            BoardModel *board = _dataSourceArray[seleted];
            NSArray *arr = board.forums;
            return arr.count > 0 ? arr.count+1 : 0;
        }
        else {
            NSInteger seleted0 = [pickerView selectedRowInComponent:0];
            NSInteger seleted1 = [pickerView selectedRowInComponent:1];
            if (seleted1 == 0) {
                return 0;
            } else {
                BoardModel *board = _dataSourceArray[seleted0];
                ForumsModel *forum = board.forums[seleted1-1];
                NSArray *arr = forum.subs;
                return arr.count > 0 ? arr.count+1 : 0;
            }
        }
    } else {
        return 0;
    }
}

#pragma mark UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *rowTitle = nil;
    if (pickerView == _picker) {
        if (component == 0) {
            BoardModel *board = _dataSourceArray[row];
            rowTitle = board.name;
        }
        else if (component == 1) {
            NSInteger seleted0 = [pickerView selectedRowInComponent:0];
            BoardModel *board = _dataSourceArray[seleted0];
            if (row > 0 && board.forums && board.forums.count > row-1) {
                ForumsModel *forum = board.forums[row-1];
                rowTitle = forum.name;
            }
            else if (board.forums && board.forums.count > 0 && row == 0) {
                rowTitle = @"请选择";
            }
        }
        else {
            
            NSInteger seleted0 = [pickerView selectedRowInComponent:0];
            NSInteger seleted1 = [pickerView selectedRowInComponent:1];
            BoardModel *board = _dataSourceArray[seleted0];
            ForumsModel *forum = board.forums[seleted1];
            if (row > 0 && forum.subs && forum.subs.count > row-1) {
                SubsModel *subForum = forum.subs[row-1];
                rowTitle = subForum.name;
            }
            else if (forum.subs && forum.subs.count > 0 && row == 0) {
                rowTitle = @"请选择";
            }
        }
        return rowTitle;
    }
    return rowTitle;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *rowTitle = nil;
    if (pickerView == _picker) {
        if (component == 0) {
            BoardModel *board = _dataSourceArray[row];
            rowTitle = board.name;
        }
        else if (component == 1) {
            NSInteger seleted0 = [pickerView selectedRowInComponent:0];
            BoardModel *board = _dataSourceArray[seleted0];
            if (board.forums && board.forums.count > 0 && row == 0) {
                rowTitle = @"请选择";
            }
            else if (row > 0 && board.forums && board.forums.count > row-1){
                ForumsModel *forum = board.forums[row-1];
                rowTitle = forum.name;
            }
        }
        else {
            NSInteger seleted0 = [pickerView selectedRowInComponent:0];
            NSInteger seleted1 = [pickerView selectedRowInComponent:1];
            BoardModel *board = _dataSourceArray[seleted0];
            if (seleted1 == 0) {
                rowTitle = @"请选择";
            } else {
                ForumsModel *forum = board.forums[seleted1-1];
                if (row > 0 && forum.subs && forum.subs.count > row-1) {
                    SubsModel *subForum = forum.subs[row-1];
                    rowTitle = subForum.name;
                }
                else if (forum.subs && forum.subs.count > 0 && row == 0) {
                    rowTitle = @"请选择";
                }
            }
        }
    }
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont fontWithSize:14.f];
        tView.textAlignment = NSTextAlignmentLeft;
        tView.textColor = K_COLOR_LIGHT_DARK;
    }
    tView.text = [NSString stringWithFormat:@"     %@",avoidNullStr(rowTitle)];
    return tView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView != _picker) {
        return;
    }
    if (component == 0) {
        [self.picker reloadComponent:1];
        [self.picker reloadComponent:2];
    }
    else if (component == 1) {
        [self.picker reloadComponent:2];
    }
}
@end
