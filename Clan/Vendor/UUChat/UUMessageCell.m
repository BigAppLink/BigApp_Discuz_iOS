//
//  UUMessageCell.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageCell.h"
#import "UUMessage.h"
#import "UUMessageFrame.h"
#import "UUAVAudioPlayer.h"
#import "UUImageAvatarBrowser.h"
#import "SJRichLabel.h"
#import "TOWebViewController.h"
#import "UIView+Additions.h"
@interface UUMessageCell ()<UUAVAudioPlayerDelegate,MLEmojiLabelDelegate>
{
    AVAudioPlayer *player;
    NSString *voiceURL;
    NSData *songData;
    
    UUAVAudioPlayer *audio;
    
    UIView *headImageBackView;
    BOOL contentVoiceIsPlaying;
}
@property (nonatomic, strong) SJRichLabel *richLabel;

@end

@implementation UUMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

        // 1、创建时间
        self.labelTime = [[UILabel alloc] init];
        self.labelTime.textAlignment = NSTextAlignmentCenter;
        self.labelTime.textColor = kUIColorFromRGB(0xadadad);
        self.labelTime.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
        self.labelTime.clipsToBounds = YES;
        self.labelTime.font = ChatTimeFont;
        [self.contentView addSubview:self.labelTime];
        
        // 2、创建头像
        headImageBackView = [[UIView alloc]init];
        headImageBackView.layer.cornerRadius = 20;
        headImageBackView.clipsToBounds = YES;
        headImageBackView.layer.masksToBounds = YES;
//        headImageBackView.layer.borderColor = [UIColor whiteColor].CGColor;
//        headImageBackView.layer.borderWidth = 1;
        headImageBackView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:headImageBackView];
        self.btnHeadImage = [YZButton buttonWithType:UIButtonTypeCustom];
        self.btnHeadImage.layer.cornerRadius = 20;
        self.btnHeadImage.layer.masksToBounds = YES;
//        [self.btnHeadImage addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [headImageBackView addSubview:self.btnHeadImage];
        
        // 3、创建头像下标
        self.labelNum = [[UILabel alloc] init];
        self.labelNum.textColor = [UIColor grayColor];
        self.labelNum.textAlignment = NSTextAlignmentCenter;
        self.labelNum.font = ChatTimeFont;
        [self.contentView addSubview:self.labelNum];
        
        // 4、创建内容
        self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        self.btnContent.exclusiveTouch = YES;
        self.btnContent.titleLabel.font = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;

        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
        //红外线感应监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        contentVoiceIsPlaying = NO;

    }
    return self;
}

//头像点击
- (void)btnHeadImageClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(headImageDidClick:userId:)])  {
        [self.delegate headImageDidClick:self userId:self.messageFrame.message.strId];
    }
}


- (void)btnContentClick{
    //play audio
    if (self.messageFrame.message.type == UUMessageTypeVoice) {
        if(!contentVoiceIsPlaying){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            contentVoiceIsPlaying = YES;
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
            //        [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
    }
    //show the picture
    else if (self.messageFrame.message.type == UUMessageTypePicture)
    {
        if (self.btnContent.backImageView) {
            [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
        }
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [[(UIViewController *)self.delegate view] endEditing:YES];
        }
    }
    // show text and gonna copy that
    else if (self.messageFrame.message.type == UUMessageTypeText)
    {
        [self.btnContent becomeFirstResponder];
        UIMenuItem *item1 = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(MenuItemCopyClicked)];
        UIMenuItem *item2 = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(MenuItemDeleteClicked)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = [NSArray arrayWithObjects:item1,item2, nil];
        [menu setTargetRect:self.btnContent.frame inView:self.btnContent.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)UUAVAudioPlayerBeiginLoadVoice
{
    [self.btnContent benginLoadVoice];
}
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self.btnContent didLoadVoice];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    contentVoiceIsPlaying = NO;
    [self.btnContent stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}


//内容及Frame设置
- (void)setMessageFrame:(UUMessageFrame *)messageFrame
{

    _messageFrame = messageFrame;
    UUMessage *message = messageFrame.message;
    
    // 1、设置时间
    self.labelTime.text = message.strTime;
    self.labelTime.frame = messageFrame.timeF;
    self.labelTime.layer.cornerRadius = kVIEW_H(_labelTime)/2;
    
    // 2、设置头像
    headImageBackView.frame = messageFrame.iconF;
    self.btnHeadImage.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
//    [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal
//                                          withURL:[NSURL URLWithString:message.strIcon]
//                                 placeholderImage:[UIImage imageNamed:@"list_avatar"]];
    [self.btnHeadImage sd_setBackgroundImageWithURL:[NSURL URLWithString:message.strIcon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"portrait"]];
    // 3、设置下标
    self.labelNum.hidden = YES;
    self.labelNum.text = message.strName;
    self.labelNum.textAlignment = NSTextAlignmentCenter;
    self.labelNum.backgroundColor = [UIColor clearColor];
    
    //    CGSize size = [Util sizeWithString:message.strName font:self.labelNum.font constraintSize:CGSizeMake(100, MAXFLOAT)];
//    if (messageFrame.nameF.origin.x > 160) {//        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, size.width, messageFrame.nameF.size.height);
////        self.labelNum.textAlignment = NSTextAlignmentRight;
//    }else{
//        
////        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x, messageFrame.nameF.origin.y + 3, 80, messageFrame.nameF.size.height);
////        self.labelNum.textAlignment = NSTextAlignmentLeft;
//    }

    // 4、设置内容
    
    //prepare for reuse
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;

    self.btnContent.frame = messageFrame.contentF;
    if (message.from == UUMessageFromMe) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
    }else{
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTitleColor:K_COLOR_DARK forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    }
    
    //背景气泡图
    UIImage *normal;
    if (message.from == UUMessageFromMe) {
        normal = [UIImage imageNamed:@"right_bubble"];
        CGSize size = normal.size;
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake((size.height-4)/2, (size.width-4)/2, (size.height-4)/2, (size.width-4)/2)];
    }
    else{
        normal = [UIImage imageNamed:@"left_bubble"];
        CGSize size = normal.size;
        //        (CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake((size.height-4)/2, (size.width-4)/2, (size.height-4)/2, (size.width-4)/2)];
    }
    [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
    [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];
#warning 测试
    switch (message.type) {
        case UUMessageTypeText:
            //chivas修改
            [self EmojiLabelText:message.strContent];
//            [self.btnContent setTitle:message.strContent forState:UIControlStateNormal];
            break;
        case UUMessageTypePicture:
        {
            self.btnContent.backImageView.hidden = NO;
            self.btnContent.backImageView.image = message.picture;
            self.btnContent.backImageView.frame = CGRectMake(0, 0, self.btnContent.frame.size.width, self.btnContent.frame.size.height);
            [self makeMaskView:self.btnContent.backImageView withImage:normal];
        }
            break;
        case UUMessageTypeVoice:
        {
            self.btnContent.voiceBackView.hidden = NO;
            self.btnContent.second.text = [NSString stringWithFormat:@"%@'s Voice",message.strVoiceTime];
            songData = message.voice;
//            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
        }
            break;
            
        default:
            break;
    }
    [self.contentView setNeedsUpdateConstraints];
}

- (void)EmojiLabelText:(NSString *)message
{
    [self.btnContent addSubview:self.richLabel];
    UIFont *richFont = [UIFont systemFontOfSize:16.0f];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{(.*?)\\/(.*?)\\}" options:0 error:nil];
    __block NSString *tempString = message;
    [regex enumerateMatchesInString:message options:0 range:NSMakeRange(0, [message length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *string = [message substringWithRange:result.range];
        tempString = [tempString stringByReplacingOccurrencesOfString:string withString:@"aa"];
        
    }];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"[/url]" withString:@""];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"[/url]" withString:@""];
    CGRect tmpRect = [tempString boundingRectWithSize:CGSizeMake(self.btnContent.width-20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:richFont,NSFontAttributeName, nil] context:nil];
    _richLabel.frame = CGRectMake(10, 0, tmpRect.size.width, tmpRect.size.height);
    _richLabel.top = self.btnContent.height/2 - _richLabel.height/2;
    _richLabel.left = self.btnContent.width/2 - _richLabel.width/2;
    [_richLabel addLinkText:message linkUrlArray:nil];
    
    
}
- (SJRichLabel *)richLabel
{
    if (!_richLabel) {
        _richLabel = [SJRichLabel new];
        _richLabel.numberOfLines = 0;
        _richLabel.delegate = self;
        _richLabel.backgroundColor = [UIColor clearColor];
        _richLabel.textAlignment = NSTextAlignmentLeft;
        _richLabel.textColor = K_COLOR_DARK;
    }
    return _richLabel;
}

- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image
{
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
    view.layer.mask = imageViewMask.layer;
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    TOWebViewController *webView = [[TOWebViewController alloc]init];
    webView.url = url;
    [self.additionsViewController.navigationController pushViewController:webView animated:YES];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [_labelNum mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headImageBackView.mas_centerX);
        make.top.equalTo(headImageBackView.mas_bottom).offset(3);
    }];
}

@end



