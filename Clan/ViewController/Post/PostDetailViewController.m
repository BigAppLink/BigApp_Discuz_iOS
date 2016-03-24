//
//  DetailViewController.m
//  Clan
//
//  Created by 昔米 on 15/5/9.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostDetailViewController.h"
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

static NSString *keyNormalData = @"keyNormalData";
static NSString *keyLouzhuData = @"keyLouzhuData";

@interface PostDetailViewController () <UIWebViewDelegate>
{
    UILabel *_tipLabel;
    UILabel *_replyLabel;
    BOOL _isShare;
    NSMutableArray *_vedioURLsArr;
}
@property (assign)     int lastPageNumer;
@property (assign)     BOOL isJump;
@property (strong, nonatomic) NSMutableArray *voteArray;
@property (copy, nonatomic) NSString *subject;
@property (strong, nonatomic) UISegmentedControl *segment;
@property (strong, nonatomic) PostDetailViewModel *detailViewModel;
@property (strong, nonatomic) CollectionViewModel *favoViewModel;
@property (strong, nonatomic) PostDetailModel *commentPostDetail;
@property (strong, nonatomic) MGTemplateEngine *webEngine; //html页面engine
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (copy, nonatomic) NSString *uploadHash;
@property (strong, nonatomic) NSMutableDictionary *dataDic; //数据数组
@property (strong, nonatomic) NSMutableDictionary *tempDataDic;
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
@property (strong, nonatomic) UIButton *viewAuthorBtn;
//楼主信息
@property (strong, nonatomic) PostListModel *louzhupost;
//当前页
@property (assign) int currentPage;
//总页数
@property (assign) int totalPage;
//只看楼主当前页
@property (assign) int currentPage_louzhu;
//只看楼主总页数
@property (assign) int totalPage_louzhu;
//是否是楼主
@property (assign) BOOL isLouzhu;
//有无上一页
@property (assign) BOOL need_more;
//举报model
@property (strong, nonatomic) Report *reportModel;
@end


@implementation PostDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNav];
    [self loadModel];
    [self buildUI];
    [self.view beginLoading];
    [self requestDataWithPage:++_currentPage withJumpAction:NO];
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
    [rightView addSubview:viewmore];
    
    //    UIButton *viewAuthorBtn = [UIButton buttonWithTitle:nil andImage:@"louzhu_N" andFrame:CGRectMake(viewmore.left-viewmore.width-5, (44-30)/2, 37, 30) target:self action:@selector(viewAuthorOnlyAction:)];
    //    self.viewAuthorBtn = viewAuthorBtn;
    //    [rightView addSubview:viewAuthorBtn];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -15;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
}

-(void)segmentAction:(UISegmentedControl *)Seg
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

- (void)navback
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    _favoViewModel = nil;
    _webEngine = nil;
    _webview.delegate = nil;
    [_webview loadHTMLString:nil baseURL:nil];
    _webview = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"DetailViewController dealloc");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //页面开始
    //add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShareCompleted:) name:@"ShareCompleted" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replySuccess:) name:@"SendReply_Success" object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //页面结束
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 初始化数据源 和 视图
//数据源
- (void)loadModel
{
    _voteArray = [NSMutableArray new];
    _vedioURLsArr = [NSMutableArray new];
    self.dataDic = [NSMutableDictionary new];
    self.tempDataDic = [NSMutableDictionary new];
    self.detailViewModel = [PostDetailViewModel new];
    self.webEngine = [MGTemplateEngine templateEngine];
    [_webEngine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:_webEngine]];
}

//视图
- (void)buildUI
{
    self.title = @"帖子详情";
    [self initBottomView];
    [self initKeyBoardBar];
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64-44)];
    web.backgroundColor = kCOLOR_BG_GRAY;
    self.webview = web;
    [self.view addSubview:web];
    [self buildBridge];
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
//    NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forThreadType:YES] ? @"detail_favo_H" : @"detail_favo";
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

#pragma mark - 桥接器
- (void)buildBridge
{
    WebViewJavascriptBridge *bg = [WebViewJavascriptBridge bridgeForWebView:self.webview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
    }];
    self.bridge = bg;
    [self registerHandlerForBridge:bg];
}

//注册js监听事件
- (void)registerHandlerForBridge:(WebViewJavascriptBridge *)bridge
{
    WEAKSELF
    //“点击回复按钮”
    [bridge registerHandler:@"clickReplyBtnEvent" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         STRONGSELF
         NSString *pid = [data valueForKey:@"pid"];
         PostListModel *listM = strongSelf.tempDataDic[pid];
         if (!listM) {
             return ;
         }
         if (pid && pid.length > 0) {
             PostDetailModel *Model = [PostDetailModel new];
             Model.pid = pid;
             Model.author = listM.author;
             Model.tid = listM.tid;
             Model.fid = strongSelf.commentPostDetail.fid;
             Model.uploadhash = strongSelf.uploadHash;
             Model.dateline = listM.dateline;
             Model.dbdateline = listM.dbdateline;
             Model.textMessage = listM.postmessage;
             [strongSelf jumpToReplyPostPageWithModel:Model];
         } else {
             [strongSelf showHudTipStr:NetError];
         }
     }];
    
    //“点击举报按钮”
    [bridge registerHandler:@"clickReportBtnEvent" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         STRONGSELF
         ReportViewController *repostVc = [[ReportViewController alloc]init];
         repostVc.state = ClanReportTPost;
         [strongSelf.navigationController pushViewController:repostVc animated:YES];
     }];
    
    //点击图片
    [bridge registerHandler:@"clickImgEvent" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         STRONGSELF
         NSArray *imgArray = [data valueForKey:@"imgArray"];
         NSString *selectedImg = [data valueForKey:@"selectedImg"];
         NSInteger index = [imgArray indexOfObject:selectedImg];
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
             strongSelf.shareImageURL = imgArray[0];
         }
         //go to 相册浏览
         [strongSelf jumpToWebBroswerWithImgUrls:urls andSelectedIndex:index];
     }];
    
    //点击头像
    [bridge registerHandler:@"clickAvatarEvent" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         STRONGSELF
         NSString *uid = [data valueForKey:@"uid"];
         if (uid && [uid isKindOfClass:[NSString class]] && uid.length > 0) {
             UserModel *user = [UserModel new];
             user.uid = uid;
             [strongSelf jumpToMemberCenterWithUser:user]; //跳转到个人中心
         }
     }];
    
    //赞主题
    [bridge registerHandler:@"clickSupportThreadBtnEvent" handler:^(id data, WVJBResponseCallback responseCallback)
    {
        STRONGSELF
        if (![UserModel currentUserInfo].logined) {
            //跳登陆页
            [strongSelf jumpToLoginPage];
            return ;
        }
        [strongSelf supportAThread:strongSelf.commentPostDetail.tid];
    }];
    
    //赞回帖
    [bridge registerHandler:@"clickSupportBtnEvent" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         STRONGSELF
         DLog(@"赞回帖");
         NSString *pid = [data valueForKey:@"pid"];
//         PostListModel *listM = _tempDataDic[pid];
         if (![UserModel currentUserInfo].logined) {
             //跳登陆页
             [strongSelf jumpToLoginPage];
             return ;
         }
         [strongSelf supportAPost:strongSelf.commentPostDetail.tid withPostId:pid];
     }];
}

#pragma mark - 请求数据 以及 显示数据
- (void)supportAThread:(NSString *)tid
{
    WEAKSELF
    [_detailViewModel request_support_AThread:tid andBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            [strongSelf.voteArray addObject:strongSelf.louzhupost.pid];
            strongSelf.louzhupost.recommended = @"1";
            if (data && [data isKindOfClass:[NSString class]] && [data isEqualToString:@"haveSupported"]) {
                [strongSelf.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hightlightedThreadSupportOnly(%@)",tid]];
            } else {
                [strongSelf.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hightlightedThreadSupport(%@)",tid]];
            }
        }
    }];
}

- (void)supportAPost:(NSString *)tid withPostId:(NSString *)pid
{
    WEAKSELF
    [_detailViewModel request_support_APost:tid withPid:pid andBlock:^(bool success, id data) {
        STRONGSELF
        if (success) {
            [strongSelf.voteArray addObject:pid];
            if (data && [data isKindOfClass:[NSString class]] && [data isEqualToString:@"haveSupported"]) {
                [strongSelf.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hightlightedPostSupportOnly(%@)",pid]];
            } else {
                [strongSelf.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"hightlightedPostSupport(%@)",pid]];
            }
        }
    }];
}

- (void)requestDataWithPage:(int)page withJumpAction:(BOOL)isJump
{
    //如果数据存在本地 直接从数据源里面取 若不存在 请求网路
    if ([self loadDataFromLocalForPage:page withJumpAction:isJump]) {
        [self hideProgressHUD];
        return;
    }
    NSString *authorID = _isLouzhu ? _louzhupost.authorid : nil;
    WEAKSELF
    [_detailViewModel request_postDetailWithTid:_postModel.tid withAuthorID:authorID atPage:page andBlock:^(id data) {
        STRONGSELF
        [strongSelf.view endLoading];
        [strongSelf hideProgressHUD];
        if (data && [data isKindOfClass:[PostDetailModel class]]) {
            PostDetailModel *detail = data;
            strongSelf.reportModel = detail.report;
            strongSelf.reportModel.tid = detail.tid;
            strongSelf.reportModel.fid = detail.fid;
            if (page == 1) {
                if (detail.postlist.count > 0) {
                    strongSelf.commentPostDetail = detail;
                    strongSelf.louzhupost = detail.postlist[0];
                    strongSelf.uploadHash = detail.uploadhash;
                    //把楼主抽离出来
                    NSMutableArray *Arr = [NSMutableArray arrayWithArray:detail.postlist];
                    [Arr removeObjectAtIndex:0];
                    detail.postlist = Arr;
                    strongSelf.subject = detail.subject;
                    [strongSelf HTMLContent:detail.postlist];
                }
            } else {
                if (isJump) {
                    strongSelf.isJump = YES;
                    [strongSelf HTMLContent:detail.postlist];
                }
                else {
                    strongSelf.isJump = NO;
                    [strongSelf addContentWithArr:detail.postlist];
                }
            }
            if (strongSelf.isLouzhu)
            strongSelf.totalPage_louzhu = detail.totalpage.intValue;
            else
            strongSelf.totalPage = detail.totalpage.intValue;
            [strongSelf saveDataSource:detail.postlist forPage:page];
        }
        else {
            if (strongSelf.isLouzhu)
                strongSelf.currentPage_louzhu = page-1;
            else
                strongSelf.currentPage = page-1;
            if (data) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:data delegate:strongSelf cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                alert.tag = 1002;
                [alert show];
            }
        }
        if (page != 1) {
            [strongSelf resetFooterView];
        } else {
            [strongSelf performSelector:@selector(resetFooterView) withObject:nil afterDelay:2];
        }
    }];
}

- (void)updateDataWithPage:(int)page
{
    NSString *authorID = _isLouzhu ? _louzhupost.authorid : nil;
    int cpage = _isLouzhu ? _currentPage_louzhu : _currentPage;
    int tpage = _isLouzhu ? _totalPage_louzhu : _totalPage;

    WEAKSELF
    [_detailViewModel request_postDetailWithTid:_postModel.tid withAuthorID:authorID atPage:page andBlock:^(id data) {
        STRONGSELF
        [strongSelf.view endLoading];
        if (data && [data isKindOfClass:[PostDetailModel class]])
        {
            PostDetailModel *detail = data;
            NSMutableArray *Arr = [NSMutableArray arrayWithArray:detail.postlist];
            if (Arr.count > strongSelf.lastPageNumer) {
                [Arr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, strongSelf.lastPageNumer)]];
                strongSelf.lastPageNumer = (int)detail.postlist.count;
                if (cpage == tpage) {
                    //添加新的评论
                    [strongSelf addContentWithArr:Arr];
                }
            }
            
            if (strongSelf.isLouzhu)
                strongSelf.totalPage_louzhu = detail.totalpage.intValue;
            else
                strongSelf.totalPage = detail.totalpage.intValue;
            [strongSelf resetFooterView];
        }
    }];
}

- (BOOL)loadDataFromLocalForPage:(int)page withJumpAction:(BOOL)isJump
{
    _isJump = isJump;
    NSString *key = _isLouzhu ? keyLouzhuData : keyNormalData;
    NSString *dataKey = [NSString stringWithFormat:@"%@_%d",key,page];
    if (_dataDic[dataKey]) {
        if (page == 1 || isJump) {
            [self HTMLContent:_dataDic[dataKey]];
        } else {
            [self addContentWithArr:_dataDic[dataKey]];
        }
        [self resetFooterView];
        return YES;
    } else {
        return NO;
    }
}

- (void)saveDataSource:(id)obj forPage:(int)page
{
    int totalPage = _isLouzhu ? _totalPage_louzhu : _totalPage;
    NSString *key = _isLouzhu ? keyLouzhuData : keyNormalData;
    NSString *dataKey = [NSString stringWithFormat:@"%@_%d",key,page];
    if (page != 1 && page != totalPage && obj) {
        //永远不保存最后一页的数据 因为最后一页的数据可能是变化的
        [_dataDic setObject:obj forKey:dataKey];
    }
    if (page == totalPage && obj) {
        NSArray *arr = (NSArray *)obj;
        _lastPageNumer = (int)arr.count;
    }
    if (obj && [obj isKindOfClass:[NSArray class]]) {
        for (PostListModel *listM in obj) {
            [_tempDataDic setObject:listM forKey:listM.pid];
            DLog(@"********* %@", listM.postmessage);
        }
    }
}

//加载html数据
- (void)HTMLContent:(id)content
{
    NSArray *com_arr = content;
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"bbs" ofType:@"html"];
    NSString *hasComment = @"0";
    NSMutableArray *commentArr = [NSMutableArray new];
    if (com_arr.count > 0) {
        //有评论
        hasComment = @"1";
        for (int i = 0; i < com_arr.count; i++) {
            PostListModel *model = com_arr[i];
            model.voteUped = [_voteArray containsObject:model.pid] ? @"1" : @"0";
            //遍历出vedio标签
            [self getAllVedioURLsForContent:model.postmessage];
            model.postmessage = [model.postmessage emojizedString1];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[PostListModel dictionaryWithPropertiesOfObject:model]] ;
            if (dic) {
                [commentArr addObject:dic];
            }
        }
    }
    NSDictionary *variables = @{
                      @"authorID": avoidNullStr(_louzhupost.authorid),
                      @"subject": avoidNullStr(_subject),
                      @"author": avoidNullStr(_louzhupost.author),
                      @"dateline": avoidNullStr(_louzhupost.dateline),
                      @"message": avoidNullStr([_louzhupost.postmessage emojizedString1]),
                      @"avatar": avoidNullStr(_louzhupost.avatar),
                      @"hasComments": avoidNullStr(hasComment),
                      @"isLouzhuPage": [NSString stringWithFormat:@"%d",_isLouzhu],
                      @"commentsArr": avoidNullStr(commentArr),
                      @"louzhuID": avoidNullStr(_louzhupost.authorid),
                      @"support": avoidNullStr(_louzhupost.recommend_add),
                      @"enable_support": ((_louzhupost.enable_recommend && [_louzhupost.enable_recommend intValue]==1)? @"1" : @"0"),
                      @"recommended" : ((_louzhupost.recommended && [_louzhupost.recommended intValue]==1) ? @"1" : @"0"),
                      @"postid":avoidNullStr(_commentPostDetail.tid)
                      };
    //遍历出vedio标签
    [self getAllVedioURLsForContent:_louzhupost.postmessage];

    NSString *html = [_webEngine processTemplateInFileAtPath:templatePath withVariables:variables];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webview loadHTMLString:html baseURL:baseURL];
    [self.webview stringByEvaluatingJavaScriptFromString:@"removeQuotesBr()"];
}

#pragma mark - 加载更多
//加载更多
- (void)addFooter
{
    __weak UIScrollView *scrollView = self.webview.scrollView;
    WEAKSELF
    [scrollView addLegendFooterWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf.isLouzhu) {
            if (strongSelf.currentPage_louzhu == strongSelf.totalPage_louzhu) {
                //超出范围了
                [strongSelf.webview.scrollView.footer setTitle:@"没有更多评论了..." forState:MJRefreshFooterStateNoMoreData];
                return ;
            }
        } else {
            if (strongSelf.currentPage == strongSelf.totalPage) {
                //超出范围了
                [strongSelf.webview.scrollView.footer setTitle:@"没有更多评论了..." forState:MJRefreshFooterStateNoMoreData];
                return;
            }
        }
        [strongSelf requestDataWithPage: strongSelf.isLouzhu ? ++strongSelf.currentPage_louzhu : ++strongSelf.currentPage withJumpAction:NO];
    }];
    [self.webview.scrollView.footer setTitle:@"加载更多评论..." forState:MJRefreshFooterStateIdle];
    [self.webview.scrollView.footer setTitle:@"没有更多评论了..." forState:MJRefreshFooterStateNoMoreData];
    [self.webview.scrollView.footer setTitle:@"评论加载中..." forState:MJRefreshFooterStateRefreshing];
}

- (void)addContentWithArr:(NSArray *)arr
{
    for (PostListModel *model in arr) {
        model.postmessage = [model.postmessage emojizedString1];
        //遍历出vedio标签
        [self getAllVedioURLsForContent:model.postmessage];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[PostListModel dictionaryWithPropertiesOfObject:model]] ;
        [dic setObject:([_voteArray containsObject:model.voteUped]?@"1":@"0") forKeyedSubscript:@"voteUped"];
        NSDictionary *variables = @{@"model":dic ? dic : [NSMutableDictionary new], @"louzhuID": _louzhupost.authorid};
        NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"commet" ofType:@"html"];
        NSString *html = [_webEngine processTemplateInFileAtPath:htmlFilePath withVariables:variables];
        NSString *injectSrc = @"var i = document.createElement('li'); i.setAttribute('class','clearFix'); i.innerHTML='%@'; document.getElementById('replyItems').appendChild(i)";
        NSString *runToInject = [NSString stringWithFormat:injectSrc, html];
        [self.webview stringByEvaluatingJavaScriptFromString:runToInject];
    }
    [self.webview stringByEvaluatingJavaScriptFromString:@"resetBindComments()"];
    [self resetFooterView];
    [self.webview.scrollView.footer endRefreshing];
}

- (void)resetFooterView
{
    int cpage = _isLouzhu ? _currentPage_louzhu : _currentPage;
    int totalPage = _isLouzhu ? _totalPage_louzhu : _totalPage;
    if (cpage < totalPage) {
        if (!self.webview.scrollView.footer) {
            [self addFooter];
        }
        self.webview.scrollView.footer.state = MJRefreshFooterStateIdle;
    } else {
        self.webview.scrollView.footer.state = MJRefreshFooterStateNoMoreData;
    }
    _tipLabel.text = [NSString stringWithFormat:@"%d/%d页",cpage,totalPage];
    [_replyBtn layoutIfNeeded];
}

#pragma mark - Action Methods
// 发表回复
- (void)comment:(id)sender
{
    if (![UserModel currentUserInfo].logined) {
        [self jumpToLoginPage];
        return;
    }
    if (self.louzhupost && self.louzhupost.pid.length == 0) {
        //无数据
        [self showHudTipStr:@"加载失败，请稍后再试"];
        return;
    }
    PostDetailModel *Model = [PostDetailModel new];
    Model.uploadhash = _uploadHash;
    //回复楼主 不加pid
    Model.author = self.louzhupost.author;
    Model.fid = _commentPostDetail.fid;
    Model.tid = self.louzhupost.tid;
    Model.dbdateline = self.louzhupost.dbdateline;
    [self jumpToReplyPostPageWithModel:Model];
}

//更多按钮
- (IBAction)viewMoreAction:(id)sender
{
    NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forType:myPost] ? @"detail_favo_H" : @"favo_N";
    NSArray *titls = @[@"收藏",@"分享", @"跳页",@"举报"];
    NSArray *imgsN = @[favoImgName,@"share_N", @"jump_N",@"jubao"];
    NSArray *imgsH = @[favoImgName,@"share_N", @"jump_N",@"jubao"];

    PopoverView *pop = [[PopoverView alloc]initWithFromBarButtonItem:_viewAuthorBtn inView:self.view titles:titls images:imgsN selectImages:imgsH];
    pop.selectIndex = 0;
    WEAKSELF
    pop.selectRowAtIndex = ^(NSInteger index)
    {
        STRONGSELF
        if (index == 0)
            [strongSelf favoAction];
        else if (index == 1)
            [strongSelf shareAction];
        else if (index == 2)
            [strongSelf jumpPageAction];
        else
            [strongSelf reportAction];
    };
    [pop show];
}

//只看楼主
- (IBAction)viewAuthorOnlyAction
{
    [self showProgressHUDWithStatus:@"加载中..."];
    [_tfPageInput resignFirstResponder];
//    NSString *imgName = _isLouzhu ? @"louzhu_H" : @"louzhu_N";
//    [_viewAuthorBtn setImage:kIMG(imgName) forState:UIControlStateNormal];
    if (_isLouzhu) {
        _currentPage_louzhu = 1;
    } else {
        _currentPage = 1;
    }
    [self requestDataWithPage:1 withJumpAction:NO];
    [self resetFooterView];
}

//收藏取消收藏
- (void)favoAction
{
    if (!self.favoViewModel) {
        self.favoViewModel = [CollectionViewModel new];
    }
    if (![UserModel currentUserInfo].logined) {
        [self jumpToLoginPage];
        return;
    }
    WEAKSELF
    if (![Util isFavoed_withID:_louzhupost.tid forType:myPost]) {
        [_favoViewModel doFavoAPostByID:_louzhupost.tid andBlock:^(BOOL success) {
            STRONGSELF
            if (success) {
                DLog(@"收藏成功");
            }
            [strongSelf resetFavoBtn];
        }];
    } else {
        [_favoViewModel request_DeleteCollection:[Util getFavoIDFromID:_louzhupost.tid forType:myPost] andType:myPost andBlock:^(BOOL state) {
            STRONGSELF
            if (state) {
                //删除成功 删除本地记录
                [Util deleteFavoed_withID:_louzhupost.tid forType:myPost];
            }
            [strongSelf resetFavoBtn];
        }];
    }
}

- (void)resetFavoBtn
{
    NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forType:myPost] ? @"detail_favo_H" : @"detail_favo";
    NSString *title =[Util isFavoed_withID:_postModel.tid forType:myPost] ? @"  已收藏" : @"  收藏";
    [self.favoButton setImage:kIMG(favoImgName) forState:UIControlStateNormal];
    [self.favoButton setTitle:title forState:UIControlStateNormal];
}
//分享
- (void)shareAction
{
    [_tfPageInput resignFirstResponder];
    if (_commentPostDetail) {
        _isShare = YES;
        NSString *descrip = [Util formatHtmlString:(_louzhupost && _louzhupost.postmessage)? _louzhupost.postmessage : @""];
        if (!descrip || descrip.length <= 0) {
            descrip = _commentPostDetail.share_url;
        }
        if (descrip && descrip.length > 140) {
            descrip = [descrip substringToIndex:139];
        }
        NSString *title = _commentPostDetail.subject;
        if (!title || title.length <= 0) {
            title = _commentPostDetail.share_url;
        }
        if (title && title.length > 140) {
            title = [title substringToIndex:139];
        }
        if (!self.shareImageURL || self.shareImageURL.length == 0) {
            NSString *returnJson = [self.webview stringByEvaluatingJavaScriptFromString:@"getShareImageURL()"];
            self.shareImageURL = returnJson;
            if (_shareImageURL && _shareImageURL.length > 0) {
                [self showProgressHUDWithStatus:@"" withLock:YES];
            }
        }
        [self doShareWithTitle:title withcontent:descrip withURL:_commentPostDetail.share_url withShareImg:kIMG(@"AppIcon60x60") withShareImgURL:self.shareImageURL withDescription:descrip];
        WEAKSELF
        self.shareFailBlock = ^(NSString *type){
            STRONGSELF
            if ([type isEqualToString:@"weixin"]) {
                [strongSelf showAlertWithMessage:@"没有安装微信客户端" andTitle:@"" andTag:1000];
            }else if([type isEqualToString:@"qq"]){
                [strongSelf showAlertWithMessage:@"没有安装qq客户端" andTitle:@"" andTag:1001];
            }
        };
    } else {
        [self showHudTipStr:@"数据异常，请稍后再试"];
    }
}

//跳页
- (void)jumpPageAction
{
    int cpage = _isLouzhu ? _currentPage_louzhu : _currentPage;
    int total = _isLouzhu ? _totalPage_louzhu : _totalPage;
    NSString *value = [NSString stringWithFormat:@"%d/%d页", cpage, total];
    self.lblPageShow.text = value;
    self.tfPageInput.text = @"";
    [self.tfPageInput becomeFirstResponder];
}

//举报
- (void)reportAction{
    if (![UserModel currentUserInfo].logined) {
        [self jumpToLoginPage];
        return;
    }
    ReportViewController *report = [[ReportViewController alloc]init];
    report.reportModel = _reportModel;
    [self.navigationController pushViewController:report animated:YES];
}

//取消跳页键盘
- (IBAction)cancleInput:(id)sender
{
    [self.tfPageInput resignFirstResponder];
}

//跳页
- (IBAction)jumpAction:(id)sender
{
    int total = _isLouzhu ? _totalPage_louzhu : _totalPage;
    if (!self.tfPageInput.text
        || [@"" isEqualToString:_tfPageInput.text]
        || self.tfPageInput.text.intValue < 1
        || self.tfPageInput.text.intValue > total) {
        [self showHudTipStr:@"您输入的页码有误"];
        return;
    }
    int i = _tfPageInput.text.intValue;
//    [self turnToPage:i];
    if (_isLouzhu)
        self.currentPage_louzhu = i;
    else
        self.currentPage = i;
    [self showProgressHUDWithStatus:@"加载中..."];
    [self requestDataWithPage:i withJumpAction:YES];
    [self.tfPageInput resignFirstResponder];
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

//跳转到个人中心
- (void)jumpToMemberCenterWithUser:(UserModel *)model
{
    MeViewController *home = [[MeViewController alloc]init];
    home.user = model;
    [self.navigationController pushViewController:home animated:YES];
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

//发表回复的前置检查
- (void)jumpToReplyPostPageWithModel:(PostDetailModel *)model
{
    if (![UserModel currentUserInfo].logined) {
        [self goToLoginPage];
        return;
    }
    if (_uploadHash && _uploadHash.length > 0) {
        model.uploadhash = _uploadHash;
        [self gotoPostSendPage:model];
        return;
    }
    if (!_commentPostDetail || !_commentPostDetail.fid || _commentPostDetail.fid.length == 0) {
        [self showHudTipStr:NetError];
        return;
    }
    WEAKSELF
    [_detailViewModel check_post_withfid:_commentPostDetail.fid andBlock:^(bool success, id data) {
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

//跳转到回复帖子页面
- (void)gotoPostSendPage:(PostDetailModel *)model
{
    PostSendViewController *postSend = [[PostSendViewController alloc]init];
    postSend.postDetailModel = model;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:postSend];
    [self presentViewController:nav animated:YES completion:nil];
}

//跳转到登陆页面
- (void)jumpToLoginPage
{
    //没有登录 跳出登录页面
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - UIAlertView 代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == 1000) {
            //下载微信
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"]];
        }else if(alertView.tag == 1001){
            //下载QQ
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/cn/app/qq/id444934666?mt=8"]];
        }
    }else if (buttonIndex == 0){
        if (alertView.tag == 1002) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 没有微信和QQ弹出提示
- (void)showAlertWithMessage:(NSString *)message andTitle:(NSString *)title andTag:(NSInteger)tag{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往下载", nil];
    alertView.tag = tag;
    [alertView show];
}
#pragma mark - UIWebviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    //读取本地的html文件的时候 要用到
    if (url == nil || [[url absoluteString] isEqualToString:@"about:blank"] || [[url scheme] isEqualToString:@"file"] || [_vedioURLsArr containsObject:[url absoluteString]]) {
        return YES;
    }
    else {
        if ([self isPostUrl:url]) {
            //跳转到帖子详情页面
            NSArray *sepers = [url.path componentsSeparatedByString:@"tid="];
            if (sepers.count == 2) {
                NSString *tid = sepers[1];
                PostDetailViewController *detail = [[PostDetailViewController alloc]init];
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [webView stringByEvaluatingJavaScriptFromString:@"removeQuotesBr()"];
    int cpage = _isLouzhu ? _currentPage_louzhu : _currentPage;

    if (cpage == 1) {
        //第一次进入页面 防止出现黑底footer
        [self resetFooterView];
    }
    if (_isJump) {
        [webView stringByEvaluatingJavaScriptFromString:@"jump()"];
        _isJump = NO;
    }
    [self hideProgressHUD];
}

#pragma mark - notification 通知
- (void)ShareCompleted:(NSNotification *)note
{
    if ([note.name isEqualToString:@"ShareCompleted"]) {
        _isShare = NO;
    }
}

//回复成功 考虑是否刷新数据
- (void)replySuccess:(NSNotification *)note
{
    if ([note.name isEqualToString:@"SendReply_Success"]) {
        int tpage = _isLouzhu ? _totalPage_louzhu : _totalPage;
        if (tpage <= 1) {
            if (self.isLouzhu) {
                //清除本地的数据源
                [_dataDic removeObjectForKey:[NSString stringWithFormat:@"%@_1",keyNormalData]];
                self.currentPage_louzhu = 1;
                [self requestDataWithPage:_currentPage_louzhu withJumpAction:YES];
            } else {
                [_dataDic removeObjectForKey:[NSString stringWithFormat:@"%@_1",keyLouzhuData]];
                //只有一页 刷新数据
                self.currentPage = 1;
                [self requestDataWithPage:_currentPage withJumpAction:YES];
            }
        }
        else {
            int cpage = _isLouzhu ? _currentPage_louzhu : _currentPage;
            int tpage = _isLouzhu ? _totalPage_louzhu : _totalPage;
            if (cpage > 1 && cpage == tpage) {
                //最后一页
                [self updateDataWithPage:cpage];
            }
        }
    }
}

#pragma mark - 键盘监听
#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note
{
    if (_isShare) {
        return;
    }
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat ty = - rect.size.height-kVIEW_H(_keyboardBarView);
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        _keyboardBarView.transform = CGAffineTransformMakeTranslation(0, ty);
        [self.view bringSubviewToFront:_keyboardBarView];
    }];
}

#pragma mark 键盘即将退出
- (void)keyBoardWillHide:(NSNotification *)note
{
    if (_isShare) {
        return;
    }
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        _keyboardBarView.transform = CGAffineTransformIdentity;
        [self.view sendSubviewToBack:_keyboardBarView];
    }];
}

//取出帖子内容里面所有的视频连接
- (void)getAllVedioURLsForContent:(NSString *)htmlString
{
    if (isNull(htmlString)) {
        return ;
    }
    //正则找出所有的vedio标签 得到vedio标签的url链接 添加进白名单
    NSString *regex = @"<div class=\"iyouzu_video\"><iframe id=\"iyouzu_youku_[0-9]+?\" src=\"(.*?)\" .*?</iframe>";
    NSString *Oriresult = [htmlString stringByMatching:regex capture:0L];
    NSString *result = [htmlString stringByMatching:regex capture:1L];
    if (result) {
        if (![_vedioURLsArr containsObject:result]) {
            [_vedioURLsArr addObject:result];
            htmlString = [htmlString stringByReplacingOccurrencesOfString:Oriresult withString:@""];
            [self getAllVedioURLsForContent:htmlString];
        }
    }
}

- (BOOL)isPostUrl:(NSURL *)url
{
    NSString *baseUrl = [NSString returnPlistWithKeyValue:@"ListAdURL"];
    NSURL *baseURI = [NSURL URLWithString:baseUrl];
    if ([baseURI.host isEqualToString:url.host] && [url.path rangeOfString:@"mod=viewthread"].location != NSNotFound) {
        return YES;
    }
    return NO;
}


@end
