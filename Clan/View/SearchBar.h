//
//  SearchBar.h
//  News
//
//  Created by fallen on 14-12-17.
//  Copyright (c) 2014年 wallstreetcn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchBar;

@protocol SearchBarDelegate <NSObject>

- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar;
- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarSearchButtonClicked:(SearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(SearchBar *)searchBar;

@end


@interface SearchBar : UIView <UITextFieldDelegate>

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIImageView *searchIcon;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, assign) BOOL showCanecelButton;
@property (nonatomic, weak) id<SearchBarDelegate> delegate;
@property (nonatomic, strong) UIButton *jumpButton;

- (void)addJumpButton;
- (id)initWithFrame:(CGRect)frame ShowCancelButton:(BOOL)flag;

@end
