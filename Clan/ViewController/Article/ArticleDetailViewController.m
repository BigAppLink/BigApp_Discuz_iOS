//
//  ArticleDetailViewController.m
//  Clan
//
//  Created by chivas on 15/9/7.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "MGTemplateEngine.h"
#import "WebViewJavascriptBridge.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"
#import "TOWebViewController.h"
#import "HomeViewModel.h"
#import "ArticleListModel.h"
#import "ArticleDetailModel.h"
#import "ICUTemplateMatcher.h"
#import "Util.h"
#import "PopoverView.h"
#import "CollectionViewModel.h"

@interface ArticleDetailViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) MGTemplateEngine *webEngine; //html页面engine
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) UIWebView *webview;
@property (strong, nonatomic) HomeViewModel *homeViewModel;
@property (strong, nonatomic) CollectionViewModel *favoViewModel;
@property (assign, nonatomic) BOOL isShare;
@property (strong, nonatomic) ArticleDetailModel *detailModel;
@property (strong, nonatomic) UIButton *viewMoreBtn;
@end

@implementation ArticleDetailViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShareCompleted:) name:@"ShareCompleted" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
    }
    if (!self.favoViewModel) {
        self.favoViewModel = [CollectionViewModel new];
    }
    [self initNav];
    [self loadModel];
    [self requestData];
    [self buildUI];
}

//- (void)initNav
//{
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detail_share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)] animated:NO];
//    
//}

- (void)initNav
{
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

//更多按钮
- (IBAction)viewMoreAction:(id)sender
{
    NSString *favoImgName = [Util isFavoed_withID:_articleModel.aid forType:myArticle] ? @"detail_favo_H" : @"favo_N";
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
            [strongSelf favoAction];
        else if (index == 1)
            [strongSelf shareAction];
//        else if (index == 2)
//            [strongSelf jumpPageAction];
//        else
//            [strongSelf reportAction];
    };
    [pop show];
}

#pragma mark - 请求数据
- (void)requestData
{
    WEAKSELF
    [_homeViewModel request_articleDetailWithId:_articleModel.aid andBlock:^(id data) {
        STRONGSELF
        if (data) {
            ArticleDetailModel *model = data;
            _detailModel = model;
            [strongSelf HTMLContent:_detailModel];
        }
    }];
}

#pragma mark - 分享
- (void)shareAction
{
    if (_detailModel) {
        _isShare = YES;
        NSString *descrip = [Util formatHtmlString:(_detailModel && _detailModel.content)? _detailModel.content : @""];
        if (!descrip || descrip.length <= 0) {
            descrip = _detailModel.share_url;
        }
        if (descrip && descrip.length > 140) {
            descrip = [descrip substringToIndex:139];
        }
        NSString *title = _detailModel.title;
        if (!title || title.length <= 0) {
            title = _detailModel.share_url;
        }
        if (title && title.length > 140) {
            title = [title substringToIndex:139];
        }
        if (!self.shareImageURL || self.shareImageURL.length == 0) {
            NSString *returnJson = [self.webview stringByEvaluatingJavaScriptFromString:@"getShareImageURL()"];
            self.shareImageURL = returnJson;
        }
        [self doShareWithTitle:title withcontent:descrip withURL:_detailModel.share_url withShareImg:kIMG(@"AppIcon60x60") withShareImgURL:self.shareImageURL withDescription:descrip];
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

//收藏取消收藏
- (void)favoAction
{
    if ([self checkLoginState]) {
        WEAKSELF
        if (![Util isFavoed_withID:_articleModel.aid forType:myArticle]) {
            [_favoViewModel doAnArticleByID:_articleModel.aid andBlock:^(BOOL success) {
                if (success) {
                    DLog(@"收藏成功");
                }
//                [strongSelf resetFavoBtn];
            }];
        } else {
            [_favoViewModel request_DeleteCollection:[Util getFavoIDFromID:_articleModel.aid forType:myArticle] andType:@"aid" andBlock:^(BOOL state) {
                STRONGSELF
                if (state) {
                    //删除成功 删除本地记录
                    [Util deleteFavoed_withID:strongSelf.articleModel.aid forType:myArticle];
                }
//                [strongSelf resetFavoBtn];
            }];
        }
    }
}

- (void)resetFavoBtn
{
//    NSString *favoImgName = [Util isFavoed_withID:_postModel.tid forType:myPost] ? @"detail_favo_H" : @"detail_favo";
//    NSString *title =[Util isFavoed_withID:_postModel.tid forType:myPost] ? @"  已收藏" : @"  收藏";
//    [self.favoButton setImage:kIMG(favoImgName) forState:UIControlStateNormal];
//    [self.favoButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - notification 通知
- (void)ShareCompleted:(NSNotification *)note
{
    if ([note.name isEqualToString:@"ShareCompleted"]) {
        _isShare = NO;
    }
}


#pragma mark - 初始化数据源 和 视图
//数据源
- (void)loadModel
{
//    _voteArray = [NSMutableArray new];
//    self.dataDic = [NSMutableDictionary new];
//    self.tempDataDic = [NSMutableDictionary new];
//    self.detailViewModel = [PostDetailViewModel new];
    self.webEngine = [MGTemplateEngine templateEngine];
    [_webEngine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:_webEngine]];
}

//视图
- (void)buildUI
{
    self.title = @"文章详情";
//    [self initBottomView];
//    [self initKeyBoardBar];
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-64)];
    web.backgroundColor = [UIColor whiteColor];
    self.webview = web;
    [self.view addSubview:web];
    [self buildBridge];
}

#pragma mark - 桥接器
- (void)buildBridge
{
    WebViewJavascriptBridge *bg = [WebViewJavascriptBridge bridgeForWebView:self.webview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
    }];
    _bridge = bg;
    [self registerHandlerForBridge:bg];
}

- (void)registerHandlerForBridge:(WebViewJavascriptBridge *)bridge{
    //点击图片
    WEAKSELF
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

//加载html数据
- (void)HTMLContent:(ArticleDetailModel *)content
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"portal_detail" ofType:@"html"];
    NSDictionary *variables = @{
                                @"message": avoidNullStr(content.content),
                                @"title": avoidNullStr(content.title),
                                @"author": avoidNullStr(content.summary),
                                @"dateline": avoidNullStr(content.dateline),
                                
                                };
    
    NSString *html = [_webEngine processTemplateInFileAtPath:templatePath withVariables:variables];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webview loadHTMLString:html baseURL:baseURL];
    [self.webview stringByEvaluatingJavaScriptFromString:@"removeQuotesBr()"];
}

#pragma mark - 没有微信和QQ弹出提示
- (void)showAlertWithMessage:(NSString *)message andTitle:(NSString *)title andTag:(NSInteger)tag{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往下载", nil];
    alertView.tag = tag;
    [alertView show];
}

- (void)dealloc
{
    _webEngine = nil;
    _webview.delegate = nil;
    [_webview loadHTMLString:nil baseURL:nil];
    _webview = nil;
    DLog(@"DetailViewController dealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
