//
//  GWUserAuthorizationManager.m
//  GWUserAuthorization
//
//  Created by gw on 2019/3/3.
//  Copyright © 2019 gw. All rights reserved.
//

#import "GWUserAuthorizationManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

static NSTimeInterval gw_authorzation_delayTime = 0.3;

@implementation GWUserAuthorizationManager
+ (void)checkAuthorization:(GWAuthorizationType)type firstRequestAccess:(void (^)(void))requestAccess completion:(void (^)(BOOL))completion {
    
    switch (type) {
        case GW_Camera: {
            
            [self checkCameraAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } completion:^(BOOL isPermission) {
                completion(isPermission);
            }];
        }
            break;
        case GW_PhotoLibrary: {
            
            [self checkPhotoLibraryAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } completion:^(BOOL isPermission) {
                completion(isPermission);
            }];
        }
            break;
        case GW_Microphone: {
            
            [self checkMicrophoneAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } completion:^(BOOL isPermission) {
                completion(isPermission);
            }];
        }
            break;
    }
    
}



+ (void)requestAuthorization:(GWAuthorizationType)type {
    switch (type) {
        case GW_Camera: {
            [self requestCameraAuthorization];
        }
            break;
        case GW_PhotoLibrary: {
            [self requestPhotoLibraryAuthorization];
        }
            break;
        case GW_Microphone: {
            [self requestMicrophoneArthorization];
        }
            break;
    }
}

+ (void)saveImageToPhotoLibrary:(UIImage *)image block:(void(^ __nullable)(void))block{
    __weak typeof (self) weakSelf = self;
    [self checkPhotoLibraryAuthorization:nil completion:^(BOOL isPermission) {
        if (!isPermission) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"相册" settingName:@"照片"];
            });
        }else{
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (block) {
                        block();
                    }
                });
            } error:nil];
        }
    }];
}

+ (void)checkCameraAuthorization:(void(^ __nullable)(void))firstRequestAccess completion:(void (^)(BOOL))completion {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            
            //第一次提示用户授权
            firstRequestAccess ? firstRequestAccess() : nil;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                completion ? completion(granted) : nil;
            }];
        }
            break;
            
        case AVAuthorizationStatusAuthorized: {
            completion ? completion(YES) : nil;
        }
            break;
            
        case AVAuthorizationStatusRestricted: {
            completion ? completion(NO) : nil;
        }
            break;
            
        case AVAuthorizationStatusDenied: {
            completion ? completion(NO) : nil;
        }
            break;
    }
}


+ (void)requestCameraAuthorization {
    
    __weak typeof (self) weakSelf = self;
    [self checkCameraAuthorization:nil completion:^(BOOL isPermission) {
        if (!isPermission) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"相机" settingName:@"相机"];
            });
            
        }
    }];
    
}



+ (void)checkPhotoLibraryAuthorization:(void(^ __nullable)(void))firstRequestAccess completion:(void (^)(BOOL))completion {
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    switch (authStatus) {
            
        case PHAuthorizationStatusNotDetermined: {
            firstRequestAccess ? firstRequestAccess() : nil;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                completion ? completion(status == PHAuthorizationStatusAuthorized) : nil;
            }];
        }
            break;
            
        case PHAuthorizationStatusRestricted: {
            completion ? completion(NO) : nil;
        }
            break;
            
        case PHAuthorizationStatusDenied: {
            completion ? completion(NO) : nil;
        }
            break;
            
        case PHAuthorizationStatusAuthorized: {
            completion ? completion(YES) : nil;
        }
            break;
    }
}


+ (void)requestPhotoLibraryAuthorization {
    __weak typeof (self) weakSelf = self;
    [self checkPhotoLibraryAuthorization:nil completion:^(BOOL isPermission) {
        if (!isPermission) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"相册" settingName:@"照片"];
            });
        }
    }];
}



+ (void)checkMicrophoneAuthorization:(void(^ __nullable)(void))firstRequestAccess completion:(void (^)(BOOL))completion {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            //第一次提示用户授权
            firstRequestAccess ? firstRequestAccess() : nil;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                completion ? completion(granted) : nil;
            }];
        }
            break;
            
        case AVAuthorizationStatusAuthorized: {
            completion ? completion(YES) : nil;
        }
            break;
            
        case AVAuthorizationStatusRestricted: {
            completion ? completion(NO) : nil;
        }
            break;
            
        case AVAuthorizationStatusDenied: {
            completion ? completion(NO) : nil;
        }
            break;
    }
    
}


+ (void)requestMicrophoneArthorization {
    
    __weak typeof (self) weakSelf = self;
    
    [self checkMicrophoneAuthorization:nil completion:^(BOOL isPermission) {
        if (!isPermission) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"麦克风" settingName:@"麦克风"];
            });
        }
    }];
}



+ (void)showSettingAlertWithAuth:(NSString *)auth settingName:(NSString *)settingName {
    
    NSString *title = [NSString stringWithFormat:@"无法使用%@",auth];
    NSString *message = [NSString stringWithFormat:@"请在iPhone的“设置-隐私-%@”中允许访问", settingName];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController *rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:setAction];
    
    [rootVC presentViewController:alertController animated:YES completion:nil];
}
@end

typedef void(^seletedImage)(UIImage *image);
@interface GWImageSelectManager()<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, copy) seletedImage selectedImage;
@end

@implementation GWImageSelectManager

- (instancetype)init{
    if (self = [super init]) {
        [self imagePicker];
    }
    return self;
}

- (void)startImageSelected:(GWAuthorizationType)type completion:(void (^)(UIImage *))completion{
    self.selectedImage = completion;
    switch (type) {
        case GW_Camera:{
             if (![self isCameraAvailable] || ![self doesCameraSupportTakingPhotos]){
                 NSLog(@"相机不可用.");
                 return;
             }
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            
            __weak typeof(self) weakSelf = self;
            [GWUserAuthorizationManager checkAuthorization:GW_Camera firstRequestAccess:nil completion:^(BOOL isPermission) {
                if (isPermission) {
                    [weakSelf presentToImagePicker];
                } else {
                    [GWUserAuthorizationManager requestAuthorization:GW_Camera];
                }
            }];
        }
            break;
        case GW_PhotoLibrary:{
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            __weak typeof(self) weakSelf = self;
            [GWUserAuthorizationManager checkAuthorization:GW_PhotoLibrary firstRequestAccess:nil completion:^(BOOL isPermission) {
                if (isPermission) {
                    [weakSelf presentToImagePicker];
                } else {
                    [GWUserAuthorizationManager requestAuthorization:GW_PhotoLibrary];
                }
            }];
        }
            break;
        default:{
            self.selectedImage ? self.selectedImage(nil) : nil;
        }
            break;
    }
}

- (void)presentToImagePicker {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        [rootVC presentViewController:self.imagePicker animated:YES completion:nil];
    });
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.selectedImage ? self.selectedImage(image) : nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.selectedImage ? self.selectedImage(nil) : nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - 摄像头和相册相关的公共类
// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// 判断是否支持某种多媒体类型：拍照，视频
- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    
    __block BOOL result = NO;
    
    if ([paramMediaType length] == 0){
        NSLog(@"Media type is empty.");
        return NO;
    }
    
    NSArray *availableMediaTypes =[UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    
    return result;
}

// 检查摄像头是否支持录像
- (BOOL) doesCameraSupportShootingVideos{
    
    return [self cameraSupportsMedia:(NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
    
}

// 检查摄像头是否支持拍照
- (BOOL) doesCameraSupportTakingPhotos{
    return [self cameraSupportsMedia:(NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}


#pragma mark - 相册文件选取相关
// 相册是否可用
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

// 是否可以在相册中选择视频
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:(NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// 是否可以在相册中选择图片
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:( NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


#pragma mark - getter

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}
@end
