//
//  PostSendModel.h
//  Clan
//
//  Created by chivas on 15/3/26.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface PostSendModel : NSObject
@property (strong, nonatomic)NSMutableArray *imageArray;
@property (copy, nonatomic)NSString *fid;
@property (copy, nonatomic)NSString *uploadhash;
@property (copy, nonatomic)NSString *uid;
@property (strong, nonatomic)NSData *imageData;
@property (copy, nonatomic)NSString *subject;
@property (copy, nonatomic)NSString *message;
@property (copy, nonatomic)NSString *typeId;
//回复帖子用字段
@property (copy, nonatomic)NSString *tid;
@property (copy, nonatomic)NSString *pid;
@property (copy, nonatomic)NSString *dateline;
@property (copy, nonatomic)NSString *dbdateline;
@property (copy, nonatomic)NSString *textMessage;
@property (copy, nonatomic)NSString *author;
/**
 *  发送主题后返回的tid
 */
@property (copy, nonatomic)NSString *myPostTid;
/**
 *  反馈用 联系方式
 */
@property (copy, nonatomic) NSString *contact;
+(PostSendModel *)PostForSend;
- (BOOL)isAllImagesHaveDone;

@end

typedef NS_ENUM(NSInteger, TweetImageUploadState)
{
    SendImageUploadStateInit = 0,
    SendImageUploadStateIng,
    SendImageUploadStateSuccess,
    SendImageUploadStateFail
};

@interface SendImage : NSObject
+ (instancetype)sendImageWithImage:(UIImage *)image;
@property (readwrite, nonatomic, strong) UIImage *image;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *attachmentId;
@property (assign, nonatomic)long long size;
@property (copy, nonatomic) NSString *fileType;
@property (copy, nonatomic) NSString *fileURL;
@property (readwrite, nonatomic, strong) NSString *imageStr;
@property (assign, nonatomic) TweetImageUploadState uploadState;
@property (strong, nonatomic) NSMutableArray *imageAttachArray;
@end
