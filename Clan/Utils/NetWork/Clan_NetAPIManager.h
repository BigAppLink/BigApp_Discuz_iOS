//
//  Clan_NetAPIManager.h
//  Clan
//
//  Created by chivas on 15/3/11.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClanNetAPI.h"
@class UserModel;
@class PostSendModel;
@class CollectionModel;
@class SendImage;
@class ForumsModel;
@class SendActivity;
@interface Clan_NetAPIManager : NSObject

@property (nonatomic, copy) NSString *kurl_base_path;
@property (copy, nonatomic) void(^postListBlock)(id sender,NSError *error);


+ (instancetype)sharedManager;
/**
 *  获取自定义首页数据
 *
 *  @param void 自定义首页
 *
 *  @return funcModel bannerModel
 */
- (void)request_customHomeWithBlock:(void(^)(id data, NSError *error))block;

/**
 *  验证码
 *
 */
- (void)request_captchaBlack:(void(^)(NSString *session))block;
/**
 *  登录问题
 *
 *  @param block
 */
- (void)request_getLoginAskWithBlock:(void(^)(id data,NSError *error))block;
/**
 *  用户登陆
 *  需调用2次才能登陆
 *  @param Fid 版块登录时才会用到 用于取check信息
 *  @param block
 */
- (void)request_Login_WithUserName:(NSString *)username andPassWord:(NSString *)password andFid:(NSString *)fid andQuestionid:(NSString *)questionid andAnswer:(NSString *)answer andBlock:(void (^)(UserModel *data, NSError *error,NSString *message))block;

/**
 *  用户注册
 *
 */
- (void)request_Register_WithUserName:(NSString *)username andPassWord:(NSString *)password andPassWord2:(NSString *)password2 andEmail:(NSString *)email andFid:(NSString *)fid andBlock:(void (^)(id data))block;

/**
 *  我的帖子收藏
 *
 *  @param void 帖子收藏
 *
 *  @return 帖子收藏数组
 */
- (void)request_MyPostCollection_atPage:(NSNumber *)page andBlock:(void(^)(id data, NSError *error))block;

/**
 *  我的板块收藏
 *
 *  @param void 板块收藏
 *
 *  @return 板块收藏数组
 */
- (void)request_MyPlateCollection_atPage:(NSNumber *)page andBlock:(void(^)(id data, NSError *error))block;

/**
 *  删除收藏
 *  删除帖子或者板块
 *  @param favid
 */
- (void)request_DeleteMyCollectionWithFavId:(NSString *)favid andType:(NSString *)type andBlock:(void(^)(id data,NSError *error))block;

/**
 *  收藏帖子
 *  @param fid 帖子ID
 */
- (void)favo_a_post_byid:(NSString *)fid andBlock:(void(^)(id data,NSError *error))block;

/**
 *  热帖
 *
 *  @param void 首页热帖
 *
 *  @return 帖子数组
 */
- (void)request_HotPostBlock:(void(^)(id data, NSError *error))block;

/**
 *  版块
 *
 *  @param void 首页版块
 *
 *  @return 版块数组
 */
- (void)request_BoardBlock:(void(^)(id data, NSError *error))block;

/**
 *  帖子列表
 *
 *  @param
 *  @param
 *  @return
 */
- (void)request_PostListWithFilter:(NSString *)filter
                        andOrderby:(NSString *)orderby
                         andDigest:(NSString *)digest
                           andPage:(NSString *)page
                            andFid:(NSString *)fid
                          andBlock:(void(^)(id data, NSError *error))block;
/**
 *  帖子列表 - 取list数据
 */
- (void)request_postListWithTopListData:(id)topData andFilter:(NSString *)filter
                             andOrderby:(NSString *)orderby
                              andDigest:(NSString *)digest
                                andPage:(NSString *)page
                                 andFid:(NSString *)fid;
/**
 *  帖子分类列表
 *
 *  @param
 *  @param
 *  @return
 */
- (void)request_classifiedPostsWithFid:(NSString *)fid andTypeId:(NSString *)type_id andPage:(int)page andBlock:(void(^)(id data, NSError *error))block;

/**
 *  帖子详情
 *
 *  @param tid 帖子ID
 *  @return
 */
- (void)request_postDetailWithTid:(NSString *)tid withAuthorID:(NSString *)authorID atPage:(int)page andBlock:(void(^)(id data, NSError *error))block;

/**
 *  发帖前置检查
 *
 *  @param fid 版块id
 *  @return
 */
- (void)check_post_withfid:(NSString *)fid andBlock:(void(^)(id data, NSError *error))block;

/**
 *  发帖,有图片
 *
 *  @param isUpdate 是否成功
 *  @param imageCount 返回提交成功的图片
 *  @return
 */
- (void)uploadSendImage:(PostSendModel *)sendModel
               andBlock:(void (^)(BOOL isUpdate,AFHTTPRequestOperation *operation,NSInteger imageCount,NSString *errorMessage))block
          progerssBlock:(void (^)(CGFloat progressValue))progress;
/**
 *  发帖,无图片
 *
 *  @param
 *  @return
 */
- (void)uploadSendPost:(PostSendModel *)sendModel andBlock:(void (^)(id data, NSError *error))block;

/**
 * 根据uid获取用户的相关资料信息
 *
 * @param uid 用户ID
 */
- (void)request_UserInfo_ByUserId:(NSString *)uid
                  WithResultBlock:(void (^)(id data, NSError *error,NSString *message))block;


/**
 * 上传头像
 */

- (void)upload_avatar:(UIImage *)image WithResultBlock:(void (^)(id data, NSError *error,NSString *message))block;

/**
 * 我的主贴
 *
 */
- (void)request_PostsForPage:(NSNumber *)page
                  withUserId:(NSString *)uid
             WithResultBlock:(void (^)(id data, NSError *error))block;


/**
 * 我的回复
 *
 */
- (void)request_ReplysForPage:(NSNumber *)page
                   withUserId:(NSString *)uid
              WithResultBlock:(void (^)(id data, NSError *error))block;


/**
 * 消息列表
 *
 */
- (void)request_DialogListWithResultBlock:(void (^)(id data, NSError *error))block;

/**
 * 删除列表
 */
- (void)delete_DialogListWithDeleteID:(NSString *)deletepm_deluid andResultBlock:(void (^)(id data, NSError *error))block;

/**
 * 会话
 *
 */
- (void)request_SessionListAtPage:(NSNumber *)page
                     withDialogID:(NSString *)did
                  WithResultBlock:(void (^)(id data, NSError *error))block;

/**
 * 发送消息
 */
- (void)post_Mess:(NSString *)message
           toUser:(NSString *)touid
  WithResultBlock:(void (^)(id data, NSError *error))block;


/**
 * 删除消息
 */

- (void)delete_Mess:(NSString *)touid withDeletepm_pmid:(NSString *)deletepm_pmid  WithResultBlock:(void (^)(id data, NSError *error))block;

/**
 * 我的收藏
 * @param fid 版块id
 */
- (void)request_favBoardWithFid:(NSString *)fid WithResultBlock:(void (^)(id data, NSError *error))block;


/**
 * 轮询新消息
 */
- (void)checkNewMessageComeWithResultBlock:(void (^)(id data, NSError *error))block;

/**
 *  搜索
 */
- (void)requestSearchWithType:(NSString *)type andKeyWord:(NSString *)keyWord andPage:(NSString *)page andBlock:(void(^)(id data, NSError *error))block;

/**
 * 赞主题
 */
- (void)request_support_AThread:(NSString *)tid withResultBlock:(void (^)(id data, NSError *error))block;

/**
 * 赞回帖
 */
- (void)request_support_APost:(NSString *)tid withPid:(NSString *)pid withResultBlock:(void (^)(id data, NSError *error))block;

#pragma mark - 好友管理
//我的好友列表
- (void)requests_FriednsListWithUid:(NSString *)uid withReturnBlock:(void(^)(id data, NSError *error))block;

/**
 *  申请加好友
 */
- (void)requestAddFriendWithUid:(NSString *)uid andMessage:(NSString *)message andBlock:(void(^)(id data, NSError *error))block;
/**
 *  删除好友
 */
- (void)requestDelegateFriendWithUid:(NSString *)uid andBlock:(void(^)(id data, NSError *error))block;

//新的好友申请列表
- (void)requests_NewFriendWithOnlyCount:(BOOL)onlyCount withReturnBlock:(void(^)(id data, NSError *error))block;

//推荐好友 可能认识的人
- (void)requests_FindFriednWithReturnBlock:(void(^)(id data, NSError *error))block;

//审核好友申请
- (void)request_dealFriendApply:(NSString *)uid agree:(BOOL)agree withBlock:(void(^)(id data, NSError *error))block;

//添加好友 检查好友的前置检查
- (void)request_checkUserIsFriend:(NSString *)uid withtype:(NSString *)optype WithReturnBlock:(void(^)(id data, NSError *error))block;

//请求版块儿的UI样式
- (void)request_AppInfoWithBlock:(void(^)(id data, NSError *error))block;

//举报
- (void)request_reporeWithTid:(NSString *)tid andFid:(NSString *)fid andReport_select:(NSString *)report_select andMessage:(NSString *)message andHandlekey:(NSString *)handlekey andUid:(NSString *)uid  andBlock:(void(^)(id data, NSError *error))block;

//第三方账号绑定登录
- (void)request_ThirdPartLogin_WithOpenId:(NSString *)openid token:(NSString *)token withLoginType:(LoginType)logintype  username:(NSString *)username pwd:(NSString *)pwd questionid:(NSString *)questionid answer:(NSString *)answer andBlock:(void(^)(id data,NSError *error))block;

//检查第三方账户的绑定状态
- (void)checkBindStatusWithOpenID:(NSString *)openid andToken:(NSString *)token andLogintype:(LoginType)type andBlock:(void(^)(id data,NSError *error))block;

//绑定并登录
- (void)request_ThirdPartRegister_WithOpenId:(NSString *)openid token:(NSString *)token withLoginType:(LoginType)logintype username:(NSString *)username pwd:(NSString *)pwd email:(NSString *)email andBlock:(void(^)(id data,NSError *error))block;

//签到
- (void)checkInWithUid:(NSString *)uid docheckInAction:(BOOL)docheck withBlock:(void(^)(id data, NSError *error))block;

//首页发帖前置检查
- (void)request_checkSendPostWithFid:(NSString *)fid
                           withBlock:(void(^)(id data, NSError *error))block;

//拉取分类信息
- (void)request_classifysWithFid:(NSString *)fid
                       withBlock:(void(^)(id data, NSError *error))block;
//获取表情包映射关系
- (void)request_downloadFaceJsonWithType:(NSString *)type
                                andBlock:(void(^)(id data,NSError *error))block;
//获取表情包
- (void)request_downloadFaceWithPath:(NSString *)path
                            andBlock:(void(^)(NSURL *filePath, NSString *fileName, NSError *error))block;
/**
 *  新版 首页启动数据
 */
- (void)request_customHomeWithListType:(NSString *)type
                              andBlock:(void (^)(id data, NSError *error))block;
//组件化新增接口
- (void)request_customHomeWithNewList:(NSString *)url
                                 page:(NSString *)page
                             andBlock:(void(^)(id data, NSError *error))block;


//文章列表
- (void)request_articleType:(NSString *)type
                       page:(NSString *)page
                   andBlcok:(void(^)(id data,NSError *error))block;

//文章详情
- (void)request_articleDetailWithId:(NSString *)aid
                           andBlock:(void(^)(id data,NSError *error))block;

//拉取文章收藏
- (void)request_articleFavoAtPage:(NSNumber *)page
                        WithBlock:(void(^)(id data,NSError *error))block;

//收藏文章
- (void)request_doFavoAnArticleWithId:(NSString *)aid
                            WithBlock:(void(^)(id data,NSError *error))block;

//取消收藏文章
- (void)request_cancleFavoAnArticleWithFovid:(NSString *)favoid
                                   WithBlock:(void(^)(id data,NSError *error))block;

//首页配置数据
- (void)request_HomeConfig:(void(^)(id data, NSError *error))block;

//投票
- (void)request_doVote:(NSString *)tid
               withfid:(NSString *)fid
       withPollanswers:(id)pollanswers
             WithBlock:(void(^)(id data,NSError *error))block;

//跳页
- (void)request_postDetailWithTid:(NSString *)tid
                  withJumpPostion:(NSString *)position
                         andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - 评分
//评分监测接口
- (void)request_ratingInfoForPostTid:(NSString *)tid
                          withPid:(NSString *)pid
                         andBlock:(void(^)(id data, NSError *error))block;

//查看全部评分
- (void)request_viewRatingsForPost:(NSString *)tid
                           withPid:(NSString *)pid
                          andBlock:(void(^)(id data, NSError *error))block;

//提交评分接口
- (void)request_RatingsPostWithtid:(NSString *)tid
                           withPid:(NSString *)pid
                   withRateResults:(NSDictionary *)paradic
                        withReason:(NSString *)reason
                          andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - 活动
//参加活动，有时候需要上传图片附件
- (void)request_uploadAcitvityFileImage:(SendImage *)sendImage
                                withFid:(NSString *)fid
                               withHash:(NSString *)hash
                               andBlock:(void(^)(id data, bool success))block;

//参加活动
- (void)request_JoinActivityWithParas:(id)paras
                              withFid:(NSString *)fid
                              withTid:(NSString *)tid
                              withPid:(NSString *)pid
                             andBlock:(void(^)(id data, NSError *error))block;

//取消参加活动
- (void)request_cancleJoinAcitivityWithReason:(NSString *)reason
                                      withTid:(NSString *)tid
                                      withPid:(NSString *)pid
                                      withfid:(NSString *)fid
                                     andBlock:(void(^)(id data, NSError *error))block;

//查看活动申请者列表
- (void)request_activityApplyListWithTid:(NSString *)tid
                                 withPid:(NSString *)pid
                                 withfid:(NSString *)fid
                                andBlock:(void(^)(id data, NSError *error))block;
//通过活动申请
- (void)request_agreeActivityApplyForapplyids:(NSArray *)applyIds
                                      withTid:(NSString *)tid
                                   withReason:(NSString *)reason
                                     andBlock:(void(^)(id data, NSError *error))block;

//拒绝活动申请
- (void)request_refuseActivityApplyForapplyids:(NSArray *)applyIds
                                       withTid:(NSString *)tid
                                    withReason:(NSString *)reason
                                      andBlock:(void(^)(id data, NSError *error))block;

//要求完善资料
- (void)request_replenishActivityApplyForapplyids:(NSArray *)applyIds
                                          withTid:(NSString *)tid
                                       withReason:(NSString *)reason
                                         andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - 帖子点评 对某个帖子进行点评
//帖子点评前置检查
- (void)request_checkCommentPostWithtid:(NSString *)tid
                                withPid:(NSString *)pid
                               andBlock:(void(^)(id data, NSError *error))block;

//添加帖子点评
- (void)request_addPostCommentWithTid:(NSString *)tid
                              withPid:(NSString *)pid
                            withParas:(id)paras
                             andBlock:(void(^)(id data, NSError *error))block;


//帖子点评相关数据
- (void)request_getPostCommentInfoWithTid:(NSString *)tid
                                  withPid:(NSString *)pid
                                 andBlock:(void(^)(id data, NSError *error))block;

//点评结果
- (void)request_viewCommentsAtPage:(NSInteger)page
                           withTid:(NSString *)tid
                           withPid:(NSString *)pid
                         withParas:(id)paras
                          andBlock:(void(^)(id data, NSError *error))block;
/**
 *  发表活动帖子
 */
- (void)upload_ActivityPost:(SendActivity *)activityModel
                   andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - 删除主题
//删除帖子
- (void)request_deletePostWithTid:(NSString *)tid
                          withFid:(NSString *)fid
                       withReason:(NSString *)reason
                         andBlock:(void(^)(id data, NSError *error))block;

#pragma mark - 购买主题-拉取购买信息
//拉取购买信息
- (void)request_threadpayInfoWithTid:(NSString *)tid
                             withPid:(NSString *)pid
                            andBlock:(void(^)(id data, NSError *error))block;

//购买主题
- (void)request_payThreadWithTid:(NSString *)tid
                        andBlock:(void(^)(id data, NSError *error))block;

@end
