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
//检查权限
+ (void)checkAuthorization:(GWAuthorizationType)type
        firstRequestAccess:(void(^ __nullable)(void))requestAccess
                completion:(void(^)(BOOL isPermission))completion;

//请求权限（如果没有，就弹出设置提示框）
+ (void)requestAuthorization:(GWAuthorizationType)type;
@end

#pragma mark - 图片选择
@interface GWImageSelectManager : NSObject

- (void)startImageSelected:(GWAuthorizationType)type completion:(void(^)(UIImage * _Nullable image))completion;

@end

NS_ASSUME_NONNULL_END
