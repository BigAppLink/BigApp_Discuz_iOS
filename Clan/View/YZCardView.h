//
//  YZCardView.h
//  Clan
//
//  Created by 昔米 on 15/4/3.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZCardView : UIView
{
    NSMutableArray *_titleArray;
    NSMutableDictionary *_actionDic;
    UISegmentedControl *_segment;
}

@property (weak, nonatomic) id target;
@property (assign) NSInteger defaultIndex;

- (void)addCardWithTitle:(NSString *)title withSel:(SEL)selector;

- (void)changeTitleAtIndex:(int)index withNewTitle:(NSString *)title;
- (void)changeSelectBtn:(NSInteger)index;
@end
