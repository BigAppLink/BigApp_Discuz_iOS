//
//  ArticleCustomViewController.m
//  Clan
//
//  Created by chivas on 15/9/6.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ArticleCustomViewController.h"
#import "ArticleModel.h"
#import "HomeViewModel.h"
#import "ArticleCell.h"
#import "ArticleDetailViewController.h"
#import "PostDetailVC.h"

@interface ArticleCustomViewController ()

@property (strong, nonatomic)BaseTableView *tableView;
@property (strong, nonatomic)HomeViewModel *homeViewModel;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (assign, nonatomic) int page;
@property (copy, nonatomic) NSString *articleType;
//@property (assign) int currentPage;

@end

@implementation ArticleCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _articleModel.title;
    if (!_homeViewModel) {
        _homeViewModel = [HomeViewModel new];
        _dataArray = [NSMutableArray array];
    }
    [self initTable];
}

- (void)setArticleModel:(ArticleModel *)articleModel{
    _articleModel= articleModel;
    _articleType = _articleModel.articleId;
}
#pragma mark - table
- (void)initTable
{
//    if (self.tabBarController)
//    {
//    }else{
//            _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenBoundsHeight-40)style: UITableViewStylePlain];
//    }
    
    _tableView = [[BaseTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenBoundsHeight-49)style: UITableViewStylePlain];
//    _tableView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kVIEW_H(self.view));
    UINib *cellNib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"ArticleCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    WEAKSELF
//    [_tableView addLegendHeaderWithRefreshingBlock:^{
//        weakSelf.page = 1;
//        [weakSelf requestData:weakSelf.articleType];
//    }];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    //加载缓存数据
    [self loadCache];
    [Util setExtraCellLineHidden:_tableView];
}

#pragma mark - 加载缓存
- (void)loadCache
{
    WEAKSELF
    [_homeViewModel request_cacheWithArticleType:_articleType andBlock:^(NSMutableArray *articleArray, BOOL isError) {
        STRONGSELF
        _dataArray = articleArray;
        [strongSelf.tableView reloadData];
    }];
    [self addPullRefreshActionWithDown];
}
#pragma mark - 刷新
//上拉下拉刷新
- (void)addPullRefreshActionWithDown
{
    WEAKSELF
    //下拉刷新
    [_tableView createHeaderViewBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.page = 1;
        [strongSelf requestData:_articleType];
    }];
    //第一次加载
//    [self loadCache:self.type];
    [_tableView beginRefreshing];
}

- (void)addPullRefreshActionWithUp
{
    if (!_tableView.legendFooter) {
        WEAKSELF
        [_tableView createFooterViewBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.page ++;
            [strongSelf requestData:_articleType];
        }];
    }
}

- (void)requestData:(NSString *)listType
{
    WEAKSELF
    [_homeViewModel request_articleType:_articleType page:@(_page).stringValue andBlcok:^(id data,BOOL isMore) {
        STRONGSELF
        [strongSelf.tableView endHeaderRefreshing];
        if (data) {
            if (strongSelf.page == 1) {
                [_dataArray removeAllObjects];
                _dataArray = data;
                
            }else{
                [strongSelf.dataArray addObjectsFromArray:data];
            }
            [strongSelf resetFooterForNeedMore:isMore];
        }
        [strongSelf.tableView configBlankPage:DataIsNothingWithDefault hasData:(strongSelf.dataArray.count > 0) hasError:(!data && _dataArray.count == 0) reloadButtonBlock:^(id sender) {
            [strongSelf requestData:strongSelf.articleType];
        }];
        [strongSelf.tableView reloadData];
    }];
}
- (void)resetFooterForNeedMore:(BOOL)need_more
{
    if (need_more) {
        if (!self.tableView.footer) {
            [self addPullRefreshActionWithUp];
        }
        self.tableView.footer.state = MJRefreshFooterStateIdle;
    } else {
        self.tableView.footer.state = MJRefreshFooterStateNoMoreData;
    }
}

#pragma mark Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleCell" forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *lineLabel = [self lineViewWithFrame:CGRectMake(0, cell.contentView.bottom - 0.5, ScreenWidth, 0.5)];
    [cell.contentView addSubview:lineLabel];
    cell.articleModel = _dataArray[indexPath.row];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ArticleModel *article = _dataArray[indexPath.row];
//    PostDetailVC *detail = [[PostDetailVC alloc]init];
//    detail.isArticle = YES;
//    PostModel *postModel = [PostModel new];
//    postModel.tid = article.articleId;
//    detail.postModel =  postModel;
//    detail.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:detail animated:YES];
    ArticleDetailViewController *articleDetailVc = [[ArticleDetailViewController alloc]init];
    articleDetailVc.articleModel = _dataArray[indexPath.row];
    articleDetailVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:articleDetailVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)lineViewWithFrame:(CGRect)frame
{
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:frame];
    lineLabel.backgroundColor = UIColorFromRGB(0xeeeeee);
    return lineLabel;
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
