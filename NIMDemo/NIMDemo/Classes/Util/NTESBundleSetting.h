//
//  NTESBundleSetting.h
//  NIM
//
//  Created by chris on 15/7/1.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
//部分API提供了额外的选项，如删除消息会有是否删除会话的选项,为了测试方便提供配置参数
//上层开发只需要按照策划需求选择一种适合自己项目的选项即可，这个设置只是为了方便测试不同的case下API的正确性

@interface NTESBundleSetting : NSObject

+ (instancetype)sharedConfig;

- (BOOL)removeSessionWhenDeleteMessages;             //删除消息时是否同时删除会话项

- (BOOL)dropTableWhenDeleteMessages;                //删除消息的同时是否删除消息表

- (BOOL)localSearchOrderByTimeDesc;                 //本地搜索消息顺序 YES表示按时间戳逆序搜索,NO表示按照时间戳顺序搜索

- (BOOL)autoRemoveRemoteSession;                    //删除会话时是不是也同时删除服务器会话 (防止漫游)
- (BOOL)autoRemoveAlias;                            //删除好友的同时删除备注

- (BOOL)autoRemoveSnapMessage;                      //阅后即焚消息在看完后是否删除

- (BOOL)needVerifyForFriend;                        //添加好友是否需要验证

- (BOOL)showFps;                                    //是否显示Fps

- (BOOL)disableProximityMonitor;                    //贴耳的时候是否需要自动切换成听筒模式

- (BOOL)enableRotate;                               //支持旋转(仅组件部分，其他部分可能会显示不正常，谨慎开启)

- (BOOL)usingAmr;                                   //使用amr作为录音

- (BOOL)fileQuickTransferEnabled;                   //文件快传开关

- (BOOL)enableAPNsPrefix;                           //推送允许带昵称

- (BOOL)enableTeamAPNsForce;                        //群消息强制推送

- (BOOL)enableAudioSessionReset;                    //允许MediaManager内部重置

- (BOOL)exceptionLogUploadEnabled;                  //允许异常错误码下日志上吧

- (BOOL)enableLocalAnti;                            //本地反垃圾开关

- (BOOL)enableSdkRemoteRender;                      //内部渲染开关

- (NSArray *)ignoreTeamNotificationTypes;           //需要忽略的群通知类型

- (BOOL)enableSyncWhenFetchRemoteMessages;          //拉取云消息时是否需要存储到本地

- (BOOL)enableCreateRecentSessionsWhenSyncRemoteMessages; //同步云消息到本地时是否创建最近会话

- (BOOL)countTeamNotification;                      //是否将群通知计入未读

- (NSInteger)maximumLogDays;                        //日志最大存在天数

- (BOOL)animatedImageThumbnailEnabled;              //支持动图缩略图

#pragma mark - 网络通话和白板
- (BOOL)serverRecordAudio;                          //服务器录制语音

- (BOOL)serverRecordVideo;                          //服务器录制视频

- (BOOL)serverRecordWhiteboardData;                 //服务器录制白板数据

- (BOOL)serverRecordHost;                           //服务端录制主讲人

- (int)serverRecordMode;                           //服务端录制模式

- (BOOL)useSocks;                                  //是否使用socks5代理

- (NSString *)customAPNsType;                       // 自定义推送类型

- (NSUInteger )socks5Type;                          //socks5类型

- (NSString *)socks5Addr;                           //socks5地址

- (NSString *)socksUsername;                       //用户名

- (NSString *)socksPassword;                       //密码

- (BOOL)useRTSSocks;                                  //白板是否使用socks5代理

- (NSUInteger)socks5RTSType;                          //白板socks5类型

- (NSString *)socks5RTSAddr;                           //白板socks5地址

- (NSString *)socksRTSUsername;                       //白板用户名

- (NSString *)socksRTSPassword;                       //白板密码

- (BOOL)videochatAutoRotateRemoteVideo;             //自动旋转视频聊天远端画面

- (UIViewContentMode)videochatRemoteVideoContentMode; //对端画面的填充模式

- (BOOL)startWithBackCamera;                        //使用后置摄像头开始视频通话

- (NSUInteger)videoMaxEncodeKbps;                   //最大发送视频编码码率

- (NSUInteger)localRecordVideoKbps;                 //本地录制视频码率

- (NSUInteger)localRecordVideoQuality;              //本地录制视频分辨率

- (BOOL)autoDeactivateAudioSession;                 //自动结束AudioSession

- (BOOL)audioDenoise;                               //降噪开关

- (BOOL)voiceDetect;                                //语音检测开关

- (BOOL)preferHDAudio;                              //期望高清语音

- (NSInteger)chatroomRetryCount;                    //进聊天室重试次数

- (BOOL)fileDownloadTokenEnabled;                   //文件下载权限控制

- (BOOL)autoFetchAttachment;                        //自动下载附件。（接收消息，刷新消息，自动拿历史消息时）

- (NIMAsymEncryptionType)AsymEncryptionType;     //非对称加密类型

- (NIMRSAPaddingMode)rsaPaddingMode;         // RSA Padding算法

- (NIMSymEncryptionType)SymEncryptionType;     //非对称加密类型

- (NIMLinkAddressType)LbsLinkAddressType; //lbs返回的link地址类型

- (NSString *)ipv4DefaultLink; // IPv4默认Link地址

- (NSString *)ipv6DefaultLink;  // IPv6默认Link地址

- (BOOL)asyncLoadRecentSessionEnabled; //是否开启异步读取最近会话

- (NSInteger)ignoreMessageType;

- (BOOL)isDeleteMsgFromServer;

- (BOOL)isIgnoreRevokeMessageCount;

- (BOOL)enablePullSubMessagesFromServer;

- (BOOL)enableSyncStickTopSessionInfos;

- (NSInteger)customClientType;

- (BOOL)isDeleteMsgFromDB;

- (BOOL)enableRevokeMsgPostscript;

- (NSString *)messageEnv;  //环境变量，用于指向不同的抄送、第三方回调等配置

@end
