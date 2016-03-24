//
//  PopoverView.h
//  Clan
//
//  Created by chivas on 15/4/20.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClanApiUrl.h"

@interface PopoverView : UIView
-(id)initWithFromBarButtonItem:(UIButton*)barButtonItem inView:(UIView *)inview titles:(NSArray *)titles images:(NSArray *)images selectImages:(NSArray *)selectImage;
-(void)show;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);
@property (nonatomic,assign) NSInteger selectIndex;
@end
