//
//  NTESGalleryViewController.m
//  NIMDemo
//
//  Created by ght on 15-2-3.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESGalleryViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+NTES.h"
#import "NTESSnapchatAttachment.h"
#import "NTESSessionUtil.h"
#import "UIView+Toast.h"
#import "NTESMediaPreviewViewController.h"
#import "UIAlertView+NTESBlock.h"
#import "NIMKitAuthorizationTool.h"
#import <SDWebImageFLPlugin/SDWebImageFLPlugin.h>
#import <SDWebImage/SDWebImage.h>
#import <YYImage/YYImage.h>

@implementation NTESGalleryItem

@end


@interface NTESGalleryViewController ()
{
    BOOL _onceToken;
}

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *galleryImageView;
@property (nonatomic,strong)    NTESGalleryItem *currentItem;
@property (nonatomic,strong)    NIMSession *session;
@property (nonatomic,strong)  IBOutlet  UIScrollView *scrollView;
@end

@implementation NTESGalleryViewController

- (instancetype)initWithItem:(NTESGalleryItem *)item session:(NIMSession *)session
{
    if (self = [super initWithNibName:@"NTESGalleryViewController"
                               bundle:nil])
    {
        _currentItem = item;
        _session = session;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadImage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.galleryImageView.isAnimating) {
        [self.galleryImageView stopAnimating];
    }

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    [self layoutGallery:_currentItem.size];
}


- (void)loadImage
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width - insets.left - insets.right,
                                             self.scrollView.height - insets.top - insets.bottom);
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_currentItem.imagePath])
    {
        [self setupImageWithPath:_currentItem.imagePath];
    }
    else
    {
        typeof(self) weakSelf = self;
        [[NIMSDK sharedSDK].resourceManager download:_currentItem.imageURL filepath:_currentItem.imagePath progress:nil completion:^(NSError * _Nullable error) {
            if (error || ![[NSFileManager defaultManager] fileExistsAtPath:_currentItem.imagePath])
            {
                return;
            }
            
            [weakSelf setupImageWithPath:weakSelf.currentItem.imagePath];
        }];
    }
    
    if (self.session)
    {
        [self setupRightNavItem];
    }
              
    if ([_currentItem.name length])
    {
        self.navigationItem.title = _currentItem.name;
    }
                          
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressImageView:)];
    [self.scrollView addGestureRecognizer:recognizer];
}

- (void)setupImageWithPath:(NSString *)path
{
    UIImage *yyImage = [self imageWithPath:path];
    self.galleryImageView.image = yyImage;
    [self layoutGallery:yyImage.size];
}

- (UIImage *)imageWithPath:(NSString *)path
{
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        return nil;
    }
    
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:path];
    YYImage *yyImage = [YYImage imageWithData:imageData
                                        scale:UIScreen.mainScreen.scale];
    return yyImage;
}



- (void)layoutGallery:(CGSize)size
{
    CGFloat width  = size.width;
    CGFloat height = size.height;
    
    CGFloat scale  = width > height? self.scrollView.contentSize.height / height : self.scrollView.contentSize.width / width;
    
    if (height * scale > self.scrollView.contentSize.height)
    {
        self.galleryImageView.size = CGSizeMake(width * scale, height * scale);
        self.scrollView.contentSize = self.galleryImageView.size;
        self.galleryImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else
    {
        self.galleryImageView.size = self.scrollView.contentSize;
        self.galleryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    self.galleryImageView.centerY = self.galleryImageView.height * .5f;
}


- (void)setupRightNavItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(onMore:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_gallery_more_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_gallery_more_pressed"] forState:UIControlStateHighlighted];
    [button sizeToFit];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = buttonItem;
}


- (void)onMore:(id)sender
{
    NIMMessageSearchOption *option = [[NIMMessageSearchOption alloc] init];
    option.limit = 0;
    option.messageTypes = @[@(NIMMessageTypeImage),@(NIMMessageTypeVideo)];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].conversationManager searchMessages:self.session option:option result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
        if (weakSelf)
        {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            NTESMediaPreviewObject *focusObject;
            
            //显示的时候新的在前老的在后，逆序排列
            //如果需要微信的显示顺序，则直接将这段代码去掉即可
            NSArray *array = messages.reverseObjectEnumerator.allObjects;
            
            for (NIMMessage *message in array)
            {
                switch (message.messageType) {
                    case NIMMessageTypeVideo:{
                        NTESMediaPreviewObject *object = [weakSelf previewObjectByVideo:message.messageObject];
                        [objects addObject:object];
                        break;
                    }
                    case NIMMessageTypeImage:{
                        NTESMediaPreviewObject *object = [weakSelf previewObjectByImage:message.messageObject];
                        //图片 thumbPath 一致，就认为是本次浏览的图片
                        if ([message.messageId isEqualToString:weakSelf.currentItem.itemId])
                        {
                            focusObject = object;
                        }
                        [objects addObject:object];
                        break;
                    }
                    default:
                        break;
                }
            }
            NTESMediaPreviewViewController *vc = [[NTESMediaPreviewViewController alloc] initWithPriviewObjects:objects focusObject:focusObject];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }        
    }];
}

- (void)onLongPressImageView:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        UIAlertController *controller = [[UIAlertController alloc] init];
        UIImage *image = [self imageWithPath:self.currentItem.imagePath];
        [[[controller addAction:@"保存至相册".ntes_localized style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [NIMKitAuthorizationTool requestPhotoLibraryAuthorization:^(NIMKitAuthorizationStatus status) {
                switch (status) {
                    case NIMKitAuthorizationStatusAuthorized:
                        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                        break;
                    default:
                        [self.view makeToast:@"没有开启权限，请开启权限".ntes_localized duration:2.0 position:CSToastPositionCenter];
                        break;
                }
            }];
        }]addAction:@"取消".ntes_localized style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}] show];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *toast = (!image || error)? [NSString stringWithFormat:@"%@：%@",@"保存图片失败 , 错误".ntes_localized,error] : @"保存图片成功".ntes_localized;
    [self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
}

- (NTESMediaPreviewObject *)previewObjectByVideo:(NIMVideoObject *)object
{
    NTESMediaPreviewObject *previewObject = [[NTESMediaPreviewObject alloc] init];
    previewObject.objectId  = object.message.messageId;
    previewObject.thumbPath = object.coverPath;
    previewObject.thumbUrl  = object.coverUrl;
    previewObject.path      = object.path;
    previewObject.url       = object.url;
    previewObject.type      = NTESMediaPreviewTypeVideo;
    previewObject.timestamp = object.message.timestamp;
    previewObject.displayName = object.displayName;
    previewObject.duration  = object.duration;
    previewObject.imageSize = object.coverSize;
    return previewObject;
}

- (NTESMediaPreviewObject *)previewObjectByImage:(NIMImageObject *)object
{
    NTESMediaPreviewObject *previewObject = [[NTESMediaPreviewObject alloc] init];
    previewObject.objectId = object.message.messageId;
    previewObject.thumbPath = object.thumbPath;
    previewObject.thumbUrl  = object.thumbUrl;
    previewObject.path      = object.path;
    previewObject.url       = object.url;
    previewObject.type      = NTESMediaPreviewTypeImage;
    previewObject.timestamp = object.message.timestamp;
    previewObject.displayName = object.displayName;
    previewObject.imageSize = object.size;
    return previewObject;
}

@end


@interface SingleSnapView : FLAnimatedImageView

@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic,copy)   NIMCustomObject *messageObject;

- (instancetype)initWithFrame:(CGRect)frame messageObject:(NIMCustomObject *)object;

- (void)setProgress:(CGFloat)progress;

@end


@implementation  NTESGalleryViewController(SingleView)

+ (UIView *)alertSingleSnapViewWithMessage:(NIMMessage *)message baseView:(UIView *)view{
    NIMCustomObject *messageObject = (NIMCustomObject *)message.messageObject;
    if (![messageObject isKindOfClass:[NIMCustomObject class]] || ![messageObject.attachment isKindOfClass:[NTESSnapchatAttachment class]]) {
        return nil;
    }
    SingleSnapView *galleryImageView = [[SingleSnapView alloc] initWithFrame:[UIScreen mainScreen].bounds messageObject:messageObject];
    galleryImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    galleryImageView.backgroundColor = [UIColor whiteColor];
    galleryImageView.contentMode  = UIViewContentModeScaleAspectFit;
    
    galleryImageView.userInteractionEnabled = NO;
    [view presentView:galleryImageView animated:YES complete:^{
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)messageObject.attachment;
        if ([[NSFileManager defaultManager] fileExistsAtPath:attachment.filepath isDirectory:nil])
        {
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:attachment.filepath];
            BOOL isGif = ([NSData sd_imageFormatForImageData:imageData] == SDImageFormatGIF);
            if (isGif) {
                galleryImageView.animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:imageData];
                if (!galleryImageView.isAnimating) {
                    [galleryImageView startAnimating];
                }
            } else {
                galleryImageView.image = [UIImage imageWithContentsOfFile:attachment.filepath];
            }
            galleryImageView.progress = 1.0;
        }
        else
        {
            [NTESGalleryViewController downloadImage:attachment.url imageView:galleryImageView];
        }
    }];
    return galleryImageView;
}

+ (void)downloadImage:(NSString *)url imageView:(SingleSnapView *)imageView{
    __weak typeof(imageView) wImageView = imageView;
    __block NSString *targetURL = url;
    [[NIMSDK sharedSDK].resourceManager fetchNOSURLWithURL:url
                                                completion:^(NSError * _Nullable error, NSString * _Nullable urlString)
     {
         if(urlString && !error) {
             targetURL = urlString;
         }
         NSURL *tartgetUrlObj = [NSURL URLWithString:targetURL];
         [imageView sd_setImageWithURL:tartgetUrlObj placeholderImage:nil options:0 context:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
             dispatch_async_main_safe(^{
                 wImageView.progress = (CGFloat)receivedSize / expectedSize;
             });
         } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
             if (error) {
                 [wImageView makeToast:@"下载图片失败".ntes_localized
                              duration:2
                              position:CSToastPositionCenter];
             }else{
                 wImageView.progress = 1.0;
             }
         }];
     }];
}

@end


@implementation SingleSnapView

- (instancetype)initWithFrame:(CGRect)frame messageObject:(NIMCustomObject *)object
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _messageObject = object;
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        CGFloat width = 200.f * UISreenWidthScale;
        _progressView.width = width;
        _progressView.hidden = YES;
        [self addSubview:_progressView];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    [self.progressView setProgress:progress];
    [self.progressView setHidden:progress>0.99];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.progressView.centerY = self.height *.5;
    self.progressView.centerX = self.width  *.5;
}


@end
