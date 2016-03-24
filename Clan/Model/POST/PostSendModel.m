//
//  PostSendModel.m
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostSendModel.h"

@implementation PostSendModel
+(PostSendModel *)PostForSend{
    PostSendModel *post = [[PostSendModel alloc] init];
    post.imageArray = [[NSMutableArray alloc] init];
    return post;
}
- (BOOL)isAllImagesHaveDone{
    for (SendImage *imageItem in _imageArray) {
        if (imageItem.uploadState != SendImageUploadStateSuccess) {
            return NO;
        }
    }
    return YES;
}
@end

@implementation SendImage
+ (instancetype)sendImageWithImage:(UIImage *)image{
    SendImage *sendImage = [[SendImage alloc] init];
    sendImage.image = image;
    sendImage.imageAttachArray = [NSMutableArray array];
    sendImage.uploadState = SendImageUploadStateInit;
    return sendImage;
}

@end
