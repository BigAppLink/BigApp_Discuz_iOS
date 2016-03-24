//
//  JoinActivityVC.m
//  Clan
//
//  Created by 昔米 on 15/11/13.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "JoinActivityVC.h"
#import "UIAlertView+BlocksKit.h"
#import "JoinFieldItem.h"
#import "IQTextView.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQDropDownTextField.h"
#import "IQTextField.h"
#import "PostAddImageCell.h"
#import "YZHelper.h"
#import "QBImagePickerController.h"
#import "PostSendModel.h"
#import "PostDetailViewModel.h"
#import "PostDetailVC.h"

@interface JoinActivityVC () <UITableViewDataSource, UITableViewDelegate, IQDropDownTextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *sourceSectionArr;
@property (nonatomic, strong) NSIndexPath *selectFilePath;
@property (nonatomic, strong) PostDetailViewModel *detailViewModel;

@end

@implementation JoinActivityVC

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
    _detailViewModel = nil;
    returnKeyHandler = nil;
    _table.delegate = nil;
    _table.dataSource = nil;
    DLog(@"JoinActivityVC 销毁了");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面结束
    [self.view endEditing:YES];
}


#pragma mark - 初始化
- (void)loadModel
{
    self.title = @"我要参加";
    if (!_tid || !_fid || !_pid || _tid.length == 0 || _pid.length == 0 || _fid.length == 0) {
        WEAKSELF
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"抱歉,活动信息出错了" cancelButtonTitle:@"返回" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    self.detailViewModel = [PostDetailViewModel new];
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnKeyHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    self.sourceSectionArr = [NSMutableArray new];
    NSMutableArray *Arr = [NSMutableArray new];
    NSMutableArray *tempArr = [[NSMutableArray alloc]initWithArray:_joinfieldArr];
    for (int i = 0; i < tempArr.count; i++) {
        JoinFieldItem *item = tempArr[i];
        if (item.defaultValue) {
            item.fieldValue = item.defaultValue;
        }
        //所有的textarea都是
        if (item.dz_formtype == DZActivityFormType_File || item.dz_formtype == DZActivityFormType_TextArea) {
            if (Arr.count > 0) {
                [_sourceSectionArr addObject:Arr];
                Arr = [NSMutableArray new];
            }
            [_sourceSectionArr addObject:@[item]];
        } else {
            [Arr addObject:item];
        }
    }
    if (Arr && Arr.count > 0 ) {
        [_sourceSectionArr addObject:Arr];
    }
    NSMutableArray *arrExt = [NSMutableArray new];
    if (_extfield && _extfield.count > 0) {
        for (NSString *itemStr in _extfield) {
            JoinFieldItem *item = [JoinFieldItem new];
            item.fieldid = itemStr;
            item.dz_formtype = DZActivityFormType_Text;
            item.title = [itemStr stringByAppendingString:@"(选填)"];
            [arrExt addObject:item];
        }
    }
    _extfield = [NSArray arrayWithArray:arrExt];
    if (arrExt && arrExt.count > 0) {
        [_sourceSectionArr addObject:arrExt];
    }
//    if (_sourceSectionArr.count > 0) {
        //有值  所以把留言信息加上去
        JoinFieldItem *item = [JoinFieldItem new];
        item.title = @"我要留言(选填)";
        item.fieldid = @"message";
        item.formtype = @"leaveMessage_dz";
        item.dz_formtype = DZActivityFormType_TextArea;
        item.f_description = @"有什么疑问可以留言哦~ 只支持文本.";
        [_sourceSectionArr addObject:@[item]];
//    }
}


- (void)buildUI
{
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    leftButton.frame = CGRectMake(0, 0, 40, 26);
    [leftButton setTitle:@"提 交" forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.backgroundColor = kCOLOR_BG_GRAY;
    table.delegate = self;
    table.dataSource = self;
    self.table = table;
    [self.view addSubview:table];
}

#pragma mark - uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sourceSectionArr.count > 1 ? _sourceSectionArr.count+1 : _sourceSectionArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sourceSectionArr.count > section) {
        NSArray *arr = _sourceSectionArr[section];
        return arr.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static float space = 15.f;
    if (_sourceSectionArr.count == indexPath.section) {
        //最后一个section 表示重置所有选项
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 50.f);
        [selectBtn setTitle:@"重置所有资料" forState:UIControlStateNormal];
        [selectBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [selectBtn setTitleColor:[Util mainThemeColor] forState:UIControlStateNormal];
        [selectBtn addTarget:self action:@selector(clearAllInfoAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:selectBtn];
        return cell;
    }
    NSArray *arr = _sourceSectionArr[indexPath.section];
    JoinFieldItem *item = arr[indexPath.row];
    if (item.dz_formtype == DZActivityFormType_TextArea) {
        static NSString *identifer_textArea = @"DZActivityFormType_TextArea";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer_textArea];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer_textArea];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            IQTextView *tv = [[IQTextView alloc] initWithFrame:CGRectMake(space, 10, kSCREEN_WIDTH-space*2, 150.f-20)];
            tv.delegate = self;
            tv.tag = 1122;
            tv.font = [UIFont fitFontWithSize:17.f];
            tv.returnKeyType = UIReturnKeyDefault;
            [cell.contentView addSubview:tv];
        }
        IQTextView *tv = [cell.contentView viewWithTag:1122];
        if ([@"leaveMessage_dz" isEqualToString:item.formtype]) {
            tv.frame = CGRectMake(0, 10, kSCREEN_WIDTH-20, 150.f-20);
            tv.backgroundColor = [UIColor whiteColor];
        } else {
            tv.frame = CGRectMake(space, 10, kSCREEN_WIDTH-space*2, 150.f-20);
            tv.backgroundColor = K_COLOR_MOST_LIGHT_GRAY;
        }
//        CGRect rect_tv = tv.frame;
//        if (item.f_description && item.f_description.length > 0) {
//            //存在描述
//            YZButton *btn = [YZButton buttonWithType:UIButtonTypeInfoLight];
//            btn.path = indexPath;
//            btn.tintColor = [Util mainThemeColor];
//            [btn addTarget:self action:@selector(showDescriptionAction:) forControlEvents:UIControlEventTouchUpInside];
//            cell.accessoryView = btn;
//            rect_tv.size.width -= 30;
//        } else {
//            cell.accessoryView = nil;
//            rect_tv.size.width -= 0;
//        }
//        tv.frame = rect_tv;
        tv.indexPath = indexPath;
        tv.placeholder = item.title;
        if (item.fieldValue) {
//            if ([@"leaveMessage_dz" isEqualToString:item.formtype]) {
//                cell.imageView.image = nil;
//            } else {
//                cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            }
            tv.text = item.fieldValue;
        } else {
//            if ([@"leaveMessage_dz" isEqualToString:item.formtype]) {
//                cell.imageView.image = nil;
//            } else {
//                cell.imageView.image = kIMG(@"act_select_n");
//            }
            tv.text = @"";
        }
       
        return cell;
    }
    else if (item.dz_formtype == DZActivityFormType_Text) {
        static NSString *identifer_textFeild = @"DZActivityFormType_TextField";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer_textFeild];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer_textFeild];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *txtLable = [UILabel new];
            txtLable.tag = 1133;
            txtLable.frame = CGRectMake(space, 0, 80, 50.f);
            txtLable.numberOfLines = 0;
            txtLable.font = [UIFont systemFontOfSize:14.f];
            txtLable.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:txtLable];
            
            UIImageView *ibgv = [[UIImageView alloc]initWithFrame:CGRectMake(space+80, 8, kSCREEN_WIDTH-space*2-80, 34.f)];
            ibgv.image = [Util imageWithColor:kCOLOR_BG_GRAY];
            ibgv.tag = 1144;
            [cell.contentView addSubview:ibgv];
            
            IQTextField *iqtf = [[IQTextField alloc]initWithFrame:CGRectMake(space+80, 8, kSCREEN_WIDTH-space*2-80, 34.f)];
            iqtf.textAlignment = NSTextAlignmentRight;
            iqtf.tag = 2233;
            iqtf.clearButtonMode = UITextFieldViewModeWhileEditing;
            iqtf.delegate = self;
            [cell.contentView addSubview:iqtf];
        }
        UILabel *txtLabel = [cell.contentView viewWithTag:1133];
        txtLabel.text = item.title;
        IQTextField *iqtf = (IQTextField *)[cell.contentView viewWithTag:2233];
        iqtf.frame = CGRectMake(space+80, 8, kSCREEN_WIDTH-space*2-80-25, 34.f);
//        if (item.f_description && item.f_description.length > 0) {
//            //存在描述
//            YZButton *btn = [YZButton buttonWithType:UIButtonTypeInfoLight];
//            btn.path = indexPath;
//            btn.tintColor = [Util mainThemeColor];
//            [btn addTarget:self action:@selector(showDescriptionAction:) forControlEvents:UIControlEventTouchUpInside];
//            cell.accessoryView = btn;
//        } else {
//            cell.accessoryView = nil;
//        }
        iqtf.placeholder = item.title;
        iqtf.indexPath = indexPath;
        if (item.fieldValue) {
//            cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iqtf.text = item.fieldValue;
        } else {
//            cell.imageView.image = kIMG(@"act_select_n");
            iqtf.text = @"";
        }
        return cell;
    }
    else if (item.dz_formtype == DZActivityFormType_Select || item.dz_formtype == DZActivityFormType_DatePicker || item.dz_formtype == DZActivityFormType_Provincepicker) {
        static NSString *identifer_select = @"DZActivityFormType_Select";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer_select];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer_select];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *txtLable = [UILabel new];
            txtLable.tag = 1133;
            txtLable.frame = CGRectMake(space, 0, 80, 50.f);
            txtLable.numberOfLines = 0;
            txtLable.font = [UIFont systemFontOfSize:14.f];
            txtLable.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:txtLable];
            
            UIImageView *ibgv = [[UIImageView alloc]initWithFrame:CGRectMake(space+80, 8, kSCREEN_WIDTH-space*2-80, 34.f)];
            ibgv.image = [Util imageWithColor:kCOLOR_BG_GRAY];
            ibgv.tag = 1144;
            [cell.contentView addSubview:ibgv];
//            cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"down")];
            IQDropDownTextField *iqtf = [[IQDropDownTextField alloc]initWithFrame:CGRectMake(space+50, 0, kSCREEN_WIDTH-space*2-50, 50.f)];
            iqtf.tag = 4455;
            iqtf.textAlignment = NSTextAlignmentRight;
            iqtf.delegate = self;
            [cell.contentView addSubview:iqtf];
        }
        UILabel *txtLabel = [cell.contentView viewWithTag:1133];
        txtLabel.text = item.title;
        IQDropDownTextField *iqtf = (IQDropDownTextField *)[cell.contentView viewWithTag:4455];
        iqtf.frame = CGRectMake(kVIEW_BX(txtLabel), 0, kSCREEN_WIDTH-kVIEW_BX(txtLabel)-space-25, 50.f);
        cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"down")];
//        if (item.f_description && item.f_description.length > 0) {
//            //存在描述
//            YZButton *btn = [YZButton buttonWithType:UIButtonTypeInfoLight];
//            btn.path = indexPath;
//            btn.tintColor = [Util mainThemeColor];
//            [btn addTarget:self action:@selector(showDescriptionAction:) forControlEvents:UIControlEventTouchUpInside];
//            cell.accessoryView = btn;
//        } else {
////            iqtf.frame = CGRectMake(kVIEW_BX(txtLabel), 3, kSCREEN_WIDTH-kVIEW_BX(txtLabel)-space, 44.f);
//
//        }
        iqtf.placeholder = item.title;
        iqtf.indexPath = indexPath;
        if (item.dz_formtype == DZActivityFormType_DatePicker) {
            [iqtf setDropDownMode:IQDropDownModeDatePicker];
        }
        else if (item.dz_formtype == DZActivityFormType_Provincepicker) {
            [iqtf setDropDownMode:IQDropDownModeTextPicker];
            [iqtf setItemList:kProvinceArray];
        }
        else {
            [iqtf setDropDownMode:IQDropDownModeTextPicker];
            [iqtf setItemList:item.choices];
        }
        if (item.fieldValue) {
//            cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iqtf.text = item.fieldValue;
        } else {
//            cell.imageView.image = kIMG(@"act_select_n");
            iqtf.text = @"";
        }
        return cell;
    }
    else if (item.dz_formtype == DZActivityFormType_Checkbox) {
        static NSString *identifer_checkbox = @"DZActivityFormType_Checkbox";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer_checkbox];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer_checkbox];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *txtLable = [UILabel new];
            txtLable.tag = 1133;
            txtLable.frame = CGRectMake(space, 0, 80, 50.f);
            txtLable.numberOfLines = 0;
            txtLable.font = [UIFont systemFontOfSize:14.f];
            txtLable.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:txtLable];
            
            UIImageView *ibgv = [[UIImageView alloc]initWithFrame:CGRectMake(space+80, 8, kSCREEN_WIDTH-space*2-80, 34.f)];
            ibgv.image = [Util imageWithColor:kCOLOR_BG_GRAY];
            ibgv.tag = 1144;
            [cell.contentView addSubview:ibgv];
            
            IQDropDownTextField *iqtf = [[IQDropDownTextField alloc]initWithFrame:CGRectMake(kVIEW_BX(txtLable), 0, kSCREEN_WIDTH-space*2-50, 50.f)];
            iqtf.tag = 5566;
            iqtf.textAlignment = NSTextAlignmentRight;
            iqtf.delegate = self;
            [cell.contentView addSubview:iqtf];
        }
        UILabel *txtLable = [cell.contentView viewWithTag:1133];
        txtLable.text = item.title;
        IQDropDownTextField *iqtf = (IQDropDownTextField *)[cell.contentView viewWithTag:5566];
        iqtf.frame = CGRectMake(kVIEW_BX(txtLable), 0, kSCREEN_WIDTH-kVIEW_BX(txtLable)-space-25, 50.f);
        cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"down")];

//        if (item.f_description && item.f_description.length > 0) {
//            //存在描述
//            YZButton *btn = [YZButton buttonWithType:UIButtonTypeInfoLight];
//            btn.path = indexPath;
//            btn.tintColor = [Util mainThemeColor];
//            [btn addTarget:self action:@selector(showDescriptionAction:) forControlEvents:UIControlEventTouchUpInside];
//            cell.accessoryView = btn;
//        } else {
////            iqtf.frame = CGRectMake(kVIEW_BX(txtLable), 10, kSCREEN_WIDTH-kVIEW_BX(txtLable)-space, 30.f);
//
//        }
        iqtf.placeholder = item.title;
        iqtf.indexPath = indexPath;
        [iqtf setDropDownMode:IQDropDownModeCheckboxPicker];
        iqtf.maxSelectValue = item.size.integerValue > 0 ? item.size.integerValue : item.choices.count;
        [iqtf setItemList:item.choices];
        if (item.fieldValue) {
//            cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [iqtf setSelectedItems:[[NSMutableArray alloc] initWithArray:item.fieldValue]];
        } else {
//            cell.imageView.image = kIMG(@"act_select_n");
            [iqtf setSelectedItems:[NSMutableArray new]];
        }
        return cell;
    }
    else if (item.dz_formtype == DZActivityFormType_File) {
        static NSString *fileCell = @"imageFileCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileCell];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCell];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 100.f)];
//            sv.tag = 8899;
//            [cell.contentView addSubview:sv];
        }
//        UIScrollView *sv = (UIScrollView *)[cell.contentView viewWithTag:8899];
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
//        if (item.f_description && item.f_description.length > 0) {
//            //存在描述
//            YZButton *btn = [YZButton buttonWithType:UIButtonTypeInfoLight];
//            btn.path = indexPath;
//            btn.tintColor = [Util mainThemeColor];
//            [btn addTarget:self action:@selector(showDescriptionAction:) forControlEvents:UIControlEventTouchUpInside];
//            cell.accessoryView = btn;
//        } else {
//            cell.accessoryView = nil;
//        }
        UIImage *add = kIMG(@"addImage");
        YZButton *addButton = [YZButton buttonWithType:UIButtonTypeCustom];
        addButton.path = indexPath;
        addButton.frame = CGRectMake(20, (100.f-add.size.height)/2.f, add.size.width, add.size.height);
        [addButton setImage:add forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:addButton];
//        CGFloat width = kSCREEN_WIDTH;
        id fileData = item.fieldValue;
        if (fileData && [fileData isKindOfClass:[SendImage class]]) {
            SendImage *fileImage = (SendImage *)fileData;
            UIImageView *ivvv = [[UIImageView alloc]initWithFrame:CGRectMake(kVIEW_BX(addButton)+30, kVIEW_TY(addButton), kVIEW_W(addButton), kVIEW_H(addButton))];
            ivvv.contentMode = UIViewContentModeScaleAspectFill;
            ivvv.clipsToBounds = YES;
            ivvv.image = fileImage.image;
            [cell.contentView addSubview:ivvv];
            
            YZButton *deletebtn = [YZButton buttonWithType:UIButtonTypeCustom];
            deletebtn.path = indexPath;
            deletebtn.frame = CGRectMake(0, 0, 40, 40);
            UIImage *deleimage = [[UIImage imageNamed:@"btn_delete_tweetimage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [deletebtn setImage:deleimage forState:UIControlStateNormal];
            deletebtn.center = CGPointMake(kVIEW_BX(ivvv), kVIEW_TY(ivvv));
            [deletebtn addTarget:self action:@selector(deleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:deletebtn];
        }
//        if (fileData && [fileData isKindOfClass:[NSArray class]]) {
//            NSArray *imageFileArr = (NSArray *)fileData;
//            for (int i = 0; i < imageFileArr.count ; i++) {
//                SendImage *sendimage = imageFileArr[i];
//                UIImageView *ivvv = [[UIImageView alloc]initWithFrame:CGRectMake((i+1)*add.size.width+(i+2)*20, kVIEW_TY(addButton), kVIEW_W(addButton), kVIEW_H(addButton))];
//                ivvv.image = sendimage.image;
//                ivvv.contentMode = UIViewContentModeScaleAspectFill;
//                ivvv.clipsToBounds = YES;
//                [sv addSubview:ivvv];
//                width = kVIEW_BX(ivvv)+kVIEW_H(addButton)+10;
//                
//                YZButton *deletebtn = [YZButton buttonWithType:UIButtonTypeCustom];
//                deletebtn.path = indexPath;
//                deletebtn.tabIndex = i;
//                deletebtn.frame = CGRectMake(0, 0, 40, 40);
//                UIImage *deleimage = [[UIImage imageNamed:@"btn_delete_tweetimage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                [deletebtn setImage:deleimage forState:UIControlStateNormal];
//                deletebtn.center = CGPointMake(kVIEW_BX(ivvv), kVIEW_TY(ivvv));
//                [deletebtn addTarget:self action:@selector(deleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
//                [sv addSubview:deletebtn];
//            }
//        }
//        sv.contentSize = CGSizeMake(width > kSCREEN_WIDTH ? width : kSCREEN_WIDTH, 100.f);
//        sv.showsHorizontalScrollIndicator = NO;
//        sv.showsVerticalScrollIndicator = NO;
        return cell;
    }
    UITableViewCell *Cell = [[UITableViewCell alloc]init];
    return Cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_sourceSectionArr.count == indexPath.section) {
        return 50.f;
    }
    NSArray *arr = _sourceSectionArr[indexPath.section];
    JoinFieldItem *item = arr[indexPath.row];
    if (item.dz_formtype == DZActivityFormType_TextArea) {
        return 150.f;
    }
    else if (item.dz_formtype == DZActivityFormType_File) {
        return 100.f;
    }
    else {
        return 50.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_sourceSectionArr.count == section) {
        return CGFLOAT_MIN;
    }
    NSArray *arr = _sourceSectionArr[section];
    if (arr.count == 1) {
        CGFloat height = 25.f;
        JoinFieldItem *item = arr[0];
        if (item.dz_formtype == DZActivityFormType_File || item.dz_formtype == DZActivityFormType_TextArea) {
            height = 25.f;
        } else {
            height = CGFLOAT_MIN;
        }
        return section == 0 ? height+40.f : height;
    } else {
        return section == 0 ? 40.f : CGFLOAT_MIN;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_sourceSectionArr.count == section) {
        return nil;
    }
    NSArray *arr = _sourceSectionArr[section];
    if (arr.count == 1) {
        JoinFieldItem *item = arr[0];
        if (item.dz_formtype == DZActivityFormType_File || item.dz_formtype == DZActivityFormType_TextArea) {
            if (section == 0) {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 25+40)];
                UILabel *laebl_tip = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH-40, 40.f)];
                laebl_tip.text = [NSString stringWithFormat:@"  注意：参加本活动将消耗您 %@ %@个",_credit_title,_credit];
                laebl_tip.font = [UIFont boldSystemFontOfSize:15.f];
                laebl_tip.textColor = [Util mainThemeColor];
                [view addSubview:laebl_tip];
                UILabel *laebl = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, kSCREEN_WIDTH-40, 25.f)];
                laebl.text = [NSString stringWithFormat:@"  %@",item.title ? item.title : @""];
                laebl.font = [UIFont systemFontOfSize:13.f];
                laebl.textColor = kColourWithRGB(153, 153, 153);
                [view addSubview:laebl];
                return view;
            } else {
                UILabel *laebl = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, kSCREEN_WIDTH-40, 25.f)];
                laebl.text = [NSString stringWithFormat:@"  %@",item.title ? item.title : @""];
                laebl.font = [UIFont systemFontOfSize:13.f];
                laebl.textColor = kColourWithRGB(153, 153, 153);
                return laebl;
            }
        }
    }
//    else {
        if (section == 0) {
            UILabel *laebl = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, kSCREEN_WIDTH-40, 40.f)];
            laebl.text = [NSString stringWithFormat:@"  注意：参加本活动将消耗您 %@ %@个",_credit_title,_credit];
            laebl.font = [UIFont boldSystemFontOfSize:15.f];
            laebl.textColor = [Util mainThemeColor];
            return laebl;
        } else {
            return nil;
        }
//    }
}


#pragma mark -  IQDropDownTextFieldDelegate

- (void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString*)item
{
    NSIndexPath *indexpath = textField.indexPath;
    if (indexpath) {
        NSArray *arr = _sourceSectionArr[indexpath.section];
        JoinFieldItem *jjjitem = arr[indexpath.row];
        jjjitem.fieldValue = item ? item : nil;
//        UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//        if (jjjitem.fieldValue) {
//            cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        } else {
//            cell.imageView.image = kIMG(@"act_select_n");
//        }
    }
}

- (void)textField:(IQDropDownTextField*)textField didSelectItems:(NSArray*)items
{
    NSIndexPath *indexpath = textField.indexPath;
    if (indexpath) {
        NSArray *arr = _sourceSectionArr[indexpath.section];
        JoinFieldItem *jjjitem = arr[indexpath.row];
        jjjitem.fieldValue = (items && items.count > 0)  ? items : nil;
//        UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//        if (jjjitem.fieldValue) {
//            cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        } else {
//            cell.imageView.image = kIMG(@"act_select_n");
//        }
    }
}


#pragma mark - textfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isKindOfClass:[IQTextField class]]) {
        IQTextField *iqTF = (IQTextField *)textField;
        NSIndexPath *indexpath = iqTF.indexPath;
        if (indexpath) {
            NSArray *arr = _sourceSectionArr[indexpath.section];
            JoinFieldItem *jjjitem = arr[indexpath.row];
            jjjitem.fieldValue = (textField.text && textField.text.length > 1) ? textField.text : nil;
//            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//            if (jjjitem.fieldValue) {
//                cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            } else {
//                cell.imageView.image = kIMG(@"act_select_n");
//            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField && [textField isKindOfClass:[IQTextField class]]) {
        IQTextField *iqTF = (IQTextField *)textField;
        NSIndexPath *indexpath = iqTF.indexPath;
        if (indexpath) {
            NSArray *arr = _sourceSectionArr[indexpath.section];
            JoinFieldItem *jjjitem = arr[indexpath.row];
            jjjitem.fieldValue = nil;
//            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//            if (jjjitem.fieldValue) {
//                cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            } else {
//                cell.imageView.image = kIMG(@"act_select_n");
//            }
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField && [textField isKindOfClass:[IQTextField class]]) {
        IQTextField *iqTF = (IQTextField *)textField;
        NSIndexPath *indexpath = iqTF.indexPath;
        if (indexpath) {
            NSArray *arr = _sourceSectionArr[indexpath.section];
            JoinFieldItem *jjjitem = arr[indexpath.row];
            jjjitem.fieldValue = (textField.text && textField.text.length > 1) ? textField.text : nil;
//            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//            if (jjjitem.fieldValue) {
//                cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            } else {
//                cell.imageView.image = kIMG(@"act_select_n");
//            }
        }
    }
}

#pragma mark - UITextViewDelegate 代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (textView && [textView isKindOfClass:[IQTextView class]]) {
        IQTextView *tv = (IQTextView *)textView;
        NSIndexPath *indexpath = tv.indexPath;
        if (indexpath) {
            NSArray *arr = _sourceSectionArr[indexpath.section];
            JoinFieldItem *jjjitem = arr[indexpath.row];
            jjjitem.fieldValue = (tv.text && tv.text.length > 1) ? tv.text : nil;
//            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//            if (jjjitem.fieldValue) {
//                cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            } else {
//                cell.imageView.image = kIMG(@"act_select_n");
//            }
        }
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView && [textView isKindOfClass:[IQTextView class]]) {
        IQTextView *tv = (IQTextView *)textView;
        NSIndexPath *indexpath = tv.indexPath;
        if (indexpath) {
            NSArray *arr = _sourceSectionArr[indexpath.section];
            JoinFieldItem *jjjitem = arr[indexpath.row];
            jjjitem.fieldValue = (tv.text && tv.text.length > 1) ? tv.text : nil;
//            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexpath];
//            if (jjjitem.fieldValue) {
//                cell.imageView.image = [[UIImage imageNamed:@"act_select_h"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            } else {
//                cell.imageView.image = kIMG(@"act_select_n");
//            }
        }
    }
}

#pragma mark - Action 
//提交
- (void)commitAction
{
    [self.view endEditing:YES];
    NSMutableArray *fileTypeImage = [NSMutableArray new];
    for (JoinFieldItem *item in _joinfieldArr) {
        if (![@"leaveMessage_dz" isEqualToString:item.formtype]) {
            if (!item.fieldValue) {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"请完善“%@”信息后在提交", item.title] cancelButtonTitle:@"好" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
                return;
            }
        }
        if (![self isValidateItem:item]) {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"“%@”信息格式不正确", item.title] cancelButtonTitle:@"好" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
            return;
        }
        if (item.dz_formtype == DZActivityFormType_File) {
            [fileTypeImage addObject:item];
        }
    }
    if (fileTypeImage.count > 0) {
        if (_uploadHash && _uploadHash.length > 0) {
            [self uploadFileImageWithItems:fileTypeImage];
        } else {
            //需要上传图片 上传图片需要拿到uploadHash  所以需要发帖前置检查
            WEAKSELF
            [_detailViewModel check_post_withfid:_fid andBlock:^(bool success, id data) {
                if (success && data) {
                    weakSelf.uploadHash = data;
                    [weakSelf uploadFileImageWithItems:fileTypeImage];
                }
            }];
        }
    } else {
        [self commitActivityInfo];
    }
}

- (void)uploadFileImageWithItems:(NSArray *)joinItems
{
    if (joinItems.count > 0) {
        JoinFieldItem *item = joinItems[0];
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [[Clan_NetAPIManager sharedManager] request_uploadAcitvityFileImage:item.fieldValue withFid:_fid withHash:_uploadHash andBlock:^(id data, bool success) {
            if (success) {
                if (item.fieldValue && [item.fieldValue isKindOfClass:[SendImage class]]) {
                    SendImage *imgaeSend = (SendImage *)item.fieldValue;
                    imgaeSend.fileURL = avoidNullStr([data valueForKey:@"abs_url"]);
                    if (joinItems.count == 1) {
                        [weakSelf dissmissProgress];
                        //图片上传完全结束
                        [weakSelf commitActivityInfo];
                    } else {
                        NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:joinItems];
                        [arr removeObject:item];
                        [weakSelf uploadFileImageWithItems:arr];
                    }
                } else {
                    [weakSelf dissmissProgress];
                    [weakSelf showHudTipStr:@"请选择附件图片"];
                    return;
                }
            } else {
                [weakSelf dissmissProgress];
                NSString *errorMess = data;
                [weakSelf showHudTipStr:errorMess];
                return ;
            }
        }];
    }
}

- (void)commitActivityInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (JoinFieldItem *item in _joinfieldArr) {
        if (item.dz_formtype == DZActivityFormType_File) {
            SendImage *attach = item.fieldValue;
            [dic setObject:attach.fileURL forKey:item.fieldid];
        }
        else {
            [dic setObject:item.fieldValue forKey:item.fieldid];
        }
    }
    for (JoinFieldItem *item in _extfield) {
        if (item.fieldValue) {
            [dic setObject:item.fieldValue forKey:item.fieldid];
        }
    }
    NSArray *arrLast = [_sourceSectionArr lastObject];
    if (arrLast.count > 0) {
        JoinFieldItem *item = arrLast[0];
        if ([@"leaveMessage_dz" isEqualToString:item.formtype]) {
            //留言信息
            [dic setObject:item.fieldValue ? item.fieldValue : @"暂无留言信息" forKey:item.fieldid];
        }
    }
    [self showProgressHUDWithStatus:@"" withLock:YES];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_JoinActivityWithParas:dic
                                                              withFid:_fid
                                                              withTid:_tid
                                                              withPid:_pid
                                                             andBlock:^(id data, NSError *error) {
                                                                 [weakSelf dissmissProgress];
                                                                 if (data) {
                                                                     NSDictionary *message = [data valueForKey:@"Message"];
                                                                     if (message && message[@"messageval"]) {
                                                                         NSString *messvalue = message[@"messageval"];
                                                                         NSString *messTip = message[@"messagestr"];
                                                                         if ([messvalue isEqualToString:@"activity_completion"]) {
                                                                             //活动申请成功
                                                                             [weakSelf showHudTipStr:messTip];
                                                                             if (weakSelf.navigationController) {
                                                                                 //把当前页面销毁 返回上一个页面
                                                                                 if (weakSelf.targetVC && [weakSelf.targetVC isKindOfClass:[PostDetailVC class]]) {
                                                                                     PostDetailVC *vc = (PostDetailVC *)weakSelf.targetVC;
                                                                                     [vc joinActivitySuccess:data];
                                                                                 }
                                                                                 [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                             }
                                                                         } else {
                                                                             //活动申请失败 提示原因
                                                                             [weakSelf showHudTipStr:messTip];
                                                                         }
                                                                     }
                                                                     
                                                                 } else {
                                                                     [weakSelf showHudTipStr:@"申请出错了，请重试~"];
                                                                 }
                                                             }];
}

//添加图片
- (IBAction)addImageAction:(id)sender
{
    if ([sender isKindOfClass:[YZButton class]]) {
        YZButton *btn = (YZButton *)sender;
        _selectFilePath = btn.path;
        [self.view endEditing:YES];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
        [actionSheet showInView:kKeyWindow];
    }
}

- (IBAction)deleteImageAction:(id)sender
{
    if ([sender isKindOfClass:[YZButton class]]) {
        YZButton *btn = (YZButton *)sender;
        NSIndexPath *path = btn.path;
        NSArray *arr = _sourceSectionArr[path.section];
        JoinFieldItem *item = arr[path.row];
        item.fieldValue = nil;
        [self.table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
//        if (fileImageData && [fileImageData isKindOfClass:[NSArray class]]) {
//            NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:fileImageData];
//            if (arr.count > index) {
//                [arr removeObjectAtIndex:index];
//                item.fieldValue = [[NSArray alloc] initWithArray:arr];
//                [self.table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
//        }
    }
}

//显示资料介绍
- (IBAction)showDescriptionAction:(id)sender
{
    if ([sender isKindOfClass:[YZButton class]]) {
        YZButton *descBtn = (YZButton *)sender;
        NSIndexPath *path = descBtn.path;
        NSArray *arr = _sourceSectionArr[path.section];
        JoinFieldItem *item = arr[path.row];
        [UIAlertView bk_showAlertViewWithTitle:item.title message:item.f_description cancelButtonTitle:@"了解了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }
}

//重置所有的信息
- (void)clearAllInfoAction
{
    [self.view endEditing:YES];
    WEAKSELF
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"确定丢弃所有已填写的资料？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //确定放弃
            for (JoinFieldItem *item in weakSelf.joinfieldArr) {
                item.fieldValue = nil;
            }
            [weakSelf.table reloadData];
        }
    }];
}

#pragma mark - UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
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
    } else if (buttonIndex == 1){
        //        相册
        if (![YZHelper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 1;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    } else {
        _selectFilePath = nil;
    }
    
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    SendImage *sendImg = [SendImage sendImageWithImage:[originalImage scaledToSize:Screen_Bounds.size highQuality:YES]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddHH";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    sendImg.fileName = [NSString stringWithFormat:@"%@%@",str,[UserModel currentUserInfo].uid];
    sendImg.size = 24;
    sendImg.fileType = @"jpg";
    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(originalImage, self,selectorToCall, NULL);
    }
    if (_selectFilePath) {
        NSArray *arr = _sourceSectionArr[_selectFilePath.section];
        JoinFieldItem *item = arr[_selectFilePath.row];
        item.fieldValue = sendImg;
//        NSMutableArray *arrfile = [[NSMutableArray alloc]initWithArray:item.fieldValue];
//        [arrfile addObject:sendImg];
//        item.fieldValue = [[NSArray alloc]initWithArray:arrfile];
        [_table reloadRowsAtIndexPaths:@[_selectFilePath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo
{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    if (_selectFilePath) {
        NSArray *arr = _sourceSectionArr[_selectFilePath.section];
        JoinFieldItem *item = arr[_selectFilePath.row];
        NSMutableArray *arrfile = [NSMutableArray new];
        for (ALAsset *assetItem in assets) {
            ALAssetRepresentation *assetRep = [assetItem defaultRepresentation];
            UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:assetItem];
            SendImage *sendImg = [SendImage sendImageWithImage:[highQualityImage scaledToSize:kScreen_Bounds.size highQuality:NO]];
            sendImg.fileName = assetRep.filename;
            sendImg.size = assetRep.size / 1024;
            sendImg.fileType = [assetRep.filename componentsSeparatedByString:@"."][1];
            [arrfile addObject:sendImg];
        }
        item.fieldValue = arrfile.count > 0 ? arrfile[0] : nil;
        [_table reloadRowsAtIndexPaths:@[_selectFilePath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

- (BOOL)isValidateItem:(JoinFieldItem *)item
{
    if (item.validate && item.validate.length > 0) {
        //有校验规则
        NSPredicate *format = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", item.validate];
        if ([item.fieldValue isKindOfClass:[NSString class]]) {
//            return [item.fieldValue evaluateWithObject:format];
            return YES;
        } else {
            //如果不是字符串就不用校验了
            return YES;
        }
    }
    else {
        //无校验规则
        return YES;
    }
}
@end
