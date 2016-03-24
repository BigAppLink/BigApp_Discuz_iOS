//
//  SesstionViewModel.h
//  Clan
//
//  Created by 昔米 on 15/4/13.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"

@interface ChatViewModel : ViewModelClass
{
    int _currentPage;
    
}
@property (strong, nonatomic) NSMutableArray *dataArray;


/**
 * 会话信息
 */
- (void)requestSessionListAtPage:(int)page withDialogId:(NSString *)did WithReturnBlock:(void(^)(bool success, id data, bool needmore, int totalpage))block;

/**
 * 所有会话信息
 */
- (void)requestSessionListwithDialogId:(NSString *)did WithReturnBlock:(void(^)(bool success, id data))block;

//删除会话信息
- (void)deleteChatWithDialogId:(NSString *)did andDeleteChatID:(NSString *)deletepm_pmid WithReturnBlock:(void(^)(bool success, id data))block;

/**
 * 发送信息
 */
- (void)sendMess:(NSString *)mess toUser:(NSString *)touid withReturnBlock: (void(^)(bool success, id data))block;

@end
