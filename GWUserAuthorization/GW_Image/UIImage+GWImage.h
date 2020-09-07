//
//  UIImage+GWImage.h
//  Zhuntiku（准题库）
//
//  Created by zdwx on 2019/11/26.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIImage (GWImage)

#pragma mark - 截屏
/// 截屏
/// @param shareView 需要截屏的页面
+ (UIImage *)gw_createScreenshotsViewImage:(UIView *)shareView;

/// 截屏 - 带圆角
/// @param shareView 需要截屏的页面
/// @param cornerRadius 圆角
+ (UIImage *)gw_createScreenshotsViewImage:(UIView *)shareView cornerRadius:(CGFloat)cornerRadius;

#pragma mark - 压缩图片

/// 压缩图片尺寸 - 压缩到一定程度会导致 图片模糊
/// @param maxLength 指定长度 byte
- (UIImage *)gw_changeImageSizeToByte:(NSUInteger)maxLength;

/// 压缩图片质量 - 压缩到一定程度无法压缩（图片清晰度优先）
/// @param maxLength 指定长度 byte
- (UIImage *)gw_changeImageQualityToByte:(NSInteger)maxLength;

/// 压缩图片质量 - 压缩到一定程度无法压缩（图片清晰度优先）
/// @param maxLength 指定长度 byte
- (NSData *)gw_dataChangeImageQualityToByte:(NSInteger)maxLength;

/// 压缩图片 - 优先压缩质量，再无法满足情况下压缩尺寸
/// @param maxLength 指定长度 byte
- (UIImage *)gw_changeImageToAppointByte:(NSUInteger)maxLength;

/// 压缩图片 - 优先压缩质量，再无法满足情况下压缩尺寸
/// @param maxLength 指定长度 byte
- (NSData *)gw_dataChangeImageToAppointByte:(NSUInteger)maxLength;

#pragma mark - 缩放图片 - 适配宽或高

/// 图片指定宽度按比例缩放
/// @param defineWidth 指定宽度
-(UIImage *)gw_imageCompressForWidth:(CGFloat)defineWidth;

/// 图片指定高度按比例缩放
/// @param defineHeight 指定高度
-(UIImage *)gw_imageCompressForHeight:(CGFloat)defineHeight;

/// 图片指定size缩放
/// @param size 指定size
-(UIImage *)gw_imageCompressForSize:(CGSize)size;


#pragma mark - 绘制图片圆角

/// 绘制圆角
/// @param radius 圆角
-(UIImage *)gw_imageForCornerRadius:(CGFloat)radius;

#pragma mark - 视频帧imageBuffer转换成image

/// sampleBuffer->image
/// @param sampleBuffer sampleBuffer description
+ (UIImage *)gw_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;


/// imageBuffer->image
/// @param imageBuffer imageBuffer description
+ (UIImage *)gw_imageFromImageStream:(CVImageBufferRef)imageBuffer;


/// image->CVPixelBufferRef (通过RGB模式转)
/// @param image image description
+ (CVPixelBufferRef)gw_pixelBufferARGBFromUIImage:(UIImage *)image;


/// image->CVPixelBufferRef (通过YUV模式转)
/// @param image image description
+ (CVPixelBufferRef)gw_pixelBufferYUVFromUIImage:(UIImage *)image;

#pragma mark - 旋转图片
/// 旋转方向
/// @param orientation orientation description
-(UIImage *)gw_imageRotation:(UIImageOrientation)orientation;


/// 旋转角度
/// @param degrees 角度
- (UIImage *)gw_imageRotatedOnDegrees:(CGFloat)degrees;

@end

NS_ASSUME_NONNULL_END
