//
//  NTESTeamReceiptDetailViewController.m
//  NIM
//
//  Created by chris on 2018/3/14.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "NTESTeamReceiptDetailViewController.h"
#import "NIMCardHeaderCell.h"
#import "NIMTeamCardMemberItem.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

static NSString * const collectionReadCellReuseId   = @"collectionReadCellReuseId";

@interface NTESTeamReceiptDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong)   NIMMessage *message;

@property (nonatomic, strong)   NSMutableArray *readMembers;

@property (nonatomic, strong)   NSMutableArray *unreadMembers;

@end

@implementation NTESTeamReceiptDetailViewController

- (instancetype)initWithMessage:(NIMMessage *)message
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        _message = message;
        _readMembers   = [[NSMutableArray alloc] init];
        _unreadMembers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"消息已读详情".ntes_localized;
    UICollectionViewFlowLayout *reasdUsersLayout = [[UICollectionViewFlowLayout alloc] init];
    reasdUsersLayout.minimumInteritemSpacing = 20;
    self.readUsers.collectionViewLayout = reasdUsersLayout;
    
    UICollectionViewFlowLayout *unreasdUsersLayout = [[UICollectionViewFlowLayout alloc] init];
    unreasdUsersLayout.minimumInteritemSpacing = 20;
    self.unreadUsers.collectionViewLayout = unreasdUsersLayout;

    self.readUsers.contentInset = UIEdgeInsetsMake(self.readUsers.contentInset.top, 10, self.readUsers.contentInset.bottom, 10);
    self.unreadUsers.contentInset = UIEdgeInsetsMake(self.unreadUsers.contentInset.top, 10, self.unreadUsers.contentInset.bottom, 10);

    
    self.readUsers.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:241.0/255.0 blue:245.0/255.0 alpha:1];
    self.unreadUsers.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:241.0/255.0 blue:245.0/255.0 alpha:1];
    
    [self.readUsers registerClass:[NIMCardHeaderCell class] forCellWithReuseIdentifier:collectionReadCellReuseId];
    [self.unreadUsers registerClass:[NIMCardHeaderCell class] forCellWithReuseIdentifier:collectionReadCellReuseId];
    
    [self request];
    [self refreshOnSegment:self.segmentControl];
}


- (IBAction)onSegmentChanged:(UISegmentedControl *)segment
{
    [self refreshOnSegment:segment];
}

- (void)refreshOnSegment:(UISegmentedControl *)segment
{
    self.unreadUsers.hidden = segment.selectedSegmentIndex != 0;
    self.readUsers.hidden = segment.selectedSegmentIndex != 1;
}

- (void)request
{
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].chatManager queryMessageReceiptDetail:self.message completion:^(NSError * _Nullable error, NIMTeamMessageReceiptDetail * _Nullable detail) {
        [SVProgressHUD dismiss];
        if (!error)
        {
            for (NSString *userId in detail.readUserIds)
            {
                NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:userId inTeam:detail.sessionId];
                if (member)
                {
                    NIMTeamCardMemberItem *item = [[NIMTeamCardMemberItem alloc] initWithMember:member
                                                                                       teamType:NIMTeamTypeAdvanced];
                    [weakSelf.readMembers addObject:item];
                }
                else
                {
                    //群成员异常，可能是被踢了
                    NIMTeamCardMemberItem *item = [[NIMTeamCardMemberItem alloc] initWithMember:member
                                                                                       teamType:NIMTeamTypeAdvanced];
                    [weakSelf.readMembers addObject:item];
                }
                
            }
            for (NSString *userId in detail.unreadUserIds)
            {
                NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:userId inTeam:detail.sessionId];
                if (member)
                {
                    NIMTeamCardMemberItem *item = [[NIMTeamCardMemberItem alloc] initWithMember:member
                                                                                       teamType:NIMTeamTypeAdvanced];
                    [weakSelf.unreadMembers addObject:item];
                }
                else
                {
                    NIMTeamCardMemberItem *item = [[NIMTeamCardMemberItem alloc] initWithMember:member
                                                                                       teamType:NIMTeamTypeAdvanced];
                    [weakSelf.unreadMembers addObject:item];
                }
            }
            [weakSelf.readUsers reloadData];
            [weakSelf.unreadUsers reloadData];
            [weakSelf.segmentControl setTitle:[NSString stringWithFormat:@"%@(%zd)",@"未读".ntes_localized, weakSelf.unreadMembers.count] forSegmentAtIndex:0];
            [weakSelf.segmentControl setTitle:[NSString stringWithFormat:@"%@(%zd)",@"已读".ntes_localized,weakSelf.readMembers.count] forSegmentAtIndex:1];
        }
        else
        {
            [weakSelf.view makeToast:@"请求失败请重试".ntes_localized duration:2.0 position:CSToastPositionCenter];
        }
        
    }];
}


- (NSArray *)data:(UICollectionView *)collectionView
{
    if (collectionView == self.readUsers)
    {
        return self.readMembers;
    }
    else
    {
        return self.unreadMembers;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger lastTotal = self.collectionItemNumber * section;
    NSInteger remain    = [self data:collectionView].count - lastTotal;
    return remain < self.collectionItemNumber ? remain:self.collectionItemNumber;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSInteger sections = [self data:collectionView].count / self.collectionItemNumber;
    sections = [self data:collectionView].count % self.collectionItemNumber ? sections + 1 : sections;
    return sections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NIMCardHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionReadCellReuseId forIndexPath:indexPath];
    id<NIMKitCardHeaderData> data = [self dataAtIndexPath:indexPath collectionView:collectionView];
    [cell refreshData:data];
    return cell;
}

- (id<NIMKitCardHeaderData>)dataAtIndexPath:(NSIndexPath*)indexpath collectionView:(UICollectionView *)collectionView
{
    NSInteger index = indexpath.section * self.collectionItemNumber;
    index += indexpath.row;
    return  [[self data:collectionView] objectAtIndex:index];
}

- (NSIndexPath *)indexPathForData:(id<NIMKitCardHeaderData>)data collectionView:(UICollectionView *)collectionView{
    NSInteger index   = [[self data:collectionView] indexOfObject:data];
    NSInteger section = index / self.collectionItemNumber;
    NSInteger row     = index % self.collectionItemNumber;
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(58, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (section == 0) {
        return UIEdgeInsetsMake(25, 0, 0, 0);
    }
    return UIEdgeInsetsMake(15, 0, 0, 0);
}



#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 20;
    [self.readUsers setCollectionViewLayout:flowLayout animated:YES];
    [self.unreadUsers setCollectionViewLayout:flowLayout animated:YES];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
     {
         [self.readUsers reloadData];
         [self.unreadUsers reloadData];
     } completion:nil];
}



#pragma mark - Private

- (NSInteger)collectionItemNumber{
    CGFloat minSpace = 20.f; //防止计算到最后出现左右贴边的情况
    return (int)((self.readUsers.frame.size.width - minSpace)/ (55 + 20));
}

@end
