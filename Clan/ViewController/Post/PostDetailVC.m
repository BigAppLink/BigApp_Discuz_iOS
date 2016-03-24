//
//  PostDetailVC.m
//  Clan
//
//  Created by 昔米 on 15/10/19.
//  Copyright © 2015年 Youzu. All rights reserved.
//

#import "PostDetailVC.h"
#import "PostDetailViewModel.h"
#import "PostModel.h"
#import "PostDetailModel.h"
#import "PostSendViewController.h"
#import "PostListModel.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
#import "WebViewJavascriptBridge.h"
#import "MeViewController.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"
#import "PopoverView.h"
#import "CollectionViewModel.h"
#import "TOWebViewController.h"
#import "LoginViewController.h"
#import "NSString+Emojize.h"
#import "ReportViewController.h"
#import "RegexKitLite.h"
#import "JoinFieldItem.h"
#import "JoinActivityVC.h"
#import "UIAlertView+BlocksKit.h"
#import "ManageActivityVC.h"
#import "ApplyActivityItem.h"
#import <objc/runtime.h>
#import "UserInfoViewModel.h"
#import "UserInfoModel.h"
#import "RatingVC.h"
#import "ViewRatingsVC.h"
#import "CommentVC.h"

static const char associatedkey;
NSString * const k_h5_key_tid = @"tid"; //帖子主题id
NSString * const k_h5_key_aid = @"aid"; //文章id
NSString * const k_h5_key_authorid = @"authorid"; //作者id
NSString * const k_h5_key_page = @"page"; //页面
NSString * const k_h5_key_pid = @"pid"; //帖子id
NSString * const k_h5_key_pollanswers = @"pollanswers"; //投票选项
NSString * const k_h5_key_role = @"role";  //只看楼主 0全部 1楼主 other某人
NSString * const k_h5_key_uid = @"uid"; //用户id
NSString * const k_h5_key_text = @"text"; ////设置弹出框文本
NSString * const k_h5_key_imgArr = @"imgArr"; //需要预览的图片地址数组
NSString * const k_h5_key_current = @"current"; //当前需要浏览的图片下标
NSString * const k_h5_key_api = @"api"; //接口别名
NSString * const k_h5_key_data = @"data"; //请求的参数，可以为空，具体值根据后台接口需要
NSString * const k_h5_key_shareUrl = @"share_url"; //分享链接
NSString * const k_h5_key_shareImage = @"share_image"; //分享图片
NSString * const k_h5_key_shareSubject = @"share_subject" ;//分享标题
NSString * const k_h5_key_shareAbstract = @"share_abstract"; //分享摘要
NSString * const k_h5_key_authorName = @"author"; //作者名称

typedef enum {
    BigDetailApi_None = 0, // api映射出错
    bigApi_bbsDetail, //帖子详情
    bigApi_setVote, //投票
    bigApi_onDetailReport, //举报
    bigApi_onDetailLike, //点赞
    bigApi_onDetailReply, //回复
    bigApi_onDetailLikeMain, //主题点赞
    bigApi_protalDetail, //文章详情
    bigApi_joinActivity, //参加活动
    bigApi_cancleJoinActivity, //取消参加活动
    bigApi_manageActivityApplyList,//管理活动申请列表
    bigApi_ratePost, //帖子评分
    bigApi_viewRatings, //查看所有评分结果
    bigApi_addPostComment, //添加帖子点评
    bigApi_getPostCommentInfo,//帖子点评相关信息
    bigApi_payThread, //购买贴子
} BigApi;

@interface PostDetailVC () <UIWebViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
    BOOL _isShare;
}

@property (strong, nonatomic) NSArray *joinfield; //如果是活动的话 这些是活动的必填项目
@property (copy, nonatomic) NSString *credit_title; //参加活动要消耗的单位（金钱 积分 还是威望等）
@property (copy, nonatomic) NSString *credit; //参加活动要消耗对应单位的量值（比如 10个积分）

@property (strong, nonatomic) UISegmentedControl *segment;
@property (strong, nonatomic) PostDetailViewModel *detailViewModel;
@property (strong, nonatomic) CollectionViewModel *favoViewModel;
@property (strong, nonatomic) PostDetailModel *commentPostDetail;
@property (strong, nonatomic) MGTemplateEngine *webEngine; //html页面engine
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (copy, nonatomic) NSString *uploadHash;
//webiew
@property (strong, nonatomic) UIWebView *webview;
//跳页键盘
@property (strong, nonatomic) UIView *keyboardBarView;
//显示页码
@property (strong, nonatomic) UILabel *lblPageShow;
//页码输入框
@property (strong, nonatomic) UITextField *tfPageInput;
//回复按钮
@property (strong, nonatomic) UIButton *replyBtn;
//收藏按钮
@property (strong, nonatomic) UIButton *favoButton;
//只看楼主按钮
@property (strong, nonatomic) UIButton *viewMoreBtn;
//当前页
@property (assign) int currentPage;
//总页数
@property (assign) int totalPage;
//总楼数
@property (assign) int maxPosition;
//是否是楼主
@property (assign) BOOL isLouzhu;
//是否是楼主
@property (assign) BOOL isTiaoLou;
//是否加载完成
@property (assign) BOOL isLoadingCompleted;

//是否正在查看全部评论跳转
@property (assign) BOOL isViewingAllRatings;


@property(copy, nonatomic) NSString *shareImageURL;
@property (strong, nonatomic) NSDictionary *apiMappingDic;
@property (strong, nonatomic) UIButton *returnTopButton;
@property (assign) CGRect returnTopButton_orgFrame;
@property (assign) BOOL showBackTopBtn;

//js callback 集合
@property (strong, nonatomic) NSMutableDictionary *jsRespondsCallbackDic;


@end

@implementation PostDetailVC

#pragma mark - 生命周期
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //页面开始
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面结束
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    _favoViewModel = nil;
    _webEngine = nil;
    _webview.delegate = nil;
    [_webview loadHTMLString:@"" baseURL:nil];
    _webview = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UserModel currentUserInfo] removeObserver:self forKeyPath:@"logined"];
    
    DLog(@"----PostDetailVC dealloc 销毁了");
}

#pragma mark - 初始化
//数据源
- (void)loadModel
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    UserModel *cUser = [UserModel currentUserInfo];
    [cUser addObserver:self forKeyPath:@"logined" options:NSKeyValueObservingOptionNew context:NULL];
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"ShareCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"SendReply_Success" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"k_dz_returnTopBtn_Status_changed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCome:) name:@"k_dz_photobroswer_close" object:nil];
    //api映射表 要跟前端保持一直
    self.jsRespondsCallbackDic = [NSMutableDictionary new];
    self.apiMappingDic = @{
                           @"bigApi_bbsDetail" : @(bigApi_bbsDetail),
                           @"bigApi_setVote" : @(bigApi_setVote),
                           @"bigApi_onDetailReport" : @(bigApi_onDetailReport),
                           @"bigApi_onDetailLike" : @(bigApi_onDetailLike),
                           @"bigApi_onDetailReply" : @(bigApi_onDetailReply),
                           @"bigApi_onDetailLikeMain" : @(bigApi_onDetailLikeMain),
                           @"bigApi_protalDetail" : @(bigApi_protalDetail),
                           @"bigApi_joinActivity" : @(bigApi_joinActivity),
                           @"bigApi_cancleJoinActivity" : @(bigApi_cancleJoinActivity),
                           @"bigApi_manageActivityApplyList" : @(bigApi_manageActivityApplyList),
                           @"bigApi_ratePost" : @(bigApi_ratePost),
                           @"bigApi_viewRatings" : @(bigApi_viewRatings),
                           @"bigApi_addPostComment" : @(bigApi_addPostComment),
                           @"bigApi_getPostCommentInfo" : @(bigApi_getPostCommentInfo),
                           @"bigApi_payThread" : @(bigApi_payThread),
                           };
    self.detailViewModel = [PostDetailViewModel new];
}

//视图
- (void)buildUI
{
    self.title = @"帖子详情";
    UIWebView *web = nil;
    if (!_isArticle) {
        [self initBottomView];
        [self initNav];
        web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-44)];
    } else {
        self.title = @"文章详情";
        web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64)];
    }
    [self initKeyBoardBar];
    web.backgroundColor = kCOLOR_BG_GRAY;
    web.scrollView.delegate = self;
    self.webview = web;
    [self.view addSubview:web];
    [self buildBridge];
    [self loadExamplePage:_webview];
    [self resetReturnTopBtn];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];//指定进度轮的大小
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
    activity.tag = 1314;
    [self.view addSubview:activity];
    [activity startAnimating];
    if (_isArticle) {
        [activity setCenter:CGPointMake(kVIEW_CENTERX(self.view), kVIEW_CENTERY(self.view))];//指定进度轮中心点
    } else {
        [activity setCenter:CGPointMake(kVIEW_CENTERX(self.view), kVIEW_CENTERY(self.view)-20)];//指定进度轮中心点
    }
}

//底部栏
- (void)initBottomView
{
    UIView *bottomview = [UIView new];
    bottomview.layer.borderWidth = .5;
    bottomview.layer.borderColor = kCOLOR_BORDER.CGColor;
    bottomview.backgroundColor = [UIColor whiteColor];
    bottomview.exclusiveTouch = YES;
    [self.view addSubview:bottomview];
    UIView *superView = self.view;
    [bottomview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(superView.mas_leading).offset(-1);
        make.trailing.equalTo(superView.mas_trailing).offset(1);
        make.bottom.equalTo(superView.mas_bottom).offset(1);
        make.height.equalTo(@44);
    }];
    CGFloat space = 15.f;
    //评论按钮
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.showsTouchWhenHighlighted = YES;
    commentBtn.exclusiveTouch = YES;
    [commentBtn setImage:kIMG(@"detail_comments") forState:UIControlStateNormal];
    [commentBtn setTitle:@"  回复" forState:UIControlStateNormal];
    [commentBtn.titleLabel setFont:[UIFont fitFontWithSize:12.f]];
    [commentBtn setTitleColor:kUIColorFromRGB(0x6c6c6c) forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [bottomview addSubview:commentBtn];
    //收藏按钮
    UIButton *favoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoBtn.showsTouchWhenHighlighted = YES;
    favoBtn.exclusiveTouch = YES;
    //    NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forThreadType:YES] ? @"favo_H" : @"detail_favo";
    //    [favoBtn setImage:kIMG(favoImgName) forState:UIControlStateNormal];
    [favoBtn setTitle:@"  收藏" forState:UIControlStateNormal];
    [favoBtn.titleLabel setFont:[UIFont fitFontWithSize:12.f]];
    [favoBtn setTitleColor:kUIColorFromRGB(0x6c6c6c) forState:UIControlStateNormal];
    [favoBtn addTarget:self action:@selector(favoAction) forControlEvents:UIControlEventTouchUpInside];
    self.favoButton = favoBtn;
    [bottomview addSubview:favoBtn];
    [self resetFavoBtn];
    //分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.showsTouchWhenHighlighted = YES;
    shareBtn.exclusiveTouch = YES;
    [shareBtn setImage:kIMG(@"detail_share") forState:UIControlStateNormal];
    [shareBtn setTitle:@"  分享" forState:UIControlStateNormal];
    [shareBtn.titleLabel setFont:[UIFont fitFontWithSize:12.f]];
    [shareBtn setTitleColor:kUIColorFromRGB(0x6c6c6c) forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomview addSubview:shareBtn];
    float width = (kSCREEN_WIDTH-2*space)/3.0;
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bottomview.mas_leading).offset(space);
        make.top.equalTo(bottomview.mas_top);
        make.height.equalTo(@44);
        make.width.equalTo(@(width));
    }];
    [favoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(commentBtn.mas_trailing);
        make.top.equalTo(bottomview.mas_top);
        make.height.equalTo(@44);
        make.width.equalTo(@(width));
    }];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(favoBtn.mas_trailing);
        make.top.equalTo(bottomview.mas_top);
        make.height.equalTo(@44);
        make.width.equalTo(@(width));
    }];
}

- (void)resetReturnTopBtn
{
    _webview.scrollView.delegate = self;
    NSString *returnTopBtn = [[NSUserDefaults standardUserDefaults] objectForKey:@"k_dz_returnTopBtn_Status"];
    if (returnTopBtn.intValue == 1) {
        //禁用
        [_returnTopButton removeFromSuperview];
        _returnTopButton = nil;
        _showBackTopBtn = NO;
        return;
    }
    _showBackTopBtn = YES;
    if (returnTopBtn.intValue == 0) {
        //左边
        self.returnTopButton_orgFrame = CGRectMake(20, kSCREEN_HEIGHT-64-100, 34, 34);
    } else if (returnTopBtn.intValue == 2) {
        //右边
        self.returnTopButton_orgFrame = CGRectMake(kVIEW_W(self.view)-34-20, kSCREEN_HEIGHT-64-100, 34, 34);
    }
    if (!_returnTopButton) {
        self.returnTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_returnTopButton setImage:kIMG(@"icon_returnTop") forState:UIControlStateNormal];
        [_returnTopButton addTarget:self action:@selector(returnToTopAction:) forControlEvents:UIControlEventTouchUpInside];
        _returnTopButton.frame = CGRectMake(_returnTopButton_orgFrame.origin.x,kSCREEN_HEIGHT, 34, 34);
        [self.view addSubview:_returnTopButton];
    }
    CGRect rect = _returnTopButton.frame;
    rect.origin.x = _returnTopButton_orgFrame.origin.x;
    _returnTopButton.frame = rect;
}

- (void)initNav
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 1) {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = CGRectMake(0, 0, 26, 26);
        [leftButton setBackgroundImage :[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navback) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
        
    }
    UISegmentedControl *statFilter = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"全部", @"楼主", nil]];
    statFilter.layer.cornerRadius = 13.f;
    statFilter.layer.borderColor = [UIColor whiteColor].CGColor;
    statFilter.layer.borderWidth = 1.0f;
    statFilter.layer.masksToBounds = YES;
    statFilter.bounds = CGRectMake(0, 0, 138.f, 30.f);
    [statFilter setSelectedSegmentIndex:0];
    [statFilter addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    self.navigationItem.titleView = statFilter;
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 44)];
    UIButton *viewmore = [UIButton buttonWithTitle:nil andImage:@"more_N" andFrame:CGRectMake(rightView.right - 37, (44-30)/2, 37, 30) target:self action:@selector(viewMoreAction:)];
    viewmore.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    self.viewMoreBtn = viewmore;
    [rightView addSubview:viewmore];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -15;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
}

//跳页键盘
- (void)initKeyBoardBar
{
    self.keyboardBarView = [[UIView alloc]init];
    self.keyboardBarView.frame = CGRectMake(0, kSCREEN_HEIGHT-64, kSCREEN_WIDTH, 44);
    self.keyboardBarView.backgroundColor = kUIColorFromRGB(0xd1d5d9);
    
    [self.view addSubview:_keyboardBarView];
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setImage:kIMG(@"cancle_n") forState:UIControlStateNormal];
    [cancleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -12, 0, 0)];
    cancleBtn.exclusiveTouch = YES;
    [cancleBtn addTarget:self action:@selector(cancleInput:) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardBarView addSubview:cancleBtn];
    UIButton *jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jumpBtn setImage:kIMG(@"select_n") forState:UIControlStateNormal];
    jumpBtn.exclusiveTouch = YES;
    [jumpBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -12)];
    [jumpBtn addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardBarView addSubview:jumpBtn];
    UILabel *showLabel = [UILabel new];
    showLabel.textColor = [UIColor darkTextColor];
    self.lblPageShow = showLabel;
    [_keyboardBarView addSubview:showLabel];
    UITextField *tf = [[UITextField alloc]init];
    tf.borderStyle = UITextBorderStyleNone;
    tf.placeholder = @"请输入页码";
    tf.backgroundColor = kCLEARCOLOR;
    tf.keyboardType = UIKeyboardTypeNumberPad;
    self.tfPageInput = tf;
    [_keyboardBarView addSubview:tf];
    UIView *superView = self.keyboardBarView;
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(superView.mas_leading).offset(5);
        make.centerY.equalTo(superView.mas_centerY);
        make.width.equalTo(@50);
        make.height.equalTo(@36);
    }];
    [jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(superView.mas_trailing).offset(-5);
        make.centerY.equalTo(superView.mas_centerY);
        make.width.equalTo(@50);
        make.height.equalTo(@36);
    }];
    [_lblPageShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(jumpBtn.mas_leading).offset(-10);
        make.width.equalTo(@80);
        make.centerY.equalTo(superView.mas_centerY);
    }];
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(cancleBtn.mas_trailing).offset(8);
        make.trailing.equalTo(_lblPageShow.mas_leading).offset(-8);
        make.centerY.equalTo(superView.mas_centerY);
    }];
}


#pragma mark - 加载html页面
- (void)loadExamplePage:(UIWebView*)webView
{
        NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"www1/index" ofType:@"html"];
        NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
      NSURL *baseURL = [NSURL URLWithString:@"#/posts_detail?bigapp_device=ios" relativeToURL:[NSURL URLWithString:htmlPath]];
        [webView loadHTMLString:appHtml baseURL:baseURL];
    //for test - by ximi
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.180.23:8080/gaofy/newest/#/posts_detail?bigapp_device=ios"]]];
}


#pragma mark - Action Methods
- (void)navback
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//更多按钮
- (IBAction)viewMoreAction:(id)sender
{
    if (_isArticle) {
        NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forType:myArticle] ? @"detail_favo_H" : @"favo_N";
        NSArray *titls = @[@"收藏",@"分享"];
        NSArray *imgsN = @[favoImgName,@"share_N"];
        NSArray *imgsH = @[favoImgName,@"share_N"];
        PopoverView *pop = [[PopoverView alloc]initWithFromBarButtonItem:_viewMoreBtn inView:self.view titles:titls images:imgsN selectImages:imgsH];
        pop.selectIndex = 0;
        WEAKSELF
        pop.selectRowAtIndex = ^(NSInteger index)
        {
            STRONGSELF
            if (index == 0)
                [strongSelf favoPortalAction];
            else if (index == 1)
                [strongSelf shareAction];
        };
        [pop show];
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forType:myPost] ? @"detail_favo_H" : @"favo_N";
        NSArray *titls = @[@"收藏",@"分享", @"跳页",@"跳楼",@"举报"];
        NSArray *imgsN = @[favoImgName,@"share_N", @"jump_N",@"detail_tiaolou",@"jubao"];
        NSArray *imgsH = @[favoImgName,@"share_N", @"jump_N",@"detail_tiaolou",@"jubao"];
        NSString *fid = responseData[@"fid"];
        NSString *tid = responseData[@"tid"];
        NSString *ismoderator = responseData[@"ismoderator"];
        //for test - by ximi
        if (ismoderator && ismoderator.intValue == 1) {
            titls = @[@"收藏",@"分享", @"跳页",@"跳楼",@"举报",@"删除主题"];
            imgsN = @[favoImgName,@"share_N", @"jump_N",@"detail_tiaolou",@"jubao",@"detail_delete"];
            imgsH = @[favoImgName,@"share_N", @"jump_N",@"detail_tiaolou",@"jubao",@"detail_delete"];
        }
        PopoverView *pop = [[PopoverView alloc]initWithFromBarButtonItem:_viewMoreBtn inView:self.view titles:titls images:imgsN selectImages:imgsH];
        pop.selectIndex = 0;
        pop.selectRowAtIndex = ^(NSInteger index)
        {
            if (index == 0)
            {
                [weakSelf favoAction];
            }
            else if (index == 1)
            {
                [weakSelf shareAction];
            }
            else if (index == 2)
            {
                [weakSelf jumpPageAction];
            }
            else if(index == 3)
            {
                [weakSelf tiaolouAction];
            }
            else if(index == 4)
            {
                [weakSelf reportAction];
            }
            else if (index == 5)
            {
                [weakSelf deletePostWithTid:tid withFid:fid];
            }
            else if (index == 6)
            {
                //打印源码
                [weakSelf showSource];
            }
        };
        [pop show];
    }];
}

//只看楼主
- (void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index) {
        case 0:
            _isLouzhu = NO;
            [self viewAuthorOnlyAction];
            break;
        case 1:
            _isLouzhu = YES;
            [self viewAuthorOnlyAction];
            break;
        default:
            break;
    }
}

//只看楼主
- (IBAction)viewAuthorOnlyAction
{
    [_tfPageInput resignFirstResponder];
    NSDictionary *dic = @{@"role" : _isLouzhu ? @"1" : @"0"};
    [_bridge callHandler:@"viewAutherOnly" data:dic responseCallback:^(id responseData) {
        
    }];
}

//跳页
- (void)jumpPageAction
{
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        DLog(@"responseData");
        weakSelf.tfPageInput.placeholder = @"请输入页码";
        NSNumber *totalPage = responseData[@"totalPage"];
        NSNumber *currentPage = responseData[@"page"];
        //取得当前页码 和 总页码
        weakSelf.currentPage = currentPage.intValue;
        weakSelf.totalPage = totalPage.intValue;
        NSString *value = [NSString stringWithFormat:@"%d/%d页", weakSelf.currentPage, weakSelf.totalPage];
        weakSelf.lblPageShow.text = value;
        weakSelf.tfPageInput.text = @"";
        [weakSelf.tfPageInput becomeFirstResponder];
        weakSelf.isTiaoLou = NO;
    }];
}

//跳页
- (IBAction)jumpAction:(id)sender
{
    int total = _isTiaoLou ? _maxPosition : _totalPage;
    if (!self.tfPageInput.text
        || [@"" isEqualToString:_tfPageInput.text]
        || self.tfPageInput.text.intValue < 1
        || self.tfPageInput.text.intValue > total) {
        [self showHudTipStr: _isTiaoLou? @"您输入的楼层有误" : @"您输入的页码有误"];
        return;
    }
    NSDictionary *dic = _isTiaoLou ? @{@"position":_tfPageInput.text} : @{@"page":_tfPageInput.text};
    WEAKSELF
    [_bridge callHandler:@"jumpAction" data:dic responseCallback:^(id responseData) {
        DLog(@"----%@",responseData);
        [weakSelf.tfPageInput resignFirstResponder];
    }];
}

//举报
- (void)reportAction
{
    if (![self checkLoginState]) {
        return;
    }
    ReportViewController *report = [[ReportViewController alloc]init];
    //    report.reportModel = _reportModel;
    [self.navigationController pushViewController:report animated:YES];
}

//删除主题
- (void)deletePostWithTid:(NSString *)tid withFid:(NSString *)fid
{
    if (![self checkLoginState]) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定删除该主题？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alert.tag = 8888;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"删除主题的原因"];
    [alert textFieldAtIndex:0].tintColor = [Util mainThemeColor];
    [[alert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    [alert show];
    NSDictionary *dic = @{@"tid":avoidNullStr(tid), @"fid":avoidNullStr(fid)};
    objc_setAssociatedObject(alert, &associatedkey, dic,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//点击图片
- (void)clickImageAction:(id)paraData
{
    NSArray *imgArray = [paraData valueForKey:k_h5_key_imgArr];
    NSString *selectedIndex = [paraData valueForKey:k_h5_key_current];
    NSMutableArray *urls = [NSMutableArray new];
    for (NSString *urlStr in imgArray) {
        //兼容ios 7 & ios 8
        if ([urlStr rangeOfString:@"bigapp:optpic"].location != NSNotFound)
            //             if ([urlStr containsString:@"bigapp:optpic"])
        {
            NSString *bigUrl = [urlStr stringByAppendingString:@"&size="];
            [urls addObject:[NSURL URLWithString:bigUrl]];
        } else {
            [urls addObject:[NSURL URLWithString:urlStr]];
        }
    }
    if (imgArray.count > 0) {
        self.shareImageURL = imgArray[0];
    }
    //go to 相册浏览
    [self jumpToWebBroswerWithImgUrls:urls andSelectedIndex:selectedIndex.intValue];
}

//点击头像
- (void)clickAvatarAction:(id)paraData
{
    NSString *uid = [paraData valueForKey:k_h5_key_uid];
    if (uid && [uid isKindOfClass:[NSString class]] && uid.length > 0) {
        UserModel *user = [UserModel new];
        user.uid = uid;
        [self jumpToMemberCenterWithUser:user]; //跳转到个人中心
    }
}

//分享
- (void)shareAction
{
    [_tfPageInput resignFirstResponder];
    WEAKSELF
    [_bridge callHandler:@"getShareInfo" data:nil responseCallback:^(id responseData) {
        if (responseData) {
            DLog(@"shareAction");
            NSString *shareURL = responseData[k_h5_key_shareUrl];
            NSString *shareImageUrl = responseData[k_h5_key_shareImage];
            NSString *descrip = responseData[k_h5_key_shareAbstract];
            NSString *shareTitle = responseData[k_h5_key_shareSubject];
            [weakSelf dealWithShareInfo:shareURL
                             shareImage:shareImageUrl
                             shareTitle:shareTitle
                           shareContent:descrip];
        } else {
            [weakSelf showHudTipStr:@"分享出错，请重试"];
        }
    }];
}

//取消跳页键盘
- (IBAction)cancleInput:(id)sender
{
    [self.tfPageInput resignFirstResponder];
}

// 发表回复
- (void)comment:(id)sender
{
    if (![self checkLoginState]) {
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *fid = responseData[@"fid"];
        NSString *tid = responseData[@"tid"];
        if (!fid || !tid || fid.length == 0 || tid.length == 0) {
            return ;
        }
        PostDetailModel *Model = [PostDetailModel new];
        Model.fid = fid;
        Model.tid = tid;
        [weakSelf jumpToReplyPostPageWithModel:Model];
    }];
}
//收藏取消收藏
- (void)favoPortalAction
{
    if ([self checkLoginState]) {
        WEAKSELF
        if (![Util isFavoed_withID:_postModel.tid forType:myArticle]) {
            [_favoViewModel doAnArticleByID:weakSelf.postModel.tid andBlock:^(BOOL success) {
                if (success) {
                    DLog(@"收藏成功");
                }
            }];
        } else {
            [_favoViewModel request_DeleteCollection:[Util getFavoIDFromID:_postModel.tid forType:myArticle] andType:@"aid" andBlock:^(BOOL state) {
                if (state) {
                    //删除成功 删除本地记录
                    [Util deleteFavoed_withID:weakSelf.postModel.tid forType:myArticle];
                }
            }];
        }
    }
}

//收藏取消收藏
- (void)favoAction
{
    if (![self checkLoginState]) {
        return;
    }
    if (!self.favoViewModel) {
        self.favoViewModel = [CollectionViewModel new];
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *tid = responseData[@"tid"];
        if (!tid || tid.length == 0) {
            tid = _postModel.tid;
        }
        if (![Util isFavoed_withID:tid forType:myPost]) {
            [weakSelf.favoViewModel doFavoAPostByID:tid andBlock:^(BOOL success) {
                STRONGSELF
                if (success) {
                    DLog(@"收藏成功");
                }
                [strongSelf resetFavoBtn];
            }];
        } else {
            [weakSelf.favoViewModel request_DeleteCollection:[Util getFavoIDFromID:tid forType:myPost] andType:myPost andBlock:^(BOOL state) {
                STRONGSELF
                if (state) {
                    //删除成功 删除本地记录
                    [Util deleteFavoed_withID:tid forType:myPost];
                }
                [strongSelf resetFavoBtn];
            }];
        }
    }];
    
}

//跳楼时间
- (void)tiaolouAction
{
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        DLog(@"responseData");
        weakSelf.tfPageInput.placeholder = @"请输入楼层号";
        NSNumber *totalposition = responseData[@"maxposition"];
        //取得当前页码 和 总页码
        weakSelf.maxPosition = totalposition.intValue;
        NSString *value = [NSString stringWithFormat:@"共%d楼", weakSelf.maxPosition];
        weakSelf.lblPageShow.text = value;
        weakSelf.tfPageInput.text = @"";
        [weakSelf.tfPageInput becomeFirstResponder];
        weakSelf.isTiaoLou = YES;
    }];
}

//返回顶部
- (IBAction)returnToTopAction:(id)sender
{
    [self.webview.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

//显示返回顶部按钮
- (void)showBackTopButton
{
    WEAKSELF
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.returnTopButton.frame = _returnTopButton_orgFrame;
    } completion:NULL];
}

//隐藏返回顶部按钮
- (void)hideBackTopButton
{
    WEAKSELF
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.returnTopButton.frame = CGRectMake(weakSelf.returnTopButton_orgFrame.origin.x, kSCREEN_HEIGHT, weakSelf.returnTopButton_orgFrame.size.width, weakSelf.returnTopButton_orgFrame.size.height);
    } completion:NULL];
}


//评分按钮
- (void)rateAction:(NSString *)pid
{
    if (![self checkLoginState]) {
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *tid = responseData[@"tid"];
        if (!tid || !pid || tid.length <= 0 || pid.length <= 0) {
            return ;
        }
        [weakSelf showProgressHUDWithStatus:@"" withLock:YES];
        [[Clan_NetAPIManager sharedManager] request_ratingInfoForPostTid:tid
                                                                 withPid:pid
                                                                andBlock:^(id data, NSError *error) {
                                                                    [weakSelf dissmissProgress];
                                                                    if (data && [data valueForKey:@"Variables"]) {
                                                                        NSDictionary *dataDic = [data valueForKey:@"Variables"];
                                                                        if (dataDic[@"status"]) {
                                                                            NSString *status = dataDic[@"status"];
                                                                            if (status && status.intValue == 1) {
                                                                                //可以评分
                                                                                NSArray *ratelist = dataDic[@"ratelist"];
                                                                                NSArray *defaultReasons = dataDic[@"reasons"];
                                                                                RatingVC *rateVC = [[RatingVC alloc]init];
                                                                                rateVC.ratelist = [[NSArray alloc]initWithArray:ratelist];
                                                                                rateVC.reasons = defaultReasons;
                                                                                rateVC.tid = tid;
                                                                                rateVC.pid = pid;
                                                                                rateVC.targetVC = weakSelf;
                                                                                [weakSelf.navigationController pushViewController:rateVC animated:YES];
                                                                                return ;
                                                                            } else {
                                                                                //不可评分
                                                                                if ([data valueForKey:@"Message"]) {
                                                                                    NSDictionary *message = [data valueForKey:@"Message"];
                                                                                    NSString *messTip = message[@"messagestr"];
                                                                                    if (messTip && messTip.length > 0) {
                                                                                        [weakSelf showHudTipStr:messTip];
                                                                                        return ;
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    [weakSelf showHudTipStr:@"抱歉，暂不能评分"];
                                                                }];

    }];
}

//查看评分按钮
- (void)viewRatingsActions:(NSString *)pid
{
    [self.view endEditing:YES];
    if (![self checkLoginState]) {
        _isViewingAllRatings = NO;
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *tid = responseData[@"tid"];
        if (!tid || !pid || tid.length <= 0 || pid.length <= 0) {
            weakSelf.isViewingAllRatings = NO;
            return ;
        }
        ViewRatingsVC *viewratings = [[ViewRatingsVC alloc]init];
        viewratings.tid = tid;
        viewratings.pid = pid;
        [weakSelf.navigationController pushViewController:viewratings animated:YES];
        weakSelf.isViewingAllRatings = NO;
    }];
}

//参加活动
- (void)joinActivityWithPid:(NSString *)pid withJoinFeild:(NSArray *)array withExtfield:(NSArray *)extArr
{
    if (![self checkLoginState]) {
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *fid = responseData[@"fid"];
        NSString *tid = responseData[@"tid"];
        if (!tid || !pid || !fid || tid.length <= 0 || pid.length <= 0 || fid.length <= 0) {
            return ;
        }
        JoinActivityVC *joinActivity = [[JoinActivityVC alloc]init];
        joinActivity.tid = tid;
        joinActivity.fid = fid;
        joinActivity.pid = pid;
        joinActivity.joinfieldArr = [[NSArray alloc]initWithArray:_joinfield];
        joinActivity.extfield = [[NSArray alloc]initWithArray:extArr];
        joinActivity.credit = _credit;
        joinActivity.credit_title = _credit_title;
        joinActivity.uploadHash = _uploadHash;
        joinActivity.targetVC = weakSelf;
        [weakSelf.navigationController pushViewController:joinActivity animated:YES];
    }];
}

//取消参加活动
- (void)cancleJoinActivityActionWithPid:(NSString *)pid
{
    if (![self checkLoginState]) {
        return;
    }
    if (!pid || pid.length <= 0) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取消参加活动" message:@"" delegate:self cancelButtonTitle:@"不取消" otherButtonTitles:@"取消参加", nil];
    alert.tag = 8899;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入取消参加活动的理由~"];
    [alert textFieldAtIndex:0].tintColor = [Util mainThemeColor];
    [[alert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
    [alert show];
    objc_setAssociatedObject(alert, &associatedkey, pid,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//管理活动申请者列表
- (void)manageApplyListsActionWithPid:(NSString *)pid
{
    if (![self checkLoginState]) {
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *fid = responseData[@"fid"];
        NSString *tid = responseData[@"tid"];
        if (!tid || !pid || !fid || tid.length <= 0 || pid.length <= 0 || fid.length <= 0) {
            return ;
        }
        ManageActivityVC *man = [[ManageActivityVC alloc]init];
        man.tid = tid;
        man.pid = pid;
        man.fid = fid;
        [weakSelf.navigationController pushViewController:man animated:YES];
    }];
}

//帖子点评
- (void)commentPostActionWithPid:(NSString *)pid
{
    if (![self checkLoginState]) {
        return;
    }
    WEAKSELF
    [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
        NSString *tid = responseData[@"tid"];
        if (!tid || tid.length == 0) {
            tid = _postModel.tid;
        }
        //帖子点评前置检查
        [weakSelf showProgressHUDWithStatus:@"" withLock:YES];
        [[Clan_NetAPIManager sharedManager] request_checkCommentPostWithtid:tid
                                                                    withPid:pid
                                                                   andBlock:^(id data, NSError *error) {
                                                                       [weakSelf dissmissProgress];
                                                                       if (data && [data valueForKey:@"Variables"]) {
                                                                           NSDictionary *dataDic = [data valueForKey:@"Variables"];
                                                                           NSString *status = dataDic[@"status"];
                                                                           if (status && status.intValue == 1) {
                                                                               //可以点评
                                                                               CommentVC *comment = [[CommentVC alloc]init];
                                                                               comment.tid = tid;
                                                                               comment.pid = pid;
                                                                               comment.targetVC = weakSelf;
                                                                               comment.commentFeild = dataDic[@"comment_fields"];
                                                                               [weakSelf.navigationController pushViewController:comment animated:YES];
                                                                           } else {
                                                                               [weakSelf showHudTipStr:@"抱歉，您没有权限点评帖子"];
                                                                           }
                                                                       } else {
                                                                           [weakSelf showHudTipStr:@"出错了，请重试"];
                                                                       }
                                                                   }];
    }];
    
}

//购买主题
- (void)payThreadActionWithTid:(NSString *)tid withPid:(NSString *)pid
{
    if (![self checkLoginState]) {
        return;
    }
    [self showProgressHUDWithStatus:@"" withLock:YES];
    //购买主题前置检查
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_threadpayInfoWithTid:tid
                                                             withPid:pid
                                                            andBlock:^(id data, NSError *error) {
                                                                [weakSelf dissmissProgress];
                                                                if (data) {
                                                                    NSDictionary *dic = [data valueForKey:@"Message"];
                                                                    NSString *messageval = dic[@"messageval"];
                                                                    NSString *messageStr = dic[@"messagestr"];
                                                                    if (dic) {
                                                                        //不允许购买 出错了
                                                                        if (messageval && [@"credits_balance_insufficient" isEqualToString:messageval]) {
                                                                            [weakSelf showHudTipStr:@"金额不足，请到PC端充值"];
                                                                        } else {
                                                                            [weakSelf showHudTipStr:messageStr ? messageStr : @"出错了，联系管理员"];
                                                                        }
                                                                    } else {
                                                                        NSDictionary *dataDic = [data valueForKey:@"Variables"];
                                                                        //允许购买
                                                                        //  author：作者用户名
                                                                        NSString *author = dataDic[@"author"];
                                                                        //消耗的积分类型，比如 金钱、威望等
                                                                        NSString *title = dataDic[@"title"];
                                                                        //本篇主题的售价
                                                                        NSString *price = dataDic[@"price"];
                                                                        //购买本主题后，用户还剩下多少钱
                                                                        NSString *balance = dataDic[@"balance"];
                                                                        //本片主题售出后作者可以得到多少钱（税后收入）
                                                                        NSString *netprice = dataDic[@"netprice"];
                                                                        NSString *payMessage = [NSString stringWithFormat:@"作者：%@\n 售价(%@)：    %@\n 作者所得(%@)：  %@\n 购买后余额(%@)：%@", author, title, price, title, netprice, title, balance];
                                                                        [UIAlertView bk_showAlertViewWithTitle:@"购买主题" message:payMessage cancelButtonTitle:@"取消" otherButtonTitles:@[@"购买"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                            if (buttonIndex == 1) {
                                                                                //去购买了
                                                                                [weakSelf payThreadActionWithTid:tid];
                                                                            }
                                                                        }];
                                                                    }
                                                                } else {
                                                                    [weakSelf showHudTipStr:NetError];
                                                                }
                                                            }];
}


//购买主题
- (void)payThreadActionWithTid:(NSString *)tid
{
    if (![self checkLoginState]) {
        return;
    }
    [self showProgressHUDWithStatus:@"" withLock:YES];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_payThreadWithTid:tid andBlock:^(id data, NSError *error) {
        [weakSelf dissmissProgress];
        if (data) {
            NSDictionary *dic = [data valueForKey:@"Message"];
            NSString *messageval = dic[@"messageval"];
            NSString *messageStr = dic[@"messagestr"];
            [weakSelf showHudTipStr:messageStr];
            if (messageval && [@"thread_pay_succeed" isEqualToString:messageval]) {
                //购买成功了 通知H5购买成功了
                [weakSelf callbackResponseWithData:data forBigApi:bigApi_payThread];
            }
        } else {
            [weakSelf showHudTipStr:NetError];
        }
        }];
}

#pragma mark - 桥接器
//建立桥接器
- (void)buildBridge
{
    WebViewJavascriptBridge *bg = [WebViewJavascriptBridge bridgeForWebView:self.webview
                                                            webViewDelegate:self
                                                                    handler:^(id data, WVJBResponseCallback responseCallback) {
                                                                        
                                                                        
                                                                    }];
    self.bridge = bg;
    [self registerHandlerForBridge:bg];
}

//注册js监听事件 (js调用native方法)
- (void)registerHandlerForBridge:(WebViewJavascriptBridge *)bridge
{
    WEAKSELF
    //“获取app环境信息”
    [bridge registerHandler:@"getEnvironment" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         id obj = [weakSelf getEnvironment];
         responseCallback(obj);
     }];
    
    //获取数据（帖子详情）
    [bridge registerHandler:@"getData" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data) {
            [weakSelf distributeAPIWithParas:data withResponseCallback:responseCallback];
        }
    }];
    
    //点击图片
    [bridge registerHandler:@"clickImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data) {
            if (responseCallback) {
                [weakSelf.jsRespondsCallbackDic setObject:responseCallback forKey:@"clickImage"];
            }
            [weakSelf clickImageAction:data];
            NSDictionary *dic = [weakSelf parasReturnToJSWithRequestResultSuccess:YES andData:@"success"];
            responseCallback(dic);
        }
    }];
    
    //点击头像
    [bridge registerHandler:@"clickAvatar" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data) {
            [weakSelf clickAvatarAction:data];
            NSDictionary *dic = [weakSelf parasReturnToJSWithRequestResultSuccess:YES andData:@"success"];
            responseCallback(dic);
        }
    }];
    
    //显示提示语
    [bridge registerHandler:@"showToast" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *text = data[k_h5_key_text];
        NSString *type = data[@"type"];
        if (type && [@"toastType_closePage" isEqualToString:type]) {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:text cancelButtonTitle:@"好" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (weakSelf.navigationController) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                }
            }];
        } else {
            [weakSelf showHudTipStr:text];
        }
    }];
}
#pragma mark - 分发API 传数据给h 5
//分发api
- (void)distributeAPIWithParas:(id)data withResponseCallback:(WVJBResponseCallback)responseCallback
{
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSString *api_name = data[k_h5_key_api];
        BigApi apitype = [self apiMappingForApiKey:api_name];
        NSDictionary *parasdic = data[k_h5_key_data];
        
        switch (apitype) {
                //帖子详情
            case bigApi_bbsDetail:
            {
                UIActivityIndicatorView *activity = [self.view viewWithTag:1314];
                NSString *tid = parasdic[k_h5_key_tid];
                NSString *authorId = parasdic[k_h5_key_authorid];
                NSString *page = parasdic[k_h5_key_page];
                NSString *postion = parasdic[@"postno"];
                if (!isNull(postion)) {
                    WEAKSELF
                    [[Clan_NetAPIManager sharedManager]request_postDetailWithTid:tid withJumpPostion:postion andBlock:^(id data, NSError *error) {
                        if (activity) {
                            [activity stopAnimating];
                            [activity removeFromSuperview];
                        }
                        STRONGSELF
                        id returnPara = [strongSelf parasReturnToJSWithRequestResultSuccess:error ? NO : YES andData:data];
                        responseCallback(returnPara);
                    }];
                } else {
                    WEAKSELF
                    [[Clan_NetAPIManager sharedManager]request_postDetailWithTid:tid withAuthorID:authorId atPage:page.intValue andBlock:^(id data, NSError *error) {
                        if (activity) {
                            [activity stopAnimating];
                            [activity removeFromSuperview];
                        }
                        STRONGSELF
                        id returnPara = [strongSelf parasReturnToJSWithRequestResultSuccess:error ? NO : YES andData:data];
                        responseCallback(returnPara);
                    }];
                }
                break;
            }
                //帖子点赞
            case bigApi_onDetailLike:
            {
                if (![self checkLoginState]) {
                    return;
                }
                NSString *tid = parasdic[k_h5_key_tid];
                NSString *pid = parasdic[k_h5_key_pid];
                if (tid && pid && tid.length > 0 && pid.length > 0) {
                    WEAKSELF
                    [[Clan_NetAPIManager sharedManager] request_support_APost:tid withPid:pid withResultBlock:^(id data, NSError *error) {
                        STRONGSELF
                        id returnPara = [strongSelf parasReturnToJSWithRequestResultSuccess:error ? NO : YES andData:data];
                        responseCallback(returnPara);
                    }];
                }
                break;
            }
                //主题点赞
            case bigApi_onDetailLikeMain:
            {
                if (![self checkLoginState]) {
                    return;
                }
                NSString *tid = parasdic[k_h5_key_tid];
                if (!tid || tid.length == 0) {
                    tid = _postModel.tid;
                }
                WEAKSELF
                [[Clan_NetAPIManager sharedManager] request_support_AThread:tid withResultBlock:^(id data, NSError *error) {
                    STRONGSELF
                    id returnPara = [strongSelf parasReturnToJSWithRequestResultSuccess:error ? NO : YES andData:data];
                    responseCallback(returnPara);
                }];
                break;
            }
                //投票
            case bigApi_setVote:
            {
                if (![self checkLoginState]) {
                    return;
                }
                NSString *tid = parasdic[k_h5_key_tid];
                NSString *fid = parasdic[@"fid"];
                NSArray *pollanswers = parasdic[k_h5_key_pollanswers];
                if (!tid || !fid || tid.length == 0 || fid.length ==0) {
                    break;
                    return;
                }
                WEAKSELF
                [[Clan_NetAPIManager sharedManager] request_doVote:tid withfid:avoidNullStr(fid) withPollanswers:pollanswers WithBlock:^(id data, NSError *error) {
                    if (data && [data valueForKey:@"Message"]) {
                        NSDictionary *dic = [data valueForKey:@"Message"];
                        NSString *messageval = dic[@"messageval"];
                        NSString *messageStr = dic[@"messagestr"];
                        if (messageStr) {
                            [weakSelf showHudTipStr:messageStr];
                        }
                        if ([@"thread_poll_succeed" isEqualToString:messageval]) {
                            id returnPara = [weakSelf parasReturnToJSWithRequestResultSuccess:YES andData:data];
                            responseCallback(returnPara);
                            return ;
                        }
                    }
                    STRONGSELF
                    id returnPara = [strongSelf parasReturnToJSWithRequestResultSuccess:NO andData:data];
                    responseCallback(returnPara);
                }];
                break;
            }
                //回复帖子
            case bigApi_onDetailReply:
            {
                if (![self checkLoginState]) {
                    return;
                }
                NSString *pid = parasdic[k_h5_key_pid];
                NSString *tid = parasdic[k_h5_key_tid];
                NSString *fid = parasdic[@"fid"];
                NSString *author = parasdic[@"author"];
                NSString *dateline = parasdic[@"dateline"];
                NSString *postmessage = parasdic[@"message"];
                if (!pid || !tid || !fid || pid.length == 0 || tid.length == 0 || fid.length == 0) {
                    return;
                }
                PostDetailModel *Model = [PostDetailModel new];
                Model.pid = pid;
                Model.author = author;
                Model.tid = tid;
                Model.fid = fid;
                Model.uploadhash = self.uploadHash;
                Model.dbdateline = dateline;
                Model.textMessage = postmessage;
                [self jumpToReplyPostPageWithModel:Model];
                break;
            }
                //举报
            case bigApi_onDetailReport:
            {
                ReportViewController *repostVc = [[ReportViewController alloc]init];
                repostVc.state = ClanReportTPost;
                [self.navigationController pushViewController:repostVc animated:YES];
                id returnPara = [self parasReturnToJSWithRequestResultSuccess:YES andData:@"success"];
                responseCallback(returnPara);
                break;
            }
                //文章详情
            case bigApi_protalDetail:
            {
                NSString *aid = parasdic[k_h5_key_aid];
                WEAKSELF
                [[Clan_NetAPIManager sharedManager]request_articleDetailWithId:aid andBlock:^(id data, NSError *error) {
                    STRONGSELF
                    id returnPara = [strongSelf parasReturnToJSWithRequestResultSuccess:error ? NO : YES andData:data];
                    responseCallback(returnPara);
                }];
                break;
            }
                //参加活动
            case bigApi_joinActivity:
            {
                NSString *pid = parasdic[@"pid"];
                if (!pid || pid.length == 0) {
                    return;
                }
                id obj = parasdic[@"special_activity"];
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *special_activityDatas = (NSDictionary *)obj;
                    //取到参加活动需要的单位 及其对应单位的量
                    self.credit_title = special_activityDatas[@"credit_title"];
                    self.credit = special_activityDatas[@"credit"];
                    id joinfiled_arr = special_activityDatas[@"joinfield"];
                    id extfield_arr = special_activityDatas[@"ufield"][@"extfield"];
                    NSMutableArray *joinFileds_arrM = [NSMutableArray new];
                    if (joinfiled_arr && [joinfiled_arr isKindOfClass:[NSArray class]]) {
                        for (id obj in joinfiled_arr) {
                            JoinFieldItem *item = [JoinFieldItem objectWithKeyValues:obj];
                            [joinFileds_arrM addObject:item];
                        }
                        //把joinfield取到
                        self.joinfield = joinFileds_arrM;
                    }
                    if (responseCallback) {
                        [_jsRespondsCallbackDic setObject:responseCallback forKey:@(bigApi_joinActivity)];
                    }
                    [self joinActivityWithPid:pid withJoinFeild:self.joinfield withExtfield:extfield_arr];
                } else {
                    [self showHudTipStr:@"活动信息出错了，请重试"];
                }
                break;
            }
                //管理活动申请列表
            case bigApi_manageActivityApplyList:
            {
                id returnPara = [self parasReturnToJSWithRequestResultSuccess:YES andData:@"success"];
                responseCallback(returnPara);
                NSString *pid = parasdic[@"pid"];
                [self manageApplyListsActionWithPid:pid];
                break;
            }
                //取消参加活动
            case bigApi_cancleJoinActivity:
            {
                [self.view endEditing:YES];
                NSString *pid = parasdic[@"pid"];
                if (responseCallback) {
                    [_jsRespondsCallbackDic setObject:responseCallback forKey:@(bigApi_cancleJoinActivity)];
                }
                [self cancleJoinActivityActionWithPid:pid];
                break;
            }
                //对帖子评分
            case bigApi_ratePost:
            {
                DLog(@"----bigApi_ratePost Action");
                [self.view endEditing:YES];
                NSString *pid = parasdic[@"pid"];
                if (responseCallback) {
                    [_jsRespondsCallbackDic setObject:responseCallback forKey:@(bigApi_ratePost)];
                }
                [self rateAction:pid];
                break;
            }
                //查看全部评分
            case bigApi_viewRatings:
            {
                [self.view endEditing:YES];
                if (_isViewingAllRatings) {
                    return;
                }
                _isViewingAllRatings = YES;
                NSString *pid = parasdic[@"pid"];
                if (responseCallback) {
                    [_jsRespondsCallbackDic setObject:responseCallback forKey:@(bigApi_viewRatings)];
                }
                [self viewRatingsActions:pid];
                break;
            }
                //添加帖子点评
            case bigApi_addPostComment:
            {
                [self.view endEditing:YES];
                NSString *pid = parasdic[@"pid"];
                if (responseCallback) {
                    [_jsRespondsCallbackDic setObject:responseCallback forKey:@(bigApi_addPostComment)];
                }
                [self commentPostActionWithPid:pid];
                break;
            }
                //获取帖子点评相关信息
            case bigApi_getPostCommentInfo:
            {
                [self.view endEditing:YES];
                NSString *pid = parasdic[@"pid"];
                NSString *tid = parasdic[@"tid"];
                WEAKSELF
                [[Clan_NetAPIManager sharedManager] request_getPostCommentInfoWithTid:tid
                                                                              withPid:pid
                                                                             andBlock:^(id data, NSError *error) {
                                                                                 id returnPara = [weakSelf parasReturnToJSWithRequestResultSuccess:error ? NO : YES andData:data];
                                                                                 responseCallback(returnPara);
                                                                             }];
                break;
            }
                //购买帖子
            case bigApi_payThread:
            {
                [self.view endEditing:YES];
                if (![self checkLoginState]) {
                    return;
                }
                NSString *pid = parasdic[@"pid"];
                NSString *tid = parasdic[@"tid"];
                if (!tid || !pid || tid.length == 0 || pid.length == 0) {
                    return;
                }
                if (responseCallback) {
                    [_jsRespondsCallbackDic setObject:responseCallback forKey:@(bigApi_payThread)];
                }
                [self payThreadActionWithTid:tid withPid:pid];
                break;
            }
            default:
                break;
        }
    }
    
}

#pragma mark - 自定义方法
//发表回复的前置检查
- (void)jumpToReplyPostPageWithModel:(PostDetailModel *)model
{
    if (![self checkLoginState]) {
        return;
    }
    if (self.uploadHash && self.uploadHash.length > 0) {
        model.uploadhash = _uploadHash;
        [self gotoPostSendPage:model];
        return;
    }
    if (!model || !model.fid || model.fid.length == 0) {
        [self showHudTipStr:NetError];
        return;
    }
    WEAKSELF
    [_detailViewModel check_post_withfid:model.fid andBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            strongSelf.uploadHash = data;
            model.uploadhash = data;
            [strongSelf gotoPostSendPage:model];
        } else {
            if (data && [data isEqualToString:kCookie_expired]) {
                [strongSelf showHudTipStr:@"登录已经过期，请重新登录"];
                [strongSelf goToLoginPage];
            }
        }
    }];
}

- (void)dealWithShareInfo:(NSString *)shareurl
               shareImage:(NSString *)shareImageUrl
               shareTitle:(NSString *)title
             shareContent:(NSString *)descrip
{
    _isShare = YES;
    if (_postSummary && _postSummary.length > 0) {
        descrip = _postSummary;
    } else {
        descrip = [Util formatHtmlString:descrip? : @""];
    }
    if (!descrip || descrip.length <= 0) {
        descrip = _commentPostDetail.share_url;
    }
    if (descrip && descrip.length > 140) {
        descrip = [descrip substringToIndex:139];
    }
    if (!title || title.length <= 0) {
        title = _commentPostDetail.share_url;
    }
    if (title && title.length > 140) {
        title = [title substringToIndex:139];
    }
    _isShare = YES;
    [self doShareWithTitle:title
               withcontent:descrip
                   withURL:shareurl
              withShareImg:kIMG(@"AppIcon60x60")
           withShareImgURL:shareImageUrl
           withDescription:descrip];
}

//环境信息
- (id)getEnvironment
{
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];
    AFNetworkReachabilityStatus networkStatus = afNetworkReachabilityManager.networkReachabilityStatus;
    NSString *device_os = [NSString stringWithFormat:@"iOS%f",[[UIDevice currentDevice].systemVersion floatValue]];
    if (networkStatus == AFNetworkReachabilityStatusUnknown) {
        networkStatus = AFNetworkReachabilityStatusNotReachable;
    }
   
    //开启网络监视器；
    NSDictionary *dic = @{
                          @"type" : @"dz",
                          @"debug" : @"false",
                          @"platform" : @"iOS",
                          @"version" : avoidNullStr([NSString returnStringWithPlist:kBIGAPPVERSION]),
                          @"theme" : @{@"color" : avoidNullStr([UIColor hexValueFromUIColor:[Util mainThemeColor]])},
                          @"postData" : _isArticle ? @{@"aid" : avoidNullStr(_postModel.tid)} : @{@"tid" : avoidNullStr(_postModel.tid)}, //帖子ID
                          @"network" : avoidNullStr(@(networkStatus)),
                          @"OS" : avoidNullStr(device_os),
                          };
    
    NSDictionary *userinfo_c = nil;
    if ([UserModel currentUserInfo].logined) {
        userinfo_c = [Util dictionaryWithPropertiesOfObject:[UserModel currentUserInfo]];
        dic = @{
                @"userinfo" : userinfo_c,
                @"type" : @"dz",
                @"debug" : @"true",
                @"platform" : @"iOS",
                @"version" : avoidNullStr([NSString returnStringWithPlist:kBIGAPPVERSION]), //发布版本号跟插件保持一致
                @"theme" : @{@"color" : avoidNullStr([UIColor hexValueFromUIColor:[Util mainThemeColor]])},
                @"postData" : _isArticle ? @{@"aid" : avoidNullStr(_postModel.tid)} : @{@"tid" : avoidNullStr(_postModel.tid)}, //帖子ID
                @"network" : avoidNullStr(@(networkStatus)),
                @"OS" : avoidNullStr(device_os),
                };
    }
    return dic;
}

//打印html 源码
- (void)showSource
{
    [_bridge callHandler:@"printSource" data:nil responseCallback:^(id responseData) {
        DLog(@"showSource---%@",responseData);
    }];
}

- (void)resetFavoBtn
{
    NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forType:myPost] ? @"detail_favo_H" : @"detail_favo";
    NSString *title =[Util isFavoed_withID:_postModel.tid forType:myPost] ? @"  已收藏" : @"  收藏";
    [self.favoButton setImage:kIMG(favoImgName) forState:UIControlStateNormal];
    [self.favoButton setTitle:title forState:UIControlStateNormal];
}


//把对象转换成json对象
- (NSString *)convertObjToJsonData:(id)originalObj
{
    NSString *jsonString = nil;
    if ([NSJSONSerialization isValidJSONObject:originalObj]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:originalObj
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
            DLog(@"---json转换出错了 %@",error);
        } else {
            jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        }

    }
    return jsonString ? jsonString : nil;
}

- (id)parasReturnToJSWithRequestResultSuccess:(BOOL)success andData:(id)callbackDatas
{
    if (!callbackDatas) {
        return nil;
    }
    NSDictionary *dic = @{
                          @"result" : success ? @"0" : @"1",
                          @"responsedatas":callbackDatas
                          };
    return dic;
}

//解析json字符串
- (id)parseJsonStr:(NSString *)jsonStr
{
    NSError *error;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    return obj;
}

//接口映射表
- (BigApi)apiMappingForApiKey:(NSString *)apiname
{
    BigApi requestApi = BigDetailApi_None;
    if (_apiMappingDic[apiname]) {
        requestApi = [_apiMappingDic[apiname] intValue];
    }
    return requestApi;
}

//判断是否是帖子链接
- (BOOL)isPostUrl:(NSURL *)url
{
    NSString *baseUrl = [NSString returnPlistWithKeyValue:@"ListAdURL"];
    NSURL *baseURI = [NSURL URLWithString:baseUrl];
    if ([baseURI.host isEqualToString:url.host] && [url.path rangeOfString:@"mod=viewthread"].location != NSNotFound) {
        return YES;
    }
    return NO;
}

#pragma mark - webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self evaluatingBigAppNativeJavaScript];
    //把环境信息注入html页面里面
    NSString *js = [NSString stringWithFormat:@"window.iosNative_getENV='%@'",[self convertObjToJsonData:[self getEnvironment]]];
    [webView stringByEvaluatingJavaScriptFromString:js];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }
    else {
        NSURL *url = [request URL];
        if ([self isPostUrl:url]) {
            //跳转到帖子详情页面
            NSArray *sepers = [url.path componentsSeparatedByString:@"tid="];
            if (sepers.count == 2) {
                NSString *tid = sepers[1];
                PostDetailVC *detail = [[PostDetailVC alloc]init];
                PostModel *postModel = [PostModel new];
                postModel.tid = tid;
                detail.postModel =  postModel;
                detail.hidesBottomBarWhenPushed = YES;
                if (self.navigationController) {
                    [self.navigationController pushViewController:detail animated:YES];
                    return NO;
                }
            }
        }
        //TODO 跳转到common web
        [self jumpToCommonPageWithUrl:url.absoluteString];
        return NO;
    }
    
//    DLog(@"--- %@ ----- navigationType：%d",url,navigationType);
//    //读取本地的html文件的时候 要用到
//    if (url == nil || [[url absoluteString] isEqualToString:@"about:blank"] || [[url scheme] isEqualToString:@"file"]) {
//        return YES;
//    }
}

#pragma mark - 页面跳转
//点击链接跳转到common页面
- (void)jumpToCommonPageWithUrl:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"";
    [self.navigationController pushViewController:webViewController animated:YES];
}

//跳转到相册
- (void)jumpToWebBroswerWithImgUrls:(NSArray *)urls andSelectedIndex:(NSInteger)index
{
    //跳转到相册
    NSArray *photosWithURL = [IDMPhoto photosWithURLs:urls];
    NSMutableArray *photos = [NSMutableArray arrayWithArray:photosWithURL];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    browser.displayCounterLabel = YES;
    browser.displayActionButton = NO;
    [browser setInitialPageIndex:index];
    [self presentViewController:browser animated:YES completion:nil];
}

//跳转到个人中心
- (void)jumpToMemberCenterWithUser:(UserModel *)model
{
    MeViewController *home = [[MeViewController alloc]init];
    home.user = model;
    [self.navigationController pushViewController:home animated:YES];
}

//跳转到回复帖子页面
- (void)gotoPostSendPage:(PostDetailModel *)model
{
    PostSendViewController *postSend = [[PostSendViewController alloc]init];
    postSend.postDetailModel = model;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postSend];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - 键盘即将显示 ---  键盘即将退出
- (void)keyBoardWillShow:(NSNotification *)note
{
    if (_isShare) {
        return;
    }
    if([_tfPageInput isFirstResponder]) {
        
        CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat ty = - rect.size.height-kVIEW_H(_keyboardBarView);
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _keyboardBarView.transform = CGAffineTransformMakeTranslation(0, ty);
            [self.view bringSubviewToFront:_keyboardBarView];
        }];
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    if (_isShare) {
        return;
    }
    if ([_tfPageInput isFirstResponder]) {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _keyboardBarView.transform = CGAffineTransformIdentity;
            [self.view sendSubviewToBack:_keyboardBarView];
        }];
    }
}

#pragma mark - 公公方法
//参加活动成功
- (void)joinActivitySuccess:(id)returnData
{
    [self callbackResponseWithData:returnData forBigApi:bigApi_joinActivity];
}

//评分成功
- (void)ratePostSuccess:(id)returnData
{
    [self callbackResponseWithData:returnData forBigApi:bigApi_ratePost];
}

//点评成功
- (void)commentPostSuccess:(id)returnData
{
    [self callbackResponseWithData:returnData forBigApi:bigApi_addPostComment];
}

//购买成功
- (void)payThreadSuccess:(id)returnData
{
    [self callbackResponseWithData:returnData forBigApi:bigApi_payThread];
}

//js回调
- (void)callbackResponseWithData:(id)returnData forBigApi:(BigApi)api
{
    if ([self.jsRespondsCallbackDic objectForKey:@(api)]) {
        WVJBResponseCallback callback = self.jsRespondsCallbackDic[@(api)];
        NSDictionary *paras = @{
                                @"result" : @"0",
                                @"responsedatas":returnData ? returnData : @"success",
                                };
        callback(paras);
        [self.jsRespondsCallbackDic removeObjectForKey:@(api)];
    }
}

#pragma mark - 注入js代码
//注入js代码 初始化javascript代
- (void)evaluatingBigAppNativeJavaScript
{
    NSString* jsPath = [[NSBundle mainBundle] pathForResource:@"dz_nativejs" ofType:@"js"];
    NSString* nativeJs = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    [self.webview stringByEvaluatingJavaScriptFromString:nativeJs];
}



#pragma mark - scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_showBackTopBtn) {
        return;
    }
    if (scrollView.contentOffset.y > 0 && scrollView.contentSize.height > kVIEW_H(self.webview)) {
        [self showBackTopButton];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!_showBackTopBtn) {
        return;
    }
    if (scrollView.contentOffset.y <= 0) {
        [self hideBackTopButton];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_showBackTopBtn) {
        return;
    }
    if (scrollView.contentOffset.y > 0 && scrollView.contentSize.height > kVIEW_H(self.webview)) {
        [self showBackTopButton];
    } else {
        [self hideBackTopButton];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (!_showBackTopBtn) {
        return;
    }
    [self hideBackTopButton];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    if (tag == 8899) {
        NSString *pid = objc_getAssociatedObject(alertView,&associatedkey);
        if (buttonIndex == 1) {
            //取消参加了
            UITextField *tf = [alertView textFieldAtIndex:0];
            NSString *reason = (tf.text && tf.text.length > 0) ? tf.text : @"";
                //取消参加活动
                WEAKSELF
                [_bridge callHandler:@"getPostData" data:nil responseCallback:^(id responseData) {
                    NSString *fid = responseData[@"fid"];
                    NSString *tid = responseData[@"tid"];
                    //取消参加活动
                    [[Clan_NetAPIManager sharedManager] request_cancleJoinAcitivityWithReason:reason withTid:tid withPid:pid withfid:fid andBlock:^(id data, NSError *error) {
                        if (data && [data valueForKey:@"Message"]) {
                            NSDictionary *messDic = [data valueForKey:@"Message"];
                            NSString *messVal = messDic[@"messageval"];
                            NSString *messTip = messDic[@"messagestr"];
                            if (messVal && [@"activity_cancel_success" isEqualToString:messVal]) {
                                //说明取消活动成功 cancle success 回调H5函数通知
                                [weakSelf callbackResponseWithData:data forBigApi:bigApi_cancleJoinActivity];
                            }
                            [weakSelf performSelector:@selector(showHudTipStr:) withObject:messTip afterDelay:0.5];
                            return ;
                        }
                        [weakSelf performSelector:@selector(showHudTipStr:) withObject:@"取消活动申请失败，请重试" afterDelay:0.5];
                    }];
                }];
        }
    }
    else if (tag == 8888) {
        if (buttonIndex == 0) {
            return;
        }
        //删除主题
        NSDictionary *dic = objc_getAssociatedObject(alertView,&associatedkey);
        NSString *tid = dic[@"tid"];
        NSString *fid = dic[@"fid"];
        UITextField *tf = [alertView textFieldAtIndex:0];
        [self showProgressHUDWithStatus:@"" withLock:YES];
        WEAKSELF
        [[Clan_NetAPIManager sharedManager] request_deletePostWithTid:tid
                                                              withFid:fid
                                                           withReason:tf.text
                                                             andBlock:^(id data, NSError *error) {
                                                                 [weakSelf dissmissProgress];
                                                                 if (data && [data valueForKey:@"Message"]) {
                                                                     NSDictionary *dic = [data valueForKey:@"Message"];
                                                                     NSString *messVal = dic[@"messageval"];
                                                                     NSString *messTip = dic[@"messagestr"];
                                                                     [weakSelf performSelector:@selector(showHudTipStr:) withObject:messTip afterDelay:0.5];
                                                                     if ([@"admin_succeed" isEqualToString:messVal]) {
                                                                         //删除成功了
                                                                         if (weakSelf.navigationController) {
                                                                             [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                         }
                                                                     }
                                                                 } else {
                                                                     [weakSelf performSelector:@selector(showHudTipStr:) withObject:@"删除失败了,检查网络,请重试" afterDelay:0.5];
                                                                 }
                                                             }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"logined"]) {
        UserModel *cuser = [UserModel currentUserInfo];
        if (cuser.logined) {
            UserInfoViewModel *infovm = [UserInfoViewModel new];
            WEAKSELF
            [infovm requestApi:nil
                        andReturnBlock:^(bool success, id data, bool isSelf) {
                            STRONGSELF
                            if (success) {
                                if (isSelf) {
                                    UserInfoModel *info = data;
                                    [[UserModel currentUserInfo] setValueWithObject:info];
                                    NSDictionary *userinfo_c = [Util dictionaryWithPropertiesOfObject:[UserModel currentUserInfo]];
                                    NSDictionary *paras = @{@"userinfo" : userinfo_c};
                                    //登录成功 通知H5
                                    [strongSelf.bridge callHandler:@"sendLoginNoti" data:paras responseCallback:^(id responseData) {
                                    }];
                                }
                            }
                        }];
           
        } else {
            //退出登录 通知H5
            [_bridge callHandler:@"sendLogoutNoti" data:nil responseCallback:^(id responseData) {
                
            }];
        }
    }
}

#pragma mark - 通知notification
- (void)notificationCome:(NSNotification *)note
{
    if ([note.name isEqualToString:@"ShareCompleted"]) {
        _isShare = NO;
    }
    else if ([note.name isEqualToString:@"SendReply_Success"]) {
        [_bridge callHandler:@"replyPostComplete" data:note.object responseCallback:^(id responseData) {
            
        }];
    }
    else if ([note.name isEqualToString:@"k_dz_returnTopBtn_Status_changed"]) {
        [self resetReturnTopBtn];
    }
    else if ([note.name isEqualToString:@"k_dz_photobroswer_close"]) {
        //通知h5当前已关闭相册 并且拿到当前的相片的index
        id obj = note.object;
        if (obj) {
            NSDictionary *dic = @{@"data" : @{@"current" : obj}};
            if ([_jsRespondsCallbackDic objectForKey:@"clickImage"]) {
                WVJBResponseCallback callback = _jsRespondsCallbackDic[@"clickImage"];
                NSDictionary *paras = @{
                                        @"result" : @"2",
                                        @"responsedatas":dic,
                                        };
                callback(paras);
                [_jsRespondsCallbackDic removeObjectForKey:@"clickImage"];
            }
        }
    }
}

@end
