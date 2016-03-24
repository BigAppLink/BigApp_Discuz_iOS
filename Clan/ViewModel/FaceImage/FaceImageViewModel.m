//
//  FaceImageViewModel.m
//  Clan
//
//  Created by chivas on 15/8/10.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "FaceImageViewModel.h"
#import "ZipArchive.h"
#import "Main.h"
#import "NSObject+Common.h"
@implementation FaceImageViewModel
- (void)request_downloadFaceWithUrl:(NSString *)url andBlock:(void(^)(BOOL isDownload))block{
    if (url) {

        NSString *pathName = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_zipFileName];
        if (pathName) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *path = [NSObject pathInDocumentDirectory:pathName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:ClanFaceImagePath]){
                [fileManager removeItemAtPath:ClanFaceImagePath error:nil];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
                [fileManager removeItemAtPath:path error:nil];
            }
        }
        [[Clan_NetAPIManager sharedManager]request_downloadFaceWithPath:url andBlock:^(NSURL *filePath, NSString *fileName, NSError *error) {
            if (error) {
                block(NO);
            }else{
                //解压zip
                //把filename存起来
                [UserDefaultsHelper saveDefaultsValue:fileName forKey:kUserDefaultsKey_zipFileName];
                NSArray*paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *documentsDirectory =[paths objectAtIndex:0];

                NSData *data = [NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:fileName]];
                DLog(@"表情包的大小 %lu",data.length);
                if (data) {
                    //有表情
                    //创建表情文件夹
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSString *facePath = [[documentsDirectory stringByAppendingPathComponent:@"ClanFaceImage"] stringByAppendingPathComponent:@"smiley"];
                    if (![fileManager fileExistsAtPath:facePath]){
                        [fileManager createDirectoryAtPath:facePath withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    NSArray *jsonInfoArray = [UserDefaultsHelper valueForDefaultsKey:kUserDefaultsKey_ClanZipJsonInfo];
                    NSInteger loc = 0;
                    for (int i = 0; i<jsonInfoArray.count; i++) {
                        NSDictionary *dic = jsonInfoArray[i];
                        NSString *path = [facePath stringByAppendingPathComponent:dic[@"pic_directory"]];
                        if (![fileManager fileExistsAtPath:path]) {
                            //如果没有表情包文件夹 创建一个
                            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        //把图片做循环放进去
//                        for (NSDictionary *faceDic in dic[@"pic_schema"]) {
//                            NSInteger len = [faceDic[@"pic_size"] integerValue];
//                            @try {
//                                // Try something
//                                NSData *faceData = [data subdataWithRange:NSMakeRange(loc,len)];
//                                UIImage *faceImage = [UIImage imageWithData:faceData];
//                                //保存到本地
//                                [UIImageJPEGRepresentation(faceImage, 1.0) writeToFile:[path stringByAppendingPathComponent:faceDic[@"pic_name"]] atomically:NO];
//                                loc = len+loc;
//                            }
//                            @catch (NSException * e) {
//                                NSLog(@"Exception: %@", e);
//                                break;
//                            }
//                            @finally {
//                            }
//                        }
                        for (id faceobj in dic[@"pic_schema"]) {
                            NSDictionary *faceDic = nil;
                            if (faceobj && [faceobj isKindOfClass:[NSDictionary class]]) {
                                faceDic = (NSDictionary *)faceobj;
                                NSInteger len = [faceDic[@"pic_size"] integerValue];
                                @try {
                                    // Try something
                                    NSData *faceData = [data subdataWithRange:NSMakeRange(loc,len)];
                                    UIImage *faceImage = [UIImage imageWithData:faceData];
                                    //保存到本地
                                    [UIImageJPEGRepresentation(faceImage, 1.0) writeToFile:[path stringByAppendingPathComponent:faceDic[@"pic_name"]] atomically:NO];
                                    loc = len+loc;
                                }
                                @catch (NSException * e) {
                                    NSLog(@"Exception: %@", e);
                                    break;
                                }
                                @finally {
                                }
                            } else {
                                DLog(@"图片下载出错了 出错了 出错了");
                            }
                    
                        }
                        
                        
                    }
                    block(YES);
                }else{
                    block(NO);
                }
                
                //                [Main unzipFileAtPath:[documentsDirectory stringByAppendingPathComponent:fileName] toDestination:ClanFaceImagePath];w

                
            }
        }];
    }else{
        block(NO);
    }
    
}


- (void)request_downloadFaceJsonWithBlock:(void(^)(BOOL isDownload))block
{
    [[Clan_NetAPIManager sharedManager]request_downloadFaceJsonWithType:nil andBlock:^(id data, NSError *error) {
        if (data) {
            //生成plist映射关系表
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"ClanFaceImage.plist"];
            if ([fileManager fileExistsAtPath:fileName]){
                [fileManager removeItemAtPath:fileName error:nil];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                id resultData = data[@"Variables"];
                if (resultData && ![resultData isKindOfClass:[NSNull class]] && data[@"Variables"]) {
                    NSDictionary *dataDic = data[@"Variables"];
                    NSArray *faceArray = dataDic[@"smilies"];
                    NSMutableDictionary *facePlistDic = [NSMutableDictionary new];
                    NSMutableDictionary *faceImageDic = [NSMutableDictionary new];
                    NSMutableArray *jsonImageArray = [NSMutableArray array];
                    for (NSDictionary *faceDic in faceArray) {
                        NSArray *smileArray = faceDic[@"smiley"];
                        NSMutableArray *faceArray = [NSMutableArray array];
                        NSMutableArray *faceImageArray = [NSMutableArray array];
                        NSMutableDictionary *jsonDic = [NSMutableDictionary new];
                        NSMutableDictionary *jsonImage = [NSMutableDictionary new];
                        for (NSDictionary *urlDic in smileArray) {
                            [faceImageArray addObject:urlDic[@"url"]];
                            NSArray *array = [urlDic[@"url"] componentsSeparatedByString:@"."];
                            [faceArray addObject:array[0]];
                            //映射关系
                            [jsonImage setObject:urlDic[@"code"] forKey:urlDic[@"url"]];
                        }
                        //表情地址
                        [faceImageDic setObject:faceImageArray forKey:faceDic[@"directory"]];
                        [jsonDic setObject:jsonImage forKey:faceDic[@"directory"]];
                        [facePlistDic setObject:faceArray forKey:faceDic[@"directory"]];
                        [jsonImageArray addObject:jsonDic];
                    }
                    //把dic存进本地userdefault
                    [UserDefaultsHelper cleanDefaultsForKey:kUserDefaultsKey_ClanFaceImage];
                    [UserDefaultsHelper saveDefaultsValue:faceImageDic forKey:kUserDefaultsKey_ClanFaceImage];
                    //存映射关系
                    [UserDefaultsHelper cleanDefaultsForKey:kUserDefaultsKey_ClanFaceJson];
                    [UserDefaultsHelper saveDefaultsValue:jsonImageArray forKey:kUserDefaultsKey_ClanFaceJson];
                    
                    //创建plist文件
                    [fileManager createFileAtPath:fileName contents:nil attributes:nil];
                    [facePlistDic writeToFile:fileName atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //回主线程
                        block(YES);
                    });
                } else {
                    block(NO);
                }
            });
        }else{
            block(NO);
        }
    }];
}

- (void)request_downloadFaceIsDownloadWithBlock:(void(^)(BOOL isDownload,NSString *url))block{
    _returnIsDown = nil;
    _returnIsDown = block;
    [self requestIsDown];
    
}

- (void)requestIsDown{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_downloadFaceJsonWithType:@"type" andBlock:^(id data, NSError *error) {
        if (error) {
//            [strongSelf requestIsDown];
        }else{
            NSDictionary *dic = data[@"Variables"];
            //1是未下载 0是已下载
            if ([dic[@"zip_flag"] isEqualToString:@"1"]) {
                weakSelf.returnIsDown(NO,dic[@"zip_url"]);
            }else{
                weakSelf.returnIsDown(YES,nil);
            }
        }
    }];
}

@end

