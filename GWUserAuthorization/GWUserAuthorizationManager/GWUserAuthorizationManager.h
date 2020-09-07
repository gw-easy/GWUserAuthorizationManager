//
//  GWUserAuthorizationManager.h
//  GWUserAuthorization
//
//  Created by gw on 2019/3/3.
//  Copyright © 2019 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
//此框架需要真机
#import "excards.h"
#import "UIImage+GWImage.h"
NS_ASSUME_NONNULL_BEGIN

#define GWUserAuthorizationManager_share [GWUserAuthorizationManager sharedInstance]
#define GWLocationManager_share [GWLocationManager sharedInstance]

#pragma mark - 用户权限
typedef NS_ENUM(NSInteger, GWAuthorizationType) {
//    相机
    GWAuthorizationType_Camera,
//    相册
    GWAuthorizationType_PhotoLibrary,
//    麦克风
    GWAuthorizationType_Microphone,
//    定位
    GWAuthorizationType_Location,
//    一直定位
    GWAuthorizationType_Location_Always,
//    日历
    GWAuthorizationType_Calendars,
};

typedef NS_ENUM(NSInteger, GWAuthorizationState) {
    GWAuthorizationStateUnkonw = 0, // 未知
    GWAuthorizationStateUnauthorized, // 未授权
    GWAuthorizationStateDenied, // 拒绝
    GWAuthorizationStateUnsupported, // 设备不支持
    GWAuthorizationStateAuthorized, // 已授权，可用
};

@interface GWUserAuthorizationManager : NSObject

//定位状态
@property (copy, nonatomic,readonly) void(^userLocationState)(GWAuthorizationState state);

+ (instancetype)sharedInstance;

/// 检查权限
/// @param type 类型
/// @param requestAccess 第一次用户授权时需要执行的操作
/// @param completion 完成 - 是否有权限 isPermission == false 表示无权限 可以自定义权限框
+ (void)checkAuthorization:(GWAuthorizationType)type
        firstRequestAccess:(void(^ __nullable)(void))requestAccess
                completion:(void(^)(GWAuthorizationState state))completion;

/// 请求权限（如果没有，就弹出设置提示框）
/// @param type 类型
+ (void)requestAuthorization:(GWAuthorizationType)type;


///  保存图片到相册
/// @param image 图片
+ (void)saveImageToPhotoLibrary:(UIImage *)image block:(void(^ __nullable)(void))block;
@end

#pragma mark - 图片选择
@interface GWImageSelectManager : NSObject


/// 从相机或者相册获取图片
/// @param type 相机/相册
/// @param completion completion description
- (void)startImageSelected:(GWAuthorizationType)type completion:(void(^)(UIImage * _Nullable image))completion;

@end

#pragma mark - 扫描二维码
@interface GWIDCardScanManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
// 摄像头设备
@property (nonatomic,strong) AVCaptureDevice *capDevice;

// AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic,strong,nullable) AVCaptureSession *capSession;

// 输出格式
@property (nonatomic,strong) NSNumber *outPutSetting;

// 视频流出流对象
@property (nonatomic,strong,nullable) AVCaptureVideoDataOutput *videoDataOutput;

// 元数据（用于人脸识别）
@property (nonatomic,strong,nullable) AVCaptureMetadataOutput *metadataOutput;

// 预览图层
@property (nonatomic,strong,nullable) AVCaptureVideoPreviewLayer *previewLayer;

// 人脸检测框区域
@property (nonatomic,assign) CGRect faceDetectionFrame;

// 队列
@property (nonatomic,strong) dispatch_queue_t queue;

// 是否打开手电筒
@property (nonatomic,assign,getter = isTorchOn) BOOL torchOn;
//是否在扫描过程中
@property (nonatomic, assign) BOOL isNoScaning;
//@property (nonatomic,assign) int type; //1:正面  2:反面
//@property (nonatomic,copy) NSString *cardNum; //身份证号
//@property (nonatomic,copy) NSString *name; //姓名
//@property (nonatomic,copy) NSString *gender; //性别
//@property (nonatomic,copy) NSString *nation; //民族
//@property (nonatomic,copy) NSString *address; //地址
//@property (nonatomic,copy) NSString *issue; //签发机关
//@property (nonatomic,copy) NSString *valid; //有效期
/// 扫描结果
@property (copy, nonatomic) void(^scanResult)( NSDictionary * _Nullable cardDict, UIImage * _Nullable scanImage);

/// 初始化
/// @param block 失败回调
- (void)initScanIDCardBlock:(nullable void(^)(BOOL success))block;
//show view
- (void)showView:(UIView *)view;

#pragma mark - 身份证信息识别
- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer isScan:(BOOL)isScan;


//开始传输
- (void)runSession;
//停止传输
- (void)stopSession;

- (void)clearSession;
@end

@interface GWLocationManager : NSObject<CLLocationManagerDelegate>
// 定位
@property (strong, nonatomic) CLLocationManager *locationManager;
//定位状态
@property (copy, nonatomic) void(^locationState)(GWAuthorizationState state);
//更新定位位置
@property (copy, nonatomic) void(^locationUpdate)(NSArray<CLLocation *> *locations);


+ (GWLocationManager *)sharedInstance;

+ (void)commentRequestLocation:(GWAuthorizationType)requestType;
@end

NS_ASSUME_NONNULL_END
/*
<!-- 相机 -->
<key>NSCameraUsageDescription</key>
<string>App需要您的同意,才能访问相机</string>
 
<!-- 相册 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>
 
<!-- 麦克风 -->
<key>NSMicrophoneUsageDescription</key>
<string>App需要您的同意,才能访问麦克风</string>

<!-- 始终访问位置 -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>App需要您的同意,才能始终访问位置</string>

<!-- 在使用期间访问位置 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>App需要您的同意,才能在使用期间访问位置</string>

<!-- 日历 -->
<key>NSCalendarsUsageDescription</key>
<string>App需要您的同意,才能访问日历</string>
 
<!-- 蓝牙 -->
<key>NSBluetoothPeripheralUsageDescription</key>
<string>App需要您的同意,才能访问蓝牙</string>
 
<!-- 通讯录 -->
<key>NSContactsUsageDescription</key>
<string>App需要您的同意,才能访问通讯录</string>
 
<!-- 媒体资料库 -->
<key>NSAppleMusicUsageDescription</key>
<string>App需要您的同意,才能访问媒体资料库</string>

<!-- NFC -->
<key>NFCReaderUsageDescription</key>
<string>App需要您的同意,才能访问NFC</string>

<!-- 语音识别 -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>App需要您的同意,才能使用语音识别功能</string>

<!-- Face ID -->
<key>NSFaceIDUsageDescription</key>
<string>App需要您的同意,才能访问Face ID</string>

<!-- 健康分享 -->
<key>NSHealthShareUsageDescription</key>
<string>App需要您的同意,才能访问健康分享</string>

<!-- 健康更新 -->
<key>NSHealthUpdateUsageDescription</key>
<string>App需要您的同意,才能访问健康更新 </string>

<!-- 住宅配件 -->
<key>NSHomeKitUsageDescription</key>
<string>App需要您的同意,才能访问住宅配件 </string>

<!-- 运动与健身 -->
<key>NSMotionUsageDescription</key>
<string>App需要您的同意,才能访问运动与健身</string>

<!-- 提醒事项 -->
<key>NSRemindersUsageDescription</key>
<string>App需要您的同意,才能访问提醒事项</string>

<!-- Siri -->
<key>NSSiriUsageDescription</key>
<string>App需要您的同意,才能使用Siri功能</string>

<!-- 电视提供商 -->
<key>NSVideoSubscriberAccountUsageDescription</key>
<string>App需要您的同意,才能访问电视提供商</string>
*/
