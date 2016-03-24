//
//  Clan_NetAPIManager.m
//  Clan
//
//  Created by chivas on 15/3/11.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "Clan_NetAPIManager.h"
#import "SDImageCache.h"
#import "MJExtension.h"
#import "UserModel.h"
#import "CollectionModel.h"
#import "CollectionListModel.h"
#import "CheckPostModel.h"
#import "PostSendModel.h"
#import "PostModel.h"
#import "NSString+Emojize.h"
#import "ReplyModel.h"
#import "NSString+Common.h"
#import "ForumsModel.h"
#import  <CoreTelephony/CTCarrier.h>
#import  <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "ClanNetAPI.h"
static NSString *product_kurl_base_path = @"http://192.168.180.93:8080/product/ui/http/index.php";
static NSString *product_kurl_base_path_test = @"http://10.2.29.10/product/ui/http/index.php";


@interface NSString (EncodingUTF8Additions)

-(NSString *) URLEncodingUTF8String;//编码
-(NSString *) URLDecodingUTF8String;//解码

@end
@implementation NSString (EncodingUTF8Additions)

- (NSString *)URLEncodingUTF8String
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)self,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

- (NSString *)URLDecodingUTF8String
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)self,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}


@end

@implementation Clan_NetAPIManager

+ (instancetype)sharedManager {
    static Clan_NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    shared_manager.kurl_base_path = [NSString returnPlistWithKeyValue:YZBasePath];
    return shared_manager;
}
//获取自定义首页数据
- (void)request_customHomeWithBlock:(void(^)(id data, NSError *error))block{
    NSDictionary *dic = @{
                          @"iyzversion" : kiyzversion,
                          @"version" : ClanVersion,
                          @"iyzmobile" : @"1",
                          @"module" : @"myhome"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (!error) {
            block(data,nil);
        }else{
            block(nil,error);
        }
    }];
}

- (void)request_captchaBlack:(void(^)(NSString *session))block
{
    NSDictionary *dic = @{@"version":ClanVersion,@"iyzmobile":@"1",@"module":@"captcha",@"pre":@"1"};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            NSNumber *code = data[@"error"];
            if (code.intValue == 0) {
                NSString *sessionid = data[@"session_id"];
                block(sessionid);
            }
        }
    }];
}
//登录问题
- (void)request_getLoginAskWithBlock:(void(^)(id data,NSError *error))block{
    NSDictionary *dic = @{
                          @"iyzmobile" : @"1",
                          @"iyzversion" : kiyzversion,
                          @"module" : @"secquestion",
                          @"version" : ClanVersion
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}

//登录
- (void)request_Login_WithUserName:(NSString *)username andPassWord:(NSString *)password andFid:(NSString *)fid andQuestionid:(NSString *)questionid andAnswer:(NSString *)answer andBlock:(void (^)(UserModel *data, NSError *error,NSString *message))block
{
    NSDictionary *dic = @{@"version":@"1",@"module":@"login",@"loginsubmit":@"yes",@"infloat":@"yes",@"lssubmit":@"yes",@"inajax":@"1",@"fastloginfield":@"username",@"username":username,@"password":password,@"cookietime":@"259200000",@"quickforward":@"yes",@"handlekey":@"ls",@"questionid":avoidNullStr(questionid),@"answer":avoidNullStr(answer)};
    
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error)
     {
         if (error) {
             block(nil,error,nil);
         }else{
             id resultData = [data valueForKeyPath:@"Variables"];
             DLog(@"%@",data);
             if ([resultData objectForKey:@"auth"] && ![[resultData objectForKey:@"auth"] isEqual:[NSNull null]]) {
                 [ClanNetAPI saveCookieData];
                 [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"kLASTUSERNAME"];
                 UserModel *user = [UserModel currentUserInfo];
                 [user setValueWithObject:[UserModel objectWithKeyValues:data[@"data"]]];
                 //设置登录成功
                 user.logined = YES;
                 [UserModel saveToLocal];
                 if (fid) {
                     [self request_checkPostWithFid:fid];
                 }
                 block(user, nil,nil);
             }else{
                 NSDictionary *errMes = data[@"Message"];
                 NSString *messStr = @"密码错误，请重试";
                 if (errMes) {
                     messStr = errMes[@"messagestr"];
                 }
                 //密码错误
                 block(nil,nil,messStr);
             }
         }
     }];
}


//用户注册

- (void)request_Register_WithUserName:(NSString *)username andPassWord:(NSString *)password andPassWord2:(NSString *)password2 andEmail:(NSString *)email andFid:(NSString *)fid andBlock:(void (^)(id data))block
{
    NSDictionary *dic = @{@"regsubmit":@"yes",@"un":avoidNullStr(username),@"pd":avoidNullStr(password),@"pd2":avoidNullStr(password2),@"em":avoidNullStr(email)};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&module=newuser&iyzmobile=1&inajax=1",_kurl_base_path,ClanVersion] withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(error);
        } else {
            NSDictionary *dic = data[@"Message"];
            if ([dic[@"messageval"] isEqualToString:@"register_succeed"]) {
                //注册成功 登录
                [ClanNetAPI saveCookieData];
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"kLASTUSERNAME"];
                
                UserModel *user = [UserModel currentUserInfo];
                [user setValueWithObject:[UserModel objectWithKeyValues:data]];
                //设置登录成功
                user.logined = YES;
                [UserModel saveToLocal];
                if (fid) {
                    [self request_checkPostWithFid:fid];
                }
            }
            block(data);
        }
    }];
}
//帖子收藏
- (void)request_MyPostCollection_atPage:(NSNumber *)page andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{@"version":ClanVersion,@"module":@"myfavthread",@"page":page};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//版块收藏
- (void)request_MyPlateCollection_atPage:(NSNumber *)page andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{@"version":ClanVersion,@"module":@"myfavforum", @"page":page};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

- (void)request_DeleteMyCollectionWithFavId:(NSString *)favid andType:(NSString *)type andBlock:(void(^)(id data,NSError *error))block
{
    NSArray *arr = [favid componentsSeparatedByString:@"_"];
    if (arr.count == 0) {
        [self showHudTipStr:@"取消收藏失败，请重试"];
        return;
    }
    NSDictionary *dic = @{
                          @"delfavorite":@"true",
                          @"formhash":avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                          @"favorite" : arr ? arr : [NSArray new]
                          };
    NSString *path = [NSString stringWithFormat:@"%@?iyzmobile=1&version=%@&module=delfav",_kurl_base_path,ClanVersion];
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//收藏一个帖子
- (void)favo_a_post_byid:(NSString *)fid andBlock:(void(^)(id data,NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"favoritesubmit" : @"true",
                              @"favoritesubmit_btn" : @"true",
                              @"formhash" : avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                              @"handlekey" : @"k_favorite"
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&module=favthread&id=%@&inajax=1",_kurl_base_path,ClanVersion,fid] withParams:paraDic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (!error) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

//收藏文章
- (void)request_doFavoAnArticleWithId:(NSString *)aid WithBlock:(void(^)(id data,NSError *error))block
{
    NSDictionary *dic = @{
                          @"id" : avoidNullStr(aid),
                          @"favoritesubmit" : @"true"
                          };
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&iyzversion=%@&iyzmobile=1&module=favarticle&formhash=%@",_kurl_base_path,ClanVersion,kiyzversion,avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash])];
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:dic
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

- (void)request_HotPostBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"version":ClanVersion,
                          @"module":@"hotthread"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

- (void)request_BoardBlock:(void(^)(id data, NSError *error))block{
    NSDictionary *dic = @{
                          @"version":ClanVersion,
                          @"module":@"forumnav",
                          @"iyzmobile":@"1"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

- (void)request_PostListWithFilter:(NSString *)filter
                        andOrderby:(NSString *)orderby
                         andDigest:(NSString *)digest
                           andPage:(NSString *)page
                            andFid:(NSString *)fid
                          andBlock:(void(^)(id data, NSError *error))block
{
    //先请求置顶 成功后请求帖子  帖子成功后请求权限
    _postListBlock = nil;
    NSDictionary *dic = @{
                          @"module":@"toplist",
                          @"page": avoidNullStr(page),
                          @"version":ClanVersion,
                          @"fid":avoidNullStr(fid),
                          @"digest":avoidNullStr(digest),
                          };
    WEAKSELF
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id topData, NSError *error) {
        if (error) {
            block(nil,error);
            return ;
        }else{
            STRONGSELF
            strongSelf.postListBlock = block;
            [strongSelf request_postListWithTopListData:topData andFilter:filter andOrderby:orderby andDigest:digest andPage:page andFid:fid];
        }
    }];
}

- (void)request_postListWithTopListData:(id)topData andFilter:(NSString *)filter
                             andOrderby:(NSString *)orderby
                              andDigest:(NSString *)digest
                                andPage:(NSString *)page
                                 andFid:(NSString *)fid{
    WEAKSELF
    NSDictionary *dic = @{@"module":@"forumdisplay",
                          @"page":page,
                          @"version":ClanVersion,
                          @"fid":avoidNullStr(fid),
                          @"filter":avoidNullStr(filter),
                          @"orderby":avoidNullStr(orderby),
                          @"digest":avoidNullStr(digest)
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id postData, NSError *error){
        STRONGSELF
        if (error) {
            if (strongSelf.postListBlock) {
                strongSelf.postListBlock(nil,error);
            }
            return ;
        }else{
            [self request_checkPostWithFid:fid];
            NSArray *dataArray = @[topData,postData];
            if (strongSelf.postListBlock) {
                strongSelf.postListBlock(dataArray,error);
            }        }
    }];
}
//请求分类帖子
- (void)request_classifiedPostsWithFid:(NSString *)fid andTypeId:(NSString *)type_id andPage:(int)page andBlock:(void(^)(id data, NSError *error))block
{
    //    http://120.24.233.197:8080/discuz/api/mobile/iyz_index.php?version=4&module=forumdisplay&fid=2&page=1&filter=typeid&typeid=4
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"module" : @"forumdisplay",
                          @"fid" : avoidNullStr(fid),
                          @"page" : [NSNumber numberWithInt:page],
                          @"filter":@"typeid",
                          @"typeid":avoidNullStr(type_id),
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
            return ;
        } else {
            block(data, nil);
        }
    }];
}

//帖子详情
- (void)request_postDetailWithTid:(NSString *)tid withAuthorID:(NSString *)authorID atPage:(int)page andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{@"version":avoidNullStr(ClanVersion),
                          @"module":@"viewthread",
                          @"tid":avoidNullStr(tid),
                          @"page":[NSNumber numberWithInt:page],
                          @"iyzversion":kiyzversion,
                          };
    
    if (authorID && authorID.length > 0) {
        dic = @{@"version":ClanVersion,
                @"authorid":avoidNullStr(authorID),
                @"module":@"viewthread",
                @"tid":avoidNullStr(tid),
                @"page":[NSNumber numberWithInt:page],
                @"iyzversion":kiyzversion,
                };
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//跳楼
- (void)request_postDetailWithTid:(NSString *)tid withJumpPostion:(NSString *)position andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{@"version":avoidNullStr(ClanVersion),
                          @"module":@"viewthread",
                          @"tid":avoidNullStr(tid),
                          @"iyzversion":kiyzversion,
                          };
    
    if (position && position.length > 0) {
        dic = @{@"version":ClanVersion,
                @"module":@"viewthread",
                @"tid":avoidNullStr(tid),
                @"iyzversion":kiyzversion,
                @"postno":position,
                };
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//发帖前置检查
- (void)check_post_withfid:(NSString *)fid andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"version":ClanVersion,
                          @"module"  : @"checkpost",
                          @"fid" : avoidNullStr(fid),
                          @"iyzmobile":@"1"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        } else {
            block(data, nil);
        }
    }];
}

- (void)uploadSendImage:(PostSendModel *)sendModel
               andBlock:(void (^)(BOOL isUpdate,AFHTTPRequestOperation *operation,NSInteger imageCount,NSString *errorMessage))block
          progerssBlock:(void (^)(CGFloat progressValue))progress{
    static NSInteger tempCount = 0;
    for (int index = 0; index < sendModel.imageArray.count ; index++) {
        SendImage *sendImage = sendModel.imageArray[index];
        sendImage.uploadState = SendImageUploadStateIng;
        NSDictionary *dic = @{
                              @"uid":avoidNullStr([UserModel currentUserInfo].uid),
                              @"filetype":avoidNullStr(sendImage.fileType),
                              @"hash":avoidNullStr(sendModel.uploadhash),
                              @"Filename":avoidNullStr(sendImage.fileName),
                              };
        [[ClanNetAPI sharedJsonClient] uploadImage:sendImage.image path:[NSString stringWithFormat:@"%@?version=%@&fid=%@&module=forumupload&iyzmobile=1",_kurl_base_path,ClanVersion,avoidNullStr(sendModel.fid)] name:@"Filedata" withParams:dic successBlock:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             DLog(@"上传图片operation success: --- %@ *** %@",operation, responseObject);
             if ([responseObject valueForKey:@"Variables"]) {
                 NSDictionary *dic = [responseObject valueForKey:@"Variables"];
                 if (![dic[@"code"] isEqualToString:@"0"]) {
                     //错误 返回错误信息
                     block(NO,operation,tempCount,dic[@"message"]);
                     return ;
                 }
                 tempCount ++;
                 if ([dic valueForKey:@"ret"]) {
                     NSDictionary *value = [dic objectForKey:@"ret"];
                     NSString *attachmentId = value[@"aId"];
                     //图片上传成功 标记图片枚举
                     sendImage.uploadState = SendImageUploadStateSuccess;
                     sendImage.attachmentId = avoidNullStr(attachmentId);
                 }
             } else {
                 sendImage.uploadState = SendImageUploadStateFail;
                 block(NO,operation,tempCount,nil);
                 [[[ClanNetAPI sharedJsonClient] operationQueue] cancelAllOperations];
                 return;
             }
             if ([sendModel isAllImagesHaveDone]) {
                 block(YES,operation,tempCount,nil);
             }
             
         } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
             DLog(@"upload image operation success: --- %@",operation);
             if ([operation.responseString integerValue]> 0) {
                 tempCount ++;
                 //图片上传成功 标记图片枚举
                 sendImage.uploadState = SendImageUploadStateSuccess;
                 sendImage.attachmentId = operation.responseString;
             } else {
                 sendImage.uploadState = SendImageUploadStateFail;
                 block(NO,operation,tempCount,nil);
                 return ;
             }
             if ([sendModel isAllImagesHaveDone]) {
                 block(YES,operation,tempCount,nil);
             }
         } progerssBlock:^(CGFloat progressValue) {
             progress(progressValue);
         }];
    }
}

- (void)uploadSendPost:(PostSendModel *)sendModel andBlock:(void (^)(id data, NSError *error))block
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash] forKey:@"formhash"];
    [dic setObject:@"1" forKey:@"wysiwyg"];
    if (sendModel.subject) {
        //新帖
        [dic setObject:@"1" forKey:@"allownoticeauthor"];
        [dic setObject:avoidNullStr(sendModel.subject) forKey:@"subject"];
        if (sendModel.typeId && sendModel.typeId.length > 0) {
            [dic setObject:avoidNullStr(sendModel.typeId) forKey:@"typeid"];
        }
    } else {
        [dic setObject:@"1" forKey:@"usesig"];
        if (sendModel.pid) {
            [dic setObject:avoidNullStr(sendModel.pid) forKey:@"reppid"];
            NSString *textMessage = nil;
            NSString *clearHteml = [NSString flattenHTML:sendModel.textMessage];
            if (clearHteml.length > 30 && [clearHteml rangeOfString:@"class=\"smile-png\""].location == NSNotFound) {
                textMessage = [clearHteml substringToIndex:30];
                textMessage = [NSString stringWithFormat:@"%@...",textMessage];
            }else{
                textMessage = clearHteml;
            }
            NSString *dateStr = [Util changeTimestampToStr:sendModel.dbdateline];
            if (!sendModel.dbdateline) {
                dateStr = sendModel.dateline;
            }
            NSString *string = [NSString stringWithFormat:@"[quote]%@ 发表于 %@ \n%@[/quote]",sendModel.author,dateStr,textMessage];
            string = [string aliasedString];
            [dic setObject:avoidNullStr(string) forKey:@"noticetrimstr"];
            [dic setObject:avoidNullStr(sendModel.pid) forKey:@"reppost"];
        }
    }
    NSString *attachString = @"";
    for (SendImage *attachment in sendModel.imageArray) {
        NSString *attachKey = [NSString stringWithFormat:@"attachnew[%@][description]",attachment.attachmentId];
        [dic setObject:@"" forKey:attachKey];
        NSString *tempField = [NSString stringWithFormat:@"[attachimg]%@[/attachimg]",attachment.attachmentId];
        attachString = attachString ? [NSString stringWithFormat:@"%@\r\n%@", attachString, tempField]:tempField;
    }
    NSString *oriStr = avoidNullStr([sendModel.message  aliasedString]) ;
    NSString *strAvoidEmoji = avoidNullStr([oriStr removeEmoji]);
    [dic setObject:[NSString stringWithFormat:@"%@%@",strAvoidEmoji,attachString] forKey:@"message"];

    NSString *module;
    NSString *type;
    if (sendModel.subject) {
        //新帖
        module = @"newthread";
        type = @"topicsubmit";
    }else{
        module = @"sendreply";
        type = @"replysubmit";
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&fid=%@&module=%@&%@=yes&tid=%@",_kurl_base_path,ClanVersion,sendModel.fid,module,type,sendModel.tid] withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (!error) {
            block(data,nil);
        }else{
            block(nil,error);
        }
    }];
}

//发表活动帖
- (void)upload_ActivityPost:(SendActivity *)activityModel
                   andBlock:(void(^)(id data, NSError *error))block{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash] forKey:@"formhash"];
    [dic setObject:@"1" forKey:@"wysiwyg"];
    [dic setObject:@"4" forKey:@"special"];
    [dic setObject:@"1" forKey:@"usesig"];
    [dic setObject:@"1" forKey:@"allownoticeauthor"];
    [dic setObject:avoidNullStr(activityModel.starttimefrom) forKey:@"starttimefrom[0]"];
    [dic setObject:avoidNullStr(activityModel.activityplace) forKey:@"activityplace"];
    [dic setObject:avoidNullStr(activityModel.activityplace) forKey:@"activitycity"];
    [dic setObject:avoidNullStr(activityModel.activityclass) forKey:@"activityclass"];
    if (activityModel.activityaid_url && activityModel.activityaid_url.length > 0) {
        [dic setObject:avoidNullStr(activityModel.activityaid) forKey:@"activityaid"];
        [dic setObject:avoidNullStr(activityModel.activityaid_url) forKey:@"activityaid_url"];
    }

    [dic setObject:avoidNullStr(activityModel.subject) forKey:@"subject"];
    NSString *attachString = @"";
    for (SendImage *attachment in activityModel.sendModel.imageArray) {
        NSString *attachKey = [NSString stringWithFormat:@"attachnew[%@][description]",attachment.attachmentId];
        [dic setObject:@"" forKey:attachKey];
        NSString *tempField = [NSString stringWithFormat:@"[attachimg]%@[/attachimg]",attachment.attachmentId];
        attachString = attachString ? [NSString stringWithFormat:@"%@\r\n%@", attachString, tempField]:tempField;
    }
    NSString *oriStr = avoidNullStr([activityModel.sendModel.message  aliasedString]) ;
    NSString *strAvoidEmoji = avoidNullStr([oriStr removeEmoji]);
    [dic setObject:[NSString stringWithFormat:@"%@%@",strAvoidEmoji,attachString] forKey:@"message"];
    NSString *userField;
    for (NSString *userfield in activityModel.userfield) {
        NSString *tempField = [NSString stringWithFormat:@"userfield[]=%@",userfield];
        userField = userField ? [NSString stringWithFormat:@"%@&%@", userField, tempField]:tempField;
    }
    if (activityModel.extfield && activityModel.extfield.length > 0) {
        [dic setObject:activityModel.extfield forKey:@"extfield"];
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&fid=%@&module=newthread&topicsubmit=yes&%@",_kurl_base_path,ClanVersion,activityModel.fid,avoidNullStr(userField)] withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (!error) {
            block(data,nil);
        }else{
            block(nil,error);
        }
    }];
    

}
//发帖权限验证
- (void)request_checkPostWithFid:(NSString *)fid
{
    NSDictionary *checkPostDic = @{@"module":@"checkpost",@"fid":avoidNullStr(fid),@"version":ClanVersion};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:checkPostDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            NSDictionary *resultData = [data valueForKeyPath:@"Variables"];
            BOOL isImageType = YES;
            CheckPostModel *checkModel = [CheckPostModel objectWithKeyValues:resultData];
            if (resultData[@"allowperm"][@"allowupload"]) {
                NSString *jpgString = nil;
                NSString *jpegString = nil;
                if (![checkModel.allowperm.allowupload[@"jpg"] isKindOfClass:[NSString class]]) {
                    NSNumber *jpgNum = checkModel.allowperm.allowupload[@"jpg"];
                    jpgString = jpgNum.stringValue;
                }else{
                    jpgString = checkModel.allowperm.allowupload[@"jpg"];
                }
                if (![checkModel.allowperm.allowupload[@"jpeg"] isKindOfClass:[NSString class]]) {
                    NSNumber *jepgNum = checkModel.allowperm.allowupload[@"jpeg"];
                    jpegString = jepgNum.stringValue;
                }else{
                    jpegString = checkModel.allowperm.allowupload[@"jpeg"];
                }
                if ([jpgString isEqualToString:@"0"] && [jpegString isEqualToString:@"0"]) {
                    //如果不支持这2种格式的话 默认为不支持上传图片
                    isImageType = NO;
                }else{
                    [[NSUserDefaults standardUserDefaults]setObject:jpgString forKey:KimageJpg];
                    [[NSUserDefaults standardUserDefaults]setObject:jpegString forKey:Kimagejpeg];
                }
                
            }
            
            [[NSUserDefaults standardUserDefaults]setBool:isImageType forKey:KimageType];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSNotificationCenter defaultCenter]removeObserver:self name:KCheckPost object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:KCheckPost object:checkModel];
        }
    }];
}
#pragma mark - 创建URL
-(NSString*) createUrl:(NSDictionary*)param url:(NSString *)url{
    for (NSString *key in param.allKeys) {
        if (![[param objectForKey:key] isEqualToString:@""]) {
            url = [url stringByAppendingFormat:@"&%@=%@",key,[[param objectForKey:key] URLEncodingUTF8String]];
        }
    }
    return url;
}

/*
 * 根据uid获取用户的相关资料信息
 */
- (void)request_UserInfo_ByUserId:(NSString *)uid WithResultBlock:(void (^)(id data, NSError *error,NSString *message))block
{
    NSDictionary *paraDic = @{
                              @"version": ClanVersion,
                              @"module": @"profile",
                              };
    if (uid && uid.length>0) {
        paraDic = @{
                    @"version": ClanVersion,
                    @"module": @"profile",
                    @"uid": avoidNullStr(uid)
                    };
    }
    [[ClanNetAPI sharedJsonClient]requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error,nil);
        }
        else {
            if (data) {
                block(data, nil,nil);
            }
            else {
                //密码错误
                block(nil,nil,@"密码错误,请重试");
            }
        }
    }];
}

/**
 * 上传头像
 */

- (void)upload_avatar:(UIImage *)image WithResultBlock:(void (^)(id data, NSError *error,NSString *message))block
{
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=uploadavatar&ac=avatar",_kurl_base_path,ClanVersion];
    DLog(@"上传头像： -- %@",path);
    [[ClanNetAPI sharedJsonClient] uploadImage:image path:path name:@"Filedata" withParams:nil successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"上传头像成功  %@",operation);
        block(responseObject, nil, @"");
        
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"上传头像失败  %@",operation);
        block(nil, error, @"上传失败");
        
    } progerssBlock:^(CGFloat progressValue) {
        
    }];
}

/**
 * 我的主贴
 *
 */
- (void)request_PostsForPage:(NSNumber *)page
                  withUserId:(NSString *)uid
             WithResultBlock:(void (^)(id data, NSError *error))block
{
    //    iyzmobile=1&version=4&module=mythread2&type=thread&uid=8
    NSDictionary *paraDic = @{
                              @"iyzmobile":@"1",
                              @"version": ClanVersion,
                              @"module": @"mythread2",
                              @"type": @"thread",
                              @"page": page,
                              @"uid" : avoidNullStr(uid)
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
        
    }];
}

/**
 * 我的回复
 *
 */
- (void)request_ReplysForPage:(NSNumber *)page
                   withUserId:(NSString *)uid
              WithResultBlock:(void (^)(id data, NSError *error))block
{
    //   iyzmobile=1&version=4&module=mythread2&type=reply&uid=8
    NSDictionary *paraDic = @{
                              @"iyzmobile":@"1",
                              @"version": ClanVersion,
                              @"module": @"mythread2",
                              @"type": @"reply",
                              @"page": page,
                              @"uid" : avoidNullStr(uid)
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
        
    }];
}

/**
 * 消息列表
 *
 */
- (void)request_DialogListWithResultBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"version": ClanVersion,
                              @"module": @"mypm"
                              };
    
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            id resultData = [data valueForKeyPath:@"Variables"];
            block(resultData, nil);
        }
    }];
    
}


/**
 * 删除列表
 */
- (void)delete_DialogListWithDeleteID:(NSString *)deletepm_deluid andResultBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"deletepm_deluid": avoidNullStr(deletepm_deluid),
                              @"formhash" : avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                              @"deletesubmit":@"true",
                              @"deletepmsubmit_btn":@"true",
                              };
    NSString *path = [NSString stringWithFormat:@"%@?iyzmobile=1&module=deletepl",_kurl_base_path];
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path withParams:paraDic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
    }];
}

/**
 * 会话
 *
 */
- (void)request_SessionListAtPage:(NSNumber *)page
                     withDialogID:(NSString *)did
                  WithResultBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"version": avoidNullStr(ClanVersion),
                              @"module": @"mypm",
                              @"subop": @"view",
                              @"touid": avoidNullStr(did),
                              };
    if (page != nil) {
        paraDic = @{
                    @"version": avoidNullStr(ClanVersion),
                    @"module": @"mypm",
                    @"subop": @"view",
                    @"touid": avoidNullStr(did),
                    @"page":avoidNullStr(page)
                    };
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
    }];
    
}

/**
 * 发送消息
 */
- (void)post_Mess:(NSString *)message toUser:(NSString *)touid WithResultBlock:(void (^)(id data, NSError *error))block
{
    NSString *formhash = [[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash];
    NSString *mess = [message  aliasedString];
    
    NSDictionary *paraDic = @{
                              @"pmsubmit" : @"true",
                              @"message" : avoidNullStr(mess),
                              @"pmsubmit_btn" : @"true",
                              };
    if (formhash && formhash.length > 0) {
        paraDic = @{
                    @"pmsubmit" : @"true",
                    @"message" : avoidNullStr(mess),
                    @"pmsubmit_btn" : @"true",
                    @"formhash" : formhash,
                    };
        
    }
    DLog(@"--消息-- %@",paraDic);
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=4&module=sendpm&touid=%@",_kurl_base_path,touid] withParams:paraDic withMethodType:Post andBlock:^(id data, NSError *error)
     {
         if (!error) {
             block(data,nil);
         }else{
             block(nil,error);
         }
     }];
    
}

/**
 * 删除消息
 */

- (void)delete_Mess:(NSString *)touid withDeletepm_pmid:(NSString *)deletepm_pmid  WithResultBlock:(void (^)(id data, NSError *error))block
{
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?iyzmobile=1&module=deletepm&deletepm_pmid=%@&touid=%@&formhash=%@",_kurl_base_path,avoidNullStr(deletepm_pmid),avoidNullStr(touid),[[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error)
     {
         if (!error) {
             block(data,nil);
         }else{
             block(nil,error);
         }
     }];
    
}


/**
 * 我的收藏
 * @param fid 版块id
 */
- (void)request_favBoardWithFid:(NSString *)fid WithResultBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"version": ClanVersion,
                              @"module": @"favforum",
                              @"handlekey": @"favoriteforum",
                              @"formhash": avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                              @"infloat":@"yes",
                              @"handlekey":@"a_favorite",
                              @"inajax":@"1",
                              @"ajaxtarget":@"fwin_content_a_favorite",
                              @"id":avoidNullStr(fid)
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
        
    }];
    
}

/**
 * 轮询新消息
 */
- (void)checkNewMessageComeWithResultBlock:(void (^)(id data, NSError *error))block
{
    UserModel *model = [UserModel currentUserInfo];
    if (!model || !model.logined) {
        return;
    }
    NSDictionary *dic = @{
                          @"version" : avoidNullStr(ClanVersion),
                          @"module" : @"checknewpm",
                          @"iyzmobile" : @"1"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
    }];
}

/**
 * 赞主题
 */
- (void)request_support_AThread:(NSString *)tid withResultBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"iyzmobile": @"1",
                              @"version": ClanVersion,
                              @"module": @"threadrecommend2",
                              @"do": @"add",
                              @"tid":avoidNullStr(tid),
                              @"hash": avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                              @"inajax": @"1",
                              @"ajaxtarget": @"recommend_add_menu_content"
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
    }];
}


/**
 * 赞回帖
 */
- (void)request_support_APost:(NSString *)tid withPid:(NSString *)pid withResultBlock:(void (^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"iyzmobile": @"1",
                              @"version": ClanVersion,
                              @"module": @"postsupport",
                              @"do": @"support",
                              @"tid":avoidNullStr(tid),
                              @"pid":avoidNullStr(pid),
                              @"hash": avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        }
        else {
            block(data, nil);
        }
    }];
}



//搜索
- (void)requestSearchWithType:(NSString *)type andKeyWord:(NSString *)keyWord andPage:(NSString *)page andBlock:(void(^)(id data, NSError *error))block{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:ClanVersion forKey:@"version"];
    [dic setObject:@"1" forKey:@"iyzmobile"];
    if (isNull(keyWord)) {
        return;
    }
    [dic setObject:avoidNullStr(keyWord) forKey:@"keyword"];
    if ([type isEqualToString:KSearchPost]) {
        [dic setObject:avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash])forKey:@"formhash"];
        [dic setObject:@"search" forKey:@"module"];
        [dic setObject:page forKey:@"page"];
        [dic setObject:@"10" forKey:@"tpp"];
    }else if ([type isEqualToString:KSearchForum]){
        [dic setObject:@"searchforum" forKey:@"module"];
    }else if ([type isEqualToString:KSearchUser]){
        [dic setObject:@"searchuser" forKey:@"module"];
        [dic setObject:avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash])forKey:@"formhash"];
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

#pragma mark - 好友管理
//我的好友列表
- (void)requests_FriednsListWithUid:(NSString *)uid withReturnBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"version" : ClanVersion,
                              @"module" : @"friend",
                              };
    if (uid && uid.length > 0) {
        paraDic = @{
                    @"version" : ClanVersion,
                    @"module" : @"friend",
                    @"uid" : uid
                    };
    }
    
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//新的好友申请列表
- (void)requests_NewFriendWithOnlyCount:(BOOL)onlyCount withReturnBlock:(void(^)(id data, NSError *error))block
{
    NSString *only_count = onlyCount ? @"1" : @"0";
    NSDictionary *paraDic = @{
                              @"iyzmobile" : @"1",
                              @"module" : @"newfriend",
                              @"version" : ClanVersion,
                              @"only_count": only_count
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//推荐好友 可能认识的人
- (void)requests_FindFriednWithReturnBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"iyzmobile" : @"1",
                              @"module" : @"findfriend",
                              @"version" : ClanVersion,
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}

//添加好友 检查好友的前置检查
- (void)request_checkUserIsFriend:(NSString *)uid withtype:(NSString *)optype WithReturnBlock:(void(^)(id data, NSError *error))block
{
    //    optype: 检查操作类型(1:加好友, 2:同意好友请求, 3:拒绝好友请求)
    NSDictionary *paraDic = @{
                              @"iyzmobile" : @"1",
                              @"module" : @"addfriend",
                              @"version" : ClanVersion,
                              @"check" : @"1",
                              @"uid" : avoidNullStr(uid),
                              @"optype": avoidNullStr(optype)
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:paraDic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}


//审核好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree withBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *paraDic = @{
                              @"gid" : @"1",
                              @"uid" : avoidNullStr(uid),
                              @"audit" : agree ? @"0" : @"1",
                              @"formhash":[[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash],
                              };
    NSString *url = [NSString stringWithFormat:@"%@?iyzmobile=1&module=auditfriend&version=%@&check=1",_kurl_base_path,ClanVersion];
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:url withParams:paraDic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data, nil);
        }
    }];
}




//申请加好友
- (void)requestAddFriendWithUid:(NSString *)uid andMessage:(NSString *)message andBlock:(void(^)(id data, NSError *error))block{
    NSDictionary *dic = @{@"uid":uid,@"note":message,@"formhash":avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash])};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&iyzmobile=%@&module=%@",_kurl_base_path,ClanVersion,@"1",@"addfriend"] withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}
//删除好友
- (void)requestDelegateFriendWithUid:(NSString *)uid andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{@"uid":uid,@"formhash":avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash])};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&iyzmobile=%@&module=%@",_kurl_base_path,ClanVersion,@"1",@"removefriend"] withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}

//请求版块儿的UI样式
- (void)request_AppInfoWithBlock:(void(^)(id data, NSError *error))block
{
    //    /discuz/api/mobile/iyz_index.php?=&=1
    NSDictionary *dic = @{
                          @"module" : @"plugcfg",
                          @"iyzmobile" : @"1",
                          @"iyzversion": kiyzversion
                          };
    
    [[ClanNetAPI sharedJsonClient] requestCustomStyleWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}

//举报
- (void)request_reporeWithTid:(NSString *)tid andFid:(NSString *)fid andReport_select:(NSString *)report_select andMessage:(NSString *)message andHandlekey:(NSString *)handlekey andUid:(NSString *)uid  andBlock:(void(^)(id data, NSError *error))block{
    NSDictionary *dic = @{
                          @"report_select":report_select,
                          @"formhash":avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                          @"message":message,
                          @"referer":@":forum.php",
                          @"reportsubmit":@"true",
                          @"rid":tid,
                          @"fid":fid,
                          @"handlekey":handlekey,
                          @"rtype":@"thread"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&iyzmobile=%@&module=%@&inajax=%@&uid=%@&tid=%@",_kurl_base_path,ClanVersion,@"1",@"report",@"1",uid,tid] withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}

//第三方登录绑定
- (void)request_ThirdPartLogin_WithOpenId:(NSString *)openid token:(NSString *)token withLoginType:(LoginType)logintype  username:(NSString *)username pwd:(NSString *)pwd questionid:(NSString *)questionid answer:(NSString *)answer andBlock:(void(^)(id data,NSError *error))block
{
    NSString *loginT = nil;
    switch (logintype) {
        case LoginTypeQQ:
            loginT = @"qq";
            break;
        case LoginTypeWechat:
            loginT = @"wechat";
            break;
        case LoginTypeWeibo:
            loginT = @"weibo";
            break;
        default:
            break;
    }
    NSString *path = [NSString stringWithFormat:@"%@?iyzmobile=1&version=%@&module=platform_login&mod=login&platform=%@",_kurl_base_path,ClanVersion,avoidNullStr(loginT)];
    NSDictionary *dic = @{
                          @"openid":avoidNullStr(openid),
                          @"token":avoidNullStr(token),
                          @"username":avoidNullStr(username),
                          @"password":avoidNullStr(pwd),
                          @"questionid":avoidNullStr(questionid),
                          @"answer":avoidNullStr(answer)
                          };
    WEAKSELF
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path withParams:dic withMethodType:Post andBlock:^(id data, NSError *error)
     {
         if (error) {
             block(nil,error);
         } else {
             NSNumber *error_code = [data valueForKeyPath:@"error_code"];
             NSString *error_msg = [data valueForKeyPath:@"error_msg"];
             if (error_code && error_code.intValue == 0) {
                 [ClanNetAPI saveCookieData];
                 [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"kLASTUSERNAME"];
                 UserModel *user = [UserModel currentUserInfo];
                 [user setValueWithObject:[UserModel objectWithKeyValues:data[@"data"]]];
                 //设置登录成功
                 user.logined = YES;
                 [UserModel saveToLocal];
             }
             else if (error_msg && error_msg.length > 0) {
                 STRONGSELF
                 [strongSelf showHudTipStr:error_msg];
             }
             block(data, nil);
         }
     }];
}

//检查第三方账户的绑定状态
- (void)checkBindStatusWithOpenID:(NSString *)openid andToken:(NSString *)token andLogintype:(LoginType)type andBlock:(void(^)(id data,NSError *error))block
{
    NSString *logintype = nil;
    switch (type) {
        case LoginTypeQQ:
            logintype = @"qq";
            break;
        case LoginTypeWechat:
            logintype = @"wechat";
            break;
        case LoginTypeWeibo:
            logintype = @"weibo";
            break;
        default:
            break;
    }
    
    NSDictionary *dic = @{
                          @"iyzmobile" : @"1",
                          @"version" : ClanVersion,
                          @"module" : @"platform_login",
                          @"mod": @"check",
                          @"platform": avoidNullStr(logintype),
                          @"openid" : avoidNullStr(openid),
                          @"token": avoidNullStr(token)
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}


//第三方登录 注册并绑定
- (void)request_ThirdPartRegister_WithOpenId:(NSString *)openid token:(NSString *)token withLoginType:(LoginType)logintype username:(NSString *)username pwd:(NSString *)pwd email:(NSString *)email andBlock:(void(^)(id data,NSError *error))block
{
    NSString *loginT = nil;
    switch (logintype) {
        case LoginTypeQQ:
            loginT = @"qq";
            break;
        case LoginTypeWechat:
            loginT = @"wechat";
            break;
        case LoginTypeWeibo:
            loginT = @"weibo";
            break;
        default:
            break;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?iyzmobile=1&version=%@&module=platform_login&mod=register&platform=%@",_kurl_base_path,ClanVersion,avoidNullStr(loginT)];
    NSDictionary *dic = @{
                          @"openid":avoidNullStr(openid),
                          @"token":avoidNullStr(token),
                          @"username":avoidNullStr(username),
                          @"password":avoidNullStr(pwd),
                          @"email":avoidNullStr(email)
                          };
    WEAKSELF
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:urlStr withParams:dic withMethodType:Post andBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:@"出错了"];
            block(nil,error);
        } else {
            NSNumber *error_code = [data valueForKeyPath:@"error_code"];
            NSString *error_msg = [data valueForKeyPath:@"error_msg"];
            if (error_code && error_code.intValue == 0) {
                //注册成功 登录
                [ClanNetAPI saveCookieData];
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"kLASTUSERNAME"];
                
                UserModel *user = [UserModel currentUserInfo];
                [user setValueWithObject:[UserModel objectWithKeyValues:data]];
                //设置登录成功
                user.logined = YES;
                [UserModel saveToLocal];
            }
            else if (error_msg && error_msg.length > 0) {
                
                [strongSelf showHudTipStr:error_msg];
            }
            block(data, nil);
        }
    }];
}

//签到
- (void)checkInWithUid:(NSString *)uid docheckInAction:(BOOL)docheck withBlock:(void(^)(id data, NSError *error))block
{
    NSString *check = docheck ? @"0" : @"1";
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"module" : @"checkin",
                          @"iyzmobile" : @"1",
                          @"check" : check
                          };
    if (uid && uid.length > 0) {
        dic = @{
                @"version" : ClanVersion,
                @"module" : @"checkin",
                @"iyzmobile" : @"1",
                @"uid" : uid,
                @"check" : check
                };
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

//首页发帖前置检查
- (void)request_checkSendPostWithFid:(NSString *)fid withBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *checkPostDic = @{
                                   @"module":@"checkpost",
                                   @"fid":avoidNullStr(fid),
                                   @"version":ClanVersion
                                   };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:checkPostDic withMethodType:Get andBlock:^(id data, NSError *error) {
        NSDictionary *resultData = [data valueForKeyPath:@"Variables"];
        BOOL isImageType = YES;
        CheckPostModel *checkModel = [CheckPostModel objectWithKeyValues:resultData];
        if (resultData[@"allowperm"][@"allowupload"]) {
            NSString *jpgString = nil;
            NSString *jpegString = nil;
            if (![checkModel.allowperm.allowupload[@"jpg"] isKindOfClass:[NSString class]]) {
                NSNumber *jpgNum = checkModel.allowperm.allowupload[@"jpg"];
                jpgString = jpgNum.stringValue;
            }else{
                jpgString = checkModel.allowperm.allowupload[@"jpg"];
            }
            if (![checkModel.allowperm.allowupload[@"jpeg"] isKindOfClass:[NSString class]]) {
                NSNumber *jepgNum = checkModel.allowperm.allowupload[@"jpeg"];
                jpegString = jepgNum.stringValue;
            }else{
                jpegString = checkModel.allowperm.allowupload[@"jpeg"];
            }
            if ([jpgString isEqualToString:@"0"] && [jpegString isEqualToString:@"0"]) {
                //如果不支持这2种格式的话 默认为不支持上传图片
                isImageType = NO;
            }else{
                [[NSUserDefaults standardUserDefaults]setObject:jpgString forKey:KimageJpg];
                [[NSUserDefaults standardUserDefaults]setObject:jpegString forKey:Kimagejpeg];
            }
            
        }
        [[NSUserDefaults standardUserDefaults]setBool:isImageType forKey:KimageType];
        [[NSUserDefaults standardUserDefaults]synchronize];
        block(data, error);
    }];
}

//拉取分类信息
- (void)request_classifysWithFid:(NSString *)fid withBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *para = @{
                           @"iyzmobile" : @"1",
                           @"module" : @"thrdtype",
                           @"version" : ClanVersion,
                           @"fid" : fid
                           };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:para withMethodType:Get andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}
//获取表情包设置项
- (void)request_downloadFaceJsonWithType:(NSString *)type andBlock:(void(^)(id data,NSError *error))block{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:ClanVersion forKey:@"version"];
    [dic setObject:@"smilies" forKey:@"module"];
    [dic setObject:@"1" forKey:@"iyzmobile"];
    if (type) {
        [dic setObject:@"1" forKey:@"type"];
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}
//获取表情包
- (void)request_downloadFaceWithPath:(NSString *)path andBlock:(void(^)(NSURL *filePath, NSString *fileName, NSError *error))block{
    [[ClanNetAPI sharedJsonClient] requestDownloadWithPath:path andBlock:^(NSURL *filePath, NSString *fileName, NSError *error) {
        if (error) {
            block(nil,nil,error);
        }else{
            block(filePath,fileName,nil);
        }
    }];
}

/**
 *  新版 首页启动数据
 */
- (void)request_customHomeWithListType:(NSString *)type andBlock:(void (^)(id data, NSError *error))block{
    NSDictionary *dic = @{
                          @"iyzversion":kiyzversion,
                          @"version":ClanVersion,
                          @"iyzmobile":@"1",
                          @"module":@"indexthread",
                          @"view":type
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (!error) {
            block(data,nil);
        }else{
            block(nil,error);
        }
    }];
}

- (void)request_customHomeWithNewList:(NSString *)url page:(NSString *)page andBlock:(void(^)(id data, NSError *error))block{
    NSDictionary *dic = @{@"page":page};
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:url withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (!error) {
            block(data,nil);
        }else{
            block(nil,error);
        }
    }];
}


//文章列表
- (void)request_articleType:(NSString *)type page:(NSString *)page andBlcok:(void(^)(id data,NSError *error))block{
    NSDictionary *dic = @{
                          @"module":@"myportal",
                          @"iyzversion":kiyzversion,
                          @"iyzmobile":@"1",
                          @"catid":avoidNullStr(type),
                          @"mod":@"list",
                          @"version":ClanVersion,
                          @"page":avoidNullStr(page)
                          };
    [[ClanNetAPI sharedJsonClient]requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
}
//文章详情
- (void)request_articleDetailWithId:(NSString *)aid andBlock:(void(^)(id data,NSError *error))block{
    NSDictionary *dic = @{
                          @"module":@"myportal",
                          @"iyzversion":kiyzversion,
                          @"iyzmobile":@"1",
                          @"aid":avoidNullStr(aid),
                          @"mod":@"view",
                          @"version":ClanVersion
                          };
    [[ClanNetAPI sharedJsonClient]requestJsonDataWithPath:_kurl_base_path withParams:dic withMethodType:Get andBlock:^(id data, NSError *error) {
        if (error) {
            block(nil,error);
        }else{
            block(data,nil);
        }
    }];
    
}

//拉取文章收藏
- (void)request_articleFavoAtPage:(NSNumber *)page WithBlock:(void(^)(id data,NSError *error))block
{
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"iyzversion" : kiyzversion,
                          @"iyzmobile" : @"1",
                          @"module" : @"myfavarticle",
                          @"type" : @"article",
                          @"page" : page
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}



//取消收藏文章
- (void)request_cancleFavoAnArticleWithFovid:(NSString *)favoid WithBlock:(void(^)(id data,NSError *error))block
{
    NSArray *arr = [favoid componentsSeparatedByString:@"_"];
    if (arr.count == 0) {
        [self showHudTipStr:@"取消收藏失败，请重试"];
        return;
    }
    NSDictionary *dic = @{
                          @"iyzmobile" : @"1",
                          @"version" : ClanVersion,
                          @"module" : @"delfav",
                          @"formhash":[[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash],
                          @"delfavorite" : @"true",
                          @"favorite" : arr ? arr : [NSArray new]
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//请求首页配置
- (void)request_HomeConfig:(void(^)(id data, NSError *error))block{
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"iyzversion" : kiyzversion,
                          @"iyzmobile" : @"1",
                          @"module" : @"indexcfg",
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//投票
- (void)request_doVote:(NSString *)tid
               withfid:(NSString *)fid
       withPollanswers:(id)pollanswers
             WithBlock:(void(^)(id data,NSError *error))block
{
    NSDictionary *dic = @{
                          @"formhash":[[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash],
                          @"tid" : tid,
                          @"pollanswers" : pollanswers
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@?version=%@&fid=%@&module=pollvote&pollsubmit=yes&quickforward=yes&inajax=1",_kurl_base_path,ClanVersion,fid]
                                                withParams:dic withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
    
}


#pragma mark - 帖子评分

//评分监测接口
- (void)request_ratingInfoForPostTid:(NSString *)tid withPid:(NSString *)pid andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"iyzmobile" : @"1",
                          @"iyzversion" : kiyzversion,
                          @"module" : @"rate",
                          @"tid" : tid,
                          @"pid" : pid
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//查看全部评分
- (void)request_viewRatingsForPost:(NSString *)tid
                           withPid:(NSString *)pid
                          andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"iyzmobile" : @"1",
                          @"iyzversion" : kiyzversion,
                          @"module": @"viewratings",
                          @"tid" : tid,
                          @"pid" : pid
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

//提交评分接口
- (void)request_RatingsPostWithtid:(NSString *)tid
                           withPid:(NSString *)pid
                   withRateResults:(NSDictionary *)paradic
                        withReason:(NSString *)reason
                          andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"formhash" : [[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash],
                          @"tid" : tid,
                          @"pid" : pid,
                          @"reason":avoidNullStr(reason),
                          };
    NSMutableDictionary *paras = [[NSMutableDictionary alloc]initWithDictionary:dic];
    [paras addEntriesFromDictionary:paradic];
    NSString *path = [NSString stringWithFormat:@"%@?iyzmobile=1&iyzversion=%@&module=ratepost",_kurl_base_path,kiyzversion];
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:paras
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

#pragma mark - 活动帖
//参加活动
- (void)request_JoinActivityWithParas:(id)paras withFid:(NSString *)fid withTid:(NSString *)tid withPid:(NSString *)pid andBlock:(void(^)(id data, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=activityclient&iyzmobile=1&fid=%@&tid=%@&pid=%@",_kurl_base_path,ClanVersion,fid,tid,pid];
    NSDictionary *dic = @{
                          @"formhash" : [[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash],
                          @"handlekey" : @"activityapplies",
                          @"payment" : @"-1",
                          @"activitysubmit" : @"true",
                          };
    NSMutableDictionary *dicM = [[NSMutableDictionary alloc]initWithDictionary:dic];
    if (paras && [paras isKindOfClass:[NSDictionary class]]) {
        [dicM addEntriesFromDictionary:paras];
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path withParams:dicM withMethodType:Post andBlock:^(id data, NSError *error) {
        DLog(@"-----%@",data);
        block(data, error);
    }];
}

//上传活动附件图片
- (void)request_uploadAcitvityFileImage:(SendImage *)sendImage withFid:(NSString *)fid withHash:(NSString *)hash andBlock:(void(^)(id data, bool success))block
{
    NSDictionary *dic = @{
                          @"uid":avoidNullStr([UserModel currentUserInfo].uid),
                          @"filetype":avoidNullStr(sendImage.fileType),
                          @"hash":avoidNullStr(hash),
                          @"Filename":avoidNullStr(sendImage.fileName),
                          };
    [[ClanNetAPI sharedJsonClient] uploadImage:sendImage.image path:[NSString stringWithFormat:@"%@?version=%@&fid=%@&module=forumupload&iyzmobile=1",_kurl_base_path,ClanVersion,avoidNullStr(fid)] name:@"Filedata" withParams:dic successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (([responseObject valueForKey:@"Variables"])) {
            NSDictionary *datasDic = [responseObject valueForKey:@"Variables"];
            if (datasDic[@"ret"]) {
                NSDictionary *retDic = datasDic[@"ret"];
                if (retDic) {
                    block(retDic, YES);
                    return;

                }
            }
        }
        block(@"附件图片上传失败了，请重试", NO);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.responseString integerValue]> 0) {
            //图片上传成功 标记图片枚举
            block(operation.responseString, YES);
            return;
        }
        block(@"附件图片上传失败了，请重试", NO);
    }progerssBlock:^(CGFloat progressValue) {
        
    }];
}

//取消参加活动
- (void)request_cancleJoinAcitivityWithReason:(NSString *)reason
                                      withTid:(NSString *)tid
                                      withPid:(NSString *)pid
                                      withfid:(NSString *)fid
                                     andBlock:(void(^)(id data, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=activityclient&iyzmobile=1&fid=%@&tid=%@&pid=%@",_kurl_base_path,ClanVersion,fid,tid,pid];
    NSDictionary *dic = @{
                          @"formhash" : [[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash],
                          @"message" : avoidNullStr(reason),
                          @"activitycancel" : @"true",
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:dic
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                      
                                                  }];
}

//查看活动申请者列表
- (void)request_activityApplyListWithTid:(NSString *)tid
                                 withPid:(NSString *)pid
                                 withfid:(NSString *)fid
                                andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"module" : @"activityapplylist",
                          @"iyzmobile" : @"1",
                          @"fid" : avoidNullStr(fid),
                          @"tid" : avoidNullStr(tid),
                          @"pid" : avoidNullStr(pid),
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//通过活动申请
- (void)request_agreeActivityApplyForapplyids:(NSArray *)applyIds
                                      withTid:(NSString *)tid
                                   withReason:(NSString *)reason
                                     andBlock:(void(^)(id data, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=activityapplylist&iyzmobile=1&tid=%@&applylistsubmit=yes",_kurl_base_path,ClanVersion,tid];
    NSDictionary *dic = @{
                          @"formhash" : avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                          @"handlekey" : @"activity",
                          @"applyidarray" : applyIds ? applyIds : [NSArray new],
                          @"reason" : avoidNullStr(reason),
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:dic
                                            withMethodType:Post andBlock:^(id data, NSError *error) {
                                                block(data, error);
                                            }];
}

//拒绝活动申请
- (void)request_refuseActivityApplyForapplyids:(NSArray *)applyIds
                                      withTid:(NSString *)tid
                                   withReason:(NSString *)reason
                                     andBlock:(void(^)(id data, NSError *error))block
{

    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=activityapplylist&iyzmobile=1&tid=%@&applylistsubmit=yes",_kurl_base_path,ClanVersion,tid];
    NSDictionary *dic = @{
                          @"formhash" : avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                          @"handlekey" : @"activity",
                          @"applyidarray" : applyIds ? applyIds : [NSArray new],
                          @"operation"  : @"delete",
                          @"reason" : avoidNullStr(reason),
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:dic
                                            withMethodType:Post andBlock:^(id data, NSError *error) {
                                                block(data, error);
                                            }];
}

//要求完善资料
- (void)request_replenishActivityApplyForapplyids:(NSArray *)applyIds
                                       withTid:(NSString *)tid
                                    withReason:(NSString *)reason
                                      andBlock:(void(^)(id data, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=activityapplylist&iyzmobile=1&tid=%@&applylistsubmit=yes",_kurl_base_path,ClanVersion,tid];
    NSDictionary *dic = @{
                          @"formhash" : avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                          @"handlekey" : @"activity",
                          @"applyidarray" : applyIds ? applyIds : [NSArray new],
                          @"operation"  : @"replenish",
                          @"reason" : avoidNullStr(reason),
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:dic
                                            withMethodType:Post andBlock:^(id data, NSError *error) {
                                                block(data, error);
                                            }];
}

#pragma mark - 帖子点评 对某个帖子进行点评
//帖子点评前置检查
- (void)request_checkCommentPostWithtid:(NSString *)tid
                                withPid:(NSString *)pid
                               andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"module" : @"comment",
                          @"tid" : avoidNullStr(tid),
                          @"pid" :avoidNullStr(pid),
                          @"iyzversion" : kiyzversion,
                          @"iyzmobile" : @"1",
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
    
}

//添加帖子点评
- (void)request_addPostCommentWithTid:(NSString *)tid
                              withPid:(NSString *)pid
                            withParas:(id)paras
                             andBlock:(void(^)(id data, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"%@?version=%@&module=commentpost&tid=%@&iyzversion=%@&iyzmobile=1&pid=%@",_kurl_base_path,ClanVersion,tid,kiyzversion,pid];
    NSMutableDictionary *paraDic = [NSMutableDictionary new];
    [paraDic setObject:avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]) forKey:@"formhash"];
    if (paras && [paras isKindOfClass:[NSDictionary class]]) {
        [paraDic addEntriesFromDictionary:paras];
    }
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:paraDic
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//帖子点评相关数据
- (void)request_getPostCommentInfoWithTid:(NSString *)tid
                                  withPid:(NSString *)pid
                                 andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"module" : @"commentmore",
                          @"tid" : avoidNullStr(tid),
                          @"pid" : avoidNullStr(pid),
                          @"iyzversion" : kiyzversion,
                          @"iyzmobile" : @"1",
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//点评结果
- (void)request_viewCommentsAtPage:(NSInteger)page
                           withTid:(NSString *)tid
                              withPid:(NSString *)pid
                            withParas:(id)paras
                             andBlock:(void(^)(id data, NSError *error))block
{
    NSDictionary *dic = @{
                          @"version" : ClanVersion,
                          @"module" : @"commentmore",
                          @"tid" : tid,
                          @"pid" : pid,
                          @"page" : @(page),
                          @"iyzmobile" : @"1",
                          @"iyzversion" : kiyzversion,
                          };
    
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

#pragma mark - 删除主题
//删除帖子
- (void)request_deletePostWithTid:(NSString *)tid
                          withFid:(NSString *)fid
                       withReason:(NSString *)reason
                         andBlock:(void(^)(id data, NSError *error))block
{
    NSString *path = [NSString stringWithFormat:@"%@?iyzmobile=1&iyzversion=%@&module=removethread",_kurl_base_path,kiyzversion];
    NSDictionary *paraDic = @{
                              @"tid" : avoidNullStr(tid),
                              @"fid" : avoidNullStr(fid),
                              @"reason" : avoidNullStr(reason),
                              @"formhash" : [[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]
                              };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:paraDic
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

#pragma mark - 购买主题-拉取购买信息
//拉取购买信息
- (void)request_threadpayInfoWithTid:(NSString *)tid
                             withPid:(NSString *)pid
                            andBlock:(void(^)(id data, NSError *error))block {
    
    NSDictionary *dic = @{
                          @"module" : @"threadpay",
                          @"iyzmobile" : @"1",
//                          @"tid" : @"960",
//                          @"pid" : @"2180",
                          @"tid" : avoidNullStr(tid),
                          @"pid" : avoidNullStr(pid),
                          @"handlekey" : @"pay",
                          @"ajaxtarget" : @"fwin_content_pay"
                          };
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:_kurl_base_path
                                                withParams:dic
                                            withMethodType:Get
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

//购买主题
- (void)request_payThreadWithTid:(NSString *)tid
                        andBlock:(void(^)(id data, NSError *error))block {
    NSDictionary *paraDic = @{
                              @"formhash" : avoidNullStr([[NSUserDefaults standardUserDefaults]stringForKey:ClanFormhash]),
                              @"referer" : @"forum.php",
                              @"tid" : avoidNullStr(tid),
//                              @"tid" : @"960",
                              @"handlekey" : @"pay",
                              @"paysubmit" : @"true"
                              };
    NSString *path = [NSString stringWithFormat:@"%@?module=threadpay&iyzmobile=1",_kurl_base_path];
    [[ClanNetAPI sharedJsonClient] requestJsonDataWithPath:path
                                                withParams:paraDic
                                            withMethodType:Post
                                                  andBlock:^(id data, NSError *error) {
                                                      block(data, error);
                                                  }];
}

@end
