//
//  LucPhotoHelper.h
//  News
//
//  Created by wallstreetcn on 14-11-5.
//  Copyright (c) 2014年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LucImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol LucPhotoHelperDelegate <NSObject>

- (void)LucPhotoHelperGetPhotoSuccess:(UIImage *)image;

@end

@interface LucPhotoHelper : NSObject <LucImageCropperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) id target;
@property (nonatomic, assign) id <LucPhotoHelperDelegate> delegate;

//编辑头像
- (void)editPortraitInView:(id)view;
@end
