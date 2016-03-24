//
//  YZDataPicker.m
//  Clan
//
//  Created by chivas on 15/10/30.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//
static NSInteger const ZHToobarHeight = 40;
static CGFloat const PMEDateHeight = 216;
#import "YZDataPicker.h"
#import "PMEDatePicker.h"
#import "NSDate+Helper.h"
@interface YZDataPicker()<PMEDatePickerDelegate>
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,assign)NSInteger pickeviewHeight;
@property (strong, nonatomic) PMEDatePicker *datePicker;
@property (copy, nonatomic) NSString *dateString;
@end
@implementation YZDataPicker
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dateString = [NSDate stringFromDate:[NSDate date] withFormat:@"yyyy-MM-dd  HH:00"];
        [self setUpToolBar];
        [self setUpPickView];
        [self setFrameWith:NO];
    }
    return self;
}

-(void)setFrameWith:(BOOL)isHaveNavControler{
    CGFloat toolViewX = 0;
    CGFloat toolViewH = _pickeviewHeight+ZHToobarHeight;
    CGFloat toolViewY ;
    if (isHaveNavControler) {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH-50;
    }else {
        toolViewY= [UIScreen mainScreen].bounds.size.height;
    }
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(toolViewX, toolViewY, toolViewW, toolViewH);
}


-(void)setUpPickView{
    _datePicker = [[PMEDatePicker alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, PMEDateHeight)];
    _datePicker.backgroundColor = [UIColor whiteColor];
    _pickerView=_datePicker;
    _pickerView.frame=CGRectMake(0, ZHToobarHeight, _pickerView.frame.size.width, _pickerView.frame.size.height);
    _pickeviewHeight=_pickerView.frame.size.height;
    _datePicker.dateDelegate = self;
    _datePicker.minimumDate = [NSDate date];
    _datePicker.dateFormatTemplate = @"yyyyMMMdHH";
    [self addSubview:_datePicker];
}

- (void)datePicker:(PMEDatePicker*)datePicker didSelectDate:(NSDate*)date{
    _dateString = [NSDate stringFromDate:date withFormat:@"yyyy-MM-dd  HH:00"];
}

-(void)setUpToolBar{
    _toolbar=[self setToolbarStyle];
    [self setToolbarWithPickViewFrame];
    [self addSubview:_toolbar];
}

-(void)setToolbarWithPickViewFrame{
    _toolbar.frame=CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, ZHToobarHeight);
}


-(UIToolbar *)setToolbarStyle
{
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"  取消" style:UIBarButtonItemStyleBordered target:self action:@selector(remove)];
    [barItems addObject:cancelBtn];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成  " style:UIBarButtonItemStyleDone target:self action:@selector(doneClick)];
    [barItems addObject:doneBtn];
    [toolbar setItems:barItems animated:YES];
    return toolbar;
}

-(void)remove{
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(toobarCancelClick)]) {
            [self.delegate toobarCancelClick];
        }
        [self removeFromSuperview];
    }];
}

- (void)doneClick{
    if ([self.delegate respondsToSelector:@selector(toobarDonBtnHaveClick:resultString:)]) {
        [self.delegate toobarDonBtnHaveClick:self resultString:_dateString];
    }
}

-(void)show{
    if (self.top < ScreenHeight) {
        return;
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat toolViewH = _pickeviewHeight+ZHToobarHeight;
        self.transform= CGAffineTransformTranslate(self.transform, 0, -toolViewH);
    }];
}

-(void)dealloc{
    
    //NSLog(@"销毁了");
}
@end
