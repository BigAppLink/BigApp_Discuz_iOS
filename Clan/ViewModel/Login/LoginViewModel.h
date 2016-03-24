//
//  LoginViewModel.h
//  Clan
//
//  Created by chivas on 15/3/11.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "ViewModelClass.h"
@interface LoginViewModel : ViewModelClass
@property (nonatomic,assign)NSInteger requestLogin;
@property (copy, nonatomic) void (^nickLoginBlock)(BOOL,id data);

@property (nonatomic,readonly,copy)NSString *username;
@property (nonatomic,readonly,copy)NSString *password;
@property (nonatomic,readonly,copy)NSString *questionid;
@property (nonatomic,readonly,copy)NSString *answer;

//获取登录验证信息
- (void)request_getLoginAskWithBlock:(void(^)(NSArray *askArray))block;
- (void)request_Login_WithUserName:(NSString *)username
                       andPassWord:(NSString *)password
                            andFid:(NSString * )fid
                     andQuestionid:(NSString *)questionid
                         andAnswer:(NSString *)answer
                withViewController:(UIViewController *)controller;


- (void)request_Register_WithUserName:(NSString *)username
                          andPassWord:(NSString *)password
                         andPassword2:(NSString *)password2
                             andEmail:(NSString *)email
                               andFid:(NSString *)fid;


//QQ账号绑定已有账户
- (void)request_ThirdPartLogin_WithOpenId:(NSString *)openid
                                    token:(NSString *)token
                            withLoginType:(LoginType)logintype
                                 username:(NSString *)username
                                      pwd:(NSString *)pwd
                               questionid:(NSString *)questionid
                                   answer:(NSString *)answer
                                 andBlock:(void(^)(id data,NSError *error))block;

//- (void)request_QQLogin_WithOpenId:(NSString *)openid
//                             token:(NSString *)token
//                          username:(NSString *)username
//                               pwd:(NSString *)pwd
//                        questionid:(NSString *)questionid
//                            answer:(NSString *)answer
//                          andBlock:(void(^)(id data,NSError *error))block;

//注册并绑定QQ账号
- (void)request_ThirdPartRegister_WithOpenId:(NSString *)openid
                                       token:(NSString *)token
                               withLoginType:(LoginType)logintype
                                    username:(NSString *)username
                                         pwd:(NSString *)pwd
                                        pwd1:(NSString *)pwd1
                                       email:(NSString *)email
                                    andBlock:(void(^)(id data,NSError *error))block;


//检查第三方登录开启的状态
- (void)request_AppInfoWithBlock:(void(^)(id data,NSError *error))block;
@end
