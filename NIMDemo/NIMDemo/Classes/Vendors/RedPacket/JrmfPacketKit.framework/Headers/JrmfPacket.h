//
//  JrmfPacket.h
//  JrmfPacketKit
//
//  Created by 一路财富 on 16/8/24.
//  Copyright © 2016年 JYang. All rights reserved.
//

//  注：IM红包类方法

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JrmfGetCustomerInfo.h"

typedef NS_ENUM(NSUInteger, JRMFPacketStatusType) {
    JRMFPacketCanGet = 0,   /**< 可领取 */
    JRMFPacketIsGet,        /**< 已领取 */
    JRMFPacketIsDue,        /**< 红包失效 */
    JRMFPacketIsNull,       /**< 手慢了，红包被抢完了 */
    JRMFPacketIsCommon,     /**< 普通红包，自己不可抢 */
    JRMFPacketUn,           /**< 未知，获取红包信息失败 */
};

typedef enum jrmfSendStatus {
    kjrmfStatCancel = 0,     // 取消发送，用户行为
    kjrmfStatSucess = 1,     // 红包发送成功
    kjrmfStatUnknow,         // 其他
}jrmfSendStatus;

typedef enum jrmfTransferStatus {
    kjrmfTrfStatusGet = 1,         // 已领取
    kjrmfTrfStatusReturn = 2,      // 退还
}jrmfTransferStatus;

typedef NS_ENUM(NSUInteger, JrmfRedPacketType) {
    RedPacketTypeSingle = 1,/**< 单人红包 */
    RedPacketTypeGroupPin,/**< 群拼手气 */
    RedPacketTypeGroupNormal,/**< 群普通 */
};

UIKIT_EXTERN NSString * const kJrmfPacketShow;/**< 界面出现 */
UIKIT_EXTERN NSString * const kJrmfPacketHide;/**< 界面消失 */

@protocol jrmfManagerDelegate <NSObject>

/**
 *  红包发送回调
 *
 *  @param envId    红包ID
 *  @param envName  红包名称
 *  @param envMsg   描述信息
 *  @param jrmfStat 发送状态
 */
- (void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat;

/**
 *  红包发送回调
 *
 *  @param envId    红包ID
 *  @param envName  红包名称
 *  @param envMsg   描述信息
 *  @param jrmfStat 发送状态
 *  @param type     红包类型
 */
- (void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat packType:(JrmfRedPacketType)type;

@optional

/**
 红包类型回调
 
 @param type 红包类型，详见 JRMFPacketStatusType 调拆包的时候才有此回调
 */
- (void)dojrmfActionGetPacketStatus:(JRMFPacketStatusType)type;

/**
 *  成功领取了一个红包回调
 *
 *  @param isDone 是否为最后一个红包；YES：领取的为最后一个红包；NO：红包未被领取完成
 *
 *  @discussion     此函数调用时，一定是成功领取了一个红包；只有红包个数>=2的时候，isDone才有效，群红包个数为1个时，默认为NO
 */
- (void)dojrmfActionOpenPacketSuccessWithGetDone:(BOOL)isDone;


/**
 成功领取一个红包的回调

 @param hasLeft     剩余红包个数
 @param total       红包总个数
 @param totalMoney  红包总钱数
 @param grabMoney   领取了多少钱
 */
- (void)dojrmfActionOpenPacketSuccessWith:(NSInteger)hasLeft total:(NSInteger)total totalMoney:(NSString *)totalMoney grabMoney:(NSString *)grabMoney;


@end

@protocol jrmfManagerTrfDelegate <NSObject>

/**
 转账成功回调代理
 
 @param receiveUid  接收者ID
 @param msg         转账描述
 @param transferId  转账单号
 @param amountStr   转账金额
 */
- (void)dojrmfTransferAccountsWithReceivedUserID:(NSString *)receiveUid Message:(NSString *)msg transferOrder:(NSString *)transferId Amount:(NSString *)amountStr;


/**
 转账处理回调
 
 @param transferOrder   转账单号
 @param transferStat    处理状态【接收|退还】
 @param amountStr       转账金额
 
 @discussion            若回调此方法，则定为处理了转账信息
 */
- (void)dojrmfTransferReceiptStatuaWithTransferOrder:(NSString *)transferOrder TransferOperateStatus:(jrmfTransferStatus)transferStat Amount:(NSString *)amountStr;

@end

@interface JrmfPacket : NSObject

@property (nonatomic, assign) id <jrmfManagerDelegate> delegate;
@property (nonatomic, assign) id <jrmfManagerTrfDelegate> trfDelegate;

/**
 *  发红包/钱包 页面标题字号 Default:18.f
 */
@property (nonatomic, assign) float titleFont;

/**
 *  发红包/钱包 页面'标题栏'颜色 支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 */
@property (nonatomic, strong) NSString * packetRGB;

/**
 *  发红包/钱包 页面'标题'颜色 支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 */
@property (nonatomic, strong) NSString * titleColorRGB;

/**
 JrmfSDK 注册方法

 @param partnerId            渠道名称（我们公司分配给你们的渠道字符串）
 @param envName              红包名称
 @param aliPaySchemeUrl      支付宝回调Scheme【保证格式的正确性】
 @param weChatSchemeUrl      微信回调Scheme
 @param isOnLine             是否正式环境 YES：正式环境    NO：测试环境
 */
+ (void)instanceJrmfPacketWithPartnerId:(NSString *)partnerId EnvelopeName:(NSString *)envName aliPaySchemeUrl:(NSString *)aliPayscheme weChatSchemeUrl:(NSString *)weChatScheme appMothod:(BOOL)isOnLine;

/**
 JrmfSDK 注册方法 dynamicToken+classname
 
 @param partnerId            渠道名称（我们公司分配给你们的渠道字符串）
 @param envName              红包名称
 @param aliPaySchemeUrl      支付宝回调Scheme【保证格式的正确性】
 @param weChatSchemeUrl      微信回调Scheme
 @param className            外部获取用户信息的类 需遵循 JrmfGetCustomerInfo 协议
 @param isOnLine             是否正式环境 YES：正式环境    NO：测试环境
 */
+ (void)instanceJrmfPacketWithPartnerId:(NSString *)partnerId EnvelopeName:(NSString *)envName aliPaySchemeUrl:(NSString *)aliPayscheme weChatSchemeUrl:(NSString *)weChatScheme customerClass:(NSString *)className dynamicToken:(BOOL)dynamicToken appMothod:(BOOL)isOnLine;

/**
 *  用户信息更新
 *
 *  aram userId             用户ID（app用户的唯一标识）
 *  @param userName         用户昵称
 *  @param userHeadLink     用户头像
 *  @param thirdToken       三方签名令牌
 *  @param completionAction 回调函数
 *
 *  @discussion      A.用户昵称、头像可单独更新，非更新是传nil即可，但不可两者同时为nil；三方签名令牌（服务端计算后给到app，服务端算法为md5（custUid+appsecret））
 *                   B.头像的URL连接字符不要过长，不超过256个字符为宜。（所有头像链接都需要限制）【注:外网可访问】【下同】
 */
+ (void)updateUserMsgWithUserId:(NSString *)userId userName:(NSString *)userName userHead:(NSString *)userHeadLink thirdToken:(NSString *)thirdToken completion:(void (^)(NSError *error, NSDictionary *resultDic))completionAction;

/**
 *  发红包
 *
 *  @param viewController 当前视图
 *  @param thirdToken     三方签名令牌
 *  @param isGroup        是否为群组红包
 *  @param receiveID      接受者ID（单人红包：接受者用户唯一标识；群红包：群组ID，唯一标识）
 *  @param userName       发送者昵称
 *  @param userHeadLink   发送者头像链接
 *  @param userId         发送者ID
 *  @param groupNum       群人数(个人红包可不传)
 *
 *  @discussion      三方签名令牌（服务端计算后给到app，服务端算法为md5（custUid+appsecret））
 */
- (void)doActionPresentSendRedEnvelopeViewController:(UIViewController *)viewController thirdToken:(NSString *)thirdToken withGroup:(BOOL)isGroup receiveID:(NSString *)receiveID sendUserName:(NSString *)userName sendUserHead:(NSString *)userHeadLink sendUserID:(NSString *)userId groupNumber:(NSString *)groupNum;

/**
 *  拆红包
 *
 *  @param viewController   当前视图
 *  @param thirdToken       三方签名令牌
 *  @param userName         当前操作用户姓名
 *  @param userHeadLink     头像链接
 *  @param userId           当前操作用户ID
 *  @param envelopeId       红包ID
 *  @param isGroup          是否为群组红包 
 *
 *  @discussion      三方签名令牌（服务端计算后给到app，服务端算法为md5（custUid+appsecret））
 */
- (void)doActionPresentOpenViewController:(UIViewController *)viewController thirdToken:(NSString *)thirdToken withUserName:(NSString *)userName userHead:(NSString *)userHeadLink userID:(NSString *)userId envelopeID:(NSString *)envelopeId isGroup:(BOOL)isGroup;

/**
 查看红包领取详情

 @param userId          用户ID
 @param packetId        红包ID
 @param thirdToken      三方签名令牌
 */
- (void)doActionPresentPacketDetailInViewWithUserID:(NSString *)userId packetID:(NSString *)packetId thirdToken:(NSString *)thirdToken;

/**
 查看收支明细

 @param userId          用户ID
 @param thirdToken      三方签名令牌
 */
- (void)doActionPresentPacketListInViewWithUserID:(NSString *)userId thirdToken:(NSString *)thirdToken;

/**
 发起转账
 
 @param viewController      基础VC
 @param thirdToken          三方签名令牌
 @param receiveId           接收者ID
 @param receiveName         接收者昵称
 @param receiveHeadLink     接收者头像链接
 @param userName            当前用户昵称
 @param userHeadLink        当前用户头像链接
 @param userId              当前用户ID
 */
- (void)doActionPresentTransferWithBaseViewController:(UIViewController *)viewController thirdToken:(NSString *)thirdToken receiveUserID:(NSString *)receiveId receiveUserName:(NSString *)receiveName receiveUserHead:(NSString *)receiveHeadLink sendUserName:(NSString *)userName sendUserHead:(NSString *)userHeadLink sendUserID:(NSString *)userId;

/**
 根据转账单号获取转账详情
 
 @param baseController  基础VC
 @param thirdToken      三方签名令牌
 @param transferOrder   转账单号
 @param cusUid          当前用户ID
 */
- (void)doPresentTransferAccountsDetailWithBaseViewController:(UIViewController *)baseController thirdToken:(NSString *)thirdToken TransferOrder:(NSString *)transferOrder OperateUserId:(NSString *)cusUid;


/**
 *  支付宝支付完成时，回调函数
 */
+ (void)doActionAlipayDone;


/**
 销毁扩展模块
 */
+ (void)destroyPacketModule;

/**
 环境配置

 @param isOnLine 环境      NO：测试；YES：正式
 
 @discussion     方法已废除废除；通过instanceJrmfPacket方法进行设置
 */
+ (void)setAppMethodOnLine:(BOOL)isOnLine __deprecated_msg("Use 'instance' func.");

/**
 *  版本号
 *
 *  @return 获取当前版本
 */
+ (NSString *)getCurrentVersion;


@end
