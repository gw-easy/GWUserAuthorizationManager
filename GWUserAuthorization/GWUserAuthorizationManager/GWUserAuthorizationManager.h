//
//  GWUserAuthorizationManager.h
//  GWUserAuthorization
//
//  Created by gw on 2019/3/3.
//  Copyright © 2019 gw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
#pragma mark - 用户权限
typedef NS_ENUM(NSInteger, GWAuthorizationType) {
//    相机
    GW_Camera,
//    相册
    GW_PhotoLibrary,
//    麦克风
    GW_Microphone
};

@interface GWUserAuthorizationManager : NSObject

/// 检查权限
/// @param type 类型
/// @param requestAccess 第一次用户授权时需要执行的操作
/// @param completion 完成 - 是否有权限
+ (void)checkAuthorization:(GWAuthorizationType)type
        firstRequestAccess:(void(^ __nullable)(void))requestAccess
                completion:(void(^)(BOOL isPermission))completion;

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

NS_ASSUME_NONNULL_END
