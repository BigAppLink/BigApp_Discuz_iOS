//
//  UUInputFunctionView.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUInputFunctionView.h"
//#import "Mp3Recorder.h"
#import "UUProgressHUD.h"

#define X(v)                    (v).frame.origin.x
#define Y(v)                    (v).frame.origin.y
#define HEIGHT(v)               (v).frame.size.height
#define RECT_CHANGE_width(v,w)      CGRectMake(X(v), Y(v), w, HEIGHT(v))

@interface UUInputFunctionView ()<UITextViewDelegate>
{
    BOOL isbeginVoiceRecord;
//    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    UILabel *placeHold;
}
@end

@implementation UUInputFunctionView

- (id)initWithSuperVC:(UIViewController *)superVC
{
    self.superVC = superVC;
    CGRect frame = CGRectMake(0, kSCREEN_HEIGHT-50-64, kSCREEN_WIDTH, 50);
    
    self = [super initWithFrame:frame];
    if (self) {
//        MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
        self.backgroundColor = [UIColor whiteColor];
        //发送消息
        self.btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSendMessage.frame = CGRectMake(kSCREEN_WIDTH-60, 0, 60, 51);
//        self.btnSendMessage.frame = CGRectMake(10, 10, 30, 30);
//        self.isAbleToSendTextMessage = NO;
        self.isAbleToSendTextMessage = YES;
        [self.btnSendMessage setTitle:@"" forState:UIControlStateNormal];
        self.btnSendMessage.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.btnSendMessage addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnSendMessage];
        [self changeSendBtnWithPhoto:NO];
        BOOL isDownFaceImage = [UserDefaultsHelper boolValueForDefaultsKey:kUserDefaultsKey_ClanZipIsDown];
        //发送图片
        self.btnSendPicture = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSendPicture.frame = CGRectMake(10, 10, 30, 30);
//        [self.btnSendPicture setBackgroundImage:[UIImage imageNamed:@"Chat_take_picture"] forState:UIControlStateNormal];
        self.btnSendPicture.titleLabel.font = [UIFont systemFontOfSize:12];
//        [self.btnSendPicture addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        if (isDownFaceImage) {
            [self addSubview:self.btnSendPicture];
        }
        
//        //改变状态（语音、文字）
//        self.btnChangeVoiceState = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.btnChangeVoiceState.frame = CGRectMake(5, 5, 30, 30);
//        isbeginVoiceRecord = NO;
//        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
//        self.btnChangeVoiceState.titleLabel.font = [UIFont systemFontOfSize:12];
//        [self.btnChangeVoiceState addTarget:self action:@selector(voiceRecord:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.btnChangeVoiceState];

        //语音录入键
//        self.btnVoiceRecord = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.btnVoiceRecord.frame = CGRectMake(70, 5, Main_Screen_Width-70*2, 30);
//        self.btnVoiceRecord.hidden = YES;
//        [self.btnVoiceRecord setBackgroundImage:[UIImage imageNamed:@"chat_message_back"] forState:UIControlStateNormal];
//        [self.btnVoiceRecord setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [self.btnVoiceRecord setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        [self.btnVoiceRecord setTitle:@"Hold to Talk" forState:UIControlStateNormal];
//        [self.btnVoiceRecord setTitle:@"Release to Send" forState:UIControlStateHighlighted];
//        [self.btnVoiceRecord addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
//        [self.btnVoiceRecord addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
//        [self.btnVoiceRecord addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
//        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
//        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
//        [self addSubview:self.btnVoiceRecord];
        NSInteger downBtnWidth = isDownFaceImage ? 50 : 0;
        
        UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(isDownFaceImage ?downBtnWidth:5, 5, kSCREEN_WIDTH-downBtnWidth-60, 50-10)];
        bgview.layer.cornerRadius = 6;
        bgview.layer.masksToBounds = YES;
        bgview.layer.borderWidth = 0.5;
        bgview.layer.borderColor = [[kUIColorFromRGB(0xc3c3c3) colorWithAlphaComponent:0.4] CGColor];

//        bgview.layer.borderColor = [[kUIColorFromRGB(0xd4d4d4) colorWithAlphaComponent:0.4] CGColor];
        [self addSubview:bgview];
        //输入框
        self.TextViewInput = [[UITextView alloc]initWithFrame:CGRectMake(downBtnWidth+5, 10, kSCREEN_WIDTH-downBtnWidth-60-10, 50-20)];
        self.TextViewInput.delegate = self;
        self.TextViewInput.font = [UIFont fontWithSize:15.f];
        self.TextViewInput.backgroundColor = kCLEARCOLOR;
        [self addSubview:self.TextViewInput];
        
        //输入框的提示语
        placeHold = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, kVIEW_H(_TextViewInput))];
        placeHold.text = @"说点什么吧~";
        placeHold.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
        [self.TextViewInput addSubview:placeHold];
        
        //分割线
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:1] colorWithAlphaComponent:1.0].CGColor;
        
        //添加通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidEndEditing:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

#pragma mark - 录音touch事件
//- (void)beginRecordVoice:(UIButton *)button
//{
//    [MP3 startRecord];
//    playTime = 0;
//    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
//    [UUProgressHUD show];
//}
//
//- (void)endRecordVoice:(UIButton *)button
//{
//    if (playTimer) {
//        [MP3 stopRecord];
//        [playTimer invalidate];
//        playTimer = nil;
//    }
//}
//
//- (void)cancelRecordVoice:(UIButton *)button
//{
//    if (playTimer) {
//        [MP3 cancelRecord];
//        [playTimer invalidate];
//        playTimer = nil;
//    }
//    [UUProgressHUD dismissWithError:@"Cancel"];
//}

//- (void)RemindDragExit:(UIButton *)button
//{
//    [UUProgressHUD changeSubTitle:@"Release to cancel"];
//}
//
//- (void)RemindDragEnter:(UIButton *)button
//{
//    [UUProgressHUD changeSubTitle:@"Slide up to cancel"];
//}
//
//
//- (void)countVoiceTime
//{
//    playTime ++;
//    if (playTime>=60) {
//        [self endRecordVoice:nil];
//    }
//}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    [self.delegate UUInputFunctionView:self sendVoice:voiceData time:playTime+1];
    [UUProgressHUD dismissWithSuccess:@"Success"];
   
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

- (void)failRecord
{
    [UUProgressHUD dismissWithSuccess:@"Too short"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

//改变输入与录音状态
- (void)voiceRecord:(UIButton *)sender
{
    self.btnVoiceRecord.hidden = !self.btnVoiceRecord.hidden;
    self.TextViewInput.hidden  = !self.TextViewInput.hidden;
    isbeginVoiceRecord = !isbeginVoiceRecord;
    if (isbeginVoiceRecord) {
        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_ipunt_message"] forState:UIControlStateNormal];
        [self.TextViewInput resignFirstResponder];
    }else{
        [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
        [self.TextViewInput becomeFirstResponder];
    }
}

//发送消息（文字图片）
- (void)sendMessage:(UIButton *)sender
{
    if (sender == _btnSendMessage) {
        NSString *resultStr = [self.TextViewInput.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
        [self.delegate UUInputFunctionView:self sendMessage:resultStr];
    }
    else{
        [self.TextViewInput resignFirstResponder];
        UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Images",nil];
        [actionSheet showInView:self.window];
    }
}

////发送消息（文字图片）
//- (void)sendMessage:(UIButton *)sender
//{
//    if (self.isAbleToSendTextMessage) {
//        NSString *resultStr = [self.TextViewInput.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
//        [self.delegate UUInputFunctionView:self sendMessage:resultStr];
//    }
//    else{
//        [self.TextViewInput resignFirstResponder];
//        UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Images",nil];
//        [actionSheet showInView:self.window];
//    }
//}


#pragma mark - TextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    placeHold.hidden = self.TextViewInput.text.length > 0;
}

- (void)textViewDidChange:(UITextView *)textView
{
//    [self changeSendBtnWithPhoto:textView.text.length>0?NO:YES];
    placeHold.hidden = textView.text.length>0;
//    DLog(@"❤️ ... %@",textView.text);
}

- (void)changeSendBtnWithPhoto:(BOOL)isPhoto
{
//    self.isAbleToSendTextMessage = !isPhoto;
    self.isAbleToSendTextMessage = YES;
    isPhoto = NO;
//    CGSize size = kIMG(@"keyboard_fasong").size;
    [self.btnSendMessage setImage:kIMG(@"keyboard_fasong") forState:UIControlStateNormal];
//    [self.btnSendMessage setTitle:isPhoto?@"":@"发送" forState:UIControlStateNormal];
//    self.btnSendMessage.frame = RECT_CHANGE_width(self.btnSendMessage, size.width+20);
//    UIImage *image = [UIImage imageNamed:isPhoto?@"Chat_take_picture":@"chat_send_message"];
//    [self.btnSendMessage setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    placeHold.hidden = self.TextViewInput.text.length > 0;
}


#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.superVC presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)openPicLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.superVC presentViewController:picker animated:YES completion:^{
        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.superVC dismissViewControllerAnimated:YES completion:^{
        [self.delegate UUInputFunctionView:self sendPicture:editImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.superVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
