//
//  SearchFriendsController.h
//  Clan
//
//  Created by 昔米 on 15/7/18.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
typedef enum {
    FriendsSearchTypeMyFriends = 0,
    FriendsSearchTypeSearchFriends
} FriendsSearchType;

@interface SearchFriendsController : BaseViewController

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *displayVC;
@property (strong, nonatomic) BaseTableView *tableview;
@property (assign, nonatomic) FriendsSearchType searchType;
@property (strong, nonatomic) NSMutableArray *friendsList;

@end
