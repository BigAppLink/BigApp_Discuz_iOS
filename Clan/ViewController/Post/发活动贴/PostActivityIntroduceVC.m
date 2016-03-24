//
//  PostActivityIntroduceVC.m
//  Clan
//
//  Created by chivas on 15/10/28.
//  Copyright (c) 2015年 Youzu. All rights reserved.
//

#import "PostActivityIntroduceVC.h"
#import "UIPlaceHolderTextView.h"
#import "QBImagePickerController.h"
#import "YZHelper.h"
#import "PostActivityInfoCell.h"
#import "PostActivityImageCell.h"
#import "PostSendModel.h"
#import "PostActivityModel.h"
@interface PostActivityIntroduceVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,QBImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) BOOL isCoverPhoto;
@property (strong, nonatomic) SendImage *coverImage;
@property (strong, nonatomic) PostSendModel *sendModel;
@property (strong, nonatomic) SendActivity *sendActivityModel;

@end

@implementation PostActivityIntroduceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_sendActivityModel) {
        _sendActivityModel = [SendActivity new];
    }
    if (!_sendModel) {
        _sendModel = [PostSendModel PostForSend];
    }
    _sendActivityModel.sendModel = _sendModel;

    //创建TableView
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

#pragma mark - 创建tableview
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.bounds.size.height - 80 - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 0;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"infoCell"];

        [_tableView registerClass:[PostActivityInfoCell class] forCellReuseIdentifier:@"PostActivityInfoCell"];
        [_tableView registerClass:[PostActivityImageCell class] forCellReuseIdentifier:@"PostActivityImageCell"];

//        _tempCell = [_tableView dequeueReusableCellWithIdentifier:@"PostActivitySelectCell"];
        
    }
    return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        PostActivityInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostActivityInfoCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.coverImage = _coverImage.image;
        WEAKSELF
        cell.addPicturesBlock = ^(){
            weakSelf.isCoverPhoto = YES;
            [weakSelf showPhotoSheet];
        };
        cell.deleteCoverImageBlock = ^(){
            weakSelf.coverImage = nil;
            weakSelf.sendActivityModel.activityImage = _coverImage;
            if (weakSelf.returnPostActivityModel) {
                weakSelf.returnPostActivityModel(weakSelf.sendActivityModel);
            }

            [weakSelf.tableView reloadData];
        };
        cell.messageValueChangedBlock = ^(NSString *messageStr){
            weakSelf.sendModel.message = messageStr;
            if (weakSelf.returnPostActivityModel) {
                weakSelf.returnPostActivityModel(weakSelf.sendActivityModel);
            }

        };
        return cell;

    }else{
        PostActivityImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostActivityImageCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WEAKSELF
        cell.addPicturesBlock = ^(){
            weakSelf.isCoverPhoto = NO;
            [weakSelf showPhotoSheet];
        };
        cell.deleteTweetImageBlock = ^(SendImage *toDelete){
            NSMutableArray *sendImages = [weakSelf.sendModel mutableArrayValueForKey:@"imageArray"];
            [sendImages removeObject:toDelete];
            [weakSelf.tableView reloadData];
        };

        cell.sendModel = _sendModel;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 220;
    }else{
        return 110;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}


#pragma mark - 显示相册
- (void)showPhotoSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    [actionSheet showInView:kKeyWindow];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        拍照
        if (![YZHelper checkCameraAuthorizationStatus]) {
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    }else if (buttonIndex == 1){
        //        相册
        if (![YZHelper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = _isCoverPhoto ? 1 : 9-_sendModel.imageArray.count;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self sendImageWithImagePicker:originalImage assetItem:nil];
    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(originalImage, self,selectorToCall, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_tableView reloadData];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    for (ALAsset *assetItem in assets) {
        ALAssetRepresentation *assetRep = [assetItem defaultRepresentation];
        UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:assetItem];
        [self sendImageWithImagePicker:highQualityImage assetItem:assetRep];
    }
    [_tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 封装图片
- (void)sendImageWithImagePicker:(UIImage *)image assetItem:(ALAssetRepresentation *)assetRep{
    SendImage *sendImg = [SendImage sendImageWithImage:[image scaledToSize:Screen_Bounds.size highQuality:NO]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddHH";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    sendImg.fileName = assetRep ?assetRep.filename: [NSString stringWithFormat:@"%@%@",str,[UserModel currentUserInfo].uid];
    sendImg.size = assetRep ? assetRep.size / 1024: 24;
    sendImg.fileType = assetRep ? [assetRep.filename componentsSeparatedByString:@"."][1] : @"jpg";
    if (_isCoverPhoto) {
        _coverImage = sendImg;
        _sendActivityModel.activityImage = _coverImage;
    }else{
        NSMutableArray *sendImages = [_sendModel mutableArrayValueForKey:@"imageArray"];
        [sendImages addObject:sendImg];
        _sendActivityModel.sendModel = _sendModel;
    }
    if (self.returnPostActivityModel) {
        self.returnPostActivityModel(_sendActivityModel);
    }
}

- (void)dealloc{
    NSLog(@"活动已销毁");
    _tableView.delegate = nil;
    _tableView.dataSource = nil;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
