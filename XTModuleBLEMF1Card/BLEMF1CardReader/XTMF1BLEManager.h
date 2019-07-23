//
//  XTMF1BLEManager.h
//  XTBLEMF1Demo
//
//  Created by apple on 2019/5/30.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mPayBleLib.h"
#import "XTMF1CBPeripheral.h"


typedef NS_ENUM(NSUInteger, XTBLEMF1NSErrorCode) {
    XTBLEMF1NSErrorCodeBLENotEnable = 1000,    //蓝牙不可用
    XTBLEMF1NSErrorCodeScanCanceled = 1001,    //扫描被取消
    XTBLEMF1NSErrorCodeNotDevice = 1003,       //未选择设备
    XTBLEMF1NSErrorCodeConnectFailed = 1004,   //连接失败
    XTBLEMF1NSErrorCodeConnectTimeOut = 1005,  //连接超时
    XTBLEMF1NSErrorCodeConnectCanceled = 1006, //连接被取消
    XTBLEMF1NSErrorCodeNotConnect= 1007,       //未连接设备
    XTBLEMF1NSErrorCodeSendFailed = 1008,      //发送失败
    XTBLEMF1NSErrorCodeReceiveFailed = 1009,   //接收失败
    XTBLEMF1NSErrorCodeReceiveTimeOut = 1010,  //接收超时
    XTBLEMF1NSErrorCodeReceiveCanceled = 1011, //接收被取消
    XTBLEMF1NSErrorCodeAutoCancelLastTimerTask = 1012,  //自动取消上个TIMER任务
};

typedef void(^MF1ScanBlock)(NSArray *bleDevices);
typedef void(^MF1ScanFinishBlock)(NSError *error);
typedef void(^MF1CentralManagerDidUpdateState)(int iStateCode);
typedef void(^MF1ConnectSuccessBlock)(void);
typedef void(^MF1ConnectFailureBlock)(NSError *error);
typedef void(^MF1ConnectStateDidChangeBlock)(XTMF1CBPeripheralConnectState state);
typedef void(^MF1ReceiveDataSuccessBlock)(id item);
typedef void(^MF1ReceiveDataFailureBlock)(NSError *error);

@interface XTMF1BLEManager : NSObject

@property (nonatomic, strong) CBCentralManager *centralManager; //蓝牙管理
@property (nonatomic, assign, readonly) BOOL isBLEEnable;       //蓝牙是否可用
@property (nonatomic, assign, readonly) BOOL isScanning;        //是否正在扫描
@property (nonatomic, assign, readonly) BOOL isRequesting;      //是否正在请求帧数据
@property (nonatomic, strong, readonly) XTMF1CBPeripheral *currentPeripheral;      //当前的蓝牙设备

+ (id)sharedManager;

/**
 扫描蓝牙
 
 @param time 扫描时间 默认15秒
 @param scanBlock 返回扫描到的设备列表
 @param finishBlock 扫描结束
 */
- (void)scanWithTime:(float)time scanBlock:(MF1ScanBlock)scanBlock finishBlock:(MF1ScanFinishBlock)finishBlock;

/**
 连接蓝牙设备
 
 @param peripheral 蓝牙设备
 @param success 成功
 @param failure 失败
 */
- (void)connectWithPeripheral:(XTMF1CBPeripheral *)peripheral success:(MF1ConnectSuccessBlock)success failure:(MF1ConnectFailureBlock)failure;

/**
 读取蓝牙读卡器电压
 
 @param success 成功
 @param failure 失败
 */
- (void)readVoltageSuccess:(void(^)(CGFloat volgateValue))success failure:(void(^)(NSError *error))failure;

/**
 上电
 
 @param success 成功
 @param failure 失败
 */
- (void)activateCardSuccess:(void(^)(NSString *serialNumber))success failure:(void(^)(NSError *error))failure;

/**
 下电
 
 @param success 成功
 @param failure 失败
 */
- (void)deactiveCardSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;

/**
 认证
 
 @param keyType 类型
 @param sector 扇区
 @param auth 秘钥
 @param success 成功
 @param failure 失败
 */
- (void)authCardWithKeyType:(NSString *)keyType sector:(int)sector auth:(NSString *)auth success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

/**
 读卡
 
 @param sector 扇区
 @param rock 块
 @param success 成功
 @param failure 失败
 */
- (void)readCardWithSector:(int)sector rock:(int)rock success:(void(^)(NSString *data))success failure:(void(^)(NSError *error))failure;

/**
 写卡
 
 @param hex 写入的hex字符串
 @param sector 扇区
 @param rock 块
 @param success 成功
 @param failure 失败
 */
- (void)writeCardWithHex:(NSString *)hex sector:(int)sector rock:(int)rock success:(void(^)(void))success failure:(void(^)(NSError *error))failure;


/**
 取消扫描蓝牙设备
 */
- (void)cancelScan;

/**
 取消蓝牙连接
 */
- (void)cancelConnect;

/**
 取消接收数据
 */
- (void)cancelReceiveData;

/**
 取消接收数据
 
 @param error 错误
 */
- (void)cancelReceiveData:(NSError *)error;

/**
 关闭Manager
 */
- (void)doClose;

/**
 蓝牙连接状态变化(连接/断开)监听
 
 @param MF1ConnectStateDidChangeBlock 回调
 */
- (void)setBlockOnConnectStateDidChange:(MF1ConnectStateDidChangeBlock)MF1ConnectStateDidChangeBlock;

/**
 设备状态改变的委托
 
 @param block 状态改变 回调
 */
- (void)setBlockOnMF1CentralManagerDidUpdateState:(MF1CentralManagerDidUpdateState)block;

/**
 保存蓝牙设备
 
 @param xtPeripheral 蓝牙设备
 */
- (void)saveXTPeripheral:(XTMF1CBPeripheral *)xtPeripheral;

/**
 移除已保存的蓝牙设备
 
 @param xtPeripheral 蓝牙设备
 */
- (void)removeSavedXTPeripheral:(XTMF1CBPeripheral *)xtPeripheral;

/**
 获取已保存的蓝牙设备
 
 @return 蓝牙设备列表
 */
- (NSArray *)getSavedXTPeripherals;

@end

