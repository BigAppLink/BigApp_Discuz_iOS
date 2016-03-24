//
//  PopoverView.m
//  Clan
//
//  Created by chivas on 15/4/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PopoverView.h"
#define kArrowHeight 10.f
#define kArrowCurvature 6.f
#define SPACE 5.f
#define ROW_HEIGHT 50.f
@interface PopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *selectImageArray;

@property (nonatomic) CGRect btrFrame;

@property (nonatomic, strong) UIButton *handerView;

@end

@implementation PopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(id)initWithFromBarButtonItem:(UIButton*)barButtonItem inView:(UIView *)inview titles:(NSArray *)titles images:(NSArray *)images selectImages:(NSArray *)selectImage
{
    self = [super init];
    if (self) {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        _btrFrame = [barButtonItem convertRect:barButtonItem.bounds toView:window];


        self.titleArray = titles;
        self.imageArray = images;
        self.selectImageArray = selectImage;
        self.frame = [self getViewFrame];
        if (!_imageView) {
            _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
            _imageView.userInteractionEnabled = YES;
            UIImage* image = [UIImage imageNamed:@"list_more"];
            UIEdgeInsets insets = UIEdgeInsetsMake(30, 0, 30, 100);
            image = [image resizableImageWithCapInsets:insets];
            _imageView.image = image;
        }
        [self addSubview:_imageView];
    }
    return self;
}
- (void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    [_imageView addSubview:self.tableView];

}
-(CGRect)getViewFrame
{
    CGRect frame = _btrFrame;
    frame.size.width = 143;
    frame.origin.x = ScreenWidth - frame.size.width - 5;
    frame.origin.y = 64;
    frame.size.height = [self.titleArray count] * ROW_HEIGHT + kArrowHeight + SPACE - 1;
    UIView *tempView = [[UIView alloc]initWithFrame:frame];
    frame = [tempView convertRect:tempView.bounds toView:self];
    return frame;
}

-(void)show
{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}
-(void)dismiss
{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
    
}

#pragma mark - UITableView

-(UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.left = _imageView.left + SPACE;
    _tableView.top = kArrowHeight;
    _tableView.width = _imageView.width - SPACE * 2;
    _tableView.height = _imageView.height - kArrowHeight - SPACE;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.backgroundColor = [UIColor clearColor];
    
    return _tableView;
}


#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        cell.backgroundColor = [UIColor clearColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, ROW_HEIGHT - 0.5, cell.width, 0.5)];
        line.backgroundColor = UIColorFromRGB(0x152333);
        [cell.contentView addSubview:line];
    }
    
    if ([_imageArray count] == [_titleArray count]) {
        if (_selectIndex == indexPath.row) {
            cell.imageView.image = [UIImage imageNamed:[_selectImageArray objectAtIndex:indexPath.row]];
        }else{
            cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
        }
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    [self dismiss:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

@end
