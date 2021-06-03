//
//  NTESMediaPreviewViewController.m
//  NIM
//
//  Created by chris on 2017/9/21.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESMediaPreviewViewController.h"
#import "UIView+NTES.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ForceDecode.h"
#import "UIImage+NTESColor.h"
#import "SDImageCoderHelper.h"
#import "NTESGalleryViewController.h"
#import "NTESVideoViewController.h"
#import "NTESSessionViewController.h"
#import <YYImage/YYImage.h>

@interface NTESMediaPreviewViewHeader : UICollectionReusableView

@property (nonatomic,strong) UILabel *titleLabel;

- (void)refresh:(NSString *)title;

@end

@interface NTESMediaPriviewViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *durationLabel;

- (void)refresh:(NTESMediaPreviewObject *)object;

@end

@interface NTESMediaPreviewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL _scollToFocus;
    NSCalendar *_calendar;
    NSMutableArray    *_titles;
    NSMutableDictionary<NSString *, NSMutableArray *> *_contents;
}

@property (nonatomic,copy) NSArray *objects;

@property (nonatomic,strong) NTESMediaPreviewObject *focusObject;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,assign) NSInteger itemCountPerLine;

@property (nonatomic,assign) CGFloat minimumInteritemSpacing;

@property (nonatomic,assign) CGFloat minimumLineSpacing;

@end

@implementation NTESMediaPreviewViewController

- (instancetype)initWithPriviewObjects:(NSArray<NTESMediaPreviewObject *> *) objects
                           focusObject:(NTESMediaPreviewObject *)focusObject
{
    self = [super init];
    if (self)
    {
        _objects = objects;
        _focusObject = focusObject;
        _itemCountPerLine = 3;
        _minimumInteritemSpacing = 1.0f;
        _minimumLineSpacing = 1.0f;
        _calendar = [NSCalendar currentCalendar];
        _contents = [[NSMutableDictionary alloc] init];
        _titles   = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"图片和视频".ntes_localized;
    
    [self sort];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = UIColorFromRGB(0x1d1d1d);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[NTESMediaPriviewViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[NTESMediaPreviewViewHeader class]forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    [self.view addSubview:self.collectionView];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!_scollToFocus && self.objects.count)
    {
        NSIndexPath *indexpath = [self indexPath:self.focusObject];
        [self.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        _scollToFocus = YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width  = (collectionView.width - self.minimumInteritemSpacing * (self.itemCountPerLine - 1)) / self.itemCountPerLine;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.minimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.minimumLineSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.width, 45);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString *title = [_titles objectAtIndex:section];
    NSArray *array  = [_contents objectForKey:title];
    return array.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESMediaPriviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NTESMediaPreviewObject *object = [self objectAtIndex:indexPath];
    [cell refresh:object];
    return cell;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NTESMediaPreviewViewHeader *reusableView;
    if (kind==UICollectionElementKindSectionHeader)
    {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        NSString *title = [_titles objectAtIndex:indexPath.section];
        [reusableView refresh:title];
    } else {
        reusableView = [[NTESMediaPreviewViewHeader alloc] init];
    }
    return reusableView;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    for (UIViewController *vc in viewControllers)
    {
        [vcs addObject:vc];
        if ([vc isKindOfClass:[NTESSessionViewController class]])
        {
            break;
        }
    }
    [vcs addObject:self];
    self.navigationController.viewControllers = [NSArray arrayWithArray:vcs];
    
    NTESMediaPreviewObject *object = [self objectAtIndex:indexPath];
    if (object.type == NTESMediaPreviewTypeImage)
    {
        NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
        item.thumbPath      = [object thumbPath];
        item.imageURL       = [object url];
        item.imagePath      = [object path];
        item.name           = [object displayName];
        item.itemId         = [object objectId];
        item.size           = [object imageSize];
        
        NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item session:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(object.type == NTESMediaPreviewTypeVideo)
    {
        NTESVideoViewItem *item = [[NTESVideoViewItem alloc] init];
        item.path = [object path];
        item.url  = [object url];
        item.itemId  = [object objectId];
        
        NTESVideoViewController *vc = [[NTESVideoViewController alloc] initWithVideoViewItem:item];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (NTESMediaPreviewObject *)objectAtIndex:(NSIndexPath *)indexPath
{
    NSString *key  = [_titles objectAtIndex:indexPath.section];
    NSArray *array = [_contents objectForKey:key];
    return [array objectAtIndex:indexPath.row];
}


- (NSIndexPath *)indexPath:(NTESMediaPreviewObject *)object
{
    NSString *key = [self keyForPreviewObject:object];
    NSArray *array = [_contents objectForKey:key];
    
    NSInteger section = [_titles indexOfObject:key];
    section = (section != NSNotFound? section : 0);
    NSInteger row = [array indexOfObject:object];
    row = (row != NSNotFound? row : 0);
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (void)sort
{
    [_contents removeAllObjects];
    [_titles removeAllObjects];
    
    [self.objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESMediaPreviewObject *object = obj;
        NSString *key = [self keyForPreviewObject:object];
        NSMutableArray *array = [_contents objectForKey:key];
        if (!array)
        {
            array = [[NSMutableArray alloc] init];
            [_contents setObject:array forKey:key];
            
            //因为objects是有序的，这里可以保证 titles 也是有序的，只有第一次出现这个 key 时才添加到 title
            [_titles addObject:key];
        }
        [array addObject:object];
    }];
}

- (NSString *)keyForPreviewObject:(NTESMediaPreviewObject *)object
{
    NSTimeInterval time = object.timestamp;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate * now  = [NSDate date];
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth);
    NSDateComponents *dateComponents = [_calendar components:components fromDate:date];
    NSDateComponents *nowComponents = [_calendar components:components fromDate:now];
    
    NSString *key;
    if (dateComponents.year == nowComponents.year && dateComponents.month == nowComponents.month && dateComponents.weekOfMonth == nowComponents.weekOfMonth)
    {
        key = @"本周".ntes_localized;
    }
    else
    {
        key = [NSString stringWithFormat:@"%zd%@%zd%@",dateComponents.year,@"年".ntes_localized, dateComponents.month, @"月".ntes_localized];
    }
    return key;
}

#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (![self isViewLoaded]) {
        return;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
}


@end

FOUNDATION_STATIC_INLINE NSUInteger NTESCacheCostForImage(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}


@implementation NTESMediaPreviewObject

- (BOOL)isEqual:(id)object
{
    NTESMediaPreviewObject *obj = (NTESMediaPreviewObject *)object;
    return [self.objectId isEqualToString:obj.objectId];
}

@end

@implementation NTESMediaPriviewViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationLabel.font = [UIFont systemFontOfSize:13.f];
        _durationLabel.textColor = UIColorFromRGB(0xffffff);
        _durationLabel.shadowColor = UIColorFromRGB(0x0);
        _durationLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        [self.contentView addSubview:_durationLabel];
    }
    return self;
}

- (void)refresh:(NTESMediaPreviewObject *)object
{
    static NSCache *previewImageCache;
    static UIImage *placeHolderImage;
    static NSCache *durationCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        previewImageCache = [[NSCache alloc] init];
        durationCache     = [[NSCache alloc] init];
        placeHolderImage  = [UIImage imageWithColor:[UIColor grayColor]];
    });

    self.imageView.image = nil;
    UIImage *image = [previewImageCache objectForKey:object.thumbPath];
    if (!image && [[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath])
    {
        //存磁盘读出
        NSData * data = [NSData dataWithContentsOfFile:object.thumbPath];
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:[UIScreen mainScreen].scale];
        if (decoder.type == YYImageTypeWebP)
        {
            image = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
        }
        else
        {
            image = [UIImage imageWithContentsOfFile:object.thumbPath];
            //预解码
            image = [SDImageCoderHelper decodedImageWithImage:image];
        }
        
        //缓存
        NSUInteger cost = NTESCacheCostForImage(image);
        if (image)
        {
            [previewImageCache setObject:image forKey:object.thumbPath cost:cost];
        }
    }
    if (!image && object.thumbUrl)
    {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:object.thumbUrl] placeholderImage:placeHolderImage];
    }
    else
    {
        self.imageView.image = image;
    }
    
    //刷新时长框
    CGRect originFrame = self.durationLabel.frame;
    if (object.duration > 0)
    {
        NSString *duration = [durationCache objectForKey:object.thumbPath];
        if (!duration)
        {
            NSInteger seconds  = (object.duration+500)/1000; //四舍五入
            duration = [NSString stringWithFormat:@"%02zd:%02zd",(NSInteger)(seconds / 60),(NSInteger)(seconds % 60)];
            [durationCache setObject:duration forKey:object.thumbPath];
        }
        self.durationLabel.text = duration;
    }
    else
    {
        self.durationLabel.text = nil;
    }
    [self.durationLabel sizeToFit];
    if (!CGRectEqualToRect(originFrame, self.durationLabel.frame))
    {
        [self setNeedsLayout];
    }
    
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    CGFloat right = 5.f;
    CGFloat botttom = 5.f;
    self.durationLabel.right = self.width - right;
    self.durationLabel.bottom = self.height - botttom;
}

@end


@implementation NTESMediaPreviewViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:15.f];
        _titleLabel.textColor = UIColorFromRGB(0xffffff);
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)refresh:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.left = 10.f;
    self.titleLabel.centerY = self.height * .5f;
}

@end

