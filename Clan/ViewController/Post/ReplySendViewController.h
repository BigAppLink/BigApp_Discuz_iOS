//
//  ReplySendViewController.h
//  Clan
//
//  Created by chivas on 15/4/2.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "BaseViewController.h"
#import "QBImagePickerController.h"
//回帖和回复的回帖都在这里写 避免逻辑混乱
@interface ReplySendViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate>
@property (copy, nonatomic) void(^imageCountUpdate)(NSInteger count);

@end
