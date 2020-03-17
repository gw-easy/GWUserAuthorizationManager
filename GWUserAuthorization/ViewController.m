//
//  ViewController.m
//  GWUserAuthorization
//
//  Created by gw on 2019/3/3.
//  Copyright © 2019 gw. All rights reserved.
//

#import "ViewController.h"
#import "GWUserAuthorizationManager/GWUserAuthorizationManager.h"
@interface ViewController ()
@property (strong, nonatomic) GWImageSelectManager *selectM;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self show];
//        [self testSave];
    });
}

- (void)testSave{
    [GWUserAuthorizationManager saveImageToPhotoLibrary:[UIImage imageNamed:@""] block:^{
        NSLog(@"yes");
    }];
}

- (void)show{
    _selectM = [[GWImageSelectManager alloc] init];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof (self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *camAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.selectM startImageSelected:GW_Camera completion:^(UIImage * _Nullable image) {
            [weakSelf selectImage:image];
        }];
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.selectM startImageSelected:GW_PhotoLibrary completion:^(UIImage * _Nullable image) {
            [weakSelf selectImage:image];
        }];
    }];
    [alertController addAction:camAction];
    [alertController addAction:photoAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)selectImage:(UIImage *)image{
    NSLog(@"%@",image);
}

@end
