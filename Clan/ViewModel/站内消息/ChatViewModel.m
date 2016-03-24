//
//  SesstionViewModel.m
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ChatViewModel.h"
#import "NSString+Common.h"
#import "SessionModel.h"

@implementation ChatViewModel

- (void)dealloc
{
    DLog(@"ChatViewModel dealloc");
}


/**
 * 会话信息
 */
- (void)requestSessionListAtPage:(int)page withDialogId:(NSString *)did
                 WithReturnBlock:(void(^)(bool success, id data, bool needmore, int totalpage))block
{
    NSNumber *pagenum = (page == 0) ? nil : [NSNumber numberWithInt:page];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_SessionListAtPage:pagenum withDialogID:did WithResultBlock:^(id data, NSError *error) {
        STRONGSELF
        if (error) {
            [strongSelf showHudTipStr:NetError];
            block(NO, nil, NO, 0);
            return ;
        }
        else {
            NSMutableArray *resultArr = [NSMutableArray new];
            id resultData = [data valueForKeyPath:@"Variables"];
            if ((resultData && resultData[@"auth"] == [NSNull null]) || [resultData[@"auth"] isEqualToString:@""]) {
                UserModel *cUser = [UserModel currentUserInfo];
                if (cUser.logined) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCookie_expired object:nil];
                }
                block(NO, kCookie_expired, NO, 0);
                return;
            }
            NSString *currentLoginMemberID = [resultData valueForKey:@"member_uid"];
            NSString *cPage = [resultData valueForKey:@"page"];
            NSMutableDictionary *toBeSortDic = [NSMutableDictionary new];
            NSMutableArray *tempSortArr = [NSMutableArray new];
            for (NSDictionary *dic in [resultData valueForKey:@"list"]) {
                SessionModel *session = [SessionModel objectWithKeyValues:dic];
                session.current_member_ID = currentLoginMemberID;
                session.message = [session.message emojizedString];
                if (session && session.pmid && session.pmid.length > 0) {
                    [toBeSortDic setObject:session forKey:session.pmid];
                    [tempSortArr addObject:session.pmid];
                }
            }
            //开始对pmid进行排序
            NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
            NSWidthInsensitiveSearch|NSForcedOrderingSearch;
            NSComparator sort = ^(NSString *obj1, NSString *obj2){
                NSRange range = NSMakeRange(0,obj1.length);
                return [obj1 compare:obj2 options:comparisonOptions range:range];
            };
            NSArray *resultArray2 = [tempSortArr sortedArrayUsingComparator:sort];
            for (NSString *pmidkey in resultArray2) {
                [resultArr addObject:toBeSortDic[pmidkey]];
            }
//            need_more：1--还有剩余数据，可以发起下一次请求；0—没有剩余数据了
            int totalPageIntValue = !isNull(cPage) ? cPage.intValue : 0;
            BOOL needmore = totalPageIntValue > 1 ? YES : NO;
            block(YES, resultArr, needmore, totalPageIntValue);
        }
    }];
    
}

- (void)requestSessionListwithDialogId:(NSString *)did WithReturnBlock:(void(^)(bool success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_SessionListAtPage:[NSNumber numberWithInt:++_currentPage] withDialogID:did WithResultBlock:^(id data, NSError *error) {
        if (error) {
            STRONGSELF
            [strongSelf showHudTipStr:NetError];
            block(NO, nil);
            return ;
        }
        else {
            STRONGSELF
            if (!strongSelf.dataArray) {
                strongSelf.dataArray = [NSMutableArray new];
            }
            id resultData = [data valueForKeyPath:@"Variables"];
            if ((resultData && resultData[@"auth"] == [NSNull null]) || [resultData[@"auth"] isEqualToString:@""]) {
                UserModel *cUser = [UserModel currentUserInfo];
                if (cUser.logined) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCookie_expired object:nil];
                }
                block(NO, kCookie_expired);
                return;
            }
            NSString *currentLoginMemberID = [resultData valueForKey:@"member_uid"];
            NSString *need_more = [resultData valueForKey:@"need_more"];
            for (NSDictionary *dic in [resultData valueForKey:@"list"]) {
                SessionModel *session = [SessionModel objectWithKeyValues:dic];
                session.current_member_ID = currentLoginMemberID;
                session.message = [session.message emojizedString];
                if (!session.message) {
                    session.message = @"";
                }
                [strongSelf.dataArray addObject:session];
            }
            //            need_more：1--还有剩余数据，可以发起下一次请求；0—没有剩余数据了
            BOOL needmore = (need_more.intValue == 0) ? NO : YES;
            if (needmore) {
                [strongSelf requestSessionListwithDialogId:did WithReturnBlock:block];
            } else {
                block(YES, strongSelf.dataArray);
            }
        }
    }];
    
}


//发送消息
- (void)sendMess:(NSString *)mess toUser:(NSString *)touid withReturnBlock: (void(^)(bool success, id data))block
{
    [self showHudWithTitleDefault:@"发送中..."];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager] post_Mess:mess toUser:touid WithResultBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hudHide];
        NSString *flag = [data valueForKey:@"Message"][@"messageval"];
        NSString *mcontent = [data valueForKey:@"Message"][@"messagestr"];
        if ([@"do_success" isEqualToString:flag]) {
            NSDictionary *dicInfo = [data valueForKey:@"Variables"];
            //发送成功
            SessionModel *model = [[SessionModel alloc]init];
            NSString *avatar = dicInfo[@"member_avatar"];
            model.msgfromid_avatar = (avatar && avatar.length > 0) ? avatar : [UserModel currentUserInfo].avatar;
            model.authorid = dicInfo[@"member_uid"];
            model.current_member_ID = dicInfo[@"member_uid"];
            model.author = dicInfo[ @"member_username"];
            model.pmid = dicInfo[@"pmid"];
            model.touid = touid;
            //TODO 转时间
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
            model.dateline = timeSp;
            model.message = dicInfo[@"message"];
            block(YES, model);
        } else {
            [strongSelf showHudTipStr:mcontent];
            block(NO, mcontent);
        }
    }];
}

//删除会话信息
- (void)deleteChatWithDialogId:(NSString *)did andDeleteChatID:(NSString *)deletepm_pmid WithReturnBlock:(void(^)(bool success, id data))block
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]delete_Mess:did withDeletepm_pmid:deletepm_pmid WithResultBlock:^(id data, NSError *error) {
        if (error) {
            STRONGSELF
            [strongSelf showHudTipStr:@"网络出错，删除失败"];
            return ;
        }
        else {
            STRONGSELF
            [strongSelf showHudTipStr:@"删除消息成功"];
            block(YES, data);
        }
    }];
}


@end
