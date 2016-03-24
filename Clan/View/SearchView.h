//
//  SearchView.h
//  Clan
//
//  Created by chivas on 15/7/8.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SearchViewDelegate <NSObject>
@required
- (void)selectType:(NSString *)type;
@end
@interface SearchView : UIView
- (instancetype)initWithFrame:(CGRect)frame;
- (void)searchWithString:(NSString *)string andType:(NSString *)type isFirst:(BOOL)isFirst;
@property (assign, nonatomic) id<SearchViewDelegate> delegate;
@end
