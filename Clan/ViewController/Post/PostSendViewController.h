//
//  PostSendViewController.h
//  Clan
//
//  Created by chivas on 15/3/25.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "QBImagePickerController.h"
@class ForumsModel;
@class PostDetailModel;
@interface PostSendViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate>
/**如果是发帖,则postModel有值 如果是回复主题则postDetailModel有值**/
@property (strong, nonatomic)ForumsModel *forumsModel;
@property (strong, nonatomic)PostDetailModel *postDetailModel;
@property (nonatomic,copy) void(^sendPostReturnBlock)(id);

//是否是从主页跳过来的
@property (assign) BOOL fromShouYe;
@property (strong, nonatomic) NSArray *dataSourceArray;

@end
