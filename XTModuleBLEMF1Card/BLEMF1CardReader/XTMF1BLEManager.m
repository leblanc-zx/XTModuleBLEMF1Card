//
//  XTMF1BLEManager.m
//  XTBLEMF1Demo
//
//  Created by apple on 2019/5/30.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import "XTMF1BLEManager.h"
#import "XTUtils.h"
#import "CBCentralManager+XT.h"
#import "BleComm.h"

typedef NS_ENUM(NSUInteger, TimerState) {
    TimerStateFinish = 0,   //正常结束
    TimerStateCancel = 1,   //被取消
};

typedef void(^TimerBlock)(TimerState state, NSError *error);

NSString *const TIMER_SCAN = @"TIMER_SCAN";
NSString *const TIMER_CONNECT = @"TIMER_CONNECT";
NSString *const TIMER_RECEIVE_DATA = @"TIMER_RECEIVE_DATA";
NSString *const SCAN_BLOCK = @"SCAN_BLOCK";
NSString *const SCAN_FINISHBLOCK = @"SCAN_FINISHBLOCK";
NSString *const CONNECT_SUCCESSBLOCK = @"CONNECT_SUCCESSBLOCK";
NSString *const CONNECT_FAILUREBLOCK = @"CONNECT_FAILUREBLOCK";
NSString *const CENTRALMANAGER_DIDUPDATESTATE_BLOCK = @"CENTRALMANAGER_DIDUPDATESTATE_BLOCK";
NSString *const CONNECTSTATE_DIDCHANGE_BLOCK = @"CONNECTSTATE_DIDCHANGE_BLOCK";
NSString *const SEND_RECEIVEDATASUCCESS_BLOCK = @"SEND_RECEIVEDATASUCCESS_BLOCK";
NSString *const SEND_RECEIVEDATAFAILURE_BLOCK = @"SEND_RECEIVEDATAFAILURE_BLOCK";

@interface XTMF1BLEManager ()<BleCommDelegate, MPayBleLibDelegate>

@property (nonatomic, strong) MPayBleLib *bleLib;
/*----Timer----*/
@property (nonatomic, strong) NSMutableDictionary *timerDictionary;
/*----BlockDic----*/
@property (nonatomic, strong) NSMutableDictionary *blockDictionary;
/*----Scan----*/
@property (nonatomic, strong) NSMutableArray *BLEDevices;
/*----connect----*/
@property (nonatomic, strong) XTMF1CBPeripheral *currentPeripheral;    //当前的蓝牙设备

@property (nonatomic, assign) BOOL isBLEEnable;     //蓝牙是否可用

@property (nonatomic, strong) id responseItem;      //接收的数据

@end

@implementation XTMF1BLEManager
static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
            [self createManager];
        }
    });
    self = obj;
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

- (void)createManager {
    //蓝牙管理创建监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XTCentralManagerInit:) name:XTCBCentralManagerInitKey object:nil];
    self.bleLib = [[MPayBleLib alloc] init];
    self.bleLib.delegate = self;
    //蓝牙连接状态变化监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XTMF1CBPeripheralConnectStateChange:) name:XTMF1CBPeripheralConnectStateChangeKey object:nil];
    
}

/**
 是否正在扫描
 
 @return 结果
 */
- (BOOL)isScanning {
    
    dispatch_source_t timer = [self getTimerWithIdentity:TIMER_SCAN];
    return timer ? YES : NO;
    
}

/**
 是否正在请求帧数据
 
 @return 结果
 */
- (BOOL)isRequesting {
    
    dispatch_source_t timer = [self getTimerWithIdentity:TIMER_RECEIVE_DATA];
    return timer ? YES : NO;
    
}

/**
 扫描蓝牙
 
 @param time 扫描时间 默认15秒
 @param scanBlock 返回扫描到的设备列表
 @param finishBlock 扫描结束
 */
- (void)scanWithTime:(float)time scanBlock:(MF1ScanBlock)scanBlock finishBlock:(MF1ScanFinishBlock)finishBlock {
   
    if (!self.isBLEEnable) {
        if (finishBlock) {
            finishBlock([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeBLENotEnable userInfo:@{@"NSLocalizedDescription":@"请打开蓝牙"}]);
        }
        return;
    }
    //正在扫描
    if (self.isScanning) {
        return;
    }
    
    //预备扫描
    if (scanBlock) {
        [self.blockDictionary setObject:scanBlock forKey:SCAN_BLOCK];
    }
    if (finishBlock) {
        [self.blockDictionary setObject:finishBlock forKey:SCAN_FINISHBLOCK];
    }
    float scanTime = time > 0 ? time : 15;
    [self.BLEDevices removeAllObjects];
    
    //开始扫描
     [self.bleLib mPayBle_SearchDevice];
    
    //开启定时器
    __weak typeof(self) weakSelf = self;
    [self openTimerWithIdentity:TIMER_SCAN timeDuration:scanTime block:^(TimerState state, NSError *error) {
        
        MF1ScanFinishBlock cahcheFinishBlock = [self.blockDictionary objectForKey:SCAN_FINISHBLOCK];
        [self.blockDictionary removeObjectForKey:SCAN_BLOCK];
        
        if (state == TimerStateFinish) {
            //timer时间到了,扫描结束
            [weakSelf.bleLib mPayBle_StopSearching];
            if (cahcheFinishBlock) {
                [self.blockDictionary removeObjectForKey:SCAN_FINISHBLOCK];
                cahcheFinishBlock(nil);
            }
        } else if (state == TimerStateCancel) {
            //timer被取消
            if (error.code == XTBLEMF1NSErrorCodeAutoCancelLastTimerTask) {
                //自动移除上次任务 do nothing
            } else {
                //扫描被取消了
                [weakSelf.bleLib mPayBle_StopSearching];
                if (cahcheFinishBlock) {
                    [self.blockDictionary removeObjectForKey:SCAN_FINISHBLOCK];
                    cahcheFinishBlock(error);
                }
            }
        }
        
    }];
    
    
}

/**
 连接蓝牙设备
 
 @param peripheral 蓝牙设备
 @param success 成功
 @param failure 失败
 */
- (void)connectWithPeripheral:(XTMF1CBPeripheral *)peripheral success:(MF1ConnectSuccessBlock)success failure:(MF1ConnectFailureBlock)failure {

    if (!self.isBLEEnable) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeBLENotEnable userInfo:@{NSLocalizedDescriptionKey:@"请打开蓝牙"}]);
        }
        return;
    }

    //正在连接中,稍后再试
    if (self.currentPeripheral.peripheral && self.currentPeripheral.connectState == XTMF1CBPeripheralConnecting) {
        if (failure) {
            NSString *msg = [NSString stringWithFormat:@"正在连接%@,请稍后再试",self.bleLib.savePeripheral.name];
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectFailed userInfo:@{NSLocalizedDescriptionKey:msg}]);
        }
        return;
    }

    if (!peripheral) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeNotDevice userInfo:@{NSLocalizedDescriptionKey:@"请选择要连接的蓝牙设备"}]);
        }
        return;
    }

    if ([peripheral.peripheral.identifier.UUIDString isEqualToString:self.currentPeripheral.peripheral.identifier.UUIDString] && self.currentPeripheral.connectState == XTMF1CBPeripheralConnectSuccess) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectFailed userInfo:@{NSLocalizedDescriptionKey:@"已连接该蓝牙设备"}]);
        }
        return;
    }

    //预备连接
    XTMF1CBPeripheral *lastPeripheral = self.currentPeripheral;
    if (success) {
        [self.blockDictionary setObject:success forKey:CONNECT_SUCCESSBLOCK];
    }
    if (failure) {
        [self.blockDictionary setObject:failure forKey:CONNECT_FAILUREBLOCK];
    }

    self.currentPeripheral = peripheral;
    
    //自动断开上个连接
    if (lastPeripheral) {
        [self.bleLib mPayBle_DisconnectDevice];
    }

    //开始连接
    self.currentPeripheral.connectState = XTMF1CBPeripheralConnecting;
    [self.bleLib mPayBle_ConnectDevice:peripheral.peripheral];
    
    //开启定时器
    __weak typeof(self) weakSelf = self;
    [self openTimerWithIdentity:TIMER_CONNECT timeDuration:15 block:^(TimerState state, NSError *error) {
        if (state == TimerStateFinish) {
            //timer时间到了，连接超时
            weakSelf.currentPeripheral.connectState = XTMF1CBPeripheralConnectTimeOut;
            //[weakSelf.bleLib mPayBle_DisconnectDevice];
            
            [weakSelf.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
            [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
            MF1ConnectFailureBlock cacheFailureBlock = [self.blockDictionary objectForKey:CONNECT_FAILUREBLOCK];
            if (cacheFailureBlock) {
                [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                cacheFailureBlock([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectTimeOut userInfo:@{NSLocalizedDescriptionKey:@"连接超时"}]);
            }
            
        } else if (state == TimerStateCancel) {
            //timer被取消
            if (error.code == XTBLEMF1NSErrorCodeAutoCancelLastTimerTask) {
                //自动移除上次任务 do nothing
            } else if (weakSelf.currentPeripheral.connectState == XTMF1CBPeripheralNotConnected) {
                //未连接
                //[weakSelf.bleLib mPayBle_DisconnectDevice];
               
                [weakSelf.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
                [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
                MF1ConnectFailureBlock cacheFailureBlock = [self.blockDictionary objectForKey:CONNECT_FAILUREBLOCK];
                if (cacheFailureBlock) {
                    [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                    cacheFailureBlock([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectFailed userInfo:@{NSLocalizedDescriptionKey: @"代码异常"}]);
                }
            } else if (weakSelf.currentPeripheral.connectState == XTMF1CBPeripheralConnecting) {
                //连接中
                //[weakSelf.bleLib mPayBle_DisconnectDevice];
                
                [weakSelf.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
                [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
                MF1ConnectFailureBlock cacheFailureBlock = [self.blockDictionary objectForKey:CONNECT_FAILUREBLOCK];
                if (cacheFailureBlock) {
                    [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                    cacheFailureBlock([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectFailed userInfo:@{NSLocalizedDescriptionKey: @"代码异常"}]);
                }
            } else if (weakSelf.currentPeripheral.connectState == XTMF1CBPeripheralConnectingCanceled) {
                //连接中被取消
                //[weakSelf.bleLib mPayBle_DisconnectDevice];
                
                [weakSelf.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
                [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
                MF1ConnectFailureBlock cacheFailureBlock = [self.blockDictionary objectForKey:CONNECT_FAILUREBLOCK];
                if (cacheFailureBlock) {
                    [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                    cacheFailureBlock(error);
                }
            } else if (weakSelf.currentPeripheral.connectState == XTMF1CBPeripheralConnectFailed) {
                //连接失败
                //[weakSelf.bleLib mPayBle_DisconnectDevice];
                
                [weakSelf.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
                [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
                MF1ConnectFailureBlock cacheFailureBlock = [self.blockDictionary objectForKey:CONNECT_FAILUREBLOCK];
                if (cacheFailureBlock) {
                    [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                    cacheFailureBlock(error);
                }
            } else if (weakSelf.currentPeripheral.connectState == XTMF1CBPeripheralConnectSuccess) {
                //连接成功了
                [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                MF1ConnectSuccessBlock cahceSuccessBlock = [self.blockDictionary objectForKey:CONNECT_SUCCESSBLOCK];
                if (cahceSuccessBlock) {
                    [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
                    cahceSuccessBlock();
                }
            } else if (weakSelf.currentPeripheral.connectState == XTMF1CBPeripheralDidDisconnect) {
                //连接成功后,断开连接
                //[weakSelf.bleLib mPayBle_DisconnectDevice];
                
                [weakSelf.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
                [self.blockDictionary removeObjectForKey:CONNECT_SUCCESSBLOCK];
                MF1ConnectFailureBlock cacheFailureBlock = [self.blockDictionary objectForKey:CONNECT_FAILUREBLOCK];
                if (cacheFailureBlock) {
                    [self.blockDictionary removeObjectForKey:CONNECT_FAILUREBLOCK];
                    cacheFailureBlock(error);
                }
            }
        }
    }];

}

- (void)sendDataSuccess:(MF1ReceiveDataSuccessBlock)success failure:(MF1ReceiveDataFailureBlock)failure {
    
    if (!self.isBLEEnable) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeBLENotEnable userInfo:@{NSLocalizedDescriptionKey:@"请打开蓝牙"}]);
        }
        return;
    }
    
    if (self.currentPeripheral.peripheral.state != CBPeripheralStateConnected) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeNotConnect userInfo:@{NSLocalizedDescriptionKey: @"请先连接蓝牙"}]);
        }
        return;
    }
    
    self.responseItem = nil;
    
    [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATASUCCESS_BLOCK];
    [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATAFAILURE_BLOCK];
    if (success) {
        [self.blockDictionary setObject:success forKey:SEND_RECEIVEDATASUCCESS_BLOCK];
    }
    if (failure) {
        [self.blockDictionary setObject:failure forKey:SEND_RECEIVEDATAFAILURE_BLOCK];
    }
    
    //开启定时器
    __weak typeof(self) weakSelf = self;
    [self openTimerWithIdentity:TIMER_RECEIVE_DATA timeDuration:15 block:^(TimerState state, NSError *error) {
        
        if (state == TimerStateFinish) {
            //timer正常结束，超时了
            [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATASUCCESS_BLOCK];
            MF1ReceiveDataFailureBlock cacheReceiveDataFailure = [self.blockDictionary objectForKey:SEND_RECEIVEDATAFAILURE_BLOCK];
            if (cacheReceiveDataFailure) {
                [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATAFAILURE_BLOCK];
                cacheReceiveDataFailure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveTimeOut userInfo:@{NSLocalizedDescriptionKey: @"请求超时"}]);
            }
        }
        if (state == TimerStateCancel) {
            //timer被取消了
            if (error.code == XTBLEMF1NSErrorCodeAutoCancelLastTimerTask) {
                //自动移除上次任务 do nothing
            } else if (error) {
                //数据接收异常 || 数据接收被取消
                [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATASUCCESS_BLOCK];
                MF1ReceiveDataFailureBlock cacheReceiveDataFailure = [self.blockDictionary objectForKey:SEND_RECEIVEDATAFAILURE_BLOCK];
                if (cacheReceiveDataFailure) {
                    [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATAFAILURE_BLOCK];
                    cacheReceiveDataFailure(error);
                }
            } else {
                //接收数据完成
                [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATAFAILURE_BLOCK];
                MF1ReceiveDataSuccessBlock cacheReceiveDataSuccess = [self.blockDictionary objectForKey:SEND_RECEIVEDATASUCCESS_BLOCK];
                if (cacheReceiveDataSuccess) {
                    [self.blockDictionary removeObjectForKey:SEND_RECEIVEDATASUCCESS_BLOCK];
                    cacheReceiveDataSuccess(weakSelf.responseItem);
                }
            }
        }
        
    }];
}

/**
 读取蓝牙读卡器电压
 
 @param success 成功
 @param failure 失败
 */
- (void)readVoltageSuccess:(void(^)(CGFloat volgateValue))success failure:(void(^)(NSError *error))failure {
    
    [self sendDataSuccess:^(id  _Nonnull item) {
        if (success) {
            success([item floatValue]);
        }
    } failure:failure];
    BOOL result = [self.bleLib mPayBle_GetBattery];
    
    if (!result) {
        [self onMPayBleResponse_PiccActivation:NO SerialNumber:nil];
    }
    
}

/**
 上电
 
 @param success 成功
 @param failure 失败
 */
- (void)activateCardSuccess:(void(^)(NSString *serialNumber))success failure:(void(^)(NSError *error))failure {
    
    [self sendDataSuccess:^(id  _Nonnull item) {
        if (success) {
            success(item);
        }
    } failure:failure];
    
    BOOL result = [self.bleLib mPayBle_RfActivateCard];
    
    if (!result) {
        [self onMPayBleResponse_PiccActivation:NO SerialNumber:nil];
    }
    
}

/**
 下电
 
 @param success 成功
 @param failure 失败
 */
- (void)deactiveCardSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    [self sendDataSuccess:^(id  _Nonnull item) {
        if (success) {
            success();
        }
    } failure:failure];
    
    BOOL result = [self.bleLib mPayBle_RfDeactivateCard];
    
    if (!result) {
        [self onMPayBleResponse_PiccDeactivation:NO];
    }
}

/**
 认证

 @param keyType 类型
 @param sector 扇区
 @param auth 秘钥
 @param success 成功
 @param failure 失败
 */
- (void)authCardWithKeyType:(NSString *)keyType sector:(int)sector auth:(NSString *)auth success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    int cardType = 0;
    if ([[keyType uppercaseString] isEqualToString:@"A"]) {
        cardType = 65;
    } else if ([[keyType uppercaseString] isEqualToString:@"B"]) {
        cardType = 66;
    } else {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey:@"类型输入错误,请输入'A'或'B'"}]);
        }
        return;
    }
    
    [self sendDataSuccess:^(id  _Nonnull item) {
        if (success) {
            success();
        }
    } failure:failure];
    
    NSString *hexKeyType = [XTUtils hexStringWithData:[XTUtils dataWithLong:cardType length:1]];
    NSString *hexSector = [XTUtils hexStringWithData:[XTUtils dataWithLong:sector length:1]];
    BOOL result = [self.bleLib mPayBle_RfMifareAuthCard:hexKeyType sData:hexSector sData:auth];
    
    if (!result) {
        [self onMPayBleResponse_MifareAuth:NO];
    }
    
}

/**
 读卡

 @param sector 扇区
 @param rock 块
 @param success 成功
 @param failure 失败
 */
- (void)readCardWithSector:(int)sector rock:(int)rock success:(void(^)(NSString *data))success failure:(void(^)(NSError *error))failure {
    
    [self sendDataSuccess:^(id  _Nonnull item) {
        if (success) {
            success(item);
        }
    } failure:failure];
    
    NSString *hexBlock = [XTUtils hexStringWithData:[XTUtils dataWithLong:(sector*4 + rock) length:1]];
    BOOL result = [self.bleLib mPayBle_RfMifareReadBlock:hexBlock];
    
    if (!result) {
        [self onMPayBleResponse_MifareReadBlock:NO sData:nil];
    }
}

/**
 写卡

 @param hex 写入的hex字符串
 @param sector 扇区
 @param rock 块
 @param success 成功
 @param failure 失败
 */
- (void)writeCardWithHex:(NSString *)hex sector:(int)sector rock:(int)rock success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    [self sendDataSuccess:^(id  _Nonnull item) {
        if (success) {
            success();
        }
    } failure:failure];
    
    NSString *hexBlock = [XTUtils hexStringWithData:[XTUtils dataWithLong:(sector*4 + rock) length:1]];
    BOOL result = [self.bleLib mPayBle_RfMifareWriteBlock:hexBlock sData:hex];
    
    if (!result) {
        [self onMPayBleResponse_MifareWriteBlock:NO];
    }
    
}

/**
 取消扫描蓝牙设备
 */
- (void)cancelScan {
    [self cancelTimerWithIdentity:TIMER_SCAN error:[NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeScanCanceled userInfo:@{NSLocalizedDescriptionKey: @"扫描被取消"}]];
}

/**
 取消蓝牙连接
 */
- (void)cancelConnect {
    
    //取消正在连接的蓝牙
    [self cancelConnecting];
    //断开已连接的蓝牙
    [self disConnected];
    
}

/**
 取消正在连接的蓝牙
 */
- (void)cancelConnecting {
    
    if (self.currentPeripheral.connectState == XTMF1CBPeripheralNotConnected ||
        self.currentPeripheral.connectState == XTMF1CBPeripheralConnectFailed ||
        self.currentPeripheral.connectState == XTMF1CBPeripheralConnectTimeOut ||
        self.currentPeripheral.connectState == XTMF1CBPeripheralConnectingCanceled ||
        self.currentPeripheral.connectState == XTMF1CBPeripheralConnectSuccess ||
        self.currentPeripheral.connectState == XTMF1CBPeripheralDidDisconnect) {
        //【未连接、连接失败、连接超时、连接中已被取消、连接成功、连接成功后断开连接】不做处理
        return;
    }
    if (self.currentPeripheral.connectState == XTMF1CBPeripheralConnecting) {
        //连接中
        self.currentPeripheral.connectState = XTMF1CBPeripheralConnectingCanceled;
        [self cancelTimerWithIdentity:TIMER_CONNECT error:[NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectCanceled userInfo:@{NSLocalizedDescriptionKey: @"连接被取消"}]];
    }
}

/**
 断开已连接的蓝牙
 */
- (void)disConnected {
    if (self.currentPeripheral.connectState == XTMF1CBPeripheralConnectSuccess) {
        //连接成功
        if (self.isBLEEnable) {
           // [self.bleLib mPayBle_DisconnectDevice];
            
            [self.centralManager cancelPeripheralConnection:self.currentPeripheral.peripheral];
        } else {
            self.currentPeripheral.connectState = XTMF1CBPeripheralNotConnected;
        }
    }
}

/**
 取消接收数据
 */
- (void)cancelReceiveData {
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:[NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveCanceled userInfo:@{NSLocalizedDescriptionKey: @"请求被取消"}]];
}

/**
 取消接收数据
 
 @param error 错误
 */
- (void)cancelReceiveData:(NSError *)error {
    if (!error) {
        [self cancelReceiveData];
    } else {
        [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:error];
    }
}

/**
 关闭Manager
 */
- (void)doClose {
    [self cancelScan];
    [self cancelConnect];
    [self cancelReceiveData];
}

/**
 蓝牙连接状态变化(连接/断开)监听
 
 @param MF1ConnectStateDidChangeBlock 回调
 */
- (void)setBlockOnConnectStateDidChange:(MF1ConnectStateDidChangeBlock)MF1ConnectStateDidChangeBlock {
    [self.blockDictionary setObject:MF1ConnectStateDidChangeBlock forKey:CONNECTSTATE_DIDCHANGE_BLOCK];
}

- (void)XTMF1CBPeripheralConnectStateChange:(NSNotification *)noti {
    
    XTMF1CBPeripheral *peripheral = noti.object;
    
    if (self.currentPeripheral && self.currentPeripheral == peripheral) {
        
        XTMF1CBPeripheralConnectState connectState = peripheral.connectState;
        
        MF1ConnectStateDidChangeBlock chacheStateDidChangeBlock = [self.blockDictionary objectForKey:CONNECTSTATE_DIDCHANGE_BLOCK];
        
        if (chacheStateDidChangeBlock) {
            chacheStateDidChangeBlock(connectState);
        }
    }
}

- (void)XTCentralManagerInit:(NSNotification *)noti {
    NSDictionary *objectDic = noti.object;
    NSString *ClassStr = [objectDic objectForKey:@"Class"];
    if ([ClassStr isEqualToString:NSStringFromClass([BleComm class])]) {
        self.centralManager = [objectDic objectForKey:@"Object"];
    }
}

/**
 设备状态改变的委托
 
 @param block 状态改变 回调
 */
- (void)setBlockOnMF1CentralManagerDidUpdateState:(MF1CentralManagerDidUpdateState)block {
    [self.blockDictionary setObject:block forKey:CENTRALMANAGER_DIDUPDATESTATE_BLOCK];
}

//插入dataList
-(void)insertList:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (self.BLEDevices.count == 0) {
        XTMF1CBPeripheral *model = [[XTMF1CBPeripheral alloc] init];
        model.peripheral = peripheral;
        model.advertisementData = advertisementData;
        model.RSSI = RSSI;
        [self.BLEDevices addObject:model];
    } else {
        BOOL isExist = NO;
        for (int i = 0; i < self.BLEDevices.count; i++) {
            XTMF1CBPeripheral *oldModel = [self.BLEDevices objectAtIndex:i];
            if ([oldModel.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                XTMF1CBPeripheral *model = [[XTMF1CBPeripheral alloc] init];
                model.peripheral = peripheral;
                model.advertisementData = advertisementData;
                model.RSSI = RSSI;
                [self.BLEDevices replaceObjectAtIndex:i withObject:model];
            }
        }
        
        if (!isExist) {
            XTMF1CBPeripheral *model = [[XTMF1CBPeripheral alloc] init];
            model.peripheral = peripheral;
            model.advertisementData = advertisementData;
            model.RSSI = RSSI;
            [self.BLEDevices addObject:model];
        }
    }
    
    for (int i = 0; i < self.BLEDevices.count; i ++) {
        XTMF1CBPeripheral *model = self.BLEDevices[i];
        if ([model.peripheral.identifier.UUIDString isEqualToString:self.currentPeripheral.peripheral.identifier.UUIDString]) {
            model.connectState = self.currentPeripheral.connectState;
        } else {
            model.connectState = XTMF1CBPeripheralNotConnected;
        }
    }
    
    MF1ScanBlock cacheScanBlcok = [self.blockDictionary objectForKey:SCAN_BLOCK];
    if (cacheScanBlcok) {
        cacheScanBlcok(self.BLEDevices);
    }
}

#pragma -mark MPayBleLibDelegate
- (void)onMPayBleResponse_Error:(int)iErrorCode Message:(NSString*)sMessage
{
    if (iErrorCode == -127) {
        //断开连接回调
        if (self.currentPeripheral.connectState == XTMF1CBPeripheralConnectTimeOut ||
            self.currentPeripheral.connectState == XTMF1CBPeripheralConnectFailed ||
            self.currentPeripheral.connectState == XTMF1CBPeripheralNotConnected ||
            self.currentPeripheral.connectState == XTMF1CBPeripheralConnecting ||
            self.currentPeripheral.connectState == XTMF1CBPeripheralConnectingCanceled ||
            self.currentPeripheral.connectState == XTMF1CBPeripheralDidDisconnect) {
            //【连接超时、连接失败、未连接、连接中、连接中已被取消、连接成功后已断开连接】都不需要处理
            return;
        }
        
        //处于连接成功状态的，才进行断开处理
        self.currentPeripheral.connectState = XTMF1CBPeripheralDidDisconnect;
        NSError *blockError = [NSError errorWithDomain:@"错误" code:110 userInfo:@{NSLocalizedDescriptionKey: @"断开连接"}];
        
        //取消数据请求
        if (self.isRequesting) {
            [self cancelReceiveData:blockError];
        }
    } else {
        if (self.isRequesting) {
            NSError *blockError = [NSError errorWithDomain:@"错误" code:iErrorCode userInfo:@{NSLocalizedDescriptionKey: sMessage}];
            [self cancelReceiveData:blockError];
        }
    }

}

- (void)onMPayBleResponse_UpdateState:(int)iStateCode Message:(NSString*)sMessage
{
    if (iStateCode == -6) {
        //设备打开成功
        self.isBLEEnable = YES;
    } else {
        self.isBLEEnable = NO;
        [self doClose];
    }

    MF1CentralManagerDidUpdateState cacheBlock = [self.blockDictionary objectForKey:CENTRALMANAGER_DIDUPDATESTATE_BLOCK];
    if (cacheBlock) {
        cacheBlock(iStateCode);
    }
}

- (void)onMPayBleResponse_GetDevice:(BOOL)bSucceed peripheral:(CBPeripheral *)peripheral;
{
    if (bSucceed) {
        [self insertList:peripheral advertisementData:nil RSSI:@(0)];
    }
}

- (void)onMPayBleResponse_IsConnected:(BOOL)bSucceed {
    
    if (bSucceed) {
        //连接成功
        self.currentPeripheral.connectState = XTMF1CBPeripheralConnectSuccess;
        [self cancelTimerWithIdentity:TIMER_CONNECT error:nil];
        
    } else {
        //连接失败
        self.currentPeripheral.connectState = XTMF1CBPeripheralConnectFailed;
        [self cancelTimerWithIdentity:TIMER_CONNECT error:[NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeConnectFailed userInfo:@{NSLocalizedDescriptionKey:@"连接失败"}]];
        
    }
    
}

- (void)onMPayBleResponse_GetBattery:(BOOL)bSucceed battery:(NSString*)sBattery {
    self.responseItem = sBattery;
    //数据接收完毕
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:bSucceed ? nil : [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey: @"读取电池电压失败"}]];
}

- (void)onMPayBleResponse_PiccActivation:(BOOL)bSucceed SerialNumber:(NSString*)sSerialNumber {
   
    self.responseItem = sSerialNumber;
    //数据接收完毕
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:bSucceed ? nil : [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey: @"上电失败"}]];
    
}

- (void)onMPayBleResponse_PiccDeactivation:(BOOL)bSucceed {
    self.responseItem = nil;
    //数据接收完毕
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:bSucceed ? nil : [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey: @"下电失败"}]];
}

- (void)onMPayBleResponse_MifareAuth:(BOOL)bSucceed
{
    self.responseItem = nil;
    //数据接收完毕
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:bSucceed ? nil : [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey: @"认证失败"}]];
}

- (void)onMPayBleResponse_MifareReadBlock:(BOOL)bSucceed sData:(NSString*)sData
{
    self.responseItem = sData;
    //数据接收完毕
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:bSucceed ? nil : [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey: @"读卡失败"}]];
}

- (void)onMPayBleResponse_MifareWriteBlock:(BOOL)bSucceed {
    self.responseItem = nil;
    //数据接收完毕
    [self cancelTimerWithIdentity:TIMER_RECEIVE_DATA error:bSucceed ? nil : [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeReceiveFailed userInfo:@{NSLocalizedDescriptionKey: @"写卡异常"}]];
}

#pragma -mark 倒计时

/**
 开启定时器
 
 @param identity 标识
 @param duration 定时时长
 @param block 回调
 */
- (void)openTimerWithIdentity:(NSString *)identity timeDuration:(float)duration block:(TimerBlock)block {
    
    if (identity.length == 0) {
        return;
    }
    
    //创建线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //移除上次任务
    dispatch_source_t timer = [self.timerDictionary objectForKey:identity];
    if (timer) {
        NSError *error = [NSError errorWithDomain:@"错误" code:XTBLEMF1NSErrorCodeAutoCancelLastTimerTask userInfo:@{@"NSLocalizedDescription": @"移除上次任务"}];
        [self cancelTimerWithIdentity:identity error:error];
    }
    
    //创建dispatch_source_t的timer
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_resume(timer);
    
    //缓存timer & block
    [self.timerDictionary setObject:timer forKey:identity];
    [self.blockDictionary setObject:block forKey:identity];
    
    //设置首次执行事件、执行间隔和精确度(默认为0.1s)
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), duration * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    
    __weak typeof(self) weakSelf = self;
    //时间间隔到点时执行block
    dispatch_source_set_event_handler(timer, ^{
        
        //取消timer
        [weakSelf.timerDictionary removeObjectForKey:identity];
        dispatch_source_cancel(timer);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            TimerBlock cacheBlock = [self.blockDictionary objectForKey:identity];
            if (cacheBlock) {
                [weakSelf.blockDictionary removeObjectForKey:identity];
                cacheBlock(TimerStateFinish, nil);
            }
        });
        
    });
    
}

/**
 取消timer
 */
- (void)cancelTimerWithIdentity:(NSString *)identity error:(NSError *)error {
    
    dispatch_source_t timer = [self.timerDictionary objectForKey:identity];
    if (timer) {
        dispatch_source_cancel(timer);
        [self.timerDictionary removeObjectForKey:identity];
        
        TimerBlock cacheBlock = [self.blockDictionary objectForKey:identity];
        if (cacheBlock) {
            [self.blockDictionary removeObjectForKey:identity];
            cacheBlock(TimerStateCancel, error);
        }
        
    }
    
}

/**
 获取timer
 */
- (dispatch_source_t)getTimerWithIdentity:(NSString *)identity {
    dispatch_source_t timer = [self.timerDictionary objectForKey:identity];
    return timer;
}

#pragma -mark lazy loading
/**
 创建Block字典
 
 @return NSMutableDictionary
 */
- (NSMutableDictionary *)blockDictionary {
    if (!_blockDictionary) {
        _blockDictionary = [[NSMutableDictionary alloc] init];
    }
    return _blockDictionary;
}

/**
 创建timer字典
 
 @return NSMutableDictionary
 */
- (NSMutableDictionary *)timerDictionary {
    if (!_timerDictionary) {
        _timerDictionary = [[NSMutableDictionary alloc] init];
    }
    return _timerDictionary;
}

/**
 创建蓝牙设备列表
 
 @return NSMutableArray
 */
- (NSMutableArray *)BLEDevices {
    if (!_BLEDevices) {
        _BLEDevices = [[NSMutableArray alloc] init];
    }
    return _BLEDevices;
}

/**
 保存蓝牙设备
 
 @param xtPeripheral 蓝牙设备
 */
- (void)saveXTPeripheral:(XTMF1CBPeripheral *)xtPeripheral {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *array = [def objectForKey:@"XTCBPeripheral.peripheral.save.key"];
    if (array.count > 0) {
        for (int i = 0; i < array.count; i ++) {
            NSString *identify = array[i];
            if ([identify isEqualToString:xtPeripheral.peripheral.identifier.UUIDString]) {
                return;
            }
        }
    }
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:array];
    [tempArray addObject:xtPeripheral.peripheral.identifier.UUIDString];
    [def setObject:tempArray forKey:@"XTCBPeripheral.peripheral.save.key"];
    [def synchronize];
}


/**
 移除已保存的蓝牙设备
 
 @param xtPeripheral 蓝牙设备
 */
- (void)removeSavedXTPeripheral:(XTMF1CBPeripheral *)xtPeripheral {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *array = [def objectForKey:@"XTCBPeripheral.peripheral.save.key"];
    
    if (array.count > 0) {
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:array];
        
        for (int i = 0; i < tempArray.count; i ++) {
            NSString *identify = tempArray[i];
            if ([identify isEqualToString:xtPeripheral.peripheral.identifier.UUIDString]) {
                [tempArray removeObject:identify];
            }
        }
        
        [def setObject:tempArray forKey:@"XTCBPeripheral.peripheral.save.key"];
        [def synchronize];
        
    }
    
}


/**
 获取已保存的蓝牙设备
 
 @return 蓝牙设备列表
 */
- (NSArray *)getSavedXTPeripherals {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *array = [def objectForKey:@"XTCBPeripheral.peripheral.save.key"];
    if (array.count > 0) {
        NSMutableArray *uuidArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < array.count; i ++) {
            NSString *identify = array[i];
            [uuidArray addObject:[[NSUUID alloc] initWithUUIDString:identify]];
        }
        
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        NSArray *periArr = [self.centralManager retrievePeripheralsWithIdentifiers:uuidArray];
        for (int i = 0; i < periArr.count; i ++) {
            XTMF1CBPeripheral *deviceModel = [[XTMF1CBPeripheral alloc] init];
            if ([deviceModel.peripheral.identifier.UUIDString isEqualToString:self.currentPeripheral.peripheral.identifier.UUIDString]) {
                deviceModel.connectState = self.currentPeripheral.connectState;
            } else {
                deviceModel.connectState = XTMF1CBPeripheralNotConnected;
            }
            deviceModel.peripheral = periArr[i];
            [resultArray addObject:deviceModel];
        }
        return resultArray;
    }
    return nil;
}

@end
