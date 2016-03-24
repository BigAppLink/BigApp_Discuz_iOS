//
//  SettingViewController.m
//  Clan
//
//  Created by 昔米 on 15/4/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "SettingViewController.h"
#import "SDImageCache.h"
#import "ClanNetAPI.h"
#import <MessageUI/MessageUI.h>
#import<MessageUI/MFMailComposeViewController.h>
#import "AboutViewController.h"
#import "NSData+SDDataCache.h"

static NSString *noImgKey = @"NoImgMode";

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>
{
    UITableView *_table;
    NSArray *_titleArr;
    UISwitch *_switch;
    //    UIButton *_versionBtn;
    UILabel *_cacheLabel;
}
@property (strong, nonatomic) UISegmentedControl *segment;
@end

@implementation SettingViewController

#pragma mark - lefecycle


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self updateLayoutWithOrientation:self.interfaceOrientation];
}

- (void)dealloc
{
    DLog(@"Setting dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kCOLOR_BG_GRAY;
    self.title = @"设置";
    _titleArr = @[@"清除缓存", @"关于我们"];

    UISegmentedControl *selector = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"左边", @"禁用", @"右边", nil]];
    selector.layer.cornerRadius = 4.f;
    selector.layer.borderColor = [Util mainThemeColor].CGColor;
    selector.layer.borderWidth = 1.0f;
    selector.layer.masksToBounds = YES;
    selector.bounds = CGRectMake(0, 0, 138.f, 25);
    [selector setSelectedSegmentIndex:0];
    [selector addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    self.segment = selector;
    NSString *defaultValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"k_dz_returnTopBtn_Status"];
    [self.segment setSelectedSegmentIndex:defaultValue.intValue];
    
    UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    _switch = switchButton;
    _switch.exclusiveTouch = YES;
    _switch.on = [[NSUserDefaults standardUserDefaults] boolForKey:noImgKey];
    
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = kCLEARCOLOR;
    table.separatorColor = kCLEARCOLOR;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (kIOS8) {
        
        table.rowHeight = UITableViewAutomaticDimension;
        table.estimatedRowHeight = 70.0;
        
    }
    table.sectionFooterHeight = 0;
    _table = table;
    [self.view addSubview:table];
    [Util setExtraCellLineHidden:table];
    
    //缓存label
    _cacheLabel = [UILabel new];
    _cacheLabel.backgroundColor = kCLEARCOLOR;
    _cacheLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_SUBTITLE];
    _cacheLabel.textColor = K_COLOR_LIGHTGRAY;
    _cacheLabel.text = [self getCache];
    [_cacheLabel sizeToFit];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)segmentAction:(UISegmentedControl *)Seg
{
    id returnTopStatus = nil;
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index) {
        case 0:
            //左边
            returnTopStatus = @(0);
            break;
        case 1:
            //禁用
            returnTopStatus = @(1);
            break;
        case 2:
            //右边
            returnTopStatus = @(2);
            break;
            
        default:
            break;
    }
    NSNumber *ori = [[NSUserDefaults standardUserDefaults] objectForKey:@"k_dz_returnTopBtn_Status"];    
    if (returnTopStatus) {
        [[NSUserDefaults standardUserDefaults] setObject:returnTopStatus forKey:@"k_dz_returnTopBtn_Status"];
    }
    if (ori && ori.intValue != Index) {
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"k_dz_returnTopBtn_Status_changed" object:nil];
    }
}


#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? _titleArr.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.textLabel.font = [UIFont fontWithSize:14.f];
        UIImageView *line = [[UIImageView alloc]initWithImage:[Util imageWithColor:K_COLOR_MOST_LIGHT_GRAY]];
        [cell.contentView addSubview:line];
        line.tag = 4455;
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(cell.contentView.mas_leading).offset(15.f);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.height.equalTo(@(0.5));
            make.width.equalTo(@(kSCREEN_WIDTH-15));
        }];
    }
    //    cell.textLabel.font = [UIFont fitFontWithSize:K_FONTSIZE_TITLE];
    if (indexPath.section == 0) {
        
        cell.textLabel.text = _titleArr[indexPath.row];
        if ([_titleArr[indexPath.row] isEqualToString:@"省流量模式"]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryView = _switch;
        }
        else if ([_titleArr[indexPath.row] isEqualToString:@"清除缓存"]) {
            _cacheLabel.text = [self getCache];
            [_cacheLabel sizeToFit];
            cell.accessoryView = _cacheLabel;
        }
        else {
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.accessoryView = [[UIImageView alloc]initWithImage:kIMG(@"jiantou_me")];
        }
        if ([_titleArr[indexPath.row] isEqualToString:@"关于我们"]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.textLabel.textColor = K_COLOR_LIGHT_DARK;
        UIImageView *line = (UIImageView *)[cell.contentView viewWithTag:4455];
        line.hidden = indexPath.row == 3 ? YES : NO;
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = @"回到顶部按钮";
        cell.textLabel.textColor = K_COLOR_LIGHT_DARK;
        cell.accessoryView = _segment;
    }
    else if(indexPath.section == 2) {
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textColor = K_COLOR_LIGHT_DARK;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [UserModel currentUserInfo].logined ? 3 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 15)];
    view.backgroundColor = UIColorFromRGB(0xf3f3f3);
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        //TODO 退出登录
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"确定退出登录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (indexPath.section == 1) {
        return;
    }
    if ([_titleArr[indexPath.row] isEqualToString:@"清除缓存"]) {
        //清除缓存 版块儿数据 和 图片缓存
        CacheDBDao *cachedb = [CacheDBDao new];
        [cachedb cleanUpCache];
        SDImageCache *cache = [SDImageCache sharedImageCache];
        [cache clearDisk];
        [cache clearMemory];
        [NSData clearCache];
        [self showHudTipStr:@"缓存已清理"];
        [tableView reloadData];
    }
    else if ([_titleArr[indexPath.row] isEqualToString:@"给我们好评"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString returnStringWithPlist:kAPP_DOWNLOAD_URL]]];
    }
    else if ([_titleArr[indexPath.row] isEqualToString:@"关于我们"])
    {
        [self gotoAbout];
    }
}

- (IBAction)switchAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:_switch.on forKey:noImgKey];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateLayoutWithOrientation:toInterfaceOrientation];
}

- (void)updateLayoutWithOrientation:(UIInterfaceOrientation)orientation
{
    
}

- (NSString *)getCache
{
    NSUInteger integer = [[SDImageCache sharedImageCache] getSize];
    NSString *value = [NSString stringWithFormat:@"%.2fMB", integer/1024.0/1024.0];
    return value;
}

//发送邮件  feedBack
- (void)displayMailComposerSheet
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass !=nil) {
        if ([mailClass canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            
            picker.mailComposeDelegate =self;
            picker.title = @"意见反馈";
            [picker setSubject:[NSString stringWithFormat:@"意见反馈 For %@[v%@]",[Util appName] ,[Util currentAppVersion]]];
            // Set up recipients
            NSArray *toRecipients = [NSArray arrayWithObject:@"bigapp_01@163.com"];
            
            [picker setToRecipients:toRecipients];
            [self presentViewController:picker animated:YES completion:^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }];
        } else {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"您尚未设置邮箱账号，请先到系统“设置”->“邮件、通讯录、日历”中添加邮箱账户" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    } else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"设备不支持邮件功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            [self hideProgressHUDSuccess:YES andTipMess:@"已取消"];
            break;
        case MFMailComposeResultFailed:
            [self hideProgressHUDSuccess:NO andTipMess:@"发送失败了，请重试"];
        case MFMailComposeResultSaved:
            [self hideProgressHUDSuccess:YES andTipMess:@"已保存"];
        case MFMailComposeResultSent:
            [self hideProgressHUDSuccess:YES andTipMess:@"已发送"];
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
//        if (_logoutBlock) {
//            _logoutBlock();
//        }
        UserModel *_cuser = [UserModel currentUserInfo];
        [_cuser logout];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kKEY_CURRENT_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [ClanNetAPI removeCookieData];
        //清除收藏的数组
        [Util cleanUpLocalFavoArray];
        //清除信息
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"KNEWS_MESSAGE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_MESSAGE_COME" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"KNEWS_FRIEND_MESSAGE"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNEWS_FRIEND_MESSAGE" object:nil];
        [_table reloadData];
        [self showHudTipStr:@"已成功退出登录"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //    MessageComposeResultCancelled,
    //    MessageComposeResultSent,
    //    MessageComposeResultFailed
}

- (void)gotoAbout
{
    DLog(@"go to about");
    AboutViewController *about = [[AboutViewController alloc]init];
    [self.navigationController pushViewController:about animated:YES];
}

@end
