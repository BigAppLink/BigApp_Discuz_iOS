//
//  LoginViewModel.m
//  Clan
//
//  Created by chivas on 15/3/11.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "LoginViewModel.h"
#import "Clan_NetAPIManager.h"
@implementation LoginViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestLogin = 0;
    }
    return self;
}

- (NSString *)URLEncodingUTF8String
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)self,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

- (void)request_getLoginAskWithBlock:(void(^)(NSArray *askArray))block{
    [[Clan_NetAPIManager sharedManager]request_getLoginAskWithBlock:^(id data, NSError *error) {
        if (data){
            NSArray *array = data[@"data"];
            block(array);
        }
    }];
}

- (void)request_Login_WithUserName:(NSString *)username
                       andPassWord:(NSString *)password
                            andFid:(NSString * )fid
                     andQuestionid:(NSString *)questionid
                         andAnswer:(NSString *)answer
                withViewController:(UIViewController *)controller
{
    _questionid = questionid;
    _answer = answer;
    BOOL status = [self approveWithUserName:username andPassWord:password andFid:fid];
    if (status) {
        [self requestApi:fid];
    }
}

- (BOOL)approveWithUserName:(NSString *)username andPassWord:(NSString *)password andFid:(NSString *)fid{
    _username = username;
    _password = password;
    if (!username || !password || username.length == 0 || password.length == 0) {
        [self showHudTipStr:@"请输入账号密码"];
        return NO;
    }
    [self showHudWithTitleDefault:@"正在登录"];
    return YES;
}

- (void)request_Register_WithUserName:(NSString *)username
                          andPassWord:(NSString *)password
                         andPassword2:(NSString *)password2
                             andEmail:(NSString *)email
                               andFid:(NSString *)fid

{
    if (username.length == 0 || password.length == 0) {
        [self showHudTipStr:@"请输入账号密码"];
        return;
    }
    if (![password isEqualToString:password2]) {
        [self showHudTipStr:@"两次输入的密码不一致"];
        return;
    }
    if (![Util validateEmail:email]) {
        [self showHudTipStr:@"邮箱格式错误"];
        return;
    }
    [self showHudWithTitleDefault:@"正在提交"];
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_Register_WithUserName:username andPassWord:password andPassWord2:password2 andEmail:email andFid:fid andBlock:^(id data) {
        STRONGSELF
        [strongSelf hudHide];
        [strongSelf dissmissProgress];
        if ([data isKindOfClass:[NSError class]]) {
//            [self showHudTipStr:data[@"error_msg"]];
            return ;
        }
        if (data) {
            NSDictionary *dic = data[@"Message"];
            if ([dic[@"messageval"] isEqualToString:@"register_succeed"]) {
                //注册成功
                strongSelf.returnBlock(data);
//                if (strongSelf.returnBlock) {
//                }
            }else{
                [strongSelf showHudTipStr:dic[@"messagestr"]];
                return ;
            }
        }
    }];
}

- (void)requestApi:(NSString *)fid
{
    WEAKSELF
    [[Clan_NetAPIManager sharedManager]request_Login_WithUserName:_username andPassWord:_password andFid:fid andQuestionid:_questionid andAnswer:_answer andBlock:^(UserModel *data, NSError *error, NSString *message) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (message) {
            [strongSelf hudHide];
            [self showHudTipStr:message];
            return;
        }
        if (error) {
            strongSelf.requestLogin++;
            if (strongSelf.requestLogin == 5) {
                //请求4次登录接口
                [self hudHide];
                [self showHudTipStr:NetError];
                return;
            }
            //不成功重复请求
            [strongSelf requestApi:fid];
        }else{
            [self hudHide];
            self.returnBlock(data);
        }
    }];
}

//第三方账号绑定已有账户
- (void)request_ThirdPartLogin_WithOpenId:(NSString *)openid
                                    token:(NSString *)token
                            withLoginType:(LoginType)logintype
                                 username:(NSString *)username
                                      pwd:(NSString *)pwd
                               questionid:(NSString *)questionid
                                   answer:(NSString *)answer
                                 andBlock:(void(^)(id data,NSError *error))block
{
    BOOL status = [self approveWithUserName:username andPassWord:pwd andFid:nil];
    if (status) {
        WEAKSELF
        [[Clan_NetAPIManager sharedManager] request_ThirdPartLogin_WithOpenId:openid token:token withLoginType:logintype username:username pwd:pwd questionid:questionid answer:answer andBlock:^(id data, NSError *error) {
            STRONGSELF
            [strongSelf hudHide];
            block(data,error);
        }];
    }
   
}


//注册并绑定QQ账号
- (void)request_ThirdPartRegister_WithOpenId:(NSString *)openid
                                token:(NSString *)token
                        withLoginType:(LoginType)logintype
                             username:(NSString *)username
                                  pwd:(NSString *)pwd
                                 pwd1:(NSString *)pwd1
                                email:(NSString *)email
                             andBlock:(void(^)(id data,NSError *error))block
{
    if (username.length == 0 || pwd.length == 0) {
        [self showHudTipStr:@"请输入账号密码"];
        return;
    }
    if (![pwd isEqualToString:pwd1]) {
        [self showHudTipStr:@"两次输入的密码不一致"];
        return;
    }
    if (![Util validateEmail:email]) {
        [self showHudTipStr:@"邮箱格式错误"];
        return;
    }
    [self showHudWithTitleDefault:@"正在提交..."];
        WEAKSELF
    [[Clan_NetAPIManager sharedManager] request_ThirdPartRegister_WithOpenId:openid token:token withLoginType:logintype username:username pwd:pwd email:email andBlock:^(id data, NSError *error) {
        STRONGSELF
        [strongSelf hudHide];
        block(data,error);
    }];
}

//检查第三方登录开启的状态
- (void)request_AppInfoWithBlock:(void(^)(id data,NSError *error))block
{
    [[Clan_NetAPIManager sharedManager] request_AppInfoWithBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}
@end
