//
//  CustomGridView.h
//  Clan
//
//  Created by chivas on 15/8/19.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomGridView : UIView
{
    NSMutableArray *_titleArray;
    NSMutableDictionary *_actionDic;
    UIButton *_tempBtn;
}
@property (strong, nonatomic)UIScrollView *scrollView;
@property (weak, nonatomic) id target;
@property (assign) int defaultIndex;
@property (strong, nonatomic)UIFont *textFont;
@property (copy, nonatomic) NSString *gridType;
@property (strong, nonatomic)UIColor *textColor;
@property (strong, nonatomic) UIViewController *viewController;
- (void)addCardWithTitle:(NSString *)title withSel:(SEL)selector;
- (void)initScrollView;
- (void)changeTitleAtIndex:(int)index withNewTitle:(NSString *)title;

- (IBAction)tapAction:(id)sender;

- (void)addCardDone;
@end
