//
//  ViewController.m
//  recognize
//
//  Created by 温国力 on 16/9/21.
//  Copyright © 2016年 wenguoli. All rights reserved.
//

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#import "ViewController.h"
#import "OYEHTTPSession.h"
#import "OYEUploadParam.h"
#import "OYEHttpRequest.h"
#import "UploadParam.h"


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    self.view.frame = CGRectMake(0, 0, width, height);
    [self setupImage];

}
#pragma mark - 修改成圆形图片
- (void)setupImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [cachesDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];
    self.imageIcon.image = selfPhoto;
    //设置圆形图片
    self.imageIcon.layer.cornerRadius = self.imageIcon.bounds.size.height * 0.5 ;
    self.imageIcon.layer.masksToBounds = YES;
}

#pragma mark - 选择照片/拍照
- (IBAction)takePhoto {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *takePhotos = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhotos];
    }];
    UIAlertAction *selectorPhotos = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectorPhotos];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:takePhotos];
    [alertController addAction:selectorPhotos];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 拍照
- (void)takePhotos
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = sourceType;
        if(iOS8Later) {
            imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
    
}
#pragma mark - 选择相册
- (void)selectorPhotos
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //1.判断存储的路径，图片还是视频
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self performSelector:@selector(saveImage:)  withObject:img afterDelay:0.5];
    }
}
#pragma mark: - 相册选择点击取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - 保存图片
- (void)saveImage:(UIImage *)image {
    
    //0.记录传入文件的是否存在
    BOOL success;
    NSError *error;
    //1.创建文件路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [cachesDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];
    NSLog(@"imageFile->>%@",imageFilePath);
    //2.如果存在就移除，重新添加
    success = [fileManager fileExistsAtPath:imageFilePath];
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    //3.对图片进行压缩为500*500
    UIImage *smallImage = [self thumbnailWithImageWithoutScale:image size:CGSizeMake(300, 300)];
    //UIImagePNGRepresentation 存储PNG的图片
    //UIImageJPEGRepresentation 存储JEPG的图片，可设置图片质量
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.8);
    [imageData writeToFile:imageFilePath atomically:YES];
    //4.写入文件
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];
    //5.读取图片文件
    self.imageIcon.image = selfPhoto;
    
    // 测试，发送网络请求
    [self postAFNImageData:smallImage];
    
    
}
#pragma mark - 测试发送网络请求
- (void)postAFNImageData: (UIImage *)image
{
    NSString *url = @"http://v.juhe.cn/certificates/query.php";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"key"] = @"ca3dadf14922b91960cb379d1ae861e4";
    parameters[@"cardType"] = @"2";
    parameters[@"pic"] = image;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =@"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
    

    OYEUploadParam *imageParam = [[OYEUploadParam alloc] init];
    imageParam.data = imageData;
    imageParam.name = @"pic";
    imageParam.filename = fileName;
    imageParam.mimeType = @"image/png";
    [OYEHTTPSession uploadWithURLString:@"query.php" parameters:parameters uploadParam:imageParam completeBlock:^(id  _Nullable responseObject, NSError * _Nullable error) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"成功 ---- %@", string);
         NSLog(@"失败 ---- %@",error);
    }];
    
    UploadParam *up = [[UploadParam alloc] init];
    up.data = imageData;
    up.name = @"pic";
    up.filename = fileName;
    up.mimeType = @"image/png";
    
    [OYEHttpRequest uploadWithURLString:url parameters:parameters uploadParam:up success:^(id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"成功请求: %@", string);
        
    } failure:^(NSError *error) {
        NSLog(@"失败请求：%@",error);
    }];
    
}
#pragma mark - 二进制转十六进制
- (NSString *)data2Hex:(NSData *)data {
    if (!data) {
        return nil;
    }
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *str = [NSMutableString stringWithCapacity:data.length * 2];
    for (int i=0; i < data.length; i++){
        [str appendFormat:@"%0x", bytes[i]];
    }
    return str;
}

#pragma mark - 改变图像的尺寸，方便上传服务器
- (UIImage *)scaleFromImage: (UIImage *)image toSize: (CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - 保持原来的长宽比，生成一个缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
#pragma mark - 仅仅是简单打开相册
- (void)onlyOpenPhotoalbum
{
    //实现相册选择器代理
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    //设置图片源(相簿)
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //设置代理
    picker.delegate = self;
    //设置可以编辑
    picker.allowsEditing = YES;
    //打开拾取器界面
    [self presentViewController:picker animated:YES completion:nil];
}




@end
