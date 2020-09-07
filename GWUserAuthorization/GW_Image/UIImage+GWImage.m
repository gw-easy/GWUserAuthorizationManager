//
//  UIImage+GWImage.m
//  Zhuntiku（准题库）
//
//  Created by zdwx on 2019/11/26.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "UIImage+GWImage.h"

@implementation UIImage (GWImage)

#pragma mark - 截屏
+ (UIImage *)gw_createScreenshotsViewImage:(UIView *)shareView{
    return [self gw_createScreenshotsViewImage:shareView cornerRadius:0];
}

+ (UIImage *)gw_createScreenshotsViewImage:(UIView *)shareView cornerRadius:(CGFloat)cornerRadius{
    if (!shareView) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(shareView.frame.size, NO, [[UIScreen mainScreen] scale]);
    if (cornerRadius>0) {
        [[UIBezierPath bezierPathWithRoundedRect:shareView.bounds cornerRadius:cornerRadius] addClip];
    }
    [shareView drawViewHierarchyInRect:shareView.bounds afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

#pragma mark - 压缩图片
- (UIImage *)gw_changeImageSizeToByte:(NSUInteger)maxLength{
    UIImage *resultImage = self;
    NSData *data = UIImageJPEGRepresentation(resultImage, 1);
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    return resultImage;
}

- (UIImage *)gw_changeImageQualityToByte:(NSInteger)maxLength{
    UIImage *resultImage = [UIImage imageWithData:[self gw_dataChangeImageQualityToByte:maxLength]];
    return resultImage;
}

- (NSData *)gw_dataChangeImageQualityToByte:(NSInteger)maxLength{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}


- (UIImage *)gw_changeImageToAppointByte:(NSUInteger)maxLength{
    return [UIImage imageWithData:[self gw_dataChangeImageToAppointByte:maxLength]];
}

- (NSData *)gw_dataChangeImageToAppointByte:(NSUInteger)maxLength{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return data;
}

#pragma mark - 缩放图片 - 适配宽或高

//指定宽度按比例缩放
-(UIImage *)gw_imageCompressForWidth:(CGFloat)defineWidth{
    
    return [self gw_imageCompressForSize:CGSizeMake(defineWidth, self.size.height / (self.size.width / defineWidth))];
}

//指定高度按比例缩放
-(UIImage *)gw_imageCompressForHeight:(CGFloat)defineHeight{
    return [self gw_imageCompressForSize:CGSizeMake(self.size.width/(self.size.height/defineHeight), defineHeight)];
}

//按比例缩放,size是你要把图显示到 多大区域 ,例如:CGSizeMake(300, 400)
-(UIImage *)gw_imageCompressForSize:(CGSize)size{
   UIImage *newImage = nil;
   CGSize imageSize = self.size;
   CGFloat width = imageSize.width;
   CGFloat height = imageSize.height;
   CGFloat targetWidth = size.width;
   CGFloat targetHeight = size.height;
   CGFloat scaleFactor = 0.0;
   CGFloat scaledWidth = targetWidth;
   CGFloat scaledHeight = targetHeight;
   CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
   if(CGSizeEqualToSize(imageSize, size) == NO){
       CGFloat widthFactor = targetWidth / width;
       CGFloat heightFactor = targetHeight / height;

       if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
       if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) *0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) *0.5;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO,[UIScreen mainScreen].scale);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [self drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();

    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 绘制图片圆角
-(UIImage *)gw_imageForCornerRadius:(CGFloat)radius{
    CGSize itemSize = CGSizeMake(self.size.width, self.size.height);
    //开启图片的上下文
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, [UIScreen mainScreen].scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    //绘制圆角矩形
    [[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:radius] addClip];
    //绘制图片
    [self drawInRect:imageRect];
    //从上下文中获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图片的上下文
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 视频帧imageBuffer转换成image
+ (UIImage *)gw_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    return [self gw_imageFromImageStream:imageBuffer];
}

+ (UIImage *)gw_imageFromImageStream:(CVImageBufferRef)imageBuffer {
    // Lock the base address of the pixel buffer
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    
    CGImageRelease(videoImage);
    
    return (image);
}

+ (CVPixelBufferRef)gw_pixelBufferARGBFromUIImage:(UIImage *)image{
    CGImageRef imageRef=[image CGImage];
    CGSize frameSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    NSDictionary *options = @{
                              (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @(YES),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES)
                              };
    CVPixelBufferRef pixelBuffer;
//    kCVPixelFormatType_32ARGB
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_64ARGB, (__bridge CFDictionaryRef) options,
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                 (CGBitmapInfo) kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef),
                                           CGImageGetHeight(imageRef)), imageRef);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}


+ (CVPixelBufferRef)gw_pixelBufferYUVFromUIImage:(UIImage *)image{
    CGImageRef imageRef = [image CGImage];
    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const unsigned char *data = CFDataGetBytePtr(pixelData);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
//    32
    NSLog(@"bitsPerPixel:%lu",bitsPerPixel);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
//    8
    NSLog(@"bitsPerComponent:%lu",bitsPerComponent);
        
    size_t frameWidth = CGImageGetWidth(imageRef);
//    4032
    NSLog(@"frameWidth:%lu",frameWidth);
    size_t frameHeight = CGImageGetHeight(imageRef);
//    3024
    NSLog(@"frameHeight:%lu",frameHeight);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
//    16128
    NSLog(@"bytesPerRow:%lu ==:%lu",bytesPerRow,bytesPerRow/4);
    
    NSDictionary *options = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, (__bridge CFDictionaryRef)(options), &pixelBuffer);
    NSParameterAssert(status == kCVReturnSuccess && pixelBuffer != NULL);
        
//    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if (CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess) {
        NSLog(@"yes");
    }
    
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
//    4032
    NSLog(@"width:%lu",width);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
//    3024
    NSLog(@"height:%lu",height);
    size_t bpr = CVPixelBufferGetBytesPerRow(pixelBuffer);
//    6052
    NSLog(@"bpr:%lu",bpr);
        
    size_t wh = width * height;
//    12192768
    NSLog(@"wh:%lu\n",wh);
    size_t size = CVPixelBufferGetDataSize(pixelBuffer);
//    18301248
    NSLog(@"size:%lu",size);
    size_t count = CVPixelBufferGetPlaneCount(pixelBuffer);
//    2
    NSLog(@"count:%lu\n",count);
        
    size_t width0 = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
//    4032
    NSLog(@"width0:%lu",width0);
    size_t height0 = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
//    3024
    NSLog(@"height0:%lu",height0);
    size_t bpr0 = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
//    4032
    NSLog(@"bpr0:%lu",bpr0);
                
    size_t width1 = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
//    2016
    NSLog(@"width1:%lu",width1);
    size_t height1 = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
//    1512
    NSLog(@"height1:%lu",height1);
    size_t bpr1 = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
//    4032
    NSLog(@"bpr1:%lu",bpr1);
        
    unsigned char *bufY = malloc(wh);
    unsigned char *bufUV = malloc(wh/2);

    size_t offset,p;

    int r,g,b,y,u,v;
    int a=255;
    for (int row = 0; row < height; ++row) {
      for (int col = 0; col < width; ++col) {
        //
        offset = ((width * row) + col);
        p = offset*4;
        //
        r = data[p + 0];
        g = data[p + 1];
        b = data[p + 2];
        a = data[p + 3];
        //
        y = 0.299*r + 0.587*g + 0.114*b;
        u = -0.1687*r - 0.3313*g + 0.5*b + 128;
        v = 0.5*r - 0.4187*g - 0.0813*b + 128;
        //
        bufY[offset] = y;
        bufUV[(row/2)*width + (col/2)*2] = u;
        bufUV[(row/2)*width + (col/2)*2 + 1] = v;
      }
    }
    uint8_t *yPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memset(yPlane, 0x80, height0 * bpr0);
    for (int row=0; row<height0; ++row) {
      memcpy(yPlane + row*bpr0, bufY + row*width0, width0);
    }
    uint8_t *uvPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    memset(uvPlane, 0x80, height1 * bpr1);
    for (int row=0; row<height1; ++row) {
      memcpy(uvPlane + row*bpr1, bufUV + row*width, width);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    free(bufY);
    free(bufUV);
    CFRelease(pixelData);
    return pixelBuffer;
}

-(UIImage *)gw_imageRotation:(UIImageOrientation)orientation{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, self.size.height, self.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, self.size.height, self.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, self.size.width, self.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, self.size.width, self.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cgImage = self.CGImage;

    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), cgImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
}

- (UIImage *)gw_imageRotatedOnDegrees:(CGFloat)degrees
{
    CGFloat roundedDegrees = (CGFloat)(round(degrees / 90.0) * 90.0);
    BOOL sameOrientationType = ((NSInteger)roundedDegrees) % 180 == 0;
    CGFloat radians = M_PI * roundedDegrees / 180.0;
    CGSize newSize = sameOrientationType ? self.size : CGSizeMake(self.size.height, self.size.width);

    UIGraphicsBeginImageContext(newSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGImageRef cgImage = self.CGImage;
    if (ctx == NULL || cgImage == NULL) {
        UIGraphicsEndImageContext();
        return self;
    }

    CGContextTranslateCTM(ctx, newSize.width / 2.0, newSize.height / 2.0);
    CGContextRotateCTM(ctx, radians);
    CGContextScaleCTM(ctx, 1, -1);
    CGPoint origin = CGPointMake(-(self.size.width / 2.0), -(self.size.height / 2.0));
    CGRect rect = CGRectZero;
    rect.origin = origin;
    rect.size = self.size;
    CGContextDrawImage(ctx, rect, cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image ?: self;
}



@end
