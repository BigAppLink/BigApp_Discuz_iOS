//
//  FaceImageViewModel.h
//  Clan
//
//  Created by chivas on 15/8/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface FaceImageViewModel : ViewModelClass
//获取表情包
- (void)request_downloadFaceWithUrl:(NSString *)url andBlock:(void(^)(BOOL isDownload))block;
//获取表情包映射关系
- (void)request_downloadFaceJsonWithBlock:(void(^)(BOOL isDownload))block;
//是否需要下载表情和映射关系
- (void)request_downloadFaceIsDownloadWithBlock:(void(^)(BOOL isDownload,NSString *url))block;
@property (copy, nonatomic) void(^returnIsDown)(BOOL isdown,NSString *url);
@end
