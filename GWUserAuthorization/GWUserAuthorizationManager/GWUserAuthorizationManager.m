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


@interface GWUserAuthorizationManager()
//定位状态
@property (copy, nonatomic,readwrite) void(^userLocationState)(GWAuthorizationState state);
@end

@implementation GWUserAuthorizationManager
static GWUserAuthorizationManager *sharedInstance = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)checkAuthorization:(GWAuthorizationType)type firstRequestAccess:(void (^)(void))requestAccess completion:(void (^)(GWAuthorizationState state))completion {
    
    switch (type) {
        case GWAuthorizationType_Camera: {
            
            [self checkCameraAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } completion:^(GWAuthorizationState state) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(state);
                });
            }];
        }
            break;
        case GWAuthorizationType_PhotoLibrary: {
            
            [self checkPhotoLibraryAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } completion:^(GWAuthorizationState state) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(state);
                });
            }];
        }
            break;
        case GWAuthorizationType_Microphone: {
            
            [self checkMicrophoneAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } completion:^(GWAuthorizationState state) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(state);
                });
                
            }];
        }
            break;
        case GWAuthorizationType_Location:{
            
            [self checkLocationAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } requestType:GWAuthorizationType_Location completion:^(GWAuthorizationState state) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(state);
                });
                
            }];
        }
            break;
        case GWAuthorizationType_Location_Always:{

            [self checkLocationAuthorization:^{
                requestAccess ? requestAccess() : nil;
            } requestType:GWAuthorizationType_Location_Always completion:^(GWAuthorizationState state) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    completion(state);
                });
                
            }];
        }
            break;
    }
    
}



+ (void)requestAuthorization:(GWAuthorizationType)type {
    switch (type) {
        case GWAuthorizationType_Camera: {
            [self requestCameraAuthorization];
        }
            break;
        case GWAuthorizationType_PhotoLibrary: {
            [self requestPhotoLibraryAuthorization];
        }
            break;
        case GWAuthorizationType_Microphone: {
            [self requestMicrophoneArthorization];
        }
            break;
        case GWAuthorizationType_Location: {
            [self requestLocationArthorization:GWAuthorizationType_Location];
        }
            break;
        case GWAuthorizationType_Location_Always: {
            [self requestLocationArthorization:GWAuthorizationType_Location_Always];
        }
            break;
    }
}

+ (void)saveImageToPhotoLibrary:(UIImage *)image block:(void(^ __nullable)(void))block{
    __weak typeof (self) weakSelf = self;
    [self checkPhotoLibraryAuthorization:nil completion:^(GWAuthorizationState state) {
        if (state == GWAuthorizationStateDenied) {
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

+ (void)checkCameraAuthorization:(void(^ __nullable)(void))firstRequestAccess completion:(void (^)(GWAuthorizationState state))completion {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            
            //第一次提示用户授权
            firstRequestAccess ? firstRequestAccess() : nil;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                completion ? completion(granted?GWAuthorizationStateAuthorized:GWAuthorizationStateDenied): nil;
            }];
        }
            break;
            
        case AVAuthorizationStatusAuthorized: {
            completion ? completion(GWAuthorizationStateAuthorized) : nil;
        }
            break;
            
        case AVAuthorizationStatusRestricted: {
            completion ? completion(GWAuthorizationStateDenied) : nil;
        }
            break;
            
        case AVAuthorizationStatusDenied: {
            completion ? completion(GWAuthorizationStateDenied) : nil;
        }
            break;
    }
}


+ (void)requestCameraAuthorization {
    
    __weak typeof (self) weakSelf = self;
    [self checkCameraAuthorization:nil completion:^(GWAuthorizationState state) {
        if (state == GWAuthorizationStateDenied) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"相机" settingName:@"相机"];
            });
            
        }
    }];
    
}



+ (void)checkPhotoLibraryAuthorization:(void(^ __nullable)(void))firstRequestAccess completion:(void (^)(GWAuthorizationState state))completion {
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    switch (authStatus) {
            
        case PHAuthorizationStatusNotDetermined: {
            firstRequestAccess ? firstRequestAccess() : nil;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                completion ? completion(status == PHAuthorizationStatusAuthorized?GWAuthorizationStateAuthorized:GWAuthorizationStateDenied) : nil;
            }];
        }
            break;
            
        case PHAuthorizationStatusRestricted: {
            completion ? completion(GWAuthorizationStateDenied) : nil;
        }
            break;
            
        case PHAuthorizationStatusDenied: {
            completion ? completion(GWAuthorizationStateDenied) : nil;
        }
            break;
            
        case PHAuthorizationStatusAuthorized: {
            completion ? completion(GWAuthorizationStateAuthorized) : nil;
        }
            break;
    }
}


+ (void)requestPhotoLibraryAuthorization {
    __weak typeof (self) weakSelf = self;
    [self checkPhotoLibraryAuthorization:nil completion:^(GWAuthorizationState state) {
        if (state == GWAuthorizationStateDenied) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"相册" settingName:@"照片"];
            });
        }
    }];
}



+ (void)checkMicrophoneAuthorization:(void(^ __nullable)(void))firstRequestAccess completion:(void (^)(GWAuthorizationState state))completion {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            //第一次提示用户授权
            firstRequestAccess ? firstRequestAccess() : nil;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                completion ? completion(granted?GWAuthorizationStateAuthorized:GWAuthorizationStateDenied) : nil;
            }];
        }
            break;
            
        case AVAuthorizationStatusAuthorized: {
            completion ? completion(GWAuthorizationStateAuthorized) : nil;
        }
            break;
            
        case AVAuthorizationStatusRestricted: {
            completion ? completion(GWAuthorizationStateDenied) : nil;
        }
            break;
            
        case AVAuthorizationStatusDenied: {
            completion ? completion(GWAuthorizationStateDenied) : nil;
        }
            break;
    }
    
}


+ (void)requestMicrophoneArthorization {
    
    __weak typeof (self) weakSelf = self;
    
    [self checkMicrophoneAuthorization:nil completion:^(GWAuthorizationState state) {
        if (state == GWAuthorizationStateDenied) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"麦克风" settingName:@"麦克风"];
            });
        }
    }];
}


+ (void)checkLocationAuthorization:(void(^ __nullable)(void))firstRequestAccess requestType:(GWAuthorizationType)requestType  completion:(void (^)(GWAuthorizationState state))completion {
    //第一次提示用户授权
    [GWLocationManager commentRequestLocation:requestType];
    GWUserAuthorizationManager_share.userLocationState = ^(GWAuthorizationState state){
        if (completion) {
            completion(state);
        }
    };
}

+ (void)requestLocationArthorization:(GWAuthorizationType)requestType {
    
    __weak typeof (self) weakSelf = self;
    
    [self checkLocationAuthorization:nil requestType:requestType completion:^(GWAuthorizationState state) {
        if (state == GWAuthorizationStateDenied) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gw_authorzation_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf showSettingAlertWithAuth:@"位置" settingName:@"位置"];
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
        case GWAuthorizationType_Camera:{
             if (![self isCameraAvailable] || ![self doesCameraSupportTakingPhotos]){
                 NSLog(@"相机不可用.");
                 return;
             }
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            
            __weak typeof(self) weakSelf = self;
            [GWUserAuthorizationManager checkAuthorization:GWAuthorizationType_Camera firstRequestAccess:nil completion:^(GWAuthorizationState state) {
                if (state == GWAuthorizationStateAuthorized) {
                    [weakSelf presentToImagePicker];
                } else {
                    [GWUserAuthorizationManager requestAuthorization:GWAuthorizationType_Camera];
                }
            }];
        }
            break;
        case GWAuthorizationType_PhotoLibrary:{
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            __weak typeof(self) weakSelf = self;
            [GWUserAuthorizationManager checkAuthorization:GWAuthorizationType_PhotoLibrary firstRequestAccess:nil completion:^(GWAuthorizationState state) {
                if (state == GWAuthorizationStateAuthorized) {
                    [weakSelf presentToImagePicker];
                } else {
                    [GWUserAuthorizationManager requestAuthorization:GWAuthorizationType_PhotoLibrary];
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


@implementation GWIDCardScanManager
static bool scanInitSuccess = NO;
- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)initScanIDCardBlock:(void(^)(BOOL success))block{
    if (!scanInitSuccess) {
        const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
        EXCARDS_Done();
        int ret = EXCARDS_Init(thePath);
        scanInitSuccess = ret == 0;
    }
    if (block) {
        block(scanInitSuccess);
    }
}

- (void)showView:(UIView *)view{
    [view.layer addSublayer:self.previewLayer];
    self.previewLayer.frame = view.bounds;
    [self runSession];
}

-(AVCaptureDevice *)capDevice {
    if (!_capDevice) {
        _capDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        if ([_capDevice lockForConfiguration:&error]) {
            if ([_capDevice isSmoothAutoFocusSupported]) {// 平滑对焦
                _capDevice.smoothAutoFocusEnabled = YES;
            }
            
            if ([_capDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
                _capDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            if ([_capDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
                _capDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            
            if ([_capDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
                _capDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            [_capDevice unlockForConfiguration];
        }else{
            NSLog(@"lockForConfiguration-error = %@",error);
        }
    }
    
    return _capDevice;
}

-(NSNumber *)outPutSetting {
    if (!_outPutSetting) {
        _outPutSetting = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    }
    return _outPutSetting;
}

-(AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
    }
    return _metadataOutput;
}

-(dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _queue;
}

-(AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:self.outPutSetting};
        [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
    }
    return _videoDataOutput;
}

#pragma mark session
-(AVCaptureSession *)capSession {
    if (!_capSession) {
        _capSession = [[AVCaptureSession alloc] init];
//        高质量
        _capSession.sessionPreset = AVCaptureSessionPresetHigh;
        // 2、设置输入：由于模拟器没有摄像头，因此最好做一个判断
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.capDevice error:&error];
        if (error) {
            NSLog(@"没有摄像设备");
        }else {
//            添加输入设备
            if ([_capSession canAddInput:input]) {
                [_capSession addInput:input];
            }
//            添加输出设备
            if ([_capSession canAddOutput:self.videoDataOutput]) {
                [_capSession addOutput:self.videoDataOutput];
            }
//            添加数据格式
            if ([_capSession canAddOutput:self.metadataOutput]) {
                [_capSession addOutput:self.metadataOutput];
                // 输出格式要放在addOutPut之后，否则奔溃
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
            }
        }
    }
    return _capSession;
}

-(AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.capSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

// session开始，即输入设备和输出设备开始数据传递
- (void)runSession {
    if (![self.capSession isRunning]) {
        dispatch_async(self.queue, ^{
            [self.capSession startRunning];
        });
    }
}

// session停止，即输入设备和输出设备结束数据传递
-(void)stopSession {
    if ([self.capSession isRunning]) {
        dispatch_async(self.queue, ^{
            [self.capSession stopRunning];
        });
    }
}

- (void)clearSession{
    dispatch_async(self.queue, ^{
        [self.capSession stopRunning];
        [self.capSession removeOutput:self.videoDataOutput];
        [self.capSession removeOutput:self.metadataOutput];
        self.videoDataOutput = nil;
        self.metadataOutput = nil;
        self.capSession = nil;
    });
}

#pragma mark - 打开／关闭手电筒
- (void)setTorchOn:(BOOL)torchOn{
    _torchOn = torchOn;
    if ([self.capDevice hasTorch]){ // 判断是否有闪光灯
        [self.capDevice lockForConfiguration:nil];// 请求独占访问硬件设备
        if (self.torchOn) {
            [self.capDevice setTorchMode:AVCaptureTorchModeOn];
        } else {
            [self.capDevice setTorchMode:AVCaptureTorchModeOff];
        }
        [self.capDevice unlockForConfiguration];// 请求解除独占访问硬件设备
    }else {
        NSLog(@"您的设备没有闪光灯");
    }
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark 从输出的数据流捕捉单一的图像帧
// AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] || [self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        if ([captureOutput isEqual:self.videoDataOutput] && !_isNoScaning) {
            _isNoScaning = YES;
            // 身份证信息识别
            [self IDCardRecognit:imageBuffer isScan:YES];
           
        }
    } else {
        NSLog(@"输出格式不支持");
    }
}

#pragma mark - 身份证信息识别
- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer isScan:(BOOL)isScan{
    
    CVBufferRetain(imageBuffer);
    
    // Lock the image buffer
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
        size_t width= CVPixelBufferGetWidth(imageBuffer);// 1920
        size_t height = CVPixelBufferGetHeight(imageBuffer);// 1080
        
        CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
        size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
//        1152
        unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        unsigned char* pixelAddress = baseAddress + offset;
        
        static unsigned char *buffer = NULL;
        if (buffer == NULL) {
            buffer = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
        }
        
        memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
        
        unsigned char pResult[1024];
        int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
        if (ret <= 0) {
            NSLog(@"ret=[%d]", ret);
            if (!isScan && _scanResult) {
                _scanResult(nil,nil);
            }
        } else {
            NSLog(@"ret=[%d]", ret);
            
            // 播放一下“拍照”的声音，模拟拍照
//            AudioServicesPlaySystemSound(1108);
            
            if ([self.capSession isRunning]) {
                [self.capSession stopRunning];
            }
            
            char ctype;
            char content[256];
            int xlen;
            int i = 0;
            
            NSMutableDictionary *cardDic = [NSMutableDictionary dictionary];
            [cardDic setValue:@(pResult[i++]) forKey:@"type"];
            
            while(i < ret){
                ctype = pResult[i++];
                for(xlen = 0; i < ret; ++i){
                    if(pResult[i] == ' ') { ++i; break; }
                    content[xlen++] = pResult[i];
                }
                
                content[xlen] = 0;
                
                if(xlen) {
                    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    if(ctype == 0x21) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"cardNum"];
                    } else if(ctype == 0x22) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"name"];
                    } else if(ctype == 0x23) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"gender"];
                    } else if(ctype == 0x24) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"nation"];
                    } else if(ctype == 0x25) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"address"];
                    } else if(ctype == 0x26) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"issue"];
                    } else if(ctype == 0x27) {
                        [cardDic setValue:[NSString stringWithCString:(char *)content encoding:gbkEncoding] forKey:@"valid"];
                    }
                }
            }
            
            UIImage *image = [UIImage gw_imageFromImageStream:imageBuffer];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_scanResult) {
                    _scanResult(cardDic,image);
                }
            });
            
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    CVBufferRelease(imageBuffer);
    _isNoScaning = NO;
}


@end


@interface GWLocationManager()

@end
@implementation GWLocationManager
static GWLocationManager *sharedLocationInstance = nil;
+ (GWLocationManager *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        sharedLocationInstance = [[self alloc] init];
    });
    return sharedLocationInstance;
}

+ (void)commentRequestLocation:(GWAuthorizationType)requestType{
    GWLocationManager_share.locationManager = [[CLLocationManager alloc] init];
    GWLocationManager_share.locationManager.delegate = GWLocationManager_share;
    if (requestType == GWAuthorizationType_Location_Always) {
        [GWLocationManager_share.locationManager requestAlwaysAuthorization];
    }else{
        [GWLocationManager_share.locationManager requestWhenInUseAuthorization];
    }
    [GWLocationManager_share.locationManager startUpdatingLocation];
    // 距离筛选器   单位:米   100米:用户移动了100米后会调用对应的代理方法didUpdateLocations
        // kCLDistanceFilterNone  使用这个值得话只要用户位置改动就会调用定位
    GWLocationManager_share.locationManager.distanceFilter = 100.0;
    // 期望精度  单位:米   100米:表示将100米范围内看做一个位置 导航使用kCLLocationAccuracyBestForNavigation
    GWLocationManager_share.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

}

#pragma mark - 定位回调(CLLocationManagerDelegate)
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            if (_locationState) {
                _locationState(GWAuthorizationStateUnauthorized);
            }
            if (GWUserAuthorizationManager_share.userLocationState) {
                GWUserAuthorizationManager_share.userLocationState(GWAuthorizationStateUnauthorized);
            }
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            if (_locationState) {
                _locationState(GWAuthorizationStateDenied);
            }
            if (GWUserAuthorizationManager_share.userLocationState) {
                GWUserAuthorizationManager_share.userLocationState(GWAuthorizationStateUnauthorized);
            }
            break;
        }
        case kCLAuthorizationStatusDenied:{
            if (_locationState) {
                _locationState(GWAuthorizationStateDenied);
            }
            if (GWUserAuthorizationManager_share.userLocationState) {
                GWUserAuthorizationManager_share.userLocationState(GWAuthorizationStateDenied);
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            if (_locationState) {
                _locationState(GWAuthorizationStateAuthorized);
            }
            if (GWUserAuthorizationManager_share.userLocationState) {
                GWUserAuthorizationManager_share.userLocationState(GWAuthorizationStateAuthorized);
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            if (_locationState) {
                _locationState(GWAuthorizationStateAuthorized);
            }
            if (GWUserAuthorizationManager_share.userLocationState) {
                GWUserAuthorizationManager_share.userLocationState(GWAuthorizationStateAuthorized);
            }
            break;
        }
        default:
            break;
    }
}

// 当定位到用户位置时调用
// 调用非常频繁(耗电)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // 一个CLLocation对象代表一个位置
//    NSLog(@"%@",locations);
    if (GWLocationManager_share.locationUpdate) {
        GWLocationManager_share.locationUpdate(locations);
    }
    // 停止定位
//    [manager stopUpdatingLocation];
}
@end
